# Defines a Kubernetes Deployment resource
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${deployment_name}
spec:
  replicas: ${replicas}
  selector:
    matchLabels:
      app: ${deployment_name}
  template:
    metadata:
      labels:
        app: ${deployment_name}
    spec:
      terminationGracePeriodSeconds: 0
      containers:
        - name: ${deployment_name}
          image: ${image}
          resources:
            requests:
              cpu: 1
      nodeSelector: ${node_selector}
