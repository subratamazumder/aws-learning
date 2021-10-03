# Replica Set
## Pre Requisite
- setup cluster & node group
- reg-service-rs.yaml
## Create Replica Set
```
kubectl create -f reg-service-rs.yaml
```
## Verify Result Set
```
kubectl describe rs reg-service-rs
kubectl get pods reg-service-rs-72gcs -o yaml
```
## Expose Service
```
kubectl expose rs reg-service-rs  --type=NodePort --port=8081 --target-port=8081 --name=eprescription-reg-rs-svc

```
### Get NodePort for Testing
```
kubectl get service -o wide
```

# Authorize ingress rule of worker node for a specific node-port
aws ec2 authorize-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 32510 --cidr $MY_IP/32 --output text

## Test Service
```
 192  ~/workspace/aws-learning/eks/ReplicaSet   master  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:32510/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 19:40:31 GMT
Content-Length: 97

{"processingNode":"reg-service-rs-hwgz8","registrationId":"8d281879-1686-47ab-b73f-8d8c23c1511e"}%
 192  ~/workspace/aws-learning/eks/ReplicaSet   master  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:32510/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 19:40:33 GMT
Content-Length: 97

{"processingNode":"reg-service-rs-hwgz8","registrationId":"349b43a5-0cd7-4cad-8caa-9b4593958d6e"}%
 192  ~/workspace/aws-learning/eks/ReplicaSet   master  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:32510/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 19:40:35 GMT
Content-Length: 97

{"processingNode":"reg-service-rs-8c82q","registrationId":"639af2d1-8603-4774-934c-386fc8df47d9"}%
 192  ~/workspace/aws-learning/eks/ReplicaSet   master 
```
## Delete PODS
 192  ~/workspace/aws-learning/eks/ReplicaSet   master  kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
eprescription-reg-pod   1/1     Running   0          18h
reg-service-rs-72gcs    1/1     Running   0          29m
reg-service-rs-8c82q    1/1     Running   0          29m
reg-service-rs-hwgz8    1/1     Running   0          29m

 192  ~/workspace/aws-learning/eks/ReplicaSet   master  kubectl delete pod reg-service-rs-72gcs
pod "reg-service-rs-72gcs" deleted
 192  ~/workspace/aws-learning/eks/ReplicaSet   master  kubectl delete pod reg-service-rs-8c82q
pod "reg-service-rs-8c82q" deleted

k8s add new pods automatically 

 192  ~/workspace/aws-learning/eks/ReplicaSet   master  kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
eprescription-reg-pod   1/1     Running   0          18h
reg-service-rs-hwgz8    1/1     Running   0          30m
reg-service-rs-j8rg9    1/1     Running   0          41s
reg-service-rs-m64xs    1/1     Running   0          28s
 192  ~/workspace/aws-learning/eks/ReplicaSet   master 

 Service is working with old & newp=ly replaced pods 
  192  ~/workspace/aws-learning/eks/ReplicaSet   master  curl -X POST -is http://$MY_EKS_NODE1_EXTERNAL_IP:32510/ep-registration-service/registrations
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Date: Sun, 03 Oct 2021 19:49:22 GMT
Content-Length: 97

{"processingNode":"reg-service-rs-m64xs","registrationId":"eeadea77-ffdc-4cba-b9fc-36f4e0e3ab3c"}%
## Clean Up

### Undo temp SG changes 
```
aws ec2 revoke-security-group-ingress --group-id sg-0283eb6dc9e7b6142 --protocol tcp --port 32510 --cidr $MY_IP/32 --output text
```
