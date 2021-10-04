### Create Public Node Group
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
kubectl run eprescription-reg-pod --image dockersubrata/eprescription-reg-service-image:2.0
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
# Authorize (remote-access) ingress rule of worker node for a specific node-port
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
- While running `kubclt get node` got below error

```~/workspace/aws-eks  kubectl get nodes
Error from server (InternalError): an error on the server ("<!DOCTYPE html>\n<html>\n<head>\n<title>Error</title>\n<style>\n    body {\n        width: 35em;\n        margin: 0 auto;\n        font-family: Tahoma, Verdana, Arial, sans-serif;\n    }\n</style>\n</head>\n<body>\n<h1>An error occurred.</h1>\n<p>Sorry, the page you are looking for is currently unavailable.<br/>\nPlease try again later.</p>\n<p>If you are the system administrator of this resource then you should check\nthe error log for details.</p>\n<p><em>Faithfully yours, nginx.</em></p>\n</body>\n</html>") has prevented the request from succeeding
```

Fix - 

Remove existing `~.kube/config` & then update kubectl cli config 
```
aws eks update-kubeconfig --name $MY_EKS_CLUSTER --region $AWS_DEFAULT_REGION
```