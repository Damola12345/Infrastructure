## Observability

-   This repository contains resources for setting up an observability stack using Prometheus, Grafana, Promtail, and Loki. These tools collectively provide a powerful solution for monitoring, visualization, and log aggregation.

## Basic Authentication
This example shows how to add authentication in a Ingress rule using a secret that contains a file generated with htpasswd. It's important the file generated is named auth (actually - that the secret has a key data.auth), otherwise the ingress-controller returns a 503.

## Create htpasswd file
```bash
$ htpasswd -c auth foo
New password: <bar>
New password:
Re-type new password:
Adding password for user foo
```

## Convert htpasswd into a secret
```bash
$ kubectl create secret generic basic-auth --from-file=auth
secret "basic-auth" created
```

Happy monitoring! 🚀