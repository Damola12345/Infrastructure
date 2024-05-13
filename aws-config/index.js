const https = require('https');
const aws = require('aws-sdk');
const ec2 = new aws.EC2();

const config = new aws.ConfigService();


// make http reques
async function apiRequest(data = {}) {
	const params = {
		host: 'hooks.slack.com',
		path: '/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
		port: 443,
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
		}
	};
	return new Promise((resolve, reject) => {
		const req = https.request(params, (res) => {
			const chunks = [];
			res.on('error', (error) => {
				reject(error);	
			});
			res.on('data', (chunk) => {
				chunks.push(chunk);	
			});
			res.on('end', () => {
				const rawData = Buffer.concat(chunks).toString()	
				let parsedData = rawData;
				try {
					parsedData = JSON.parse(rawData)	
				} catch {}

				resolve(parsedData);	
			});
		});	

		req.write(JSON.stringify(data))
		req.end();
	});
};

// Helper function used to validate input
function checkDefined(reference, referenceName) {
    if (!reference) {
        throw new Error(`Error: ${referenceName} is not defined`);
    }
    return reference;
}

// Check whether the message is OversizedConfigurationItemChangeNotification or not
function isOverSizedChangeNotification(messageType) {
    checkDefined(messageType, 'messageType');
    return messageType === 'OversizedConfigurationItemChangeNotification';
}

// Get configurationItem using getResourceConfigHistory API.
function getConfiguration(resourceType, resourceId, configurationCaptureTime, callback) {
    config.getResourceConfigHistory({ resourceType, resourceId, laterTime: new Date(configurationCaptureTime), limit: 1 }, (err, data) => {
        if (err) {
            callback(err, null);
        }
        const configurationItem = data.configurationItems[0];
        callback(null, configurationItem);
    });
}

// Convert from the API model to the original invocation model
/*eslint no-param-reassign: ["error", { "props": false }]*/
function convertApiConfiguration(apiConfiguration) {
    apiConfiguration.awsAccountId = apiConfiguration.accountId;
    apiConfiguration.ARN = apiConfiguration.arn;
    apiConfiguration.configurationStateMd5Hash = apiConfiguration.configurationItemMD5Hash;
    apiConfiguration.configurationItemVersion = apiConfiguration.version;
    apiConfiguration.configuration = JSON.parse(apiConfiguration.configuration);
    if ({}.hasOwnProperty.call(apiConfiguration, 'relationships')) {
        for (let i = 0; i < apiConfiguration.relationships.length; i++) {
            apiConfiguration.relationships[i].name = apiConfiguration.relationships[i].relationshipName;
        }
    }
    return apiConfiguration;
}

// Based on the type of message get the configuration item either from configurationItem in the invoking event or using the getResourceConfigHistiry API in getConfiguration function.
function getConfigurationItem(invokingEvent, callback) {
    checkDefined(invokingEvent, 'invokingEvent');
    if (isOverSizedChangeNotification(invokingEvent.messageType)) {
        const configurationItemSummary = checkDefined(invokingEvent.configurationItemSummary, 'configurationItemSummary');
        getConfiguration(configurationItemSummary.resourceType, configurationItemSummary.resourceId, configurationItemSummary.configurationItemCaptureTime, (err, apiConfigurationItem) => {
            if (err) {
                callback(err);
            }
            const configurationItem = convertApiConfiguration(apiConfigurationItem);
            callback(null, configurationItem);
        });
    } else {
        checkDefined(invokingEvent.configurationItem, 'configurationItem');
        callback(null, invokingEvent.configurationItem);
    }
}

// Check whether the resource has been deleted. If it has, then the evaluation is unnecessary.
function isApplicable(configurationItem, event) {
    checkDefined(configurationItem, 'configurationItem');
    checkDefined(event, 'event');
    const status = configurationItem.configurationItemStatus;
    const eventLeftScope = event.eventLeftScope;
    return (status === 'OK' || status === 'ResourceDiscovered') && eventLeftScope === false;
}

// This is where it's determined whether the resource is compliant or not.
// In this example, we simply decide that the resource is compliant if it is an instance and its type matches the type specified as the desired type.
// If the resource is not an instance, then we deem this resource to be not applicable. (If the scope of the rule is specified to include only
// instances, this rule would never have been invoked.)
async function terminateResource(resourceId = '') {
    if (!resourceId) return;    

    const params = {
        InstanceIds: [ resourceId ],   
    };
    try {
        await ec2.terminateInstances(params).promise();
    } catch (error) {
        console.log(error);

        try { // stop instance incase it doesn't terminate
           await ec2.stopInstances(params).promise();
           await ec2.terminateInstances(params).promise();
        } catch {}; 
    };
};

async function evaluateChangeNotificationCompliance(configurationItem, ruleParameters) {
    checkDefined(configurationItem, 'configurationItem');
    checkDefined(ruleParameters, 'ruleParameters');

    if (configurationItem.resourceType !== 'AWS::EC2::Instance') {
        return 'NOT_APPLICABLE';
    }

    const instanceTags = configurationItem.tags;
    if (!instanceTags || !Object.keys(instanceTags || {}).length) {
	try {
		await apiRequest({ text: `Instance: ${configurationItem.resourceId} NON_COMPLIANT and would be deleted` });
	} catch {};
        await terminateResource(configurationItem.resourceId);

        return 'NON_COMPLIANT';
    }

    return 'COMPLIANT';
}



// This is the handler that's invoked by Lambda
// Most of this code is boilerplate; use as is
exports.handler = (event, context, callback) => {
    checkDefined(event, 'event');
    const invokingEvent = JSON.parse(event.invokingEvent);
    const ruleParameters = JSON.parse(event.ruleParameters);
    getConfigurationItem(invokingEvent, async (err, configurationItem) => {
        if (err) {
            callback(err);
        }
        let compliance = 'NOT_APPLICABLE';
        const putEvaluationsRequest = {};
        if (isApplicable(configurationItem, event)) {
            // Invoke the compliance checking function.
            compliance = await evaluateChangeNotificationCompliance(configurationItem, ruleParameters);
        }
        // Put together the request that reports the evaluation status
        putEvaluationsRequest.Evaluations = [
            {
                ComplianceResourceType: configurationItem.resourceType,
                ComplianceResourceId: configurationItem.resourceId,
                ComplianceType: compliance,
                OrderingTimestamp: configurationItem.configurationItemCaptureTime,
            },
        ];
        putEvaluationsRequest.ResultToken = event.resultToken;

        // Invoke the Config API to report the result of the evaluation
        config.putEvaluations(putEvaluationsRequest, (error, data) => {
            if (error) {
                callback(error, null);
            } else if (data.FailedEvaluations.length > 0) {
                // Ends the function execution if any evaluation results are not successfully reported.
                callback(JSON.stringify(data), null);
            } else {
                callback(null, data);
            }
        });
    });
};