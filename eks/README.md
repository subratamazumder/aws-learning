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

```
### KeyPair
```
aws ec2 create-key-pair --key-name eks-poc-keypair --query 'KeyMaterial' --output text > eks-poc-keypair.pem
openssl rsa -in eks-poc-keypair.pem -check
chmod 400 eks-poc-keypair.pem

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

eksctl utils associate-iam-oidc-provider \
    --cluster $MY_EKS_CLUSTER \
    --approve

 ~/workspace/aws-eks  aws eks describe-cluster --name $MY_EKS_CLUSTER --query "cluster.identity.oidc.issuer" --output text
aws iam list-open-id-connect-providers | grep FC516FA5668564DCACE63388A48F564F
DELETE ME - https://oidc.eks.eu-west-2.amazonaws.com/id/FC516FA5668564DCACE63388A48F564F
### Create Node Group
## Clean Up
aws ec2 delete-key-pair --key-name eks-poc-keypair

## Reference
https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html
https://www.sslshopper.com/article-most-common-openssl-commands.html


