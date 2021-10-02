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

```
### KeyPair
```
aws ec2 create-key-pair --key-name eks-poc-keypair
save key in to a file say eks-poc-keypair.pem
chmod 700 eks-poc-keypair.pem
```
### IAM Roles
### Create Cluster
### Create Node Group

