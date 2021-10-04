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
eksctl create cluster --name=$MY_EKS_CLUSTER --without-nodegroup --tag="name:poc"
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
- (Working With Public Node Group)[README-public-node-group.md]
- (Working With Replica Set)[README-private-node-group.md]
- (Working With Deployments)[README-private-node-group.md]
- (Working With Horizonal Auto Scaler)[#]
- (Working With Private Node Group with LB)[#]
- (Working With DATABASE)[#]
- (Working With Logging & Monitoring)[#]
