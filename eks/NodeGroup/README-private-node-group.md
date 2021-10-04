### Create Node Group
```
eksctl create nodegroup --cluster=$MY_EKS_CLUSTER \
                       --name=$MY_EKS_PRV_NODE_GROUP1 \
                       --managed \
                       --node-type=t3.medium \
                       --node-ami-family=AmazonLinux2 \
                       --nodes=2 \
                       --nodes-min=2 \
                       --nodes-max=3 \
                       --node-volume-size=25 \
                       --ssh-access \
                       --ssh-public-key=$MY_EKS_KEYPAIR \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --alb-ingress-access \
                       --node-private-networking
eksctl create nodegroup --help [for more information]
```
## Create Deployments
```
 192  ~/workspace/aws-learning/clean-up   master ●  kubectl create deployment reg-service-deployment --image=dockersubrata/eprescription-reg-service-image:6.0
deployment.apps/reg-service-deployment created
 192  ~/workspace/aws-learning/clean-up   master ●  kubectl get deploy
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
reg-service-deployment   1/1     1            1           10s
 192  ~/workspace/aws-learning/clean-up   master ●  kubectl get po
NAME                                      READY   STATUS    RESTARTS   AGE
reg-service-deployment-568f847c47-bjp2q   1/1     Running   0          22s
 192  ~/workspace/aws-learning/clean-up   master ●  kubectl get rs
NAME                                DESIRED   CURRENT   READY   AGE
reg-service-deployment-568f847c47   1         1         1       26s
 192  ~/workspace/aws-learning/clean-up   master ● 
```
## Expose Service over ELB port 80
```

kubectl expose deployment reg-service-deployment --type=LoadBalancer --port=80 --target-port=8081 --name=reg-service-deployment-lb-svc

```
### Get Endpoint for Testing
```
192  ~/workspace/aws-learning/clean-up   master ●  kubectl get svc
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
kubernetes                      ClusterIP      10.100.0.1      <none>                                                                    443/TCP        153m
reg-service-deployment-lb-svc   LoadBalancer   10.100.141.72   a28139536c4364e9fa7a9007c68acc22-2139149315.eu-west-2.elb.amazonaws.com   80:32767/TCP   7m7s
 192  ~/workspace/aws-learning/clean-up   master ● 

 export  MY_EKS_PRV_NODE1_EXTERNAL_DNS=a28139536c4364e9fa7a9007c68acc22-2139149315.eu-west-2.elb.amazonaws.com
```
# Authorize ingress rule of worker node for a specific node-port
aws ec2 authorize-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 31719 --cidr $MY_IP/32 --output text

### Testing
#### Run Test

```
 192  ~/workspace/aws-learning/clean-up   master ●  curl -X POST -is http://$MY_EKS_PRV_NODE1_EXTERNAL_DNS/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Mon, 04 Oct 2021 16:06:53 GMT
Content-Length: 139

{"processingNode":"reg-service-deployment-568f847c47-bjp2q","registrationId":"3644d581-a8f2-49bb-a36a-39be2d14c67b","serviceVersion":"6.0"}%
 192  ~/workspace/aws-learning/clean-up   master ● 
```
#### Verify logs
```
 192  ~/workspace/aws-learning/clean-up   master ●  kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
reg-service-deployment-568f847c47-bjp2q   1/1     Running   0          22m
 192  ~/workspace/aws-learning/clean-up   master ●  kubectl logs -f reg-service-deployment-568f847c47-bjp2q
2021/10/04 15:45:25 HTTP Go Server is Listening on  reg-service-deployment-568f847c47-bjp2q : 8081
2021/10/04 16:06:53 Request received from 192.168.168.228:12977
2021/10/04 16:06:53 Returning 201 from node reg-service-deployment-568f847c47-bjp2q


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
eksctl delete nodegroup --cluster=$MY_EKS_CLUSTER --name=$MY_EKS_PRV_NODE_GROUP1
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

Remove existing `~.kube/config` & then update kubectl cli config 
```
aws eks update-kubeconfig --name $MY_EKS_CLUSTER --region $AWS_DEFAULT_REGION
```