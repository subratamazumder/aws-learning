# Demo Service deployed on EKS accesing DynamoDB
## Enable IAM OIDC Provider
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  eksctl utils associate-iam-oidc-provider --cluster $MY_EKS_CLUSTER --approve
2021-10-05 00:46:57 [ℹ]  eksctl version 0.68.0
2021-10-05 00:46:57 [ℹ]  using region eu-west-2
2021-10-05 00:46:58 [ℹ]  will create IAM Open ID Connect provider for cluster "eks-eprescription-poc" in "eu-west-2"
2021-10-05 00:46:59 [✔]  created IAM Open ID Connect provider for cluster "eks-eprescription-poc" in "eu-west-2"
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master  aws eks describe-cluster --name $MY_EKS_CLUSTER --query "cluster.identity.oidc.issuer" --output text
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master  aws iam list-open-id-connect-providers | grep 5D890EF92D856F1EC37B855E1EADCF2F
            "Arn": "arn:aws:iam::567824033118:oidc-provider/oidc.eks.eu-west-2.amazonaws.com/id/5D890EF92D856F1EC37B855E1EADCF2F"
## Create Dynamo Table
./deploy-table.sh
## Create IAM Policy
aws iam create-policy --policy-name eprescrition-poc-dynamo-full-access-profile-table-policy --policy-document file://dynamo-full-access-policy.json

export MY_EKS_DYNAMO_POLICY_ARN=arn:aws:iam::567824033118:policy/eprescrition-poc-dynamo-full-access-profile-table-policy
## Create SA with K8s Cluster

192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  eksctl create iamserviceaccount \
              --name reg-service-dynamo-sa \
              --cluster $MY_EKS_CLUSTER \
              --attach-policy-arn $MY_EKS_DYNAMO_POLICY_ARN \
              --approve
 2021-10-05 01:49:31 [ℹ]  created serviceaccount "default/reg-service-dynamo-sa"
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●              

 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  kubectl get sa
NAME                    SECRETS   AGE
default                 1         11h
reg-service-dynamo-sa   1         4m29s
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ● 

## Deploy pods & expose service via LB
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  kubectl apply -f reg-service-deployment-dynamo.yaml -f reg-service-deployment-lb-svc-dynamo.yaml
deployment.apps/reg-service-deployment-dynamo created
service/reg-service-deployment-lb-svc-dynamo created

 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  kubectl get svc
NAME                                   TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
kubernetes                             ClusterIP      10.100.0.1       <none>                                                                    443/TCP        11h
reg-service-deployment-lb-svc-dynamo   LoadBalancer   10.100.52.61     a77b17abe03c84355922425d1c049700-1268584681.eu-west-2.elb.amazonaws.com   80:31795/TCP   11s
reg-service-deployment-lb-svc-yaml     LoadBalancer   10.100.251.235   a11bfe4666666439ab29563ad3d6a906-32361183.eu-west-2.elb.amazonaws.com     80:31012/TCP   119m
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ● 

## Test LB Service
 export  MY_EKS_PRV_NODE1_EXTERNAL_DNS_DYNAMO=a77b17abe03c84355922425d1c049700-1268584681.eu-west-2.elb.amazonaws.com


  192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  curl -X POST -is http://$MY_EKS_PRV_NODE1_EXTERNAL_DNS_DYNAMO/ep-registration-service/registrations \
   -H "Content-Type: application/json" \
   -d '{"firstName": "rimpa", "lastName": "paul"}'
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Tue, 05 Oct 2021 03:24:39 GMT
Content-Length: 145

{"processingNode":"reg-service-deployment-dynamo-9fd9bfb98-5w7d5","registrationId":"d831eb63-7b05-4667-b736-6d624b4f2820","serviceVersion":"7.0"}%
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  aws dynamodb scan --table-name eprescription-user-profile
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ● 

  192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ●  kubectl get pods
NAME                                             READY   STATUS    RESTARTS   AGE
reg-service-deployment-dynamo-55df5d47df-jp89r   1/1     Running   0          4m1s
reg-service-deployment-dynamo-55df5d47df-l9zm2   1/1     Running   0          4m1s
reg-service-deployment-dynamo-55df5d47df-zvbqf   1/1     Running   0          4m1s
reg-service-deployment-yaml-bdb7b58bb-2gnxb      1/1     Running   0          135m
reg-service-deployment-yaml-bdb7b58bb-g7pkc      1/1     Running   0          135m
reg-service-deployment-yaml-bdb7b58bb-nn65k      1/1     Running   0          135m
 192  ~/workspace/aws-learning/eks/SampleDemoDynamo   master ● 

kubectl exec -it my-first-pod -- /bin/bash
 kubectl exec -it reg-service-deployment-dynamo-55df5d47df-jp89r -- /bin/sh