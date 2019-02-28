# Services designing for easily scale up/down a Kubernetes cluster

One of the most important archictectural factors is the ability to **scale horizontally**, adjusting the number of identical copies of the application to distribute load and increase availability. This is an alternative to **vertical scaling**, which attempts to manipulate the same factors by deploying on machines with greater or fewer resources.

The **microservices** design pattern works well for scalable deployments on clusters. Developers create small, composable applications that communicate over the network through well-defined **REST APIs** instead of larger compound programs that communicate through through internal programming mechanisms. Decomposing monolithic applications into discrete single-purpose components makes it possible to scale each function independently. Much of the complexity and composition that would normally exist at the application level is transferred to the operational realm where it can be managed by Kubernetes.

# Kubernetes and Stateful services

**How does kubernetes deal with stateful services?**

Kubernetes offers a few tools for developing stateful applications: *StatefulSets*, *session affinity* and *leader election*.

## StatefulSets
[StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) are used for building stateful distributed systems by providing a few key features:

 - A unique index for each pod
 - Ordered pod creation
 - Stable, unique network identifiers.
 - Stable, persistent storage.

Some services require a notion of cluster membership to run successfully. In Kubernetes, this means that each pod in a service knows about each other pod in the service, and that those pods are able to communicate with each other consistently. This is facilitated by *StatefulSets* which guarantee pods have unique and addressable identities, and _persistent volumes_ which guarantee that any data written to disk will be available after a pod restart.

### Creating a StatefulSet
The `web.yaml` file, described below, creates a Headless Service, `nginx`, to publish the IP addresses of Pods in the StatefulSet, `web`.

```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      ports:
      - port: 80
        name: web
      clusterIP: None
      selector:
        app: nginx
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: web
    spec:
      serviceName: "nginx"
      replicas: 2
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: k8s.gcr.io/nginx-slim:0.8
            ports:
            - containerPort: 80
              name: web
            volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
      volumeClaimTemplates:
      - metadata:
          name: www
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 1Gi
```

The StatefulSet controller created two PersistentVolumeClaims that are bound to two [PersistentVolumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). The `volumeMounts` field in the StatefulSets `spec` ensures that the `/usr/share/nginx/html` directory is backed by a PersistentVolume.

## Session Affinity
[Session affinity](https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/affinity/cookie) always directs traffic from a client to the same pod. It is typically used as an optimization to ensure that the same pod receives traffic from the same user so that you can leverage session caching. It is worth noting that session affinity is a best-effort endeavour and there are scenarios where it will fail due to pod restarts or network errors.

When deploying services, one can configure session affinity using YAML. For example, the following service uses `ClientIP` session affinity, which will route all requests originating from the same IP address to the same pod:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
  sessionAffinity: ClientIP
```

This configuration works well for routing traffic to the same pod after it has reached the Kubernetes cluster. To enable session affinity for traffic that originates outside of the Kubernetes cluster, it is required configuring Ingress into the cluster for session affinity.
With nginx Ingress, we enable session affinity when defining the route to our service. For example, the following Ingress uses HTTP cookies, the cookie is named `route` and the value of the cookie is hashed using `sha1`.
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-test
  annotations:
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "route"
    nginx.ingress.kubernetes.io/session-cookie-hash: "sha1"

spec:
  rules:
  - host: stickyingress.example.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /
```

NGINX will set in the HTTP Headers with 'Set-Cookie: route', setting the right defined stickiness cookie that contains the hash of the used upstream in that request.


## Leader Election
[Leader election](https://kubernetes.io/blog/2016/01/simple-leader-election-with-kubernetes/) is typically used when you want only one instance of your service (one pod) to act on data at one time.
For example, if you want to ensure only one instance of your service updates customer information at a time, you must lock the data that is being accessed.

Kubernetes runs an etcd cluster that consistently stores Kubernetes cluster state, and this can be leveraged to perform leader election simply by leveraging the Kubernetes API server.

To perform leader election, we use two properties of all Kubernetes API objects:

-   ResourceVersions - Every API object has a unique ResourceVersion, and you can use these versions to perform compare-and-swap on Kubernetes objects
-   Annotations - Every API object can be annotated with arbitrary key/value pairs to be used by clients.

## Summary
One can leverage the etcd cluster used by the Kubernetes API server to perform leader election, use StatefulSets to define a cluster membership topology for a service, and can use session affinity to consistently route traffic to the same pod. All of these can helps to develop a highly-available stateful application.
