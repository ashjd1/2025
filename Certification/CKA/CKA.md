CKA reference to the course https://github.com/kodekloudhub/certified-kubernetes-administrator-course


you can use "k" insted of "kubectl"

$ kubectl get all
$ kubectl replace --foce -f pod.yaml -> delete exesting pod and will create new from same file.

master node and worked node

master node has control plain component by which it can manage multiple worked nodes and its containers

kubelet is present on all the nodes and it always listen to master node and manage the node.
also master node fetches the data from kubelet to monitor nodes and container .

recent version from 1.24 version of k8s docker is not supported.
instead it supports containerD, very similar to docker
so instead of "docekr ps -a" you will need to use "nerdctl ps -a" replace "docker" with "nerdctl".

ETCD (etcd cluster): -

	is a distributed reliable key value store, it stores data in key and value format.
	when you run any "kubectl get" command that time data get read from ETCD and then present to you.
	
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
	Replicaset can manage pods which are created by the replicaset itself and also the pods matched with spec:selector:matchLabels, no matter when you create the pod, but this not happens with replicationcontroller.
	

	KEEP IN MIND:- in ReplicaSet you have to match the labels whatever you are giving in spec:template:labels to spec:selector:matchLabels, otherwise you will get error.

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
		1. change the number in file and run "kubectl replace -f <file-name>" 
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
		Advance topic, check it here <link>
		
	
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

	So sheduller map the pod to node, not oly that all the things like whcich namespace, which node all those things,
	so If default sheduller is of then pod will be in peding state.
	so you can manually assigne the pod to node, no need for sheduler, use "nodeName" only in spec:nodeName: <node name>
	
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
	If we set taint (node) and tolaration (pod) it will alwasy place pod in that node or vice varsa.
	basicelly with taint and tolaration we can adjust the pod and nodes relation.
	
	for node:
	kubectl taint nodes node-name key=value:taint-effect
	
	three kind of tolorations are there 1. NoSchedule
										2. PreferNoSchedule
										3. NoExecution
										
	kubectl taint nodes node01 app=blue:NoSchedule -> for node
	
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
		NoSchedule = Do not allow pods to be scheduled on this node unless they have a matching toleration.
		toleration = app=blue
		
		So now only pods with app=blue will get to place on node01
		
		command to remove taint from node
		kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule-
		to remoce the taint the command is exactly the same, just add - at the end.
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
		size: Large			# when node is created this labes are given to that node, so that large pod get assign to large node.
		
	you can label the node as well with below command: -
	"$ kubectl label nodes node01 size=Large"
	
	Affinity: -
	
		requiredDuringSchedulingIgnoreDuringExecution
		preferredDuringSchedulingIgnoreDuringExecution
		
		Syntax for this is nor easy to remember, you can refer k8s documentation.
		https://kubernetes.io/docs/home/
		
	we can use Taint and Tolaration, like label the node and pod.
	but there is chance that pod might will endup in other node where node is not labeled
	so to come over this issue we have Affinity, so that exact pod will endup in exact node.
	
Resource limite: -

	By default k8s dont have resource limits.
	so in resource limit we set min and max limits to the pod and container.
	for CPU: - if pod start using more CPU than limit then k8s will throtel that pod and get back to its limit.
	for MEMORY: - if pod start using more memory, then pod will be terminited with error out of memory.
	
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

	If you dont set resource on pod then pod can consume all the resource of node and then node not able to host any other pod.
	If you only set limits and no-request then ks automatecly set no-request as same as limits so limits=no-request, in this case.
	If you only set request then you will get required limite and max till node get full, but other pod get on that same node and 
		requested and limited some space then pod 2 will get as requested and pod 1 might will not get enough space only the requested.
	
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
			  - default: 					# This values are for user, if he forgot to add, then by default used this value
				  cpu: 500m					# default limits
				defaultRequest:				# default requests
				  cpu: 500m
				max:						# but min and max values are to limit, like if user tried to excced there values k8s will reject the pod.
				  cpu: "1"					# max and min define the limit range
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
			  - default: 					# This values are for user, if he forgot to add, then by default used this value
				  memory: 1Gi				# default limits
				defaultRequest:				# default requests
				  memory: 1Gi
				max:						# but min and max values are to limit, like if user tried to excced there values k8s will reject the pod.
				  memory: 1Gi				# max and min define the limit range
				min:
				  memory: 500Mi
				type: Container

		There is another varation is ResourceQuota, but it is for namespace level object, you can check below.

		| Feature          | LimitRange                        | ResourceQuota                                 |
		| ---------------- | --------------------------------- | --------------------------------------------- |
		| Scope            | Per **container/pod**             | Per **namespace**                             |
		| Enforces limits? | Yes (min, max per pod/container)  | Yes (total across namespace)                  |
		| Sets defaults?   | Yes (`default`, `defaultRequest`) | No                                            |
		| Prevents misuse? | Yes (bad container configs)       | Yes (resource overuse in namespace)           |
		| Example          | Max 1 CPU per container           | Max 10 CPUs total for all pods in a namespace |

DaemonSet: -

	DaemonSet create one pod per node, like if you create deamonset it will create node on all the nodes, no matter how may pods are there.
	if node get deleted or down then that pod will also destoried.
	DaemonSet use the node affinity and Default scheduler, land exact pod on exact node.
	
	Mostely it is used to nomitoring purpose, requirement is something like monitoring or counting the nodes.
	
	there is no directly way to create DaemonSet, you have to rigth yaml file.
	but there is work around, you can create the Deployment and then make changes accrounding to DaemonSet, 
	you need to change the kind and replicas only, also you can refer the documentation from k8s docs.
	
StaticPod: -

	If you place the file at /etc/kubernetes/manifest location, k8s will sautomaticelly will create the pod.
	that pods called as static pod.
	
	IF you the static pod on your cluster you can identify it but checing the name of pod.
	pod will have the name of node at the end of pod name.
	one more method is there, you can check the yaml file of that pod "kubectl get pod <pod name> -n <name space> -o yaml"
	then you can check for "owerReference", in kind you will get node, if that pod is static pod.
	Otherwise it will be something like ReplicaSet or Deployment.
	
	you can check the k8s configuration file at /var/lib/kubelet/config.yaml
	
	NOTE: - if you want to use "--command" option in kubectl command then always use at the end, even --dry-run shoule be before that command.
			it is not mandatary to have yaml of static file in /etc/kubernetes/manifest, is its not there then you can check "/var/lib/kubelet/config.yaml"
			you will get the folder in here. named as "staticPodPath:"
			And you can ssh to node and go to that node just by ssh <node name or IP>, you will get IP as "kubectl get nodes -o wide."
			

	Create a static pod named static-busybox that uses the busybox image , run in the default namespace and the command sleep 1000
	
	$ kubectl run static-busybox --image=busybox -n default --dry-run=client -o yaml --command -- sleep 1000
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

	Default prority value is 0.
	
	apiVersion: scheduling.k8s.io/v1
	kind: PriorityClass
	metadata:
	  name: high-priority
	value: 1000000				 				    	# There is range for this vlaue you can google it.
	globalDefault: true / false          			   	# This value will give high-priority to all the pods created
	preemptionPolicy: PreemptLowerPriority / Never		# Default is "PreemptLowerPriority", that means it will kill the lower prority and get that place.
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

kubeschedulerConfiguration: -

	k8s is highly extensible, you can create your won scheduler.
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
	
	The differnce in scheduling "scheduler as pod" and "configuring it in k8s configuration (in /etc/kubernetes/manifests/kube-scheduler.yaml here)" is, 
	instead of configuring it in k8s configuration just configure it in pod.yaml file (you have to write pod.yaml file), 
	in both the cases you have to write "my-schedular.yaml".

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
	
	Scheduling queue			# All the nodes are here with scheduler to get bind with node.
	Filtering					# Filter out the pods accroding to its priority, resource requirement, taint and tolaration.
	Scoring						# then schedular score the node according to pod requirents, only high scoring nodes will be left. like there is 4 nodes with 2CPU, 4CPU, 10CPU and 16CPU and pod need 10CPU then 16CPU node will get high score.
	Binding						# Pod will get binded with high scoring node or will get allocated on that node.
	
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
	
	Admission Controllers as better security magers to how we can use the k8s cluster, aprt from simply validation configurations, can do lot more,
	like change the request itself or perform addational operation before the pod get created.
	
	Some examples of admisssion controller which run in k8s as default: - AlwaysPullImage -> as name suggest, EventRateLimit -> allwase monitor the limit and try to manage limits, 
	NameSpaceExist -> If you try to create resource in namespace which dose not exist, it will reject that request. 
	
	NamespaceAutoProvision is not default admisssion controller but you can use it or enable it,
	it will allow to create namespace if dose not exist.
	
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
		
		