CKA reference to the course https://github.com/kodekloudhub/certified-kubernetes-administrator-course
https://notes.kodekloud.com/docs/CKA-Certification-Course-Certified-Kubernetes-Administrator/Introduction/Course-Introduction

some of the configuration files are at "/etc/kubernetes/manifests/"
Execute any command in pod without going inside the pod 

NOTE: - if you want to use "--command" option in kubectl command then always use at the end, even --dry-run even the -o yaml shoule be before that command. and to give any command you will need to add --, ex. "$ kubectl run static-busybox --image=busybox -n default --dry-run=client -o yaml --command -- sleep 1000"

You can ssh to node and go to that node just by ssh <node name or IP>, you will get IP as "kubectl get nodes -o wide."

"$ k exec <pod-name> -- <command>"
example 
"$ kubectl exec nginx -- ls /"
"$ kubectl exec nginx -- env"

If you want to specify the container inside the pod then use below command.
"$ kubectl exec my-pod -c app -- ps aux"

you can use "k" insted of "kubectl"

$ kubectl get all
$ kubectl replace --foce -f pod.yaml -> delete exesting pod and create new from same file.

you can create dir(ashu) then put all your yaml files there, then go to parent dir(../) then then run
"$ k create -f ashu/" 
it will create all the resources in single command from that dir.

master node and worked node

master node has control plain component by which it can manage multiple worked nodes and its containers

kubelet is present on all the nodes and it always listen to master node and manage the node.
also master node fetches the data from kubelet to monitor nodes and container .

recent version from 1.24 version of k8s "docker" is not supported.
instead it supports containerD, very similar to docker
check more on containerD in here "https://github.com/containerd/containerd"
so instead of "docekr ps -a" you will need to use "nerdctl ps -a" replace "docker" with "nerdctl".

ETCD (etcd cluster): -

	etcd is a distributed and reliable key-value store used by Kubernetes to store cluster data in key-value format. 
	When you run a command such as kubectl get pods, the request goes to the Kubernetes API Server, and the API Server reads 
	the required data from etcd (or from its cache) and returns the result to you. etcd stores information about Pods, Deployments, 
	Services, ConfigMaps, Secrets, Nodes, and the overall cluster state.
	
	An etcd cluster is a group of one or more etcd servers that work together to store Kubernetes cluster data reliably. 
	It keeps critical information such as Pods, Deployments, Services, Secrets, ConfigMaps, and cluster state. In a multi-node etcd 
	cluster, the members synchronize data using the Raft consensus algorithm, ensuring consistency even if some nodes fail. 
	Kubernetes API Server reads from and writes to etcd to maintain the desired state of the cluster. Having multiple etcd members 
	provides high availability and protects against data loss if a server goes down.
	
	Commands: -
	to run any command with etcd you will need to export "ETCDCTL_API" veriable to "3", with this veriable etcd understand to use its version 3 by default its a 2.2 or something.
	Then to ecexute ant etcd command we need server ip and port (end point), ca cert, server cert and server key. so command become as "$ etcdctl snapshot save <backup-file> --endpoints=<endpoint> --cacert=<ca.crt> --cert=<server.crt> --key=<server.key>"
	Why we need to specify these details? usually the ETCD server talk to api-server and api-server take care of authentation, but as we are manually requesting ETCD cluster, we need to take care of authentation as well, so we need to provide the details.
	
kube-apiserver: -

	there are multiple component in k8s, so connecting all those components to each other and talking to each other with right information 
	is done by kube-apiserver.
	
pods

	smallest block in k8s.
	in single pod we can have multiple container but not same kind of containers, we can have multiple containers of differnt kinds.
	like you can't run two python container in single pod, but you can run python and nginx cotainers in single pod.

	you will get the yaml file of existing pod in detail.
	$ kubectl get pods nginx -o yaml 

	you can create pods with commandline without yaml file. and you can create yaml file as well with command.
	follow the below commands
	
	$ kubectl run nginx-2 --image=nginx --dry-run=client -o yaml
	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx-2
	  name: nginx-2
	spec:
	  containers:
	  - image: nginx
		name: nginx-2
		resources: {}
	  dnsPolicy: ClusterFirst
	  restartPolicy: Always
	status: {}
	
	$ kubectl run nginx-2 --image=nginx --dry-run=client -o yaml > pod.yaml
	
	$ ls
	pod.yaml

	$ kubectl create -f pod.yaml
	pod/nginx-2 created
	
	$ kubectl get pods
	NAME      READY   STATUS    RESTARTS   AGE
	nginx-2   1/1     Running   0          6s
	
	$ cat pod.yaml
	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx-2
	  name: nginx-2
	spec:
	  containers:
	  - image: nginx
		name: nginx-2
		resources: {}
	  dnsPolicy: ClusterFirst
	  restartPolicy: Always
	status: {}
	
	$ kubectl run nginx --image=nginx
	pod/nginx created
	
	$ kubectl get pod
	NAME      READY   STATUS    RESTARTS   AGE
	nginx     1/1     Running   0          7s
	nginx-2   1/1     Running   0          3m33s

	Note: - pod with labels in kubectl run command
	
	$ kubectl run redis --image=redis:alpine --labels="tire=db" --dry-run=client -o yaml
	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		tire: db
	  name: redis
	spec:
	  containers:
	  - image: redis:alpine
		name: redis
		resources: {}
	  dnsPolicy: ClusterFirst
	  restartPolicy: Always
	status: {}
	
	kubectl get pods --selector env=dev 					-> you will get the pods from env labels.
	kubectl get pods --selector env=dev, bu=finance 		-> label with finance and dev.

Replicaset: -
	
	replication controller is older technology and got replaced with replicaset.
	in replicationcontroller "selector" is not mandatory but in Replicaset it is mandatory.
	Replicaset can manage pods which are created by the replicaset itself and also the pods matched with spec:selector:matchLabels, 
	no matter when you create the pod, but this not happens with replicationcontroller.
	

	KEEP IN MIND:- in ReplicaSet you have to match the labels whatever you are giving in spec:template:labels to 
	spec:selector:matchLabels, otherwise you will get error.

	replicationcontroller: -
		$ kubectl get replicationcontroller
		NAME      DESIRED   CURRENT   READY   AGE
		replica   3         3         3       35m
		
		$ kubectl get pods
		NAME            READY   STATUS    RESTARTS   AGE
		replica-mr4hb   1/1     Running   0          35m
		replica-vclwt   1/1     Running   0          35m
		replica-xmfdm   1/1     Running   0          35m
		
		$ cat replicationController.yaml
		apiVersion: v1
		kind: ReplicationController
		metadata:
		  name: replica
		  labels:
			app: myapp-replica
		spec:
		  template:
			metadata:
			  name: replica-pod
			  labels:
				app: myapp-pod
			spec:
			  containers:
				- name: nginx-name
				  image: nginx
		  replicas: 3
		  
		  
	ReplicaSet: -

		$ kubectl get rs
		NAME      DESIRED   CURRENT   READY   AGE
		replica   3         3         3       46s
		
		$ kubectl get pods
		NAME            READY   STATUS    RESTARTS   AGE
		replica-brv6z   1/1     Running   0          51s
		replica-bvks8   1/1     Running   0          51s
		replica-p8h2d   1/1     Running   0          51s
		
		$ cat replicaset.yaml
		apiVersion: apps/v1
		kind: ReplicaSet
		metadata:
		  name: replica
		  labels:
			app: myapp-replica
		spec:
		  template:
			metadata:
			  name: replica-pod
			  labels:
				app: myapp-pod
			spec:
			  containers:
				- name: nginx-name
				  image: nginx
		  replicas: 3
		  selector:
			matchLabels:
			  app: myapp-pod

	how to scale-up and scale-down the replicas 
		1. change the number of replicas in file and run "kubectl replace -f <file-name>" 
		2. there is command to scale the pods, "kubectl scale --replicas=10 -f <file-name>" (will not change any file, but still you will have the changes).
			
Deployment: -

	deploment is exactly same as replicalset, just one feature.
	you can role and role back your update to pods one after another, even you can pause the update as well.
	
	you can create deployment from command line, commands as below: -
	
	$ kubectl create deployment --image=nginx nginx
	deployment.apps/nginx created

	$ kubectl get deployment
	NAME    READY   UP-TO-DATE   AVAILABLE   AGE
	nginx   1/1     1            1           10s

	$ kubectl create deployment --image=nginx nginx-2 --dry-run=client -o yaml
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  creationTimestamp: null
	  labels:
		app: nginx
	  name: nginx
	spec:
	  replicas: 1
	  selector:
		matchLabels:
		  app: nginx
	  strategy: {}
	  template:
		metadata:
		  creationTimestamp: null
		  labels:
			app: nginx
		spec:
		  containers:
		  - image: nginx
			name: nginx
			resources: {}
	status: {}

	$ kubectl create deployment --image=nginx nginx-2 --dry-run=client -o yaml > deployment.yaml

	$ ls
	deployment.yaml

	$ kubectl get deployment
	NAME      READY   UP-TO-DATE   AVAILABLE   AGE
	nginx     1/1     1            1           2m22s
	nginx-2   1/1     1            1           13s

	$ kubectl get pods
	NAME                       READY   STATUS    RESTARTS   AGE
	nginx-2-8487d69879-746d2   1/1     Running   0          4m48s
	nginx-66686b6766-4qp6b     1/1     Running   0          6m57s

	$ kubectl create deployment --image=nginx nginx-with-4-replicas --replicas=4 --dry-run=client -o yaml
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  creationTimestamp: null
	  labels:
		app: nginx-with-4-replicas
	  name: nginx-with-4-replicas
	spec:
	  replicas: 4
	  selector:
		matchLabels:
		  app: nginx-with-4-replicas
	  strategy: {}
	  template:
		metadata:
		  creationTimestamp: null
		  labels:
			app: nginx-with-4-replicas
		spec:
		  containers:
		  - image: nginx
			name: nginx
			resources: {}
	status: {}

	$ kubectl create deployment --image=nginx nginx-with-4-replicas --replicas=4 --dry-run=client -o yaml  > nginx-deployment.yaml

	$ ls
	nginx-deployment.yaml

	$ kubectl create -f nginx-deployment.yaml
	deployment.apps/nginx-with-4-replicas created

	$ kubectl get deployment
	NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
	nginx-with-4-replicas   3/4     4            3           9s

	$ kubectl get pods
	NAME                                     READY   STATUS    RESTARTS   AGE
	nginx-with-4-replicas-86d9bcd478-ftn5x   1/1     Running   0          17s
	nginx-with-4-replicas-86d9bcd478-mwnts   1/1     Running   0          17s
	nginx-with-4-replicas-86d9bcd478-q2x8d   1/1     Running   0          17s
	nginx-with-4-replicas-86d9bcd478-qfjqt   1/1     Running   0          17s

	$ cat nginx-deployment.yaml
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  creationTimestamp: null
	  labels:
		app: nginx-with-4-replicas
	  name: nginx-with-4-replicas
	spec:
	  replicas: 4
	  selector:
		matchLabels:
		  app: nginx-with-4-replicas
	  strategy: {}
	  template:
		metadata:
		  creationTimestamp: null
		  labels:
			app: nginx-with-4-replicas
		spec:
		  containers:
		  - image: nginx
			name: nginx
			resources: {}
	status: {}
	
	Deployment update and rollback: -
		update image in deployment
			"$ kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1"
			"$ k set image deployment <name of deployment> <container name>:<new image>"
		
		Advance topic, check it here <link>

	There are multiple strategy to roll-update, one of them is "Recreate", in recreate all the pods will be deleted and recreate with new update,
	on this strategy you can face the application downtime, and it is not default strategy used in k8s.
	
	"Rolling update" in this strategy one pod will be deleted and one pod will be up with new version same for another pod,
	pods will be down one by one and get up one by one, not all pods down and all pods up. one down one up, same precress repetated for all the precess.
	This strategy is default strategy used by k8s.
	
	to update the image from deployment you can use "$kubectl  set image deployment <deployment name> <previous CONTAINER name>=<new image>" command.
	
	$ kubectl create deployment nginx-deployment --image=nginx --replicas=10                    
	deployment.apps/nginx-deployment created

	$ kubectl describe deployment nginx-deployment
	Name:                   nginx-deployment
	Namespace:              default
	CreationTimestamp:      Sun, 12 Oct 2025 04:50:07 +0000
	Labels:                 app=nginx-deployment
	Annotations:            deployment.kubernetes.io/revision: 1
	Selector:               app=nginx-deployment
	Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
	StrategyType:           RollingUpdate
	MinReadySeconds:        0
	RollingUpdateStrategy:  25% max unavailable, 25% max surge
	Pod Template:
	  Labels:  app=nginx-deployment
	  Containers:
	   nginx:
		Image:         nginx
		Port:          <none>
		Host Port:     <none>
		Environment:   <none>
		Mounts:        <none>
	  Volumes:         <none>
	  Node-Selectors:  <none>
	  Tolerations:     <none>
	Conditions:
	  Type           Status  Reason
	  ----           ------  ------
	  Available      True    MinimumReplicasAvailable
	  Progressing    True    NewReplicaSetAvailable
	OldReplicaSets:  <none>
	NewReplicaSet:   nginx-deployment-6cfb98644c (10/10 replicas created)
	Events:
	  Type    Reason             Age   From                   Message
	  ----    ------             ----  ----                   -------
	  Normal  ScalingReplicaSet  41s   deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 0 to 10
	  
	$ kubectl set image deployment nginx-deployment nginx=nginx:1.7.1
	deployment.apps/nginx-deployment image updated

	$ kubectl describe deployment nginx-deployment
	Name:                   nginx-deployment
	Namespace:              default
	CreationTimestamp:      Sun, 12 Oct 2025 04:50:07 +0000
	Labels:                 app=nginx-deployment
	Annotations:            deployment.kubernetes.io/revision: 2
	Selector:               app=nginx-deployment
	Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
	StrategyType:           RollingUpdate
	MinReadySeconds:        0
	RollingUpdateStrategy:  25% max unavailable, 25% max surge                        			          # you can see the which strategy used to roll update.
	Pod Template:
	  Labels:  app=nginx-deployment
	  Containers:
	   nginx:
		Image:         nginx:1.7.1
		Port:          <none>
		Host Port:     <none>
		Environment:   <none>
		Mounts:        <none>
	  Volumes:         <none>
	  Node-Selectors:  <none>
	  Tolerations:     <none>
	Conditions:
	  Type           Status  Reason
	  ----           ------  ------
	  Available      True    MinimumReplicasAvailable
	  Progressing    True    NewReplicaSetAvailable
	OldReplicaSets:  nginx-deployment-6cfb98644c (0/0 replicas created)										# check here
	NewReplicaSet:   nginx-deployment-6857755f8 (10/10 replicas created)									# check here		
	Events:
	  Type    Reason             Age                  From                   Message
	  ----    ------             ----                 ----                   -------
	  Normal  ScalingReplicaSet  4m20s                deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 0 to 10
	  Normal  ScalingReplicaSet  2m19s                deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 0 to 3
	  Normal  ScalingReplicaSet  2m19s                deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 10 to 8
	  Normal  ScalingReplicaSet  2m19s                deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 3 to 5
	  Normal  ScalingReplicaSet  118s                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 8 to 7
	  Normal  ScalingReplicaSet  118s                 deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 5 to 6
	  Normal  ScalingReplicaSet  117s                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 7 to 6
	  Normal  ScalingReplicaSet  117s                 deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 6 to 7
	  Normal  ScalingReplicaSet  115s                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 6 to 5
	  Normal  ScalingReplicaSet  106s (x8 over 115s)  deployment-controller  (combined from similar events): Scaled down replica set nginx-deployment-6cfb98644c from 1 to 0
	  	
	When you create the deployemnt, that time deployemnt create the replicaset under the hood, when  you update the deployment that time another replicaset is get created,
	and pod get deleted from older replica and new one created in new replica, similarlly happes for all the pods and update is rolled one pod by one pod.
	
	if you run get command for replica, you can see older repicas have 0 pods and new replicas has 10 pods, check the timestamp.
	
	$ kubectl get replicaset
	NAME                          DESIRED   CURRENT   READY   AGE
	nginx-deployment-6857755f8    10        10        10      6m36s					# updated replicas
	nginx-deployment-6cfb98644c   0         0         0       8m37s					# older replicas

	to rollback, you can use below command.
	
	$ kubectl rollout undo deployment nginx-deployment
	deployment.apps/nginx-deployment rolled back
	
	$ kubectl get replicaset
	NAME                          DESIRED   CURRENT   READY   AGE
	nginx-deployment-6857755f8    0         0         0       15m					# updated replicas
	nginx-deployment-6cfb98644c   10        10        10      17m					# roll backed replicas / older replicas
	
	$ kubectl describe deployment nginx-deployment
	Name:                   nginx-deployment
	Namespace:              default
	CreationTimestamp:      Sun, 12 Oct 2025 04:50:07 +0000
	Labels:                 app=nginx-deployment
	Annotations:            deployment.kubernetes.io/revision: 3
	Selector:               app=nginx-deployment
	Replicas:               10 desired | 10 updated | 10 total | 10 available | 0 unavailable
	StrategyType:           RollingUpdate
	MinReadySeconds:        0
	RollingUpdateStrategy:  25% max unavailable, 25% max surge
	Pod Template:
	  Labels:  app=nginx-deployment
	  Containers:
	   nginx:
		Image:         nginx
		Port:          <none>
		Host Port:     <none>
		Environment:   <none>
		Mounts:        <none>
	  Volumes:         <none>
	  Node-Selectors:  <none>
	  Tolerations:     <none>
	Conditions:
	  Type           Status  Reason
	  ----           ------  ------
	  Available      True    MinimumReplicasAvailable
	  Progressing    True    NewReplicaSetAvailable
	OldReplicaSets:  nginx-deployment-6857755f8 (0/0 replicas created)
	NewReplicaSet:   nginx-deployment-6cfb98644c (10/10 replicas created)
	Events:
	  Type    Reason             Age                 From                   Message
	  ----    ------             ----                ----                   -------
	  Normal  ScalingReplicaSet  17m                 deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 0 to 10
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 0 to 3
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 10 to 8
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 3 to 5
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 8 to 7
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 5 to 6
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 7 to 6
	  Normal  ScalingReplicaSet  15m                 deployment-controller  Scaled up replica set nginx-deployment-6857755f8 from 6 to 7
	  Normal  ScalingReplicaSet  14m                 deployment-controller  Scaled down replica set nginx-deployment-6cfb98644c from 6 to 5
	  Normal  ScalingReplicaSet  65s                 deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 0 to 3
	  Normal  ScalingReplicaSet  65s                 deployment-controller  Scaled down replica set nginx-deployment-6857755f8 from 10 to 8
	  Normal  ScalingReplicaSet  64s                 deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 3 to 5
	  Normal  ScalingReplicaSet  63s                 deployment-controller  Scaled down replica set nginx-deployment-6857755f8 from 8 to 7
	  Normal  ScalingReplicaSet  63s                 deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 5 to 6
	  Normal  ScalingReplicaSet  62s                 deployment-controller  Scaled down replica set nginx-deployment-6857755f8 from 7 to 6
	  Normal  ScalingReplicaSet  62s                 deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 6 to 7
	  Normal  ScalingReplicaSet  61s                 deployment-controller  Scaled down replica set nginx-deployment-6857755f8 from 6 to 5
	  Normal  ScalingReplicaSet  61s                 deployment-controller  Scaled up replica set nginx-deployment-6cfb98644c from 7 to 8
	  Normal  ScalingReplicaSet  60s (x10 over 14m)  deployment-controller  (combined from similar events): Scaled up replica set nginx-deployment-6cfb98644c from 8 to 9
	  
	Some command, you will need to know.

	$ kubectl rollout status deployment nginx-deployment
	deployment "nginx-deployment" successfully rolled out

	$ kubectl rollout history deployment nginx-deployment
	deployment.apps/nginx-deployment 
	REVISION  CHANGE-CAUSE
	5         <none>
	6         kubectl set image deployment nginx-deployment nginx=nginx:1.7.1 --record=true

	If you want to edit strategy then add spec:strategy:type <strategy name>, in deployemnt.yaml file.
	
	and if you want to change strategy of existing deployment then, "$ kubectl edit deployemnt <name>"
	search for "strategy:" then change the type of strategy.


	
Services: -
	
	NOTE: - If you done specifi the type of service, it will consider it as ClusterIP, by default.
	
	NodePort: -
		as it explained in name, like node and port, node cand be accessed by it port, so NodePort.
		
		so NodePort servies gives you the port to access the pod, 
		port on pod is called as "TargetPort", 
		port on service is called as just "port".
		port on node called as "nodeport". 
		Range of nodeport is from 30000 to 32767.
		To connect the any service to any pod, we need to use the "selector" in service and use exact labes in service from pod which
		you want to include in the service. 
		
	ClusterIP: -
		in production environment, there are nultiple containers and pods are running, so one go down and other come up
		that that pod should be get connect in service, so in clusted IP create single IP for multiple pods,
		like in backend you have multiple redis cervice running, then single port will be there to connect any one of redis pod.
		
	LoadBalancer: -
		is as name suggest, balance the load from services. 
		NOTE: - it is only availabe in limited cloud, if loadbalancer is not availabe there then it will be treate as NodePort.
		cloud platform should have its own load balancer, like GCP, AWS, AZURE have.
		
	$ cat service.yaml
	apiVersion: v1
	kind: Service
	metadata:
	  name: ashu-nginx-service
	spec:
	  type: NodePort/ClusterIP/LoadBalancer
	  selector:
		app: ashu-app        # with this selector service get idea, which pod to keep in contact and which one is to ignore.
	  ports:
		- port: 8080         # Service port
		  targetPort: 80     # Container port
		  nodePort: 30008    # Node port (optional & must be in range 30000–32767)

	NOTE: - in below commands nginx pod is already there and we are inclusing that pod in new srvice while creating,
	So it is easy way to inlcude pod and create the service.
	
	$ kubectl expose pod nginx --port=3007 --target-port=80 --name=nginx-service --dry-run=client -o yaml

	apiVersion: v1
	kind: Service
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx-service
	spec:
	  ports:
	  - port: 3007
		protocol: TCP
		targetPort: 80
	  selector:
		run: nginx
	status:
	  loadBalancer: {}
	
	$ kubectl expose pod nginx --port=3007 --target-port=80 --name=nginx-service --dry-run=client --type=nodeport -o yaml

	apiVersion: v1
	kind: Service
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx-service
	spec:
	  ports:
	  - port: 3007
		protocol: TCP
		targetPort: 80
	  selector:
		run: nginx
	  type: nodeport
	status:
	  loadBalancer: {}
  
  	$ kubectl expose pod nginx --port=3007 --target-port=80 --name=nginx-service --dry-run=client --type=loadbalancer -o yaml

	apiVersion: v1
	kind: Service
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx-service
	spec:
	  ports:
	  - port: 3007
		protocol: TCP
		targetPort: 80
	  selector:
		run: nginx
	  type: loadbalancer
	status:
	  loadBalancer: {}

	You can include depoyment aswell. Command as below: -
	
	$ kubectl expose deployment nginx-deployment --port=3070 --target-port=81 --name=nginx-deployment  --dry-run=client -o yaml
	apiVersion: v1
	kind: Service
	metadata:
	  creationTimestamp: null
	  labels:
		app: nginx-deployment
	  name: nginx-deployment
	spec:
	  ports:
	  - port: 3070
		protocol: TCP
		targetPort: 81
	  selector:
		app: nginx-deployment
	status:
	  loadBalancer: {}
	
	NodePort service for deployment.
	
	$ kubectl expose deployment nginx-deployment --port=3070 --target-port=81 --name=nginx-deployment  --dry-run=client --type nodeport -o yaml
	apiVersion: v1
	kind: Service
	metadata:
	  creationTimestamp: null
	  labels:
		app: nginx-deployment
	  name: nginx-deployment
	spec:
	  ports:
	  - port: 3070
		protocol: TCP
		targetPort: 81
	  selector:
		app: nginx-deployment
	  type: nodeport
	status:
	  loadBalancer: {}

	There is command to create the servie as you want, command as below: -
	
	$ kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml

	apiVersion: v1
	kind: Service
	metadata:
	  creationTimestamp: null
	  labels:
		app: redis
	  name: redis
	spec:
	  ports:
	  - name: 6379-6379
		port: 6379
		protocol: TCP
		targetPort: 6379
	  selector:
		app: redis
	  type: ClusterIP
	status:
	  loadBalancer: {}

NameSpace: -
	
	To change namespace perminantly use below command 
	"$ kubectl config set-context --current --namespace=<your-namespace>"
	in production if you want to create multiple project then Creating namespace will be helpful.
	Also you can isolate your work with multiple Namespace.
	you are creating the pod and want to specifi  the namespace then in metadata section you can specify the metadata:namespace: <name>
	At the beggning you will be in the default namespace, if you want to switch to other namespace use below command:
	"$ kubectl config set-context $(kubectl config current-context) --namespace=ashu"
	To get all resources from all namespaces you can use "--all-namespaces" flag.
	"$ kubectl get pods --all-namespaces"
		
	$ cat namespace.yaml
	apiVersion: v1
	kind: Namespace
	metadata:
	  name: ashu-namespace

	$ kubectl create -f namespace.yaml
	namespace/ashu-namespace created

	$ kubectl get namespace
	NAME              STATUS   AGE
	ashu-namespace    Active   6s

	$ kubectl create namespace ashu
	namespace/ashu created

	$ kubectl get namespace
	NAME              STATUS   AGE
	ashu              Active   8s
	
	ResourceQuota: -
		you can create ResourceQuota for each namespace, so that namespace be limited to use it hardware.
		
		apiVersion: v1
		kind: ResourceQuota
		metadata:
		  name: ashu-resource-quota
		  namespace: ashu
		spec:
		  hard:
			pods: "10"
			requests.cpu: "4"
			requests.memory: "5Gi"
			limits.cpu: "10"
			limits.memory: "10Gi"

Imperative commands in Kubernetes are direct kubectl commands you run in the terminal to create, update, or delete resources immediately—without needing a manifest file.
Imperative commands are useful for quick, interactive tasks or experimentation.
ex: - "kubectl run mypod --image=nginx"

kubectl apply command: -

	there are 3 differnt types, like local yaml file conevrted to live object configuration converted to json file.
	so every time you hit apply command then all three files are get conpared one by one and at the end you will get final result in json file and 
	you can see changed in you cluster.
	
Sheduling: -

	So sheduller map the pod to node, not only that, all the things, like whcich namespace, which node all those things.
	So you can manually decide which pod to which node, for that use "nodeName" only in spec:nodeName: <node name>
	
	apiVersion: v1
	kind: Pod
	metadata:
	  name: nginx
	spec:
	  nodeName: node01
	  containers:
		- name: nginx
		  image: nginx

taint and tolaration: -

	taint is for node and tolaration is for pod.
	If we set taint (node) and tolaration (pod) it will allow pod in that node. basicelly with taint and tolaration we can adjust the which pod goes on whcih node.
	
	for node:
	$ kubectl taint nodes node-name key=value:taint-effect
	$ kubectl taint nodes node01 app=blue:NoSchedule 
	NoSchedule = Do not allow pods to be scheduled on this node unless they have a matching toleration as app=blue.
	So now only pods with app=blue will get to place on node01
	
	three kind of tolorations effect are there 1. NoSchedule
										2. PreferNoSchedule
										3. NoExecution

	NoSchedule       → If pod does not mactches the tain and toleration then no schedule
	PreferNoSchedule → Try another node first; if none is suitable, placing it here is okay.
	NoExecute        → Don't place new Pods here, and remove (delete) (evict) existing Pods that don't have the matching toleration.
	
	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx
	spec:
	  containers:
	  - image: nginx
		name: nginx
	  tolerations:
		- key: "app"							# app
		  operator: "Equal"					    # =
		  value: "blue"							# blue
		  effect: "NoSchedule"					# NoSchedule
		  
		NOTE: - if you compare the spec:tolerations to kubectl taint command, it is exactly the same.
		app, equal, blue, NoSchedule exactly same on command and yaml file.
		
		command to remove taint from node
		kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule-
		to remove the taint the command is exactly the same, just add - at the end.
		I got this "node-role.kubernetes.io/control-plane:NoSchedule" from "kubectl describe node <node name>."
		you will get one line as taint, just copy that and add - at then end then effect will be removed.
		
Node selector and node Affinity : - 

	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx
	spec:
	  containers:
	  - image: nginx
		name: nginx
	  nodeSelector:			# nodeSelector key pare value comes from node
		size: abc			# when node is add this labes, pod get assigned to abc node.
		
	you can label the node as well with below command: -
	"$ kubectl label nodes node01 size=abc"
	
Affinity: -

	requiredDuringSchedulingIgnoreDuringExecution
	preferredDuringSchedulingIgnoreDuringExecution
	
	Syntax for this is not easy to remember, you can refer k8s documentation.
	https://kubernetes.io/docs/home/
	
	In node selector we can mention only one label, and if we need to add multiple lables then we can use Affinity
	
	we can use Taint and Tolaration, like label the node and pod. and Taint and Tolaration just allows pod on node, not assign the pod to the node also there is chance that pod might will endup in other node where node dont have taint so to come over this issue we have Affinity, so that exact pod will endup in exact node.
	
	| Operator       | Meaning                                                  |
	| -------------- | -------------------------------------------------------- |
	| `In`           | Label value **must be one of** the specified values.     |
	| `NotIn`        | Label value **must not be** one of the specified values. |
	| `Exists`       | The label key **must exist** (value doesn't matter).     |
	| `DoesNotExist` | The label key **must not exist**.                        |
	| `Gt`           | Label value **must be greater than** the given integer.  |
	| `Lt`           | Label value **must be less than** the given integer.     |

	apiVersion: v1
	kind: Pod
	metadata:
	  name: nginx
	spec:
	  affinity:
		nodeAffinity:
		  requiredDuringSchedulingIgnoredDuringExecution:
			nodeSelectorTerms:
			- matchExpressions:
			  - key: disktype
				operator: In
				values:
				- ssd            
	  containers:
	  - name: nginx
		image: nginx
		imagePullPolicy: IfNotPresent


	
Resource and limite: -

	By default k8s dont have resource limits.
	so in resource limit we set min and max limits to the pod and container.
	for CPU: - if pod start using more CPU than limiter from k8s will throtel that pod and get back to its limit.
	for MEMORY: - if pod start using more memory, then pod will be terminited with error out of memory.
	
	apiVersion: v1
	kind: Pod
	metadata:
	  name: my-pod
	spec:
	  containers:
	  - name: my-container
		image: myimage
		resources:
		  requests:
			cpu: 2
			memory: "4Gi"
				
	apiVersion: v1
	kind: Pod
	metadata:
	  name: pod-resources-demo
	  namespace: pod-resources-example
	spec:
	  resources:
		limits:					# upper limit/ max limit
		  cpu: "1"
		  memory: "200Mi"
		requests:				# lower limit/ min limit
		  cpu: "1"
		  memory: "100Mi"
	  containers:
	  - name: pod-resources-demo-ctr-1
		image: nginx

	If you dont set resource, then pod might consume all the resource of node and then node not able to host any other pod.
	If you only set limits and dident mention request then ks automatecly set request as same as limits so limits=request. 
	If you only set request then you will get required limite and max till node get full, but other pod get on that same node and requested and limited some space then pod 2 will get as requested and pod 1 might will not get enough space only the requested.
	
	exactly smae for memory above containt is for CPU.
	for memory if other pod need to access the memory from same node and it dont have much space, then we need to kill the pod
	to share the memory, because we cant throtal meomory like cpu, if memory is assigned, then assigned, done.
	you cant get that memory back, so need to delete the pod.
	
	LimitRange: -
		by default we dont have the resource limit, and if we want to set some default limit to every pod, we can use kind:LimitRange
	
		CPU LimitRange: -
			apiVersion: v1
			kind: LimitRange
			metadata:
			  name: cpu-resource-constraint
			spec:
			  limits:
			  - default: 		  #This values are for user, if he forgot to add, then by default used this value
				  cpu: 500m		  #default limits
				defaultRequest:	  #default requests
				  cpu: 500m
				max:			  #min and max values are to limit, like if user tried to excced there values k8s will reject the pod.
				  cpu: "1"		  #max and min define the limit range
				min:
				  cpu: 100m
				type: Container

		Momery LimitRange: -
			apiVersion: v1
			kind: LimitRange
			metadata:
			  name: memory-resource-constraint
			spec:
			  limits:
			  - default: 		  #This values are for user, if he forgot to add, then by default used this value
				  memory: 1Gi	  #default limits
				defaultRequest:	  #default requests
				  memory: 1Gi
				max:			  #min and max values are to limit, like if user tried to excced there values k8s will reject the pod.
				  memory: 1Gi	  #max and min define the limit range
				min:
				  memory: 500Mi
				type: Container


		LimiteRange is created in NameSpace, not on node, or on cluster. also you can control on what to add limites, like on container on pod or on volumes, mention in LimitRange:spec:limits:type: Container, Pod, PersistentVolumeClaim
		
		There is another varation is ResourceQuota, but it is for namespace level object, you can check below.

		| Feature          | LimitRange                        | ResourceQuota                                 |
		| ---------------- | --------------------------------- | --------------------------------------------- |
		| Scope            | Per **container/pod**             | Per **namespace**                             |
		| Enforces limits? | Yes (min, max per pod/container)  | Yes (total across namespace)                  |
		| Sets defaults?   | Yes (`default`, `defaultRequest`) | No                                            |
		| Prevents misuse? | Yes (bad container configs)       | Yes (resource overuse in namespace)           |
		| Example          | Max 1 CPU per container           | Max 10 CPUs total for all pods in a namespace |


	ResourceQuota: -
		you can create ResourceQuota for each namespace, so that namespace be limited to use it hardware.
		
		apiVersion: v1
		kind: ResourceQuota
		metadata:
		  name: ashu-resource-quota
		  namespace: ashu
		spec:
		  hard:
			pods: "10"
			requests.cpu: "4"
			requests.memory: "5Gi"
			limits.cpu: "10"
			limits.memory: "10Gi"

DaemonSet: -

	DaemonSet create one pod per node, like if you create deamonset it will create pod on all the nodes, no matter how may nodes are there.	if node gets deleted or down then that pod will also destoried.	DaemonSet use the node affinity and Default scheduler to land on exact node.
	
	Mostely it is used to nomitoring purpose, requirement is something like monitoring or counting the nodes.
	
	there is no directly way to create DaemonSet like "$k create DaemonSet", you have to rigth yaml file. you can create DaemonSet as the Deployment just change the kind to DaemonSet and dont mention the replicas, also you can refer the documentation from k8s docs.
	
StaticPod: -

	If you place the pod.yaml file at /etc/kubernetes/manifest location, kubelet will automaticelly will create the pod. that kind pods called as static pod, Static pod alwas has kind as Node (kind: Node) in "ownerReferences:"
	Even if the whole cluster is down, still you can create the pod, just put the pod.yaml at above location, and kubelet will make sure that, pod is always allive.
	You can identify the static pod on your cluster, pod will have the name of node at the end of pod name.
	Why we need the static pod, conside whole cluster is down and now you want to restart automatelly, so you can create one pod for that task, to load or install whole cluster again wothout human touch.
	you can check the k8s configuration file at /var/lib/kubelet/config.yaml
	
	what is diff in static pod and deployment so static pod is managed by the kubelet and deployment is managed by the daemon controller
	CoreDNS, kube-proxy cant be deployed as static pod.
	it is not mandatary to have yaml of static pod in /etc/kubernetes/manifest, which Dir is assigned for static pod is mentioned here "/var/lib/kubelet/config.yaml" as "staticPodPath: /etc/kubernetes/manifests", you will get the folder in here, you can place the yaml file in that path.
			
	Create a static pod named static-busybox that uses the busybox image , run in the default namespace and the command sleep 1000
	
	$ kubectl run static-busybox --image=busybox -n default --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/pod.yaml
		apiVersion: v1
		kind: Pod
		metadata:
		  creationTimestamp: null
		  labels:
			run: static-busybox
		  name: static-busybox
		  namespace: default
		spec:
		  containers:
		  - command:
			- sleep
			- "1000"
			image: busybox
			name: static-busybox
			resources: {}
		  dnsPolicy: ClusterFirst
		  restartPolicy: Always
		status: {}
		
PriorityClass: -

	There is no kubectl create priorityclass (or k create pc) command.
	Default prority value is 0.
	
	apiVersion: scheduling.k8s.io/v1
	kind: PriorityClass
	metadata:
	  name: high-priority
	value: 1000000				 				    	# There is range for this vlaue you can google it.
	globalDefault: true / false          			   	# This value will give high-priority to resource in whole cluster
	preemptionPolicy: PreemptLowerPriority / Never		
	# Default is "PreemptLowerPriority", that means it will kill the lower prority and get that place.
	# and in never, it will wait to get sapce and then place itself according to priority.		
	
	Pod example used with PriorityClass with above PriorityClass

	apiVersion: v1
	kind: Pod
	metadata:
	  name: nginx
	  labels:
		env: test
	spec:
	  containers:
	  - name: nginx
		image: nginx
	  priorityClassName: high-priority

multiple scheduler: -
	
	check here https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/
	k8s is highly extensible, you can create your own scheduler.
	If you check k8s configuration file at "/etc/kubernetes/manifests/kube-scheduler.yaml", you will see "--kubeconfig=/etc/kubernetes/scheduler.conf"
	this is default scheduler configuration file.
	If you want your scheduler, you can point the location of your configuration file (my-schedular.yaml) in this option "--kubeconfig=/etc/kubernetes/scheduler.conf". 
	
	ex: -
	$ cat my-schedular.yaml
	apiVersion: kubescheduler.config.k8s.io/v1
	kind: KubeSchedulerConfiguration
	profiles:
		- schedulerName: my-schedular

	Another method is to download the binaries from google and configure it.
	
	above both the methods are not used most of the time, so not recommended to follow those.
	with kubeadm most of the component are deployed as either pod or deployment within the k8s cluster.
	so we will try to create scheduler with pod.
	
	The differnce in scheduling "scheduler as pod" and "configuring it in k8s configuration (in /etc/kubernetes/manifests/kube-scheduler.yaml here)" is, instead of configuring it in k8s configuration just configure it in pod.yaml file (you have to write pod.yaml file), in both the cases you have to write "my-schedular.yaml".

	Now, dont get confused with pod and schedular, like both are same level kinds and how we can run one into another.
	so its not like that, pod is kind and scheduler is service, so we can run the pod as scheduler, even default scheduler also ran as pod check at "/etc/kubernetes/scheduler.conf"
	just create normal pod and configure the schedulers path then that pod will be ran as scheduler
	
	$ cat pod-as-schedular.yaml
	apiVersion: v1
	kind: Pod
	metadata:
	  name: my-kube-scheduler
	  namespace: kube-system
	spec:
	  containers:
	  - command:
		- kube-scheduler
		- --address=127.0.0.1
		- --kubeconfig=/etc/kubernetes/scheduler.conf  		    # authentation informationt that will connect to k8s api server.
		- --config=/root/config.yaml					    	# This will be our custome scheduler file.
		image: k8s.gcr.io/kube-scheduler:v1.29.0				# image for scheduler.
		name: kube-scheduler
		
	$ cat /etc/kubernetes/my-schedular.yaml
	apiVersion: kubescheduler.config.k8s.io/v1
	kind: KubeSchedulerConfiguration
	profiles:
		- schedulerName: my-schedular

	$ kubectl get pod -A
	NAMESPACE            NAME                                      READY   STATUS             RESTARTS      AGE
	kube-system          kube-scheduler-controlplane               1/1     Running            2 (13m ago)   20d
	kube-system          my-kube-scheduler                         0/1     CrashLoopBackOff   4 (73s ago)   2m48s

	multiple copies of same schedular are running on different nodes but only one can be active at a time. and thats why we need to use "leaderElection:" option
	who will lead the scheduling activities. -> check more on google or k8s docs about this.
	
	you can use that custom scheduler to schedule your pod, just mention in "spec:schedulerName: my-kube-scheduler"
	If scheduler is working properly then pod will be in running state otherwise it will be in pending state.
	If you want to check which scheduler schedule which pod, you can use "$ kubectl get events -o wide" command
	you can check the schedulers logs as well, kubectl logs <scheduler-name> -n <name space name>
	
	
Scheduler profile: -	
	
	when you try to create pod, pod get allocated to node, befor that 4 sorting happens as below.
	
	Scheduling queue	# All the nodes are here with scheduler to get bind with node.
	Filtering			# Filter out the pods accroding to its priority, resource requirement, taint and tolaration.
	Scoring				# then schedular score the node according to pod requirents, only high scoring nodes will be left. like there is 4 nodes with 2CPU, 4CPU, 10CPU and 16CPU and pod need 10CPU then 16CPU node will get high score.
	Binding			    # Pod will get binded with high scoring node or will get allocated on that node.
	
	I think this video is not that important so skipping it, all related to scheduling queue, in detailed video.
	https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/14295628#overview

Admission Controllers: -
	
	kubectl -> apiserver -> resource get created
	kubectl -> kubelete -> apiserver -> authentation -> autherization -> resources get created
	
	you can create role, like develpoer and give him a specific permissions
	
	Role:- 
		apiVersion: rbac.authorization.k8s.io/v1
		kind: Role
		metadata:
		  name: developer
		rules:
		- apiGroups: [""] # "" indicates the core API group
		  resources: ["pods"]
		  verbs: ["list", "get", "create", "update", "delete"]
		  resourceNames: ["blue", "red"]

	Now conside deveploer, try to run different command from rules:verbs: then autherization will denied and request will get canceled, we can restrict the access.
	Even we can restrict access to the specific namespace as well (rules:resourceNames).
	
	All this managed auto ApiServer only and wont go beyound that, because you will create resource and roles with kubectl command all those managed by ApiServer.
	Now consider you want to use speficic docekrhub registory or you dont want to allow container run as root user or dont want to use latest tag on any image,
	you cant achive this thing with role based restriction as we see above, and this is where "Admission Controllers" comes in play.
	
	kubectl -> kubelete -> apiserver -> authentation -> autherization -> Admission Controllers -> resources get created
	
	Admission Controllers as better security magers to how we can use the k8s cluster, aprt from simply validation configurations, can do lot more,	like change the request itself or perform addational operation before the pod get created.
	
	Some examples of admisssion controller which run in k8s as default: - AlwaysPullImage -> as name suggest, EventRateLimit -> allwase monitor the limit and try to manage limits, NameSpaceExist -> If you try to create resource in namespace which dose not exist, it will reject that request. 
	
	NamespaceAutoProvision is not default admisssion controller but you can use it or enable it, it will allow to create namespace if dose not exist.
	
	you can check all the default Admission Controller with "$ kube-apiserver -h | grep enable-admission-plugines" command.
	In hosted or playground environments online, you don’t have direct access to the control plane, so you can’t run kube-apiserver directly, but on actual server you will be able to run that command.
	So you are on online playground you can you "$ ps -ef | grep kube-apiserver | grep admission-plugins" command to have same result.
	
	Now to use the plugine, you will need to edit the kube-apiserver.yaml file.
	add --enable-admission-plugine=NodeRestriction,NamespaceAutoProvision at spec:containers:command:, now you will be able to create pod in namespace evenif that
	namespace dose not exeist, it will create for you.
	
	IF you want to desable default admission controller, you edit same file and same lication as below,
	"--disable-admission-plugine=DefaultStoregeClass".
	
Validate and mutate admission controller: -

	Validating admission controller is controller which validate things like NamespaceExists Admission controller, it validate if the namespace exists or not.
	
	Mutating controllers are those controllers who can modifuy the things, like DefaultStorageClass, if you are creating resource and not mentioned about the 
	storgae class it will set to DefaultStorageClass, it will mutate the request and add storage class by itself.
	
	Some admission controller can do both mutate and validate, mutate will run 1st then validate, like NamespaceAutoProvision, it will mutate, will create the namespace,
	after that it will run the NamespaceExists, it will validate, if namespace created and exists or not.
	
	# Check it after this course, need to understad properly, https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/48276505#overview
	

Logging and Monitoring: -

	K8s has the kubelet agent, which get instruction from k8s api master server and execure.
	kubelet has another sub component named as cADVISOR (Container advisor), this retrive the performance from pod and make availabe 
	through kubelet api to metrics server.
	
	by Default metrics server is not there you will need to configure it, from github. check on google how to configure it.
	$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
	
	after configuration you can run "$ kubectl top node" an "$ kubectl top pod" command
	with above command you can check how much CPU and memory get consumned by the node and the pod.
	
	log: - 
		"$ kubectl logs -f <pod name>" you will get all the logs related to the container inside the node.
		If there are multiple containers inside the same node, you can use "$ kubectl logs -f <pod name> <container name>" 
		
Docker ommands and args: -
	
	"$ docker run ubuntu" will run ubuntu container and exit, container is not up and running.
	container ment to do some task, like computation, some analysis and not to do some continus task, like hosting OS, so once its task is done it will exit.
	
	If you append the command as a argument at the end of "docke run command" , it will execute that command, if there is some CMD or ENTRYOPINT mentioned in Dockerfile, 
	even that aslo will get overwitten that command.
	
	CMD ["sleep", "5"] or CMD sleep 5, mention this in Dockerfile, and it will execute everytime when we run the container.
	CMD should be mentioned exactly like that, not like CMD["sleep 5"] or CMD[sleep 5], it will give error.
	
	you can use the ENTRYOPINT as well, ENTRYOPINT can access the argiment from commandline.
	if you just mention the sleep in ENTRYOPINT and pass the 5 as here "$ docker run ubuntu 5" then it will sleep for 5 sec.
	But if you did same while using the CMD it will replace whole "$ CMD["sleep", "5"]" with 5 and then Dockerfile dont know what to do with 5 so you will get error.
	also if you just mention "$ CMD["sleep"]" then Dockerfile will treate it as sleep and wont able to execute any command.
	
Pod ommand and args: -

	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx
a	spec:
	  containers:
	  - image: nginx
		name: nginx
		command: ["sleep", 10]									# this will get executed as ENTRYOPINT
		args: ["7"]												# this will get execute as CMD
		
		
Environment variable: -

	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx
	spec:
	  containers:
	  - image: nginx
		name: nginx
		env:													# export
		- name: APP_COLOR										# APP_COLOR=
		  value: blue											# blue
		  
	configMaps: -
		If your server have multile pods and resources then it is difficult to manage the environment veriables,
		in this kind of scenario configMaps comes handy, you can create configMaps and mention it in pod. 
		
		you can create from below command: -
		
		$ kubectl create configmap ashu-config --from-literal=NAME=ashu \
		> --from-literal=AGE=75 \
		> --from-literal=PLACE=heaven

		configmap/ashu-config created

		apiVersion: v1
		data:
		  AGE: "75"
		  NAME: ashu
		  PLACE: heaven
		kind: ConfigMap
		metadata:
		  creationTimestamp: null
		  name: ashu-config
		
		$ kubectl get configmap
		NAME                       DATA   AGE
		ashu-config                3      8m58s

		$ kubectl describe configmap ashu-config
		Name:         ashu-config
		Namespace:    default
		Labels:       <none>
		Annotations:  <none>

		Data
		====
		AGE:
		----
		75

		NAME:
		----
		ashu

		PLACE:
		----
		heaven


		BinaryData
		====

		Events:  <none>

		If there are multile parameters then it will be complicatated and difficult to write all the options and parameters, so you can create the file, just mention all the parametest in that file.

		$ cat configMAp.properties 
		NAME=ashu
		AGE=75
		PLACE=heaven

		$ kubectl create configmap ashu-configmap-from-file --from-file=/root/configMAp.properties --dry-run=client -o yaml
		apiVersion: v1
		data:
		  configMAp.properties: |
			NAME=ashu
			AGE=75
			PLACE=heaven
		kind: ConfigMap
		metadata:
		  creationTimestamp: null
		  name: ashu-configmap-from-file
		
		$ kubectl create configmap ashu-configmap-from-file --from-file=/root/configMAp.properties                         
		configmap/ashu-configmap-from-file created
		
		$ kubectl get configmap
		NAME                       DATA   AGE
		ashu-configmap-from-file   1      7s
		
		$ kubectl describe configmap ashu-configmap-from-file
		Name:         ashu-configmap-from-file
		Namespace:    default
		Labels:       <none>
		Annotations:  <none>

		Data
		====
		configMAp.properties:
		----
		NAME=ashu
		AGE=75
		PLACE=heaven



		BinaryData
		====

		Events:  <none>
		
	ConfigMap from yaml file: -
	
	$ cat configmap.yaml 
	apiVersion: v1
	kind: ConfigMap
	metadata:
	  name: ashu-configmap-from-yaml
	data:
	  NAME: ashu
	  AGE: 75
	  PLACE: heaven
	
	$ kubectl create -f configmap.yaml
	configmap/ashu-configmap-from-yaml created
	
	$ kubectl get configmap
	NAME                       DATA   AGE
	ashu-configmap-from-yaml   3      14s
	
	$ kubectl describe configmap ashu-configmap-from-yaml
	Name:         ashu-configmap-from-yaml
	Namespace:    default
	Labels:       <none>
	Annotations:  <none>

	Data
	====
	AGE:
	----
	75

	NAME:
	----
	ashu

	PLACE:
	----
	heaven


	BinaryData
	====

	Events:  <none>
	
	How we can configure it in pod or use those veriables in pod

	$ kubectl get configmap
	NAME                       DATA   AGE
	ashu-config                3      29m
	ashu-configmap-from-file   1      20m
	ashu-configmap-from-yaml   3      9m31s
	kube-root-ca.crt           1      28d

	$ cat pod.yaml 
	apiVersion: v1
	kind: Pod
	metadata:
	  creationTimestamp: null
	  labels:
		run: nginx
	  name: nginx
	spec:
	  containers:
	  - image: nginx
		name: nginx
		envFrom:								# this is list do we can mention as meny parameters as we want even configMap also.
		- configMapRef: 
			name: ashu-config
			
	$ kubectl create -f pod.yaml 
	pod/nginx created
	
	$ kubectl describe pod nginx
	Name:             nginx
	Namespace:        default
	Priority:         0
	Service Account:  default
	Node:             node01/172.30.2.2
	Start Time:       Sat, 18 Oct 2025 12:07:52 +0000
	Labels:           run=nginx
	Annotations:      cni.projectcalico.org/containerID: a231f5adbe6e616e1085271118f58f4bbf349be3b3b4e092f06ac15a9c559e77
					  cni.projectcalico.org/podIP: 192.168.1.4/32
					  cni.projectcalico.org/podIPs: 192.168.1.4/32
	Status:           Running
	IP:               192.168.1.4
	IPs:
	  IP:  192.168.1.4
	Containers:
	  nginx:
		Container ID:   containerd://428dd20613baf3781e43675fb19d6091a4fee7ec026a3622e5b523e2f516a77f
		Image:          nginx
		Image ID:       docker.io/library/nginx@sha256:3b7732505933ca591ce4a6d860cb713ad96a3176b82f7979a8dfa9973486a0d6
		Port:           <none>
		Host Port:      <none>
		State:          Running
		  Started:      Sat, 18 Oct 2025 12:08:01 +0000
		Ready:          True
		Restart Count:  0
		Environment Variables from:
		  ashu-config  ConfigMap  Optional: false
		Environment:   <none>
		Mounts:
		  /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vz6xb (ro)
	Conditions:
	  Type                        Status
	  PodReadyToStartContainers   True 
	  Initialized                 True 
	  Ready                       True 
	  ContainersReady             True 
	  PodScheduled                True 
	Volumes:
	  kube-api-access-vz6xb:
		Type:                    Projected (a volume that contains injected data from multiple sources)
		TokenExpirationSeconds:  3607
		ConfigMapName:           kube-root-ca.crt
		Optional:                false
		DownwardAPI:             true
	QoS Class:                   BestEffort
	Node-Selectors:              <none>
	Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
								 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
	Events:
	  Type    Reason     Age   From               Message
	  ----    ------     ----  ----               -------
	  Normal  Scheduled  69s   default-scheduler  Successfully assigned default/nginx to node01
	  Normal  Pulling    68s   kubelet            Pulling image "nginx"
	  Normal  Pulled     61s   kubelet            Successfully pulled image "nginx" in 7.727s (7.727s including waiting). Image size: 62706233 bytes.
	  Normal  Created    60s   kubelet            Created container: nginx
	  Normal  Started    60s   kubelet            Started container nginx
	  
Secret: -
	secret is exactly like configMap, just the difference is it stores the username and password, so its a secret.
	you can encode the test with "$ echo "ash-jd" | base64" command, base64 is very basic form of encoding, there are multiple way, that you can use.
	
		$ kubectl create secret generic ashu --from-literal=USER=ashu --dry-run=client -o yaml
		apiVersion: v1
		data:
		  USER: YXNodQ==
		kind: Secret
		metadata:
		  creationTimestamp: null
		  name: ashu

		$ kubectl create secret generic ashu --from-literal=USER=ashu
		secret/ashu created

		$ kubectl get secret
		NAME   TYPE     DATA   AGE
		ashu   Opaque   1      10s


	From file: -

		$ cat secret.properties 
		USER=ashu

		$ kubectl create secret generic ashu-from-file --from-file=/root/secret.properties --dry-run=client -o yaml
		apiVersion: v1
		data:
		  secret.properties: VVNFUj1hc2h1Cg==
		kind: Secret
		metadata:
		  creationTimestamp: null
		  name: ashu-from-file

		$ kubectl create secret generic ashu-from-file --from-file=/root/secret.properties                         
		secret/ashu-from-file created

		$ kubectl get secrets
		NAME             TYPE     DATA   AGE
		ashu             Opaque   1      5m4s
		ashu-from-file   Opaque   1      8s

		$ kubectl describe secret ashu-from-file
		Name:         ashu-from-file
		Namespace:    default
		Labels:       <none>
		Annotations:  <none>

		Type:  Opaque

		Data
		====
		secret.properties:  10 bytes
	
	From yaml file.

		$ echo "ashu" | base64
		YXNodQo=

		$ cat secret.yaml 
		apiVersion: v1
		kind: Secret
		metadata:
		  name: ashu-from-yaml-file
		data:
		  USER: YXNodQo=
		
		$ kubectl create -f secret.yaml 
		secret/ashu-from-yaml-file created
		
		$ kubectl describe secret ashu-from-yaml-file
		Name:         ashu-from-yaml-file
		Namespace:    default
		Labels:       <none>
		Annotations:  <none>

		Type:  Opaque

		Data
		====
		USER:  5 bytes
	
	Pass the secret in pod

		$ cat pod.yaml 
		apiVersion: v1
		kind: Pod
		metadata:
		  creationTimestamp: null
		  labels:
			run: nginx
		  name: nginx
		spec:
		  containers:
		  - image: nginx
			name: nginx
			envFrom:								# this is list do we can mention as meny parameters as we want even configMap or even secret.
			- secretRef: 
				name: ashu

MultiContainerPod: -

		apiVersion: v1
		kind: Pod
		metadata:
		  creationTimestamp: null
		  labels:
			run: nginx
		  name: nginx
		spec:
		  containers:								# this is array, you can mention as much container as you want in array format.
		  - image: nginx
			name: nginx-container
		  - image: busybox
			name: busybox-container
			
	There are some patterns of multicontainer pods,
	
	Co-located container: -
		So both the containers start at a time and dependent on each other, and continue service.
		
			apiVersion: v1
			kind: Pod
			metadata:
			  creationTimestamp: null
			  labels:
				run: nginx
			  name: nginx
			spec:
			  containers:
			  - image: nginx
				name: nginx-container
			  - image: busybox
				name: busybox-container
		
	Regular init container: -
		two containers, but one is just used to start the main container, once the main container is tarted then 1st container termeneted.
		
			apiVersion: v1
			kind: Pod
			metadata:
			  creationTimestamp: null
			  labels:
				run: nginx
			  name: nginx
			spec:
			  containers:								# this is array, you can mention as much container as you want in array format.
			  - image: nginx
				name: nginx-container
			  initContainers:							# This container starts 1st. This is also an array.
			  - image: busybox
				name: busybox-container
			  - image: busybox							# Then this container start, and at nginx container will start.
				name: busybox-container-1

		
	Sidecar contaiern: -
		Similart to regular init container, it start the mian container, but does not get terminited, it continues operation with main container.
		Sidecar container usually used to get logs of termination of main-container.
		
			apiVersion: v1
			kind: Pod
			metadata:
			  creationTimestamp: null
			  labels:
				run: nginx
			  name: nginx
			spec:
			  containers:								# This is array, you can mention as much container as you want in array format.
			  - image: nginx
				name: nginx-container
			  initContainers:							# This container starts 1st. This is also an array.
			  - image: busybox
				name: busybox-container
				restartPolicy: Always					# This make sure that this container never get down, until main-cintainer dont get terminiated, so works as side-car.
		
		
	The difference in Co-located and Sidecar contaiern we have privalage to start the 1st container in sidecar container, but in co-located container, both have to start at a time.
	
	
Auto scalling: -
	Infra Vertical scaling: -
		when you keep same server and scale up the resource like CPU and memory, thats a vertical scaling.
	
	Infra Horizontal scaling: -
		when you create new server without disturbing original server, thats a hotizontal scaling.
		
	scaling workload exactly same in k8s like infra scaling, vertical scling is adding multiple container in single pod with "$ kubeclt edit pod <podname>" command.
	and for horizontal scaling we increase the number of pods with "$ kubeclt scale" command.
	
	horizontal pod autoscaler(HPA): -
		
		HPA keep checking the resources (resource metrics)from the deployment/pod file and if it exceds that level which we have mentioned in command it will scale up.
		
		$ k create deployment dep-app-ash --image=nginx --replicas=4
		deployment.apps/dep-app-ash created

		$ k autoscale deployment dep-app-ash --cpu-percent=50 --min=1 --max=10
		horizontalpodautoscaler.autoscaling/dep-app-ash autoscaled
		
		# "--cpu-percent=50 --min=1 --max=10" If resource get utilised till 50% then scale, while scaling down and up, min down should be 1 pod and max up should be 10 pods

		$ k get hpa
		NAME          REFERENCE                TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
		dep-app-ash   Deployment/dep-app-ash   cpu: <unknown>/50%   1         10        4          20s

		$ k autoscale deployment dep-app-ash --cpu-percent=50 --min=1 --max=10 --dry-run=client -o yaml
		apiVersion: autoscaling/v2
		kind: HorizontalPodAutoscaler
		metadata:
		  creationTimestamp: null
		  name: dep-app-ash
		spec:
		  maxReplicas: 10
		  metrics:
		  - resource:
			  name: cpu
			  target:
				averageUtilization: 50
				type: Utilization
			type: Resource
		  minReplicas: 1
		  scaleTargetRef:
			apiVersion: apps/v1
			kind: Deployment
			name: dep-app-ash
		status:
		  currentMetrics: null
		  desiredReplicas: 0
		  
	with yaml file: -

		apiVersion: autoscaling/v2
		kind: HorizontalPodAutoscaler
		metadata:
		  name: hpa-name
		spec:
		  scaleTargetRef:
			apiVersion: apps/v1
			kind: Deployment
			name: dep-app-ash
		  minReplicas: 2
		  maxReplicas: 10
		  metrics:
			- type: Resource
			  resource:
				name: cpu
				target:
				  type: Utilization
				  averageUtilization: 50

	In place pod resizing: -

		only work for CUP and memory, and need to check this leacture once again,
		https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/48755083#overview
		
	Vertical pod autoscaling(VPA): -
		Vertical pos autoscaling does not comes with default seting, we need to configure it. 
		
		we neec to confire it in cluster 
		"$ git clone https://github.com/kubernetes/autoscaler.git"
		"$ cd autoscaler/vertical-pod-autoscaler/"
		"$ ./hack/vpa-up.sh"
		
		so this is not built in feature so we need to write yaml file always,
		
		one way to scale verticaly, is to edit that pod, like "$ kubeclt edit pod " and make changes in that file, delete previous pod and recreate new one.
		https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/48755089#overview
		
Cluster maintenence : - 
	
	OS upgrade: -
	
		conside due to some reason, node is down for 5 min for some reason, then all the pods from that node will be killed, becaus it considered as dead node.
		and why 5 min, because it configured in k8s server, and when node comes up then it comes as blank, no pod or any other service will be runing on that node,
		when the node is down, and you have replica or deplouyemnt from that node, then those pods will be created on other node.
		
		while the maintenence, you will need to take down the nodes, if that node is down for 5 min it will be dead, so you can drain the node,
		with command "$ kubectl drain node-1" you will need to use "--ignore-daemonsets to ignore daemonsets" option, then all the resources from that node will be shifted to the other node, and node will be completely empty,
		and then you can work on it. Once maintenence is node then node can be come up with "$ kubectl uncordon node-1", so now node is up and running but still its empty,
		then node is up, then all the resources which moved to other node will not come automatecly to that node, if that resource deleted and recreated then it will be on that node(node-1)
		
		there is another command "$ kubectl cordon node-2" which will make sure that no any other resource will scheduled for this node.
		so that we can drain the node and cordon, so will be empty and no other resource will be on that node.
		
		you cannot drain the node if there is pod which is not managed by replicas or deployment.
		because pod which is managed by replics or deployment can be easily created but, canot create indivusal pod, so cant drain that node.
		
		
	cluster upgrade: -
		
		As you know there are multiple component in k8s server, like api-server, controller-manager, kube-scheduler, kubelete, kube-proxy and kubectl,
		is it good to have the all component at same version, but cluster can manage the other version from other component, but from all those components, 
		only api-server is import part, because only api-server can talk with all other component in cluster, so api-server always at hight version than other components.
		
		you can update master node and worker nodes, you can take down the master node and upgrade, meanwhile other worker nodes will be accessable to user,
		just you cant change anything in those nodes, update, edit, create and delete on any service, if any pod deleted that will be deleted, untile master node is not up and running.
		
		once master node is up and running then we can upgrade worked nodes
		there are 3 strategys 
		1. all worker nodes will be down and upgraded, but user will face the downtime.
		2. upgrade one node at a time, while updating one node move resources to other node and upgrade that node.
		3. add new allreday upgraded node, then move resources from older node to new node then delete older node. repeat smae for all older nodes.
		
		steps: -
		$ k drain node01													# donw 
		$ k cordon node01													# unschedulable
		$ apt upgrade kubeadm=<version>										# upgrading  
		$ apt upgrade kubelete=<version>									# upgrading
		$ kubeadm upgrade node config --kubelet-version <version>			# upgrading
		$ systemctl restart kubelete										# up
		$ kubectl cordon node01												# scheduable
		
		do this same for all nodes and all nodes will be upgraded.
		
		lab is not done: -
		https://uklabs.kodekloud.com/topic/practice-test-cluster-upgrade-process-2/
		https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/18277588#overview
		
		
	Backup and restore: -
		you can take backup of all resources from whole cluster, run below command: -
		$ k get all --all-namespaces -o ymaml > config.yaml
		you will have all config saved in config.yaml file, if in case you lose cluster, due to some reason, you can re-create it with that file.
		also check about velero by HeptlO, this also help taking backup of resource which are not covered in config.yaml
		
		ETCD cluster backup: -
			stores the state of cluster, all the state and configuration of resources are store in ETCD cluster.
			you can take backup of etcd-cluster
			"$ etcdctl snapshot save snapshot.db"
			
			$ ls
			snapshot.db
			
			$ etcdctl snapshot status snapshot.db		
			+----------+----------+------------+------------------+------------------+
			|   HASH   |  REVISION| TOTAL KEYS |    TOTAL SIZE    |     VERSION      |
			+----------+----------+------------+------------------+------------------+
			| abc123...|   123456 |       7890 |         12.3 MB  |      3.5.0       |
			+----------+----------+------------+------------------+------------------+

			$ systemctl stop kube-apiserver
			Service kube-apiserver stopped
			
			$ etcdctl snapshot restore snapshot.db --data-dir /var/lib/etcd-from-Backup
			
			need to check more check here
			https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/14296066#overview
			https://uklabs.kodekloud.com/topic/practice-test-backup-and-restore-methods-2/
			
Security: -

	k8s security primitives: -
	
		where you are hosting the k8s cluster, that host much disabled root access and password based login, login should work only with ssh (keys). 
		
		When we access the k8s cluster, main part is API-server, so main line of defeance is api-server, we need to make sure that, who can access (TLS certificates) and what they do (RBACK) in cluster.	for accessing the cluster we should give only ssh key based access, no password or any other access.
		
	Authentation: -
	
		so kube-api-server can manage the access to user, if you run any command it will go to api-server then it will authentate 1st then process request. so we can allow or restrict the access to user, but we dont have something like user in k8s cluster, we do have service account, we can create service account insted and manage it as user, we can use ssh or some certification to process the authentation.
		
	TLS certificates: -
	
		pudhil explanation dobal manane ahe tari pan ekada verify karave: -
		why do we need certificate, if you are thinking just about the VM, then only VM are not there who reqiures the keys, there are servers and servicas which need the key too and the server we are considering those are not in your reach, you migh need to share to some company or client and those people will configure your key. now while you share the key to server or service or client they need security, that the key is authentated and secure so to do so, we use the certificate,	certifiacet have the info of who is owner of that key, the public key, the signed instutate, validity and may more info, by checing this certifate server manager or clinet get secutity that this key is authentate and suecure and trusted. If certificate is signed by some instutate then it is considered my many more client or serves if it signed by you then that certifiate will be considered by those who know you and trusts you.
		
		Now more about keys: -
		so while you are access any server your ID and password is sent to server and hacker can access credincianls through the network trafic, so it should be encrrypted. there are two differnet type of encryption
		
		Symmetric encryption: - 
			encryption happens with a key can decrypted with same key, so if server need to decrypt then key must need to sent, so again hacker got key and can encrypte your data. not safe 
		
		asymmetric encryption: - 
			so in this method we have public and private key, we need to configure the public key in server and can access through the private key,
			we must keep and protect the public key.
			
		so similer method used in certification,
		
		1st step private key: -
		$ openssl genrsa -out ashu-private-key.key 1024
		
		2nd step create public certification with private key using below command: -
		$ openssl rsa -in ashu-private-key.key -pubout > ashu-public-key.pem
		
		now you will think in all these process where crtification comes in play?
		so when key transfer happens from server to user and user to server, certificates also send with key, you certificat have all the details from where , who has sent,
		so you can check is the send is autherised or not.
		
		to generate your won cwerificate, we need to autherise the certificate, there are multiple instuate who do this job, so use below command: -
		$ openssl req -new -key ashu-private-key.key -out ashu-certificate.csr -subj "/C=US/ST=ca/O=MyOrg, Inc./CN=serve.com" 
		instuate will verify then they will sent it back to you as certified.
		Now how to send this certifiacet, with above command, you will get "ashu-certificate.csr" file and it has some text, so you have to pest that text on 
		there website so they will very and give it back to you, or you can send the .csr file as well.
 		
		So server have its own public and private keys called as "server certicate" and user have its own public and private keys called as "client certicatate",
		and the instuate who verity certicatate they also have certificate alled as "root certificate"
		
		public key extenion as .cer or .pem and private key can be .key or *.key.pem
		
		
		Create your own certificate: -
		$ openssl genrsa -out ashu-private-key.kay 2048 -> create private key 
		$ ls
		ashu-private-key.kay
		$ openssl req -new -key ashu-private-key.kay -subj "/CN=KUBERNETES-CA" -out ashu-certificate.csr -> Creating csr file for request, we can go to web and pest that csr and get signed. 
		$ ls
		ashu-certificate.csr
		# we have specified that we need sertificate for CN=KUBERNETES-CA (Common Name k8s certificate authentity) 
		$ openssl x509 -req -in ashu-certificate.csr -signkey ashu-private-key.kay -out ashu-certificate.csr -> we can sign it by ourself as well.
		Certificate request self-signature ok
		subject=CN = KUBERNETES-CA
		
		core difference between signing by a CA and self-signing a certificate.
		CA-signed certificate    = Trusted by others (like browsers, operating systems, or Kubernetes clusters).
		Self-signed certificate  = Only trusted by you or others mutual to you.
		
	View Certificate: -
		with below command
	
		"$ openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noount"
			Certificate:
				Data:
					Version: 3 (0x2)
					Serial Number: 6418292435937852215 (0x59125af704a6fb37)
					Signature Algorithm: sha256WithRSAEncryption
					Issuer: CN = kubernetes																 -> Issuer
					Validity
						Not Before: Oct 19 15:43:17 2025 GMT
						Not After : Oct 19 15:48:17 2026 GMT    										 -> expiry
					Subject: CN = kube-apiserver		       											 -> name
					Subject Public Key Info:
						Public Key Algorithm: rsaEncryption
							Public-Key: (2048 bit)
							Modulus:
								00:ba:59:c4:5d:d4:ae:07:c7:d6:53:0a:ed:5b:f4:
								1f:58:ca:9f:37:50:ac:c5:2c:63:51:4a:2d:a3:15:
								be:27:a3:9e:cb:18:93:9b:13:ee:af:2f:75:e9:72:
								1e:3e:4a:a8:03:38:ba:7d:76:3e:5b:85:b8:7c:01:
								0a:49:7c:f1:23:0b:5e:af:fa:af:73:8f:0f:df:3d:
								b3:8f:55:03:23:36:ca:e8:23:1e:d7:fb:a8:91:1f:
								4a:c6:fa:96:05:79:ae:4a:71:7d:76:00:54:3d:a3:
								df:3d:64:59:82:15:22:25:b1:ce:72:70:8e:4c:42:
								5e:1b:3b:53:c2:15:49:41:80:eb:4b:99:7b:e8:17:
								89:f2:78:32:27:2f:20:bb:58:a2:fa:d6:e1:ae:14:
								b4:6e:0b:b7:be:6a:9e:cc:92:a4:1b:d0:68:25:ab:
								68:be:3f:8b:3f:72:df:e0:c6:c9:d5:3d:02:9a:a7:
								f7:42:18:76:8e:41:90:e4:1a:e6:cd:57:98:7d:ea:
								10:aa:24:38:fc:55:2e:f1:c6:5a:4f:f8:b8:a4:ac:
								4a:88:bf:f6:01:18:87:8f:44:9e:6b:b5:19:ff:39:
								2e:eb:a1:ce:a6:d7:12:95:55:a3:d2:7a:8a:10:e8:
								8f:78:5c:58:59:23:78:ed:13:06:94:9d:dd:06:41:
								a9:17
							Exponent: 65537 (0x10001)
					X509v3 extensions:
						X509v3 Key Usage: critical
							Digital Signature, Key Encipherment
						X509v3 Extended Key Usage: 
							TLS Web Server Authentication
						X509v3 Basic Constraints: critical
							CA:FALSE
						X509v3 Authority Key Identifier: 
							54:B8:9B:1D:59:BB:A7:2D:79:2C:03:30:BA:C1:66:84:FD:C1:B3:84
						X509v3 Subject Alternative Name: 														-> Alternative Names
							DNS:controlplane, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, IP Address:10.96.0.1, IP Address:172.30.1.2
				Signature Algorithm: sha256WithRSAEncryption
				Signature Value:
		# it has many more data, but to check certificate you will need this data only.

		Docker will not work so use "crictl" insted of "docker"
		"$ crictl ps -a"
		

	CertificateSigningRequest: -

		Consider there is new teamemate in your project and you have to give admin lavel permission, sign his certificate, then you have to create certificate and sign 
		then that persion will get that authority.

		Follow below steps: -
		
		$ openssl genrsa -out my-user.key 2048
		$ ls
		my-user.key
		$ openssl req -new -key my-user.key -subj "/CN=my-user" -out my-user.csr
		$ ls
		my-user.csr  my-user.key
		$ cat my-user.csr | base64 -w 0
		LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1Z6Q0NBVDhDQVFBd0VqRVFNQTRHQTFVRUF3d0hiWGt0ZFhObGNqQ0NBU0l3RFFZSktvWklodmNOQVFFQgpCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFMK0VrSHZQd2tkdExEN2VoZXo0QWNoVWxnRTJ3QjdNWlVpdXR0ei9UaERiCkFseFhNNjFWdzRGalBqRDJ3cnFGSjlUQmFrK2RVVGNmZnZOUlR5Z3RSY1VXb2VUcHZNLzJoODRrZEk4UmxJeDEKR25YRndxclg4SGpudEhnRXB6UU9Kd0wyNlhKL3JJS3pka3ZIcDhqQVd5ZGxhT3hvOFdIcnNlbi8vSXpOWEp2dApORWZPay85Z2s5dXFtdVVGZVZtYlBFSDlnOW93dDJPOU0wcnBEN2wzOEZvWlNPbGczU25oTnZBTXhFUERSVXJzCjkwYStEQWI1NDE5L09PR3NRTkJIN1NOQWFYaEhEQitiYjZKczQyRWlKOStQNFB5NlY3aVM0UUFBaVZDR3hHMG0KcWdKWTFHNFZKK0hrYjFMV0MzKzRLT1BYd2hpL1VPWG81NmprSm5PNEo4RUNBd0VBQWFBQU1BMEdDU3FHU0liMwpEUUVCQ3dVQUE0SUJBUUN2MW1iQmJXWFpKRC9QZHdPSVcrckdHbHpBSERZc3g3YXpCbVFJZFJRS3pTQVNsK2FJCnFzWDF6MVd4ZDZrRjhTbldEeXo4TXUwK2poV2RVaHNyM2lTVHAwNFcraGY2bkdOVTRnV0x0eDM4WkRIK1dDc2cKUDRIamJNUE1EdHRWL0dmQXIwaytTb3lHU003WjZIYzgzTDJZM2JjQTZOd0d6a2RrYWxMSncydnRtSE5OYkx1dQp6ai96WEVocTE3b3RmUkJCZ0xMZUZwZ28ra1JkKzlCSjRldFVsN3E3cFdmWTRQQ3Z5Myt2YTUzbFFwRHNEOWE1CnQ5eG1MZHMycWFNT2xHUy9mNUxDZlhiK0kvVGt3ajdRTHhEK1E3M3pHdFpROHZNU243alRpbU5VNWhoOUxiZUsKbXdSNmMwdHFvdmRzbmg1MmF6SUJ3Q2lKSXZONVVUeHJxOGtZCi0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=controlplane:~$ vim user.yaml
		$ vim user.yaml
			apiVersion: certificates.k8s.io/v1
			kind: CertificateSigningRequest
			metadata:
			  name: my-user-csr
			spec:
			  request:
				LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1Z6Q0NBVDhDQVFBd0VqRVFNQTRHQTFVRUF3d0hiWGt0ZFhObGNqQ0NBU0l3RFFZSktvWklodmNOQVFFQgpCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFMK0VrSHZQd2tkdExEN2VoZXo0QWNoVWxnRTJ3QjdNWlVpdXR0ei9UaERiCkFseFhNNjFWdzRGalBqRDJ3cnFGSjlUQmFrK2RVVGNmZnZOUlR5Z3RSY1VXb2VUcHZNLzJoODRrZEk4UmxJeDEKR25YRndxclg4SGpudEhnRXB6UU9Kd0wyNlhKL3JJS3pka3ZIcDhqQVd5ZGxhT3hvOFdIcnNlbi8vSXpOWEp2dApORWZPay85Z2s5dXFtdVVGZVZtYlBFSDlnOW93dDJPOU0wcnBEN2wzOEZvWlNPbGczU25oTnZBTXhFUERSVXJzCjkwYStEQWI1NDE5L09PR3NRTkJIN1NOQWFYaEhEQitiYjZKczQyRWlKOStQNFB5NlY3aVM0UUFBaVZDR3hHMG0KcWdKWTFHNFZKK0hrYjFMV0MzKzRLT1BYd2hpL1VPWG81NmprSm5PNEo4RUNBd0VBQWFBQU1BMEdDU3FHU0liMwpEUUVCQ3dVQUE0SUJBUUN2MW1iQmJXWFpKRC9QZHdPSVcrckdHbHpBSERZc3g3YXpCbVFJZFJRS3pTQVNsK2FJCnFzWDF6MVd4ZDZrRjhTbldEeXo4TXUwK2poV2RVaHNyM2lTVHAwNFcraGY2bkdOVTRnV0x0eDM4WkRIK1dDc2cKUDRIamJNUE1EdHRWL0dmQXIwaytTb3lHU003WjZIYzgzTDJZM2JjQTZOd0d6a2RrYWxMSncydnRtSE5OYkx1dQp6ai96WEVocTE3b3RmUkJCZ0xMZUZwZ28ra1JkKzlCSjRldFVsN3E3cFdmWTRQQ3Z5Myt2YTUzbFFwRHNEOWE1CnQ5eG1MZHMycWFNT2xHUy9mNUxDZlhiK0kvVGt3ajdRTHhEK1E3M3pHdFpROHZNU243alRpbU5VNWhoOUxiZUsKbXdSNmMwdHFvdmRzbmg1MmF6SUJ3Q2lKSXZONVVUeHJxOGtZCi0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=   
			  signerName: kubernetes.io/kube-apiserver-client
			  usages:
			  - client auth
		$ kubectl create -f user.yaml 
		certificatesigningrequest.certificates.k8s.io/my-user-csr created
		$ kubectl get csr
		NAME          AGE   SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
		my-user-csr   13s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Pending
		$ kubectl certificate approve my-user-csr
		certificatesigningrequest.certificates.k8s.io/my-user-csr approved
		$ kubectl get csr
		NAME          AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
		my-user-csr   4m41s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
		$ kubectl get csr my-user-csr -o jsonpath='{.status.certificate}' | base64 --decode > my-user.crt  --> my-user.crt is signed certificate.
		controlplane:~$ ls
		filesystem  my-user.crt  my-user.csr  my-user.key  user.yaml
		$ cat my-user.crt
		-----BEGIN CERTIFICATE-----
		MIIC+DCCAeCgAwIBAgIRAKjuefUGVidU+GKhRkRqNRYwDQYJKoZIhvcNAQELBQAw
		FTETMBEGA1UEAxMKa3ViZXJuZXRlczAeFw0yNTExMDIwNTM4MzJaFw0yNjExMDIw
		NTM4MzJaMBIxEDAOBgNVBAMTB215LXVzZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
		DwAwggEKAoIBAQC/hJB7z8JHbSw+3oXs+AHIVJYBNsAezGVIrrbc/04Q2wJcVzOt
		VcOBYz4w9sK6hSfUwWpPnVE3H37zUU8oLUXFFqHk6bzP9ofOJHSPEZSMdRp1xcKq
		1/B457R4BKc0DicC9ulyf6yCs3ZLx6fIwFsnZWjsaPFh67Hp//yMzVyb7TRHzpP/
		YJPbqprlBXlZmzxB/YPaMLdjvTNK6Q+5d/BaGUjpYN0p4TbwDMRDw0VK7PdGvgwG
		+eNffzjhrEDQR+0jQGl4Rwwfm2+ibONhIiffj+D8ule4kuEAAIlQhsRtJqoCWNRu
		FSfh5G9S1gt/uCjj18IYv1Dl6Oeo5CZzuCfBAgMBAAGjRjBEMBMGA1UdJQQMMAoG
		CCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUVLibHVm7py15LAMw
		usFmhP3Bs4QwDQYJKoZIhvcNAQELBQADggEBAJrwGIu35CYyIwlpNENgTtrnKPTY
		KxOGKfiQX8K4vbupz/6q7TG41DyCXvq5WXSYZwDdOTVDMqW7vC6iUjZ3wUX2w4s4
		NY3OCyOD2QNtz97KEZNoaOFNmbRT+R0S0FfEGDHYN1cu00naRm0JlURsaUgrI9vs
		ZBEKQwfrwTI/+nxLO6Ra42wSEQ8BWwvIkwimrUCONhYNF9g5TvDNHNLsGV8EFKfH
		sf26TDuo6KD34E3v1PS6CpXEhXjY+5nCkgjoJB9psI7yo95Unt430iYZtIh02AEt
		unj9Qv4XoUXm0Und8Y1NyyqjXgN3uCIrgNK9tZDQmPLfUJmZKuRiCX/bY9k=
		-----END CERTIFICATE-----
		
		$ k certificate deny agent-smith
		certificatesigningrequest.certificates.k8s.io/agent-smith denied
		$ k get csr
		NAME          AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
		agent-smith   5m53s   kubernetes.io/kube-apiserver-client           agent-x                    <none>              Denied
		$ k delete csr agent-smith
		certificatesigningrequest.certificates.k8s.io "agent-smith" deleted
		
	kubeConfig: -
	
		when you work on live project there can be multiple cluster, each cluster has its own control plane and nodes that runs workloads.
		Now if you want to change the cluster then "kubeConfig" comes in play, you will get the config file at "/root/.kube/config"
		If you check that file, you will get the cluster, context and current-context, so context is basically conbination of user and cluster,
		context defines, which user will access which cluster, and "currect-context" is default context whic defines  default user to access 
		default cluster. you can change the context with command "kubectl config use-context <context-name>" it will not change the config file, 
		just configration.
		
		Single cluster file looks like this

		cat /root/.kube/config 
			apiVersion: v1
			clusters:
			- cluster:
				certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJREJwdzF0cFJWNmt3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1Ea3dOVEExTXpSYUZ3MHpOVEV4TURjd05URXdNelJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURDWlhLUk05TDBkcGtEaTU0b0prdldYK3dMNTBFbFJudmlvaGx0NHBibFVzd1JXWkgvSEw5NHFtUHYKT2ZZdVMzRmJIMlNteGJCZmFHVVJZbmFnMktpSnV0eUh5a0F2dnJ3ZXlzMGxaYWY3TkZUTjRGSm9hUzYyL1RnSAora3JJSlZKZXZiak5HSW5oSjJmSEtUcTBsWWRna1B1QUxxRXR6SG8xRmdtaXhxelNvWVhaQmZZSVJzL1RUVlhhCkVyNGhKc1ZxbUlldHdKSXlNWTBuZnlUWE1Wak8wdTE0RmRPenhmeEIxRVlpT0xRNnBkVExKSnVrMHpQekRZOXQKb1lISnY4RU9iUTQybjhOTkZsN2FINWNVb3BtOHZEWUdYWWVjZ0tqY3lJeGRaRDFBYmgzZWYzQmtIUDZKQ2hkQQpxdnJUTEFqVWZFTkh0alhHeFdqbWQ1T0RQcE9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJScGJUaVExQ2dIZ3VBL3g0VUJkdFR0QVZ3a2tqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2pQSkRNZkxHdwpJTExDY3FCVzFUVE53SWpNZXA4cjFCWDZjOTgvMHlWc2paZVZXVWJKanpNQVFDSmsvWUVpTzF5NkJUWnFKZjZsCjlCOUl4dG5Fbk5uVnVpdnp4TnVVVGtGeDJPY09zQ2JLa2FaRU44djBSZEc5U2ZIVitJbjRIZzlkcWFRYlN3dUoKblBSRTk1OGk5R0dLcVFyaFZQQnRDcEtta3BGUHZ5Z2hNMVpGTXpmdTgvbStZb3lnSmhYN3oza2YzS05FWnNMZgpQMHdoYlc4N1pjOHM0dUF2RXdSSGU3MzJUeWdmK1ptV2JJbFZxT2d6K09BNW5aTlNRT2tvUHVhR2d1NHIwMG5FCldIRkU0UTEweGk5dUVrY1dOUitoQnQ3b2RJMUxkaFcvc3k3bkFoTVAySm1CZ3EwaitjNzc1dmM1NkpCcnlOTEsKR1R4cjVET25TcDZuCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
				server: https://controlplane:6443
			  name: kubernetes
			contexts:
			- context:
				cluster: kubernetes
				user: kubernetes-admin
			  name: kubernetes-admin@kubernetes
			current-context: kubernetes-admin@kubernetes
			kind: Config
			users:
			- name: kubernetes-admin
			  user:
				client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJWjFPYURKN0h3QVF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1Ea3dOVEExTXpSYUZ3MHlOakV4TURrd05URXdNelJhTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFESDNURU0KRmlpVExmSklSd0R2UFJNbllsMWpFV0RxOVp5cjJyUjR5SE4wOUl0SHpBZ3V3ZVdCRS9TOTRIKzdyc09Zanlmagord0Z6cDI5cjhia2JLSFVLNlRpQ0NNN05Ub1UwOGdOTHdMdktXdng5UnY3TzV0L1lOWTJzZDdmZUU1SHhadDl4CnFnSXhZRmZiQmVDVW9wY1ZERHR0cjVDU0dtTTQrN3YrL1h3MXJjclluR2VSQnNIbWRpYWFPMG41UVZpOE9kQlgKYkRJMlZqV0N0NDZaNitaRVFGVzgyaGhGZXlOVlIxcU5rZnZ1a0FBbEp5bGFJWFNrQWhnTm9wRU5kQW5GWTc2QgpMU3ZxdElwcWhDK1ArOFRNV3Fma2lhQ1YzMHFyQ1RsSlRmeG92UFBwTFVjT3RibFp1RmM0YStqN1NKcnlBeWZCCk9JNzF5UXFsZDVRQTduVjFBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkdsdE9KRFVLQWVDNEQvSApoUUYyMU8wQlhDU1NNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUNuYjBuc0hWUlVHMnRXUloweWlzbFJnbTRRCjlkeWtaMERMU0ZnRlZrUHFtaG9MR1lQN3k5L2lhZnc3MmhtYldpbjdtNGZudFg5bUgxNTIyUTZOTi90bHdEY1UKNE1TcWIreTY2ZTlYYjNyckZjM2hqTDlHbVJBY0IreFM1MGViUGtxTnJJL2xkNWZPd08vbGZTRmRyeG5qNmxpSQpQWUk5Q25IdWRiNGhMUENqY2gzOXBsb25wakpscTdLdjJBVzJZbER4YnBzc1VxaEJDUkFKc1cxajBCZGpreTN2Cm5EMDBBZDB3RURxa3Voa3pNNUtEU1l0dzB1dUJRSmlUakxTS2YrTnpLdHIxTUZRVFJhTHd4WlNJazFpcHJ4V0YKZHBUUDhIL21Rak54cXQySCtYU1g3MkoydWZpRzlObWp6UkhSaVFlN0pmR3RHZWpUbWhmdGZIdHNHdUlNCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
				client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBeDkweERCWW9reTN5U0VjQTd6MFRKMkpkWXhGZzZ2V2NxOXEwZU1oemRQU0xSOHdJCkxzSGxnUlAwdmVCL3U2N0RtSThuNC9zQmM2ZHZhL0c1R3loMUN1azRnZ2pPelU2Rk5QSURTOEM3eWxyOGZVYisKenViZjJEV05ySGUzM2hPUjhXYmZjYW9DTVdCWDJ3WGdsS0tYRlF3N2JhK1FraHBqT1B1Ny92MThOYTNLMkp4bgprUWJCNW5ZbW1qdEorVUZZdkRuUVYyd3lObFkxZ3JlT21ldm1SRUJWdk5vWVJYc2pWVWRhalpINzdwQUFKU2NwCldpRjBwQUlZRGFLUkRYUUp4V08rZ1MwcjZyU0thb1F2ai92RXpGcW41SW1nbGQ5S3F3azVTVTM4YUx6ejZTMUgKRHJXNVdiaFhPR3ZvKzBpYThnTW53VGlPOWNrS3BYZVVBTzUxZFFJREFRQUJBb0lCQUJ2R0tKQzR3T2xqRXk0Kwp5bW5KOVBySXpVTFNkc053Q2xaS0l1dVRWT2diSzYwak5MMDZyaEszOFRvMGFTRVljam43SllkUVZGZjhHL0hHCk9sRUVndTlYT3ZFUnhFWDg5QlNkZW5QR2Z0SS9hVTJ5SzFWdXBBdHB0Y2NTZy9kVkw0elB4NXdHRE1sTHpYOEoKc1dIaERsbkZ4TG5EWjJCdys2VHBrVlhTdldEQUI4MFo2VFFqL3JRcnlveVRZMkJPelh6QW1tbHZHemR0TTR2bwpmbG0rSi9sZDVvSkFLSzR2OW9CcDYxcFo1bHZNb3Q0M1dJVkhTTmo3Y2oybVRFdnF1WS9aU3N6SVNUSmR2VXdyCjN4SjNqL0d4QXpPNXN6TWhJTDdFRnZaUEtka0RkUmZ6VGZzQTdjeDFTUU9MYUVsREdwcFczVzFQelBFRnNVbmwKcFVCR3lta0NnWUVBNDhhcjIycjRBeWgreW9ZdVdNTktsclRiQ29QK1lTWXYzZjMrQlZUR2VLaGJmY0lzNXpmSgowNUZWNGdKdWQ1VHZlNXM0T0I4NnRRTEsxaWRuNkI5WWlUYkt6RllEUHpkS2tyTmk2NGVWejF6OXNSMzcwWnllCkJHT2FjUVB0RFpEY3k3TDBPbzZkV2ZQZHVUcEEwejlCT3Z1Z1NFdG13bTh1Nng0UlVEQlNvNE1DZ1lFQTRLRWUKQ2RCc0JuUVFCUEs3eUd4cWNVWXVzU2U3a1RQa21GMER3WW5CaEdqWjRuTklwWnB5QytZdjZ0akNpZnI3d3A0UwpnZ014d2xibjB1bCtUNWZOV3I1TmlmQUNuQnBPQ1ZvSmJvRjB5ZkZqWXA2SjNhMzRJMHVnS3lFWWNidkpNcjNGCjVZMFRLTVZSNDlsYUpQMEVCamRMeGhBeXhNTmswY0M4R005YUdhY0NnWUJpcWRnZmYwSlcrOStRRW5kWTg1OEgKa09lZ3NuUXAyTVM3UUI0Y2FSQmZpMjIyRjdvam5jTEs1aFZ4aE9RYzRHS3NCQnhpRXdUM0MzS1pPUkNGTjY2KwpJUUhQYVNLVzYzaGQrMTVKNzcwd3lYTUttWlpPd2F5ZzhoUWdDRGRTdlFFbkt5a25oRWNjZzhuelJneDJkTnZvCmxMNWxFbVE4ckxTQ0c5QWNFQko3eVFLQmdDRU1VMGtLV3ZwUUZSTkZTdzlmdEFGYVhBQkFZajRvcmxja1NDc3YKUTBOaDBieVpUWFRmMWl1ZUFDckRIVXdEbXdxMUN2QUozRVpGVnZJVzNEaUZrdmJvekt1Z25pR3RWUkhYSjFBVQp4OFAyT2JNR3RDM2pMSUMwM2FtNndzZm80dDhPUUpGWFFoeGJlNExVTllqL21KbjVoTEp0SzZyN1BGZ0h6U1N4ClRRWTlBb0dBTDR2STVrTytKekNtOWdUZzFkUTQxZUxJd3RqTVRYQ1JQc3ZVcDVsWkxIaFB6OWw0RE04VUVrZTUKWHhzekVqMGhNeGZ3a0tFZEdMUEZSY3VEbmNOVkRwKzkvbG5XTWFGdTBLMUlpd3oySVg5ajVmZldvdVNFcGZETAp3R1NHK0VhbjE3RDJsOXJNRWVuMnNkRzhQbmpLRmZXRHMwNlNCQXpHOFRkY3FZYUVNdTA9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

		if you have your won config file and want to use that file as default one, then replace the /root/.kube/config file with your custome file.
		or add path in "~/.bashrc" as KUBECONFIG=/PATH/TO/YOUR-CONFIG
		Actual production project with multiple clusters config file looks like this 
	
		apiVersion: v1
		clusters:
		- cluster:
			certificate-authority: /etc/kubernetes/pki/ca.crt
			server: https://controlplane:6443
		  name: development
		- cluster:
			certificate-authority: /etc/kubernetes/pki/ca.crt
			server: https://controlplane:6443
		  name: kubernetes-on-aws
		- cluster:
			certificate-authority: /etc/kubernetes/pki/ca.crt
			server: https://controlplane:6443
		  name: production
		- cluster:
			certificate-authority: /etc/kubernetes/pki/ca.crt
			server: https://controlplane:6443
		  name: test-cluster-1
		contexts:
		- context:
			cluster: kubernetes-on-aws
			user: aws-user
		  name: aws-user@kubernetes-on-aws
		- context:
			cluster: test-cluster-1
			user: dev-user
		  name: research
		- context:
			cluster: development
			user: test-user
		  name: test-user@development
		- context:
			cluster: production
			user: test-user
		  name: test-user@production
		current-context: research
		kind: Config
		users:
		- name: aws-user
		  user:
			client-certificate: /etc/kubernetes/pki/users/aws-user/aws-user.crt
			client-key: /etc/kubernetes/pki/users/aws-user/aws-user.key
		- name: dev-user
		  user:
			client-certificate: /etc/kubernetes/pki/users/dev-user/developer-user.crt
			client-key: /etc/kubernetes/pki/users/dev-user/dev-user.key
		- name: test-user
		  user:
			client-certificate: /etc/kubernetes/pki/users/test-user/test-user.crt
			client-key: /etc/kubernetes/pki/users/test-user/test-user.key


		I would like to use the dev-user to access test-cluster-1. Set the current context to the right one so I can do that with 
		this command 
		"$  k config use-context research --kubeconfig my-kube-config"
				
		Kubectx:
			With this tool, you don't have to make use of lengthy “kubectl config” commands to switch between contexts. This tool is particularly useful to 
			switch context between clusters in a multi-cluster environment.

		Installation:
			sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
			sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

		To switch to a new context:
			kubectx <context_name>

		To switch back to previous context:
			kubectx -

		To see current context:
			kubectx -c

		
		Kubens:
			This tool allows users to switch between namespaces quickly with a simple command.

		Installation:
			sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
			sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

		To switch to a new namespace:
			kubens <new_namespace>
			
		To switch back to previous namespace:
			kubens -
		
	Role base access control (rback)
		Roles are use to autharised a access, like crerate role define what kind of permission you want to give to this role, then role-binding comes to play
		and you can bind that role to any user or group
		
		Role and role-binding created under the name-space 
		
		you can check which authration methods used in system, check "/etc/kubernetes/manifests/kube-apiserver.yaml" file, 
		check for "--authorization-mode"
	
		So everything in k8s get controlerd by api and api server, api server has its own prorities and api groups,
		and api groups containes multile kinds(pod, service like that), at the initial devepolment of k8s in 2006, there were not much kinds, 
		like pod, service configMap, those are stored in "api/v1" group or folder, but later as k8s grows they start adding the foldes as "apis/app/v1"
		so those are in "api/v1" group those called as core api group, you can check below table as well.
		
		| Type     | Example Path                         | Group                     | Version | YAML apiVersion                |
		| -------- | ------------------------------------ | ------------------------- | ------- | ------------------------------ |
		| Core     | `/api/v1`                            | `""` (empty)              | v1      | `v1`                           |
		| Non-core | `/apis/apps/v1`                      | apps                      | v1      | `apps/v1`                      |
		| Non-core | `/apis/batch/v1`                     | batch                     | v1      | `batch/v1`                     |
		| Non-core | `/apis/networking.k8s.io/v1`         | networking.k8s.io         | v1      | `networking.k8s.io/v1`         |
		| Non-core | `/apis/rbac.authorization.k8s.io/v1` | rbac.authorization.k8s.io | v1      | `rbac.authorization.k8s.io/v1` |

		/api/v1
		
			/api/v1/pods
			/api/v1/services
			/api/v1/configmaps
			/api/v1/secrets
			/api/v1/nodes
			/api/v1/namespaces
		
		/apis/apps/v1
		
			/apis/apps/v1/Deployment
			/apis/apps/v1/ReplicaSet
			/apis/apps/v1/DaemonSet
			/apis/apps/v1/StatefulSet
			/apis/apps/v1/ControllerRevision
		
		/apis/batch/v1
			every group has some resource, need to check
		/apis/networking.k8s.io/v1
		/apis/rbac.authorization.k8s.io/v1	

		so why this matters in RBACK, because when we create the role in yaml file, we need specifi the "apiGroup" and "resource", so to have 
		knowladge of apiGroup and resource is handy 
		
		apiVersion: rbac.authorization.k8s.io/v1
		kind: Role
		metadata:
		  namespace: default
		  name: pod-reader
		rules:								 		   	 -> its list you can add as much as you want 
		- apiGroups: [""]      							 -> we have to tell k8s that all resources from core group("" empty string means core group)
		  resources: ["pods"]   						 -> k8s has added all resources from core group, but which one to choose, so it will choose pod,
		  resourcesName: ["blue", "green"]				 -> k8s has added all the pods, which one to choose, so it will choose blue and green pods
		  verbs: ["get", "watch", "list", "update"]		 -> user can perform only this actions on pod 
		- apiGroups: ["apps"]							 -> Now we are telling use apiGroup as "apps", you can check above table to what comes under the "apps"
		  resources: ["deployments"]					 -> work on Deployment from app
		  verbs: ["get", "list", "watch"]

		"$ k get role"
		No resources found in default namespace.
		
		"$ k get role -A"
		NAMESPACE     NAME                                             CREATED AT
		blue          developer                                        2025-11-10T05:15:05Z
		kube-public   kubeadm:bootstrap-signer-clusterinfo             2025-11-10T05:04:50Z
		kube-public   system:controller:bootstrap-signer               2025-11-10T05:04:50Z
		kube-system   extension-apiserver-authentication-reader        2025-11-10T05:04:50Z
		kube-system   kube-proxy                                       2025-11-10T05:04:51Z
		kube-system   kubeadm:kubelet-config                           2025-11-10T05:04:50Z
		kube-system   kubeadm:nodes-kubeadm-config                     2025-11-10T05:04:50Z
		kube-system   system::leader-locking-kube-controller-manager   2025-11-10T05:04:50Z
		kube-system   system::leader-locking-kube-scheduler            2025-11-10T05:04:50Z
		kube-system   system:controller:bootstrap-signer               2025-11-10T05:04:50Z
		kube-system   system:controller:cloud-provider                 2025-11-10T05:04:50Z
		kube-system   system:controller:token-cleaner                  2025-11-10T05:04:50Z
	
		"$ k describe role kube-proxy -n kube-system"
		Name:         kube-proxy
		Labels:       <none>
		Annotations:  <none>
		PolicyRule:
		  Resources   Non-Resource URLs  Resource Names  Verbs
		  ---------   -----------------  --------------  -----
		  configmaps  []                 [kube-proxy]    [get]
	
	RoleBinding
		
		apiVersion: rbac.authorization.k8s.io/v1
		kind: RoleBinding
		metadata:
		  name: read-pods
		  namespace: default
		subjects:
		- kind: User											-> who is user, so nned to mention in name.
		  name: jane 											-> tell kind to use user as jane (case sencative)
		  apiGroup: rbac.authorization.k8s.io					-> where to find this user, in "rbac.authorization.k8s.io"
		roleRef:
		  kind: Role 											-> what we are looking for, so we are looking for role
		  name: pod-reader 										-> what is name of role, so its a pod-reader (this must match the name of the Role or ClusterRole you wish to bind to
		  apiGroup: rbac.authorization.k8s.io
		
		"$ kubectl get rolebinding"
		
		you can check if you have acccess or not, with bewlo Command
		"$ kubectl auth can-i create deployment"
		"$ kubectl auth can-i delete nodes"
		"$ kubectl auth can-i create deployment --as aws-user"
		"$ kubectl auth can-i delete pod --as dev-user --namespace test"
		
		
		Role: -
		"$ cat dev-user-role.yaml" 
			apiVersion: rbac.authorization.k8s.io/v1
			kind: Role
			metadata:
			  namespace: default
			  name: developer
			rules:
			- apiGroups: [""]
			  resources: ["pods"]
			  verbs: ["delete", "create", "list"]

		"$ k create -f dev-user-role.yaml" 
		role.rbac.authorization.k8s.io/developer created
			
		RoleBinding: -
		"$ cat dev-user-role-binding.yaml" 
			apiVersion: rbac.authorization.k8s.io/v1
			kind: RoleBinding
			metadata:
			  name: dev-user-binding
			  namespace: default
			subjects:
			- kind: User
			  name: dev-user # "name" is case sensitive
			  apiGroup: rbac.authorization.k8s.io
			roleRef:
			  kind: Role #this must be Role or ClusterRole
			  name: developer # this must match the name of the Role or ClusterRole you wish to bind to
			  apiGroup: rbac.authorization.k8s.io

		"$ k create -f dev-user-role-binding.yaml" 
		rolebinding.rbac.authorization.k8s.io/dev-user-binding created

		"$ k get role"
		NAME         CREATED AT
		developer    2025-11-10T05:36:36Z

		"$ k get rolebinding"
		NAME               ROLE             AGE
		dev-user-binding   Role/developer   34s

	Cluster Role: -
		
		Exactly same as role and role binding, just opperate at cluster lavel, Cluster role can be operated at namespce level, but not vice versa,
		If you create ClusterRole and mention pod and bind to user then you are giving access to pod through out the cluster.
		
		Node. PV cluster-role, cluster-role-binding, certificate-signing-request, namescpaes are comes under the cluster scope.
		Role and RoleBinding can be used for namespace lavel only, but for the cluster scope we need to use Cluser Role and Cluser role binding.
		to get all the resoruces from cluster scope you can use "$ k api-resources --namespaced=false" command
	
		$ k api-resources --namespaced=false
			NAME                                SHORTNAMES   APIVERSION                        NAMESPACED   KIND
			componentstatuses                   cs           v1                                false        ComponentStatus
			namespaces                          ns           v1                                false        Namespace
			nodes                               no           v1                                false        Node
			persistentvolumes                   pv           v1                                false        PersistentVolume
			mutatingwebhookconfigurations                    admissionregistration.k8s.io/v1   false        MutatingWebhookConfiguration
			validatingadmissionpolicies                      admissionregistration.k8s.io/v1   false        ValidatingAdmissionPolicy
			validatingadmissionpolicybindings                admissionregistration.k8s.io/v1   false        ValidatingAdmissionPolicyBinding
			validatingwebhookconfigurations                  admissionregistration.k8s.io/v1   false        ValidatingWebhookConfiguration
			customresourcedefinitions           crd,crds     apiextensions.k8s.io/v1           false        CustomResourceDefinition
			apiservices                                      apiregistration.k8s.io/v1         false        APIService
			selfsubjectreviews                               authentication.k8s.io/v1          false        SelfSubjectReview
			tokenreviews                                     authentication.k8s.io/v1          false        TokenReview
			selfsubjectaccessreviews                         authorization.k8s.io/v1           false        SelfSubjectAccessReview
			selfsubjectrulesreviews                          authorization.k8s.io/v1           false        SelfSubjectRulesReview
			subjectaccessreviews                             authorization.k8s.io/v1           false        SubjectAccessReview
			certificatesigningrequests          csr          certificates.k8s.io/v1            false        CertificateSigningRequest
			bgpconfigurations                                crd.projectcalico.org/v1          false        BGPConfiguration
			bgppeers                                         crd.projectcalico.org/v1          false        BGPPeer
			blockaffinities                                  crd.projectcalico.org/v1          false        BlockAffinity
			caliconodestatuses                               crd.projectcalico.org/v1          false        CalicoNodeStatus
			clusterinformations                              crd.projectcalico.org/v1          false        ClusterInformation
			felixconfigurations                              crd.projectcalico.org/v1          false        FelixConfiguration
			globalnetworkpolicies                            crd.projectcalico.org/v1          false        GlobalNetworkPolicy
			globalnetworksets                                crd.projectcalico.org/v1          false        GlobalNetworkSet
			hostendpoints                                    crd.projectcalico.org/v1          false        HostEndpoint
			ipamblocks                                       crd.projectcalico.org/v1          false        IPAMBlock
			ipamconfigs                                      crd.projectcalico.org/v1          false        IPAMConfig
			ipamhandles                                      crd.projectcalico.org/v1          false        IPAMHandle
			ippools                                          crd.projectcalico.org/v1          false        IPPool
			ipreservations                                   crd.projectcalico.org/v1          false        IPReservation
			kubecontrollersconfigurations                    crd.projectcalico.org/v1          false        KubeControllersConfiguration
			flowschemas                                      flowcontrol.apiserver.k8s.io/v1   false        FlowSchema
			prioritylevelconfigurations                      flowcontrol.apiserver.k8s.io/v1   false        PriorityLevelConfiguration
			ingressclasses                                   networking.k8s.io/v1              false        IngressClass
			ipaddresses                         ip           networking.k8s.io/v1              false        IPAddress
			servicecidrs                                     networking.k8s.io/v1              false        ServiceCIDR
			runtimeclasses                                   node.k8s.io/v1                    false        RuntimeClass
			clusterrolebindings                              rbac.authorization.k8s.io/v1      false        ClusterRoleBinding
			clusterroles                                     rbac.authorization.k8s.io/v1      false        ClusterRole
			deviceclasses                                    resource.k8s.io/v1                false        DeviceClass
			resourceslices                                   resource.k8s.io/v1                false        ResourceSlice
			priorityclasses                     pc           scheduling.k8s.io/v1              false        PriorityClass
			csidrivers                                       storage.k8s.io/v1                 false        CSIDriver
			csinodes                                         storage.k8s.io/v1                 false        CSINode
			storageclasses                      sc           storage.k8s.io/v1                 false        StorageClass
			volumeattachments                                storage.k8s.io/v1                 false        VolumeAttachment
			volumeattributesclasses             vac          storage.k8s.io/v1                 false        VolumeAttributesClass
			

	ClusterRole: -
		apiVersion: rbac.authorization.k8s.io/v1
		kind: ClusterRole
		metadata:
		  name: reader
		rules:
		- apiGroups: [""]
		  resources: ["ndoe"]
		  verbs: ["get", "watch", "list"]

	ClusterRoleBinding: -
		apiVersion: rbac.authorization.k8s.io/v1
		kind: ClusterRoleBinding
		metadata:
		  name: read-global
		subjects:
		- kind: user
		  name: maga # Name is case sensitive
		  apiGroup: rbac.authorization.k8s.io
		roleRef:
		  kind: ClusterRole
		  name: reader
		  apiGroup: rbac.authorization.k8s.io



		Similar to the namespace roles as we saw above, we have core-group here as well


		| Type         | Example Path                            | Group                          | Version | YAML `apiVersion`                 | Example Kinds / Resources                                          |
		| ------------ | --------------------------------------- | ------------------------------ | ------- | --------------------------------- | ------------------------------------------------------------------ |
		| **Core**     | `/api/v1`                               | `""` (empty)                   | v1      | `v1`                              | `nodes`, `namespaces`, `persistentvolumes`, `componentstatuses`    |
		| **Non-core** | `/apis/apiextensions.k8s.io/v1`         | `apiextensions.k8s.io`         | v1      | `apiextensions.k8s.io/v1`         | `customresourcedefinitions (CRDs)`                                 |
		| **Non-core** | `/apis/apiregistration.k8s.io/v1`       | `apiregistration.k8s.io`       | v1      | `apiregistration.k8s.io/v1`       | `apiservices`                                                      |
		| **Non-core** | `/apis/admissionregistration.k8s.io/v1` | `admissionregistration.k8s.io` | v1      | `admissionregistration.k8s.io/v1` | `mutatingwebhookconfigurations`, `validatingwebhookconfigurations` |
		| **Non-core** | `/apis/authentication.k8s.io/v1`        | `authentication.k8s.io`        | v1      | `authentication.k8s.io/v1`        | (mostly cluster-wide authentication APIs, e.g. token reviews)      |
		| **Non-core** | `/apis/authorization.k8s.io/v1`         | `authorization.k8s.io`         | v1      | `authorization.k8s.io/v1`         | `subjectaccessreviews`, `selfsubjectaccessreviews`                 |
		| **Non-core** | `/apis/certificates.k8s.io/v1`          | `certificates.k8s.io`          | v1      | `certificates.k8s.io/v1`          | `certificatesigningrequests (CSRs)`                                |
		| **Non-core** | `/apis/rbac.authorization.k8s.io/v1`    | `rbac.authorization.k8s.io`    | v1      | `rbac.authorization.k8s.io/v1`    | `clusterroles`, `clusterrolebindings`                              |
		| **Non-core** | `/apis/storage.k8s.io/v1`               | `storage.k8s.io`               | v1      | `storage.k8s.io/v1`               | `storageclasses`, `volumeattachments`, `csinodes`, `csidrivers`    |
		| **Non-core** | `/apis/node.k8s.io/v1`                  | `node.k8s.io`                  | v1      | `node.k8s.io/v1`                  | `runtimeclasses`                                                   |
		| **Non-core** | `/apis/policy/v1`                       | `policy`                       | v1      | `policy/v1`                       | (no cluster-scoped resources; PSP deprecated)                      |
		| **Non-core** | `/apis/flowcontrol.apiserver.k8s.io/v1` | `flowcontrol.apiserver.k8s.io` | v1      | `flowcontrol.apiserver.k8s.io/v1` | `flowschemas`, `prioritylevelconfigurations`                       |

	Service account: -
		
		while k8s works, pods and services talk and access to each other, while talking, they need to autherise each other, for that Service account comes in play.
		service account provides the token to each pod and service, and get configured with each other, so thay can autheris each other.
		Service accoutn can create the token CA and NS info and store it in "/var/run/secrets/kubernetes.io/serviceaccount/" location on pod.
 	
		$ k get sa
		NAME      SECRETS   AGE
		default   0         4m29s
		dev       0         22s

		$ k describe sa default 
		Name:                default
		Namespace:           default
		Labels:              <none>
		Annotations:         <none>
		Image pull secrets:  <none>
		Mountable secrets:   <none>
		Tokens:              <none>
		Events:              <none>

		$ k create sa dashboard-sa
		serviceaccount/dashboard-sa created

		$ k create token dashboard-sa
		eyJhbGciOiJSUzI1NiIsImtpZCI6IkRUNTI0U3NCRmpQZDZwZmFzb1RBLXdwNmxndDVlN2dNektVamotd2RxaVEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiLCJrM3MiXSwiZXhwIjoxNzYyODcwNjUxLCJpYXQiOjE3NjI4NjcwNTEsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiYzBhMTAyYTgtZjdlZi00ZWI2LTgzY2YtMTQ0MDAxYzUwOGY4Iiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0Iiwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImRhc2hib2FyZC1zYSIsInVpZCI6IjhhMWI0MzYwLTQwOTQtNDZlNC05MmM1LTgxY2NmMzZmZDUzZSJ9fSwibmJmIjoxNzYyODY3MDUxLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpkYXNoYm9hcmQtc2EifQ.VGV8TNeof4iwVxqu5VbvMsCRJB3GYHDp7tWytl9jLIbPWWC6Xz4LUQDs5H8DRW0Wj5m91D27sQWLodslgX9oxoI2W-7V7MYINTVyaeS6LWknw8dHIOkIEpMVitCVCOSAyKKgLqiE9qRsPgLpjaIuwNVevmHtHy5ZtC8gkRosOmgUucA9ZsOtIH2G4ANLNFgY5dzqftax0BkytHSfRIPKcGLs10rCNeLO2T0qsYJyDB0Y9KimphP98vhhFejbaL583GSw9PVIH4zdHf_nDm2NmdCrf3O21IM85RCNIFob41MpXYD9APPKh04Gt0rY_AmP2EznsLTwAjTduJpX0rc9Uw
	
		"$ k create serviceaccount dashbord"
		serviceaccount/dashbord created
		
		"$ cat service-account.yaml"
			apiVersion: v1
			kind: ServiceAccount
			metadata:
			  name: dashbord-yaml-file
			  namespace: default

		"$ k create -f service-account.yaml" 
		serviceaccount/dashbord-yaml-file created

		"$ k get serviceaccount"
		NAME                 SECRETS   AGE
		dashbord             0         2m6s
		dashbord-yaml-file   0         14s
		default              0         22d
		
		"$ k describe serviceaccount dashbord-yaml-file"
		Name:                dashbord-yaml-file
		Namespace:           default
		Labels:              <none>
		Annotations:         <none>
		Image pull secrets:  <none>
		Mountable secrets:   <none>
		Tokens:              <none>
		Events:              <none>
		
		$ cat pod.yaml 
			apiVersion: v1
			kind: Pod
			metadata:
			  labels:
				run: nginx
			  name: nginx
			spec:
			  containers:
			  - image: nginx
				name: nginx
			  serviceAccountName: dashbord									-> we can use service account like this
		  
		$ k describe pod/nginx
			Name:             nginx
			Namespace:        default
			Priority:         0
			Service Account:  dashbord											-> check here
			Node:             node01/172.30.2.2
			Start Time:       Tue, 11 Nov 2025 10:23:33 +0000
			Labels:           run=nginx
			Annotations:      cni.projectcalico.org/containerID: 3954a69f8aa19604e5e5e4092cee74ad617b36ae00a1e3e8a0978d35de582525
							  cni.projectcalico.org/podIP: 192.168.1.4/32
							  cni.projectcalico.org/podIPs: 192.168.1.4/32
			Status:           Running
			IP:               192.168.1.4
			IPs:
			  IP:  192.168.1.4
			Containers:
			  nginx:
				Container ID:   containerd://470639456cfbc2128bc9d651266d801e7741e849f388882f06e0114c2410f0f0
				Image:          nginx
				Image ID:       docker.io/library/nginx@sha256:1beed3ca46acebe9d3fb62e9067f03d05d5bfa97a00f30938a0a3580563272ad
				Port:           <none>
				Host Port:      <none>
				State:          Running
				  Started:      Tue, 11 Nov 2025 10:23:45 +0000
				Ready:          True
				Restart Count:  0
				Environment:    <none>
				Mounts:
				  /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-csjxx (ro)
			  
	Docker image security: -
		If you want to use private repo from docekrhub, then we need to use credentails, rigth?
		then you need to create the secret 
		
		"$ kubectl create secret docker-registry regcred --docker-server=<your-registry-server> \
														 --docker-username=<your-name> \ 
														 --docker-password=<your-pword> \
														 --docker-email=<your-email>"
		
		and then you can use imagePullSecret with that secret in pod defination file,
		
		apiVersion: v1
		kind: Pod
		metadata:
		  labels:
			run: nginx
		  name: nginx
		spec:
		  containers:
		  - image: nginx
			name: nginx
		  imagePullSecret:
			- regcred										-> here
			
			
	Security in Docker: -
		So there is one file in every linux machine "/usr/include/linux/capability.h", which defines how many capability has to user, like what he can do on this machine,
		so wehn you create the docker container, that time limited capability are added to container, if you want fill capability, then we use --privilaged flag, so that 
		all the capability added to docekr container.
		
		
		We are running the "ubuntu-sleeper" pod as user who as userID as 1010, yaml file as belwo

			apiVersion: v1
			kind: Pod
			metadata:
			  creationTimestamp: "2025-11-13T13:54:50Z"
			  generation: 1
			  name: ubuntu-sleeper
			  namespace: default
			  resourceVersion: "784"
			  uid: 6ee16b3d-3032-4d33-9c48-ec6d5a4aaaed
			spec:
			  securityContext:
				runAsUser: 1010
			  containers:
			  - command:
				- sleep
				- "4800"
				image: ubuntu
				imagePullPolicy: Always
				name: ubuntu			
				
		we are running the "multi-pod" pod as user who has "1002" userID,
		but the "sidecar" container will be run as user "1001"
			apiVersion: v1
			kind: Pod
			metadata:
			  name: multi-pod
			spec:
			  securityContext:
				runAsUser: 1001
				capabilities:
				  add: ["NET_ADMIN", "SYS_TIME"]              Adding the capabilities
			  containers:
			  -  image: ubuntu									1002
				 name: web
				 command: ["sleep", "5000"]
				 securityContext:
				  runAsUser: 1002

			  -  image: ubuntu									1001
				 name: sidecar
				 command: ["sleep", "5000"]
				 
	Networking policy: -
		
		how any user access any website as bewlow.
		
		user -----> frountEnd -----> API -----> dataBase -----> API -----> frountEnd -----> user.
		   request          request    request          result     result           result

					
		 -----> frountEnd ----->              -----> API ----->
		ingress           Egress             ingress     Egress
		trafic            trafic             trafic      trafic
		
		Basically in-comming trafic is Ingress trafic and out-going traffic is Egress trafic.
		
		
		In k8s-cluster every resource can talk to any other resource in default setting, but now you want to limit that talking, like which resource talk to which resource
		we can limit using network policy
		
		apiVersion: networking.k8s.io/v1
		kind: NetworkPolicy
		metadata:
		  name: test-network-policy
		  namespace: default
		spec:
		  podSelector:
			matchLabels:
			  name: db					-> name of pod	on which newtwork policy get applied	
		  policyTypes:
		  - Ingress
		  ingress:						ingress always start with "from" and egress alwas start with "to"
		  - from:						-> from 
			- podSelector:
				matchLabels:
				  role: frontend
			ports:
			- protocol: TCP
			  port: 6379


			Check the above yaml file, we are apply the NetworkPolicy to pod db, and making sure that trafic come to db frome only from frontend pod and its 6379 port only (this port is db pods port).
			
		
		apiVersion: networking.k8s.io/v1
		kind: NetworkPolicy
		metadata:
		  name: test-network-policy
		  namespace: default
		spec:
		  podSelector:
			matchLabels:
			  role: db
		  policyTypes:
		  - Egress
		  egress:					ingress alwas start with "from" and egress alwas start with "to"
		  - to:						-> to
			- ipBlock:
				cidr: 10.0.0.0/24
			ports:
			- protocol: TCP	
			  port: 5978
			  
		Now check the above yaml now we are limiting the trafic to go only to mentioned IPs through port 5978 (this port is from db pod).
		the pod db will send trafic to that only no any other out going.
		
		Now consider there are multiple pods with same labes on differnet namespace, with default k8s setting (all resource talk to all resources), so 
		the pods with with same labes in different namespace will send trafic to our pod.
		
		we dont want that, to handel we can mention namespaceSelector
		
		apiVersion: networking.k8s.io/v1
		kind: NetworkPolicy
		metadata:
		  name: test-network-policy
		  namespace: default
		spec:
		  podSelector:
			matchLabels:
			  role: db
		  policyTypes:
		  - Ingress
		  ingress:
		  - from:
			- podSelector:
				matchLabels:
				  role: frontend
			  namespaceSelector: 
				matchLabels:
				  kubernetes.io/metadata.name: <namespace name>    --> this will make sure to select the pod from mentioned namespace only.
			ports:
			- protocol: TCP
			  port: 6379


		Now if you do this, this will allow trafaic from whole name space and also with matching lables pod, all resources from namespace and marching pods from all resources.

		  policyTypes:
		  - Ingress
		  ingress:
		  - from:
			- podSelector:
				matchLabels:
				  role: frontend
			- namespaceSelector: 
				matchLabels:
				  kubernetes.io/metadata.name: <namespace name>


		$ k get networkpolicy
		NAME             POD-SELECTOR   AGE
		payroll-policy   name=payroll   26s

		$ k describe networkpolicy payroll-policy
		Name:         payroll-policy
		Namespace:    default
		Created on:   2025-11-14 05:41:37 +0000 UTC
		Labels:       <none>
		Annotations:  <none>
		Spec:
		  PodSelector:     name=payroll
		  Allowing ingress traffic:
			To Port: 8080/TCP
			From:
			  PodSelector: name=internal
		  Not affecting egress traffic
		  Policy Types: Ingress
		  


		Create a network policy to allow egress traffic from the Internal application only to the payroll-service and db-service.
		Use the spec given below. You might want to enable ingress traffic to the pod to test your rules in the UI.
		Also, ensure that you allow egress traffic to DNS ports TCP and UDP (port 53) to enable DNS resolution from the internal pod.

		Policy Name: internal-policy
		Policy Type: Egress
		Egress Allow: payroll
		Payroll Port: 8080
		Egress Allow: mysql
		MySQL Port: 3306


		$ cat network.yaml 
			apiVersion: networking.k8s.io/v1
			kind: NetworkPolicy
			metadata:
			  name: internal-policy
			  namespace: default
			spec:
			  podSelector:
				matchLabels:
				  name: internal
			  policyTypes:
			  - Egress
			  egress:
			  - to:
				- podSelector:
					matchLabels:
					  name: payroll
				ports:
				- protocol: TCP
				  port: 8080
			  - to:
				- podSelector:
					matchLabels:
					  name: mysql
				ports:
				- protocol: TCP
				  port: 3306
				  
		$ k create -f network.yaml 
		networkpolicy.networking.k8s.io/internal-policy created
		
	Custome Resoure Defination and custome controller : -
		need to check, https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/48273217#overview check here 
		or check official docs
		
		
Docker storage: -

	✔ Storage driver
	Handles Docker’s internal storage (deails with dockers storage)
	Manages image layers + container writable layer
	Data is inside Docker, not on the host as normal files
	Not persistent → deleted when container is removed

	✔ Volume driver (deails with contaiern and host volume)
	Handles the persistent storage that containers use
	Manages volumes stored on the host (or remote storage)
	Data is outside the container’s internal filesystem\
	Persistent → survives container delete 

	when you create the Dockerfile and build it, docker treate the evey stage as layer and precess one by one
	consider you have 2 different Dockerfiles, and only last two lines are different and all the above file is same, and one you have build all ready and another one have To
	build, then docker only build last two different commands and will get all data from cashe of previous build.
	
	Volumes: -
		$ docker volume create ashu
		ashu

		$ ls /var/lib/docker/               
		buildkit  containers  engine-id  image  network  overlay2  plugins  runtimes  swarm  tmp  volumes

		$ ls /var/lib/docker/volumes/
		ashu  backingFsBlockDev  metadata.db

		$ ls /var/lib/docker/volumes/ashu/
		_data

		$ ls /var/lib/docker/volumes/ashu/_data/

		$ ls -la /var/lib/docker/volumes/ashu/_data/
		total 8
		drwxr-xr-x 2 root root 4096 Nov 17 14:21 .
		drwx-----x 3 root root 4096 Nov 17 14:21 ..
		
		
		you can use this dir with -v option 
		$ docker run -v ashu:/var/lib/ nginx		
		then all the files and folder from that dir will get mounted on container, aslo if you create the file in that folder on container, that file 
		will be replicated on host machine, so even if contianer gone you will have the file.
		$ docker run -v ashu_no:/var/lib/ nginx
		If ashu_no dose not exeist on host docker will automaticelly create foler in volumes.
		If you dont want to use default path then then just mention full path in docker command its calls bind mount, and the method with default path called as volume mount.
		
		you can use --mount option as well, symtem as belwo
		--mount type=<bind>/<mount>,source=<host path>,target=<mcontainer path>
		
		Volumes in k8s 
			apiVersion: v1
			kind: Pod
			metadata:
			  name: hostpath-demo-pod
			spec:
			  containers:
				- name: my-container
				  image: busybox
				  command: ["sleep", "3600"]
				  volumeMounts:
					- name: mydata
					  mountPath: /app/data   # TARGET inside container
			  volumes:						 # we can use use it from cloud storage as well, need to check.
				- name: mydata
				  hostPath:
					path: /home/ubuntu/data  # SOURCE on host
					type: Directory

	Persistent Volumes: -
		Now consider you are on live project and every person need volume to mount, so insated of mounting the each user indivualy, admistrator can create the 
		persistent volume so indivual user and whole team can access that PV, so no need to create seperat volume mount every time.
		
		apiVersion: v1
		kind: PersistentVolume
		metadata:
		  name: ashu-pv
		spec:
		  capacity:
			storage: 5Gi
		  hostPath:
			path: /user/
		  accessModes:
			- ReadWriteOnce


		$ k create -f pv.yaml 
		persistentvolume/ashu-pv created

		$ k get pv
		NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
		ashu-pv   5Gi        RWO            Retain           Available                          <unset>                          5s

	Persistent Volumes claim: -
		PCV is like claimig the volume from existing volume, is might be from PV, if you dont specify PV then k8s will create PV automaticely on the bases of 
		storage class.
	
		apiVersion: v1
		kind: PersistentVolumeClaim
		metadata:
		  name: myclaim
		spec:
		  accessModes:
			- ReadWriteOnce
		  resources:
			requests:
			  storage: 1Gi


		apiVersion: v1
		kind: PersistentVolumeClaim
		metadata:
		  name: foo-pvc
		  namespace: foo
		spec:
		  storageClassName: "" # Empty string must be explicitly set otherwise default StorageClass will be set
		  volumeName: foo-pv


	Use PVC in pod 

		apiVersion: v1
		kind: Pod
		metadata:
		  name: mypod
		spec:
		  containers:
			- name: myfrontend
			  image: nginx
			  volumeMounts:
			  - mountPath: "/var/www/html"
				name: mypd
		  volumes:
			- name: mypd
			  persistentVolumeClaim:
				claimName: myclaim


	storage class: - (need to check) https://ibm-learning.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/learn/lecture/21795216#overview
		What is the name of the Storage Class that does not support dynamic volume provisioning?
		
		k get sc
		NAME                        PROVISIONER                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
		local-path (default)        rancher.io/local-path           Delete          WaitForFirstConsumer   false                  4m52s
		local-storage               kubernetes.io/no-provisioner    Delete          WaitForFirstConsumer   false                  4s
		portworx-io-priority-high   kubernetes.io/portworx-volume   Delete          Immediate              false                  4s
		
		hint
		Look for the storage class name that uses no-provisioner
		
		solution 
		The local-storage storage class makes use of the no-provisioner and currently does not support dynamic provisioning.
		Refer to the tab above the terminal (called Local Storage) to read more about it.
		
Networking: - (not understand much, becasue dont have much knoladge on networking, need to check networking)
	Switch 
		A switch is a physical device that connects multiple machines and forwards data to the correct machine based on MAC addresses.
		connect both machine at eth0 to switch and switch will take care of data transfer, and congrats you have created the small network.
		
	Routing: -
		A Router is a physical device that connects multiple networks to each other, also router is shared in multiple networs it as ips as per networks
		each netwokr assinge one ip to router, so one router can have multiple IPs
		
		
	Switch:
		A switch is a networking device that connects multiple devices within the same local network (like computers, printers, or servers in a home 
		or office). It uses MAC addresses to send data only to the specific device it’s meant for, making communication fast and efficient. Switches 
		operate at the data link layer and help create a smooth internal network where devices can easily share information.

	Router:
		A router connects multiple networks together, most commonly linking your local home or office network to the internet. It uses IP addresses to 
		determine the best path for data to travel across networks. Routers manage traffic between networks, assign IP addresses, and often include 
		extra features like firewalls or Wi-Fi, ensuring secure and organized communication.

	Gateway:
		A gateway acts as a bridge between two different networks that may use different protocols or architectures. It translates data from one 
		format to another so devices on one network can communicate with devices on another. Gateways are often found at network edges, enabling 
		communication between incompatible systems, such as connecting a company’s internal network to an external service or cloud platform.
		
		
	Diff in Router and Gateway

	Here’s the difference between a router and a gateway in simple terms:
	Router
		A router connects similar types of networks (for example, your home network to the internet). It mainly uses IP addresses to route data 
		between networks. Routers decide the best path for data to travel and handle traffic between connected networks.
	Gateway
		A gateway connects different or incompatible networks (for example, a network using one protocol to another using a different protocol). 
		It translates data formats, protocols, or architectures so devices on each network can communicate. A gateway is more complex than a router 
		because it performs conversion in addition to routing.

	In short:
	Router = connects similar networks + routes data.
	Gateway = connects different networks + converts data.

	DNS: -
		
		Domain name basics 
			The first part of www.google.com is www, which is a subdomain. A subdomain is used to organize different sections of a website.
			For example, mail.google.com is Google’s email service, and drive.google.com is Google Drive. The www subdomain is traditionally 
			used to indicate the web server, but technically it’s just one of many possible subdomains.
			
			The middle part, google, is the second-level domain (SLD). This is the main name of the website that the organization or individual 
			owns and controls. For instance, in google.com, Google owns the “google” part, and in example.com, someone else could own “example”. 
			The second-level domain represents the core identity of the website.
			
			The last part, .com, is the top-level domain (TLD). TLDs indicate the type or category of the domain, such as .com for commercial
			businesses, .org for organizations, .edu for educational institutions, or .gov for government sites. Together, the subdomain, 
			second-level domain, and TLD form a fully qualified domain name (FQDN), which uniquely identifies a resource on the internet.

	Ping google.com -> result on screen 
	When you run `ping www.google.com`, ping first needs an IP address, so it asks the system resolver to look up the name. The resolver follows the 
	order in `/etc/nsswitch.conf` (usually `hosts: files dns`). First it checks `/etc/hosts` for a matching entry. If the name is not there, Linux 
	reads the DNS servers from `/etc/resolv.conf` and sends a DNS query (UDP port 53) to the first nameserver listed. If no reply comes, it tries the 
	next nameserver. The DNS server returns the IP address for google.com.

	With the IP address known, ping creates ICMP Echo Request packets. The Linux kernel checks the routing table to choose the path, and if needed, 
	performs ARP to get the MAC address of the next hop. Then the ICMP packets are sent to the destination. The remote machine replies with ICMP Echo 
	Reply packets, and ping displays the results (time, TTL, packet size). This repeats every second until you stop the command.

	if you want to see from where to where your request is going when you ping use "traceroute google.com" command, you will get all servers IPs
	
	$ tracert google.com (windows command)

	Tracing route to google.com [142.250.195.46]
	over a maximum of 30 hops:

	  1     1 ms     1 ms     5 ms  192.168.1.1						-> you can search these IPs in google, and you will get the lication of each hops server.
	  2    36 ms    16 ms    25 ms  110.226.15.255					-> pune 
	  3    67 ms    36 ms     7 ms  125.20.27.9						-> bhopal
	  4     8 ms     8 ms    10 ms  116.119.161.135					-> bangalore
	  5    51 ms    12 ms    15 ms  173.194.125.54					-> California 
	  6    10 ms     8 ms    10 ms  192.178.110.225					-> California
	  7    13 ms    11 ms    10 ms  142.250.238.81					-> California -> found the server here in California
	  8    23 ms    11 ms     9 ms  maa03s37-in-f14.1e100.net [142.250.195.46]

	In short: **ping → resolver → nsswitch → hosts → DNS → IP → routing → ARP → ICMP exchange → output on screen.**

		$ ip netns
		cni-cdb9c97c-d002-69ab-d294-2a6e31b521bc (id: 0)
		cni-8bc979c8-243d-eabb-9e46-8089108f676d (id: 1)

		$ ip netns add ashu-newtwork

		$ ip netns
		cni-cdb9c97c-d002-69ab-d294-2a6e31b521bc (id: 0)
		cni-8bc979c8-243d-eabb-9e46-8089108f676d (id: 1)
		ashu-newtwork
		
================================= will get back after network seassion =====================================================

Helm: -

	Helm is package manager for k8s
	https://helm.sh/docs/intro/quickstart/
	
	$ helm create hellow-world
	Creating hellow-world
	
	$ tree hellow-world/
	hellow-world/
	|-- Chart.yaml
	|-- charts
	|-- templates
	|   |-- NOTES.txt
	|   |-- _helpers.tpl
	|   |-- deployment.yaml
	|   |-- hpa.yaml
	|   |-- ingress.yaml
	|   |-- service.yaml
	|   |-- serviceaccount.yaml
	|   `-- tests
	|       `-- test-connection.yaml
	`-- values.yaml

	4 directories, 10 files

	if you check the "Chart.yaml" you will see the "apiVersion: v2" that means this folder is created with helm3 
	if you see "apiVersion: v1" then helm2 is used.
	also you will get the "appVersion: <something>" this means version of application which is runing with helm, here I have create the hello-world
	application. And simpy "version" means verison of the char which we created.
	
	Templating: -
		template only works with helm, and we need to keep resource files in templates filder and values file outside the templates folder.
		read the example you will understand.
		
		
	mychart/
	  Chart.yaml
	  values.yaml
	  templates/
		   deployment.yaml
		   service.yaml
		
		templates/deploment.yaml
			apiVersion: apps/v1
			kind: Deployment
			metadata:
			  name: template-example
			spec:
			  replicas: {{ .Values.replicaCount }}
			  selector:
				matchLabels:
				  app: {{ include "myapp.name" . }}
			  template:
				metadata:
				  labels:
					app: {{ include "myapp.name" . }}
				spec:
				  containers:
					- name: {{ include "myapp.name" . }}
					  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
					  ports:
						- containerPort: {{ .Values.service.port }}

		templates/service.yaml
			apiVersion: v1
			kind: Service
			metadata:
			  name: {{ include "myapp.fullname" . }}
			spec:
			  type: {{ .Values.service.type }}
			  selector:
				app: {{ include "myapp.name" . }}
			  ports:
				- port: {{ .Values.service.port }}
				  targetPort: {{ .Values.service.port }}

		values.yaml
			replicaCount: 2

			image:
			  repository: nginx
			  tag: latest

			service:
			  type: ClusterIP
			  port: 80

	
	
	

Kustomize: -
	so in live project, live project runs in multiple stages like production, staging, deployment. like that all every stage has different configuration,
	conside ex, there is one deployment in production only one replics is there in staging there are 2 and in deployment there will be 5.
	
	so there are 3 dirs then you will always need to keep track of replicas in each yaml and if you miss one of them there will be big issue, so to adress this issue 
	we have kustomize
	
	you will need to manage only one yaml file and then Kustomize will take care of all the other path.
	
					$ tree ashu-prod/
					ashu-prod/
					|-- base
					|   `-- deployment-yaml.yaml
					`-- overlays
						|-- deploy
						|   `-- kustomixation.yaml
						|-- dev
						|   `-- kustomixation.yaml
						`-- stag
							`-- kustomixation.yaml

					6 directories, 4 files

					$ cat ashu-prod/base/deployment-yaml.yaml 
					apiVersion: apps/v1
					kind: Deployment
					metadata:
					  labels:
						app: deployment-yaml
					  name: deployment-yaml
					spec:
					  replicas: 3
					  selector:
						matchLabels:
						  app: deployment-yaml
					  strategy: {}
					  template:
						metadata:
						  labels:
							app: deployment-yaml
						spec:
						  containers:
						  - image: nginx
							name: nginx
							resources: {}
					status: {}

					$ cat ashu-prod/overlays/deploy/kustomixation.yaml 
					spec:
					  replicas: 1

	so you will need to manage the "ashu-prod/base/deployment-yaml.yaml" file only, then the "ashu-prod/overlays" other things from "overlays" dir will take care
	this example only include Deployment but there will be more files in base dir. so it is easy to manage.
	
	
	so it is similatr to helm but helm is too advence, and overall can manage the whole k8s, but kustomization has limination and limited things.
	
	$ cat ashu/kustomization.yaml				we can add apiVersion and Kind, but not mandatary but adding is good practice.
		resources:
			- deployment.yaml						these are the files, which need to manage.
			- pod.yaml
			
		commonLabels:							these is what we need to manage in those files
			company: ashu-common-name			so we are adding the command name in those yaml file, so similarly we can manage lot of things from here.
			
	Create all files kustomization.yaml, deployment.yaml and pod.yaml then run 
	$ kustomize build ashu/
	command, this command will just crate configuration in yaml file, not create anything.
	you will need to redirect output in file or use pipe command with it.
	
	$ kustomize build ashu/ | k create -f -
	or 
	$ kustomize build ashu/ > kustomization.yaml
	$ k create -f kustomization.yaml
	or
	$ Kustomize apply -k ashu/						-k for kustomization
	
	to delete use below commands 
	
	$ kustomize build ashu/ | k delete -f -
	or
	$ Kustomize delete -k ashu/						-k for kustomization


	in live project there will be lot of folders and resource files, and you want to crate resource then it will be deficult to create all resource once,
	this aslo take care by the kustomization, just create yaml file and mention files, and you are just one command away from create full project.
	yaml file and dir structor as below.

	$ tree ashu-prod/
	ashu-prod/
	|-- kustomization.yaml
	`---~
		|-- deploy
		|   `-- pod-dep.yaml
		|   `-- dependent-dep.yaml
		|-- dev
		|   `-- pod-dev.yaml
		|   `-- dependent-dev.yaml
		`-- stag
		    `-- pod-stag.yaml
		    `-- dependent-stag.yaml

	6 directories, 4 files


	$ cat kustomization.yaml
	
	resources:
		- deploy/pod-dep.yaml
		- deploy/dependent-dep.yaml
		- dev/pod-dev.yaml
		- dev/dependent-dev.yaml
		- stag/pod-stag.yaml
		- stag/dependent-stag.yaml
		
	$ kustomize build ashu-prod/ | k create -f -
	your all resources will be created.
	
	
	Now see, there will 100s of files and dir and writing those and maintains will be pain again, so to simplyfy again we can create each dirs Kustomize.yaml file 
	and mention yaml file, and in parent Kustomize.yaml just mention the dir names, parent Kustomize.yaml will pick up the all child Kustomize.yaml and will create
	resources accordingly
	
	
	$ tree ashu-prod/
	ashu-prod/
	|-- kustomization.yaml
	`---~
		|-- deploy
		|   `-- pod-dep.yaml
		|   `-- dependent-dep.yaml
		|   `-- kustomization.yaml
		|-- dev
		|   `-- pod-dev.yaml
		|   `-- dependent-dev.yaml
		|   `-- kustomization.yaml
		`-- stag
		    `-- pod-stag.yaml
		    `-- dependent-stag.yaml
		    `-- kustomization.yaml
			
	parent kustomization.yaml
	
	resources:
		- deploy/
		- dev/
		- stage/
		
	child kustomization.yaml from deploy folder
	
	resoruces:
		- pod-dep.yaml
		- dependent-dep.yaml
		
	$ cat kustomization.yaml
		apiVersion: kustomize.config.k8s.io/v1beta1
		kind: Kustomization
		resources:
		  - db/db-config.yaml
		  - db/db-depl.yaml
		  - db/db-service.yaml
		  - message-broker/rabbitmq-config.yaml
		  - message-broker/rabbitmq-depl.yaml
		  - message-broker/rabbitmq-service.yaml
		  - nginx/nginx-depl.yaml
		  - nginx/nginx-service.yaml
		  
		commanTransformation: -
			with kustomization we can add labes, namespaces and annotations
			- commandLabel
			- namePrefix / namesuffix
			- namespace
			-commonAnnotations
		  
	ImageTransformation: -
		we can transform image as well, change the existing image from yaml with new image.
		

		You can kustomize the whole project with reference of below file,
		if you add it to the chield kustomization then it will be applied to only that Dir and if you add to parent dir then it will be applicable to whole project.

			$ kustomization.yaml
				resoruces:
					- pod-dep.yaml
					- dependent-dep.yaml
				commonLabels:
				  sandbox: dev
					
				nameSufix: -storage
				namePrefix: new-
				
				images:
				  - name: postgres
				  - newName: mysql				
				  - newTag: "1.23"
					
				namespace: logging	
				
				commonAnnotations:
				  owner: bob@gmail.com
				  
				  
	Patch: -
		so it similar to the transform, but more specific, line chnaging just name of resource, changing name, yeah specific,
		if there are multiple kustomization files, then you will need to add parent kustomization.yaml files path as "../../base", some thing like that
		there are two differnt types of patch one is json 6902 patch and another one is strategic merge patch,
		
		json 6902 Patch
		kustomization.yaml
			patches:
				- taget:
					kind: deployment
					name: <deployment name>
				patch: |-
					- op: replace
					  path: /metadata/name
					  value: <new deployment name>
					  
		If you apply this patch then, it will find the "deployment", then will find "<deployment name>", the will find "/metadata/name" then will replace older name 
		with  "<new deployment name>".
		
		strategic merge patch
		kustomization.yaml
			patches:
				- patch: |-
					apiVersion: apps/v1
					kind: Deployment
					metadata: 
						name: <deployment name>
					metadata: 
						name: <new deployment name>
						

		To change the replica count 
		kustomization.yaml
			patches:
				- patch: |-
					apiVersion: apps/v1
					kind: Deployment
					metadata:
					  name: my-app       # must match the name in the base
					spec:
					  replicas: 5
		
		if there are multiple pathch then We can mention in each in differnt pathch, it is easy to maintain
		
			kustomization.yaml
				patches:
					- replace-count.yaml
					
			replace-count.yaml
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: my-app       # must match the name in the base
				spec:
				  replicas: 5

		To add any parameters, below filw will add org labels, json 6902 patch
		
			kustomization.yaml
				patches:
					- taget:
						kind: deployment
						name: <deployment name>
					patch: |-
						- op: add/remove/
						  path: /spec/template/metadata/labels/org
						  value: <new name>

		To add any parameters, below filw will add org labels, strategic merge patch 
			kustomization.yaml
				patches:
					- replace-count.yaml

			replace-count.yaml
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: my-app       # must match the name in the base
				spec:
				  template:
					metadata:
						labels:
							org: <NEW NAME>

		To remove any parameters, below filw will add org labels, strategic merge patch 
			kustomization.yaml
				patches:
					- replace-count.yaml

			replace-count.yaml
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: my-app       # must match the name in the base
				spec:
				  template:
					metadata:
						labels:
							org: null
	
		Now how to change the list, like we have list in container section, image and name, so how to chane those?

			kustomization.yaml
				patches:
					- taget:
						kind: deployment
						name: <deployment name>
					patch: |-
						- op: add/remove/
						  path: /spec/template/spec/containers/0      this zero represent 1st element, because there will be more than one container, so index that
						  value:									  as per the container count.
							name: nginx
							image: nginx

		To add/remove list, follow same steps just do add as operation, use same index if you want to add exacly at the end then use "-"
		
			kustomization.yaml
				patches:
					- taget:
						kind: deployment
						name: <deployment name>
					patch: |-
						- op: add/remove/
						  path: /spec/template/spec/containers/-      this - adds last element, because there will be more than one container, so index that
						  value:									  as per the container count.
							name: nginx
							image: nginx
		
		and with strategic merge patch to add the list
			kustomization.yaml
				patches:
					- replace-count.yaml

			replace-count.yaml
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: my-app       # must match the name in the base
				spec:
				  template:
					spec:
						containers:
							- image: busybox				new will be add directly 
							  name: busybox

		
		Remove the intem from list.
			kustomization.yaml
				patches:
					- replace-count.yaml

			replace-count.yaml
				apiVersion: apps/v1
				kind: Deployment
				metadata:
				  name: my-app       # must match the name in the base
				spec:
				  template:
					spec:
						containers:
							- $patch: delete				operation
							  name: busybox					which item to delete

		To replace image
			patches:
			  - target:
				  kind: Deployment
				  name: api-deployment
				patch: |-
				  - op: replace
					path: /spec/template/spec/containers/0/image
					value: caddy
					
					
		Components: - need to check more on Components
		https://notes.kodekloud.com/docs/CKA-Certification-Course-Certified-Kubernetes-Administrator/2025-Updates-Kustomize-Basics/Components