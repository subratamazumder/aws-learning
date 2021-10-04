# Deployments
## Pre Requisite
- setup cluster & node group
## Create Deployments
```
kubectl create deployment reg-service-deployment --image=dockersubrata/eprescription-reg-service-image:4.0 
```
## Verify Deployment
```
kubectl get deploy
192  ~/workspace/aws-learning/eks/ReplicaSet   master ●  kubectl get deploy
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
reg-service-deployment   1/1     1            1           9s
 192  ~/workspace/aws-learning/eks/ReplicaSet   master ●  kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
reg-service-deployment-546f949d85-sk479   1/1     Running   0          17s
 192  ~/workspace/aws-learning/eks/ReplicaSet   master ●  kubectl get rs
NAME                                DESIRED   CURRENT   READY   AGE
reg-service-deployment-546f949d85   1         1         1       72s
kubectl describe deployment reg-service-deployment
Sacle UP
kubectl scale --replicas=5 deployment/reg-service-deployment

Sacle DOWN
kubectl scale --replicas=2 deployment/reg-service-deployment
```
## Expose Service
```

kubectl expose deployment reg-service-deployment --type=NodePort --port=80 --target-port=8081 --name=reg-service-deployment-svc

```
### Get NodePort for Testing
```
kubectl get service -o wide
```

# Authorize ingress rule of worker node for a specific node-port
aws ec2 authorize-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 30274 --cidr $MY_IP/32 --output text

## Test Service with image 4.0

```
 192  ~/workspace/aws-learning/eks   master ●  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:30274/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 22:48:16 GMT
Content-Length: 139

{"processingNode":"reg-service-deployment-546f949d85-8xfr7","registrationId":"3fdf704c-819e-4df9-80cc-2dc234e3bc50","serviceVersion":"4.0"}%
 192  ~/workspace/aws-learning/eks   master ● 
 ```
## Rollout newer version 5.0
syntax : kubectl set image deployment/<Deployment-Name> <Container-Name>=<Container-Image> --record=true
kubectl set image deployment/reg-service-deployment eprescription-reg-service-image=dockersubrata/eprescription-reg-service-image:5.0 --record=true

 192  ~/workspace/aws-learning/eks   master ●  kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
reg-service-deployment-546f949d85-8xfr7   1/1     Running   0          145m
reg-service-deployment-546f949d85-b5kjc   1/1     Running   0          145m
reg-service-deployment-546f949d85-bkv5x   1/1     Running   0          145m
reg-service-deployment-546f949d85-g4rzp   1/1     Running   0          145m
reg-service-deployment-546f949d85-sk479   1/1     Running   0          167m
 192  ~/workspace/aws-learning/eks   master ●  kubectl set image deployment/reg-service-deployment eprescription-reg-service-image=dockersubrata/eprescription-reg-service-image:5.0 --record=true
deployment.apps/reg-service-deployment image updated

new pods are getting creted  with new image version5.0
 192  ~/workspace/aws-learning/eks   master ●  kubectl get pods
NAME                                      READY   STATUS              RESTARTS   AGE
reg-service-deployment-546f949d85-8xfr7   0/1     Terminating         0          146m
reg-service-deployment-546f949d85-b5kjc   0/1     Terminating         0          146m
reg-service-deployment-546f949d85-bkv5x   1/1     Terminating         0          146m
reg-service-deployment-546f949d85-g4rzp   1/1     Terminating         0          146m
reg-service-deployment-546f949d85-sk479   1/1     Running             0          168m
reg-service-deployment-6c484d5db-55thv    0/1     ContainerCreating   0          1s
reg-service-deployment-6c484d5db-56fj4    0/1     ContainerCreating   0          0s
reg-service-deployment-6c484d5db-g7k5s    1/1     Running             0          4s
reg-service-deployment-6c484d5db-xzfrl    1/1     Running             0          4s
reg-service-deployment-6c484d5db-zxw99    1/1     Running             0          4s
 192  ~/workspace/aws-learning/eks   master ●  kubectl rollout status deployment/reg-service-deployment
deployment "reg-service-deployment" successfully rolled out
 192  ~/workspace/aws-learning/eks   master ● 

All new pods are running with image version5.0

  192  ~/workspace/aws-learning/eks   master ●  kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
reg-service-deployment-6c484d5db-55thv   1/1     Running   0          86s
reg-service-deployment-6c484d5db-56fj4   1/1     Running   0          85s
reg-service-deployment-6c484d5db-g7k5s   1/1     Running   0          89s
reg-service-deployment-6c484d5db-xzfrl   1/1     Running   0          89s
reg-service-deployment-6c484d5db-zxw99   1/1     Running   0          89s
 192  ~/workspace/aws-learning/eks   master ● 
New replica set gets created
  192  ~/workspace/aws-learning/eks   master ●  kubectl get rs
NAME                                DESIRED   CURRENT   READY   AGE
reg-service-deployment-546f949d85   0         0         0       173m
reg-service-deployment-6c484d5db    5         5         5       4m51s
 192  ~/workspace/aws-learning/eks   master ● 

## Test Service with image 5.0 roll out
```
 192  ~/workspace/aws-learning/eks   master ●  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:30274/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 23:58:56 GMT
Content-Length: 138

{"processingNode":"reg-service-deployment-6c484d5db-g7k5s","registrationId":"54c20ce9-8578-41f3-936e-028ef1857c2c","serviceVersion":"5.0"}%
 192  ~/workspace/aws-learning/eks   master ● 
```
## Rollout newer version 6.0
kubectl edit deployment/reg-service-deployment --record=true
 192  ~/workspace/aws-learning/eks   master ●  kubectl edit deployment/reg-service-deployment --record=true
deployment.apps/reg-service-deployment edited
 192  ~/workspace/aws-learning/eks   master ● 

  192  ~/workspace/aws-learning/eks   master ●  kubectl rollout status deployment/reg-service-deployment
deployment "reg-service-deployment" successfully rolled out
 192  ~/workspace/aws-learning/eks   master ● 

Anothe RS got created  
192  ~/workspace/aws-learning/eks   master ●  kubectl get rs
NAME                                DESIRED   CURRENT   READY   AGE
reg-service-deployment-546f949d85   0         0         0       3h12m
reg-service-deployment-568f847c47   5         5         5       2m3s
reg-service-deployment-6c484d5db    0         0         0       24m
 192  ~/workspace/aws-learning/eks   master ● 
## Test Service with image 6.0 roll out
 192  ~/workspace/aws-learning/eks   master ●  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:30274/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Mon, 04 Oct 2021 00:19:16 GMT
Content-Length: 139

{"processingNode":"reg-service-deployment-568f847c47-2jbrh","registrationId":"00c6aecb-a817-4f33-b306-8cd1f20e1133","serviceVersion":"6.0"}%
 192  ~/workspace/aws-learning/eks   master ● 
## Verify Rollout History
 ```
 192  ~/workspace/aws-learning/eks   master ●  kubectl rollout history deployment/reg-service-deployment
deployment.apps/reg-service-deployment
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment/reg-service-deployment eprescription-reg-service-image=dockersubrata/eprescription-reg-service-image:5.0 --record=true
3         kubectl edit deployment/reg-service-deployment --record=true

 192  ~/workspace/aws-learning/eks   master ● 


kubectl rollout history deployment/reg-service-deployment --revision=2

 ✘ 192  ~/workspace/aws-learning/eks   master ●  kubectl rollout history deployment/reg-service-deployment --revision=2
deployment.apps/reg-service-deployment with revision #2
Pod Template:
  Labels:	app=reg-service-deployment
	pod-template-hash=6c484d5db
  Annotations:	kubernetes.io/change-cause:
	  kubectl set image deployment/reg-service-deployment eprescription-reg-service-image=dockersubrata/eprescription-reg-service-image:5.0 --re...
  Containers:
   eprescription-reg-service-image:
    Image:	dockersubrata/eprescription-reg-service-image:5.0
    Port:	<none>
    Host Port:	<none>
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>

 192  ~/workspace/aws-learning/eks   master ● 

```
## Undo/Roll Back to 5.0 (revision=2)
```
kubectl rollout undo deployment/reg-service-deployment --to-revision=2

 192  ~/workspace/aws-learning/eks   master ●  kubectl rollout undo deployment/reg-service-deployment --to-revision=2
deployment.apps/reg-service-deployment rolled back
 192  ~/workspace/aws-learning/eks   master ●  kubectl get pods
NAME                                      READY   STATUS        RESTARTS   AGE
reg-service-deployment-568f847c47-7lj64   0/1     Terminating   0          12m
reg-service-deployment-6c484d5db-5vxm2    1/1     Running       0          8s
reg-service-deployment-6c484d5db-dc4p8    1/1     Running       0          7s
reg-service-deployment-6c484d5db-n87p4    1/1     Running       0          10s
reg-service-deployment-6c484d5db-nzx87    1/1     Running       0          10s
reg-service-deployment-6c484d5db-vdk29    1/1     Running       0          10s
 192  ~/workspace/aws-learning/eks   master ● 

Previous RS got activated now with new pods for that specific RS
 NAME                                DESIRED   CURRENT   READY   AGE
reg-service-deployment-546f949d85   0         0         0       3h23m
reg-service-deployment-568f847c47   0         0         0       12m
reg-service-deployment-6c484d5db    5         5         5       35m
 192  ~/workspace/aws-learning/eks   master ● 

```
## Test Service with image 5.0 post undo/roll back
```
 192  ~/workspace/aws-learning/eks   master ●  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:30274/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Mon, 04 Oct 2021 00:32:56 GMT
Content-Length: 138

{"processingNode":"reg-service-deployment-6c484d5db-nzx87","registrationId":"69b2f9de-78b4-438f-a7ba-4f551cde5ac4","serviceVersion":"5.0"}%
 192  ~/workspace/aws-learning/eks   master ● 
```
## Clean Up

### Undo temp SG changes 
```
aws ec2 revoke-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 32510 --cidr $MY_IP/32 --output text
```
