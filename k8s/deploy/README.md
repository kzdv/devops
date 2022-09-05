# Cluster Deployment

This deploys Fleet and the Application YAML to the current kubectl context for the KZDV web applications.

## Pre-requisites

This assumes that the cluster has already had Sealed Secrets, MySQL, RabbitMQ, cert-manager, and ingress-nginx deployed. Most of these
 are not handled because of dependencies or the use of passwords. Sealed Secrets are per-cluster sealed so we cannot rely on them to be
 shareable via the Git repository. This is solveable if we use something like GCP's Secret Manager, but at the moment we are not.

### Sealed Secret Deployment

To deploy with expected settings:

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
kubectl rollout status -n kube-system deployment/sealed-secrets-controller
```

*NOTE:* If the certificate does not match the ones used to seal these secrets, they will need to be regenerated. The public key used to seal the secrets will not be valid as a new certificate is generated on installation.

### MySQL Deployment

To deploy with expected settings:

```bash
kubectl create namespace mysql
kubectl create secret generic passwords -n mysql --from-literal=mysql-root-password=root --from-literal=mysql-password=password

cat <<EOF >/tmp/mysql.values.yaml
auth:
  username: zdv
  database: zdv
  existingSecret: passwords
primary:
  resources:
    limits:
      cpu: 250m
      memory: 1024Mi
EOF

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mysql bitnami/mysql -n mysql -f /tmp/mysql.values.yaml
rm /tmp/mysql.values.yaml
```

**NOTE**: The credentials used by the applications are sealed in secrets. If you are not going to use those passwords, please regenerate the sealed secrets in this repo.

### RabbitMQ Deployment

To deploy with expected settings:

Create a secret, set these values.

**NOTE**: The credentials used by the applications are sealed in secrets. If you are not going to use those passwords, please regenerate the sealed secrets in this repo.

```bash
cat <<EOF >/tmp/rabbitmq.secret.yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: rabbit-secret
  namespace: rabbitmq
stringData:
  RABBITMQ_ERLANG_COOKIE: ""
  RABBITMQ_PASS: ""
  RABBITMQ_USER: ""
EOF
```

Now install:

```bash
kubectl create namespace rabbitmq
kubectl apply -n rabbitmq -f /tmp/rabbitmq.secret.yaml
kubectl apply -n rabbitmq -f yaml/rabbitmq/
```

### Redis deployment

Install via:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install redis bitnami/redis -n redis --create-namespace --set sentinel.enabled=true --set sentinel.masterSet=master --set auth.sentinel=false
```

### Ingress-nginx Deployment

Install via:

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

### Cert-manager Deployment

Install via:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.9.1 \
  --set installCRDs=true
```

## Deploy Fleet

Deploy Fleet to the current kubectl context. We use fleet as a single-cluster GitOps tool to manage application deployments for the local cluster.

```bash
helm -n cattle-fleet-system install --create-namespace --wait fleet-crd https://github.com/rancher/fleet/releases/download/v0.3.10/fleet-crd-0.3.10.tgz
helm -n cattle-fleet-system install --create-namespace --wait fleet https://github.com/rancher/fleet/releases/download/v0.3.10/fleet-0.3.10.tgz
```

Once fleet has been installed, label your current cluster:

```bash
kubectl label clusters.fleet.cattle.io -n fleet-local local env=local
```

Replace local in the above with the appropriate environment: prod, dev, local. This label instructs Fleet which Kustomize overlay to use.

## Define GitRepo

Deploy the GitRepo for your environment.

```bash
kubectl apply -f yaml/fleet-gitrepo.yaml
```

Note: On initial rollout, deployments may initially fail to start. This is due to them being created before the secrets have been unsealed and applied to the namespace. This can be
ignored unless it persists.
