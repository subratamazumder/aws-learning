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

 ~/workspace/aws-eks  aws eks describe-cluster --name $MY_EKS_CLUSTER --query "cluster.identity.oidc.issuer" --output text
aws iam list-open-id-connect-providers | grep FC516FA5668564DCACE63388A48F564F
DELETE ME - https://oidc.eks.eu-west-2.amazonaws.com/id/FC516FA5668564DCACE63388A48F564F
```

### Create Node Group
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
### Build a docker image

docker tag <existing-image> <hub-user>/<repo-name>[:<tag>]

### Create a POD
kubectl run nginx-pod --image stacksimplify/kubenginx:1.0.0
kubectl get pods
kubectl describe pods nginx-pod

### Create a Service
kubectl expose pod nginx-pod  --type=NodePort --port=80 --target-port=80 --name=nginx [default protocol is TCP]

# Retrieve current IP address
export MY_IP=`curl -s http://whatismyip.akamai.com/`

# Authorize access on ports 22 and 3389
aws ec2 authorize-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 31351 --cidr $MY_IP/32 --output text

## Clean Up
undo >> SG changes aws ec2 revoke-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 31351 --cidr $MY_IP/32 --output text

eksctl delete nodegroup --cluster=$MY_EKS_CLUSTER --name=$MY_EKS_PUB_NODE_GROUP1
eksctl delete cluster $MY_EKS_CLUSTER
aws ec2 delete-key-pair --key-name $MY_EKS_KEYPAIR

## Reference
https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html
https://www.sslshopper.com/article-most-common-openssl-commands.html

## Issues Faced
1. While ceating node group "Not authorized to perform: iam:CreateRole"
Fix - eksctl delete nodegroup --region=eu-west-2 --cluster=eks-eprescription-poc --name=$MY_EKS_PUB_NODE_GROUP1
Delete AWSCompromisedKeyQuarantineV2 managed policy from the IAM user which is executing eksctl CLIs 
2. While running kubclt commands to get node details
192  ~/workspace/aws-eks  kubectl get nodes
Error from server (InternalError): an error on the server ("<!DOCTYPE html>\n<html>\n<head>\n<title>Error</title>\n<style>\n    body {\n        width: 35em;\n        margin: 0 auto;\n        font-family: Tahoma, Verdana, Arial, sans-serif;\n    }\n</style>\n</head>\n<body>\n<h1>An error occurred.</h1>\n<p>Sorry, the page you are looking for is currently unavailable.<br/>\nPlease try again later.</p>\n<p>If you are the system administrator of this resource then you should check\nthe error log for details.</p>\n<p><em>Faithfully yours, nginx.</em></p>\n</body>\n</html>") has prevented the request from succeeding

Fix - remove existing ~.kube/config & then run 
aws eks update-kubeconfig --name $MY_EKS_CLUSTER --region $AWS_DEFAULT_REGION