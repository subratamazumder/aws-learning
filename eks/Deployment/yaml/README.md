 # Deployment via yaml delarative way
 ## Create Deployment
 ```
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  kubectl apply -f reg-service-deployment.yaml
deployment.apps/reg-service-deployment-yaml created
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  get rs
zsh: command not found: get
 ✘ 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  kubectl get rs
NAME                                    DESIRED   CURRENT   READY   AGE
reg-service-deployment-568f847c47       1         1         1       7h3m
reg-service-deployment-yaml-bdb7b58bb   3         3         3       29s
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  kubectl get pods
NAME                                          READY   STATUS    RESTARTS   AGE
reg-service-deployment-568f847c47-bjp2q       1/1     Running   0          7h3m
reg-service-deployment-yaml-bdb7b58bb-2gnxb   1/1     Running   0          36s
reg-service-deployment-yaml-bdb7b58bb-g7pkc   1/1     Running   0          36s
reg-service-deployment-yaml-bdb7b58bb-nn65k   1/1     Running   0          36s
```
 ## Create LB Service
 ```
  192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  kubectl apply -f reg-service-deployment-lb-svc.yaml
service/reg-service-deployment-lb-svc-yaml created
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ●  kubectl get svc
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
kubernetes                           ClusterIP      10.100.0.1       <none>                                                                    443/TCP        9h
reg-service-deployment-lb-svc        LoadBalancer   10.100.141.72    a28139536c4364e9fa7a9007c68acc22-2139149315.eu-west-2.elb.amazonaws.com   80:32767/TCP   7h5m
reg-service-deployment-lb-svc-yaml   LoadBalancer   10.100.251.235   a11bfe4666666439ab29563ad3d6a906-32361183.eu-west-2.elb.amazonaws.com     80:31012/TCP   82s
 192  ~/workspace/aws-learning/eks/Deployment/yaml   master ● 
 ```
 ## Test LB Service
 export  MY_EKS_PRV_NODE1_EXTERNAL_DNS_YAML=a11bfe4666666439ab29563ad3d6a906-32361183.eu-west-2.elb.amazonaws.com


 curl -X POST -is http://$MY_EKS_PRV_NODE1_EXTERNAL_DNS_YAML/ep-registration-service/registrations