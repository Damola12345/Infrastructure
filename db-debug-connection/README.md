# Redis, mysql , sql server command 

- The command creates a temporary Kubernetes pod running the MySQL 8.0 image and opens an interactive Bash shell inside it. This allows you to run commands and interact with the pod's environment. Once you exit the shell, the pod is automatically deleted.
    - `kubectl run mysql-client --image=mysql:8.0 -it --rm --restart=Never -- /bin/bash`

- Once inside the pod, you should be able to run the `msql` command to connect to your msql
    - `mysql -h dev.xxxxx.us-east-1.rds.amazonaws.com -u damola -P 3306  -p `

- The command creates a temporary interactive pod running a Bash shell using the latest Redis Docker image. 
    - `kubectl run redis-client --image=redis:latest -it --rm --restart=Never -- /bin/bash` 

- Once inside the pod, you should be able to run the `redis-cli` command to connect to your redis
    - `redis-cli -h damola-redis-cluster.xxxx.0009.euw1.cache.amazonaws.com -p 6379` 

- Once inside the pod, you should be able to run the `sqlcmd` command to connect to your SQL Server instance
    - `sqlcmd -S xxxx-dev.xxxxxx.eu-west-1.rds.amazonaws.com -U damola -P xxxxxxxxx -Q "SELECT @@VERSION"` 