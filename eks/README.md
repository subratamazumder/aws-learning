# Setting Up EKS Cluster
## Install CLI(s)
### kubectl
```
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/darwin/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin\necho 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
kubectl version --short --client
```
### eksctl

```
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
eksctl version

```
## Cluster Pre Requisite
### CLIs Defaults

```
export AWS_DEFAULT_PROFILE=devtest
export AWS_DEFAULT_REGION=eu-west-2
export MY_EKS_CLUSTER=eks-eprescription-poc
export MY_EKS_KEYPAIR=eks-poc-keypair
export MY_EKS_PUB_NODE_GROUP1=eks-eprescription-poc-ng-pub1
export MY_IP=`curl -s http://whatismyip.akamai.com/`

```
### KeyPair
```
aws ec2 create-key-pair --key-name $MY_EKS_KEYPAIR --query 'KeyMaterial' --output text > $MY_EKS_KEYPAIR.pem
openssl rsa -in $MY_EKS_KEYPAIR.pem -check
chmod 400 $MY_EKS_KEYPAIR.pem

```
### Create Cluster
```
eksctl create cluster --name=$MY_EKS_CLUSTER --without-nodegroup
eksctl get cluster

 192  ~/workspace/aws-eks  eksctl get cluster
2021-10-02 17:31:16 [ℹ]  eksctl version 0.68.0
2021-10-02 17:31:16 [ℹ]  using region eu-west-2
NAME			REGION		EKSCTL CREATED
eks-eprescription-poc	eu-west-2	True
 192  ~/workspace/aws-eks 
```
### IAM Roles
To use IAM roles for service accounts, an IAM OIDC provider must exist for your cluster.
```
eksctl utils associate-iam-oidc-provider --cluster $MY_EKS_CLUSTER --approve
```
#### Verify IAM OIDC Provider
```
 ~/workspace/aws-eks  aws eks describe-cluster --name $MY_EKS_CLUSTER --query "cluster.identity.oidc.issuer" --output text
https://oidc.eks.eu-west-2.amazonaws.com/id/FCXXXXXXXXXXXXXXX64F

aws iam list-open-id-connect-providers | grep FCXXXXXXXXXXXXXXX64F

"Arn": "arn:aws:iam::XXXXXXXXXXXX:oidc-provider/oidc.eks.eu-west-2.amazonaws.com/id/FCXXXXXXXXXXXXXXX64F"
```

### Create Node Group
```
eksctl create nodegroup --cluster=$MY_EKS_CLUSTER \
                       --name=$MY_EKS_PUB_NODE_GROUP1 \
                       --managed \
                       --node-type=t3.medium \
                       --node-ami-family=AmazonLinux2 \
                       --nodes=2 \
                       --nodes-min=2 \
                       --nodes-max=3 \
                       --node-volume-size=25 \
                       --instance-prefix=eprescription-poc \
                       --ssh-access \
                       --ssh-public-key=$MY_EKS_KEYPAIR \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --alb-ingress-access
eksctl create nodegroup --help [for more information]

aws eks update-kubeconfig --name $MY_EKS_CLUSTER --region $AWS_DEFAULT_REGION
### Get External IP for Testing
kubectl get nodes -o wide
export MY_EKS_NODE1_EXTERNAL_IP=xxx.xxx.xxx.xxx
### Build a docker image
https://github.com/subratamazumder/go-docker

```

### Create a POD
```
kubectl run eprescription-reg-pod --image dockersubrata/eprescription-reg-service-image:1.0
kubectl get pods
kubectl describe pods eprescription-reg-pod
```

### Create a Service
```
kubectl expose pod eprescription-reg-pod  --type=NodePort --port=8081 --target-port=8081 --name=eprescription-reg-svc
[default protocol is TCP]
```
### Get NodePort for Testing
```
kubectl get service -o wide
```
# Authorize ingress rule of worker node for a specific node-port
aws ec2 authorize-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 31719 --cidr $MY_IP/32 --output text

### Testing
#### Run Test
```
 ~/workspace/aws-eks  curl -is http://$MY_EKS_NODE1_EXTERNAL_IP:31719/health
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 01:54:02 GMT
Content-Length: 15
{"status":"OK"}

 ~/workspace/aws-eks  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:31719/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 01:54:33 GMT
Content-Length: 57
{"registrationId":"dea7d54b-bdb7-4f12-a704-e4165eafc7d4"}
```
#### Verify logs
```
kubectl logs -f eprescription-reg-pod

```
## Clean Up
### Undo temp SG changes 
```
aws ec2 revoke-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 31719 --cidr $MY_IP/32 --output text
```
### Delete EKS Objects
```
kubectl delete svc eprescription-reg-svc
kubectl delete pod eprescription-reg-pod
eksctl delete nodegroup --cluster=$MY_EKS_CLUSTER --name=$MY_EKS_PUB_NODE_GROUP1
eksctl delete cluster $MY_EKS_CLUSTER
```
### Delete Other Resources
```
aws ec2 delete-key-pair --key-name $MY_EKS_KEYPAIR
```
## Reference
https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html
https://www.sslshopper.com/article-most-common-openssl-commands.html

## Issues Faced
- While `ceating node group` got error as "Not authorized to perform: iam:CreateRole"
Fix -
```
eksctl delete nodegroup --region=eu-west-2 --cluster=eks-eprescription-poc --name=$MY_EKS_PUB_NODE_GROUP1
```

Delete `AWSCompromisedKeyQuarantineV2` managed policy from the IAM user which is executing eksctl CLIs

- While running `kubclt get node` got below error

```~/workspace/aws-eks  kubectl get nodes
Error from server (InternalError): an error on the server ("<!DOCTYPE html>\n<html>\n<head>\n<title>Error</title>\n<style>\n    body {\n        width: 35em;\n        margin: 0 auto;\n        font-family: Tahoma, Verdana, Arial, sans-serif;\n    }\n</style>\n</head>\n<body>\n<h1>An error occurred.</h1>\n<p>Sorry, the page you are looking for is currently unavailable.<br/>\nPlease try again later.</p>\n<p>If you are the system administrator of this resource then you should check\nthe error log for details.</p>\n<p><em>Faithfully yours, nginx.</em></p>\n</body>\n</html>") has prevented the request from succeeding
```

Fix - 
Remove existing `~.kube/config` & then run 
```aws eks update-kubeconfig --name $MY_EKS_CLUSTER --region $AWS_DEFAULT_REGION
```