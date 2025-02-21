# AWS EKS Cluster with Karpenter, Graviton, and Spot Instances

## Overview
This Terraform project automates the deployment of an Amazon EKS cluster with Karpenter as the cluster autoscaler. The infrastructure leverages both x86 and ARM64 (Graviton) instances, including AWS Spot instances for cost optimization.

## Prerequisites
Ensure you have the following installed:
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)
- kubectl ([matching the EKS version](https://kubernetes.io/docs/tasks/tools/install-kubectl/))

## Directory Structure
```
terraform-eks-karpenter/
├── backend/               # Terraform backend configuration
├── modules/               # Reusable Terraform modules
├── main.tf                # Root Terraform configuration
├── variables.tf           # Variable definitions
├── terraform.tfvars       # Terraform variable values
├── backend.tf             # Backend configuration
└── README.md              # Project documentation
```

## Deployment Steps

### Step 1: Clone the Repository
1. Clone the repository and navigate to the project directory:
   ```sh
   git clone https://github.com/StanleyBundi/terraform-eks-karpenter.git
   cd terraform-eks-karpenter
   ```

### Step 2: Set Up the Terraform Backend
If the backend does not exist, you must create it first:
1. Navigate to the `backend/` directory:
   ```sh
   cd backend
   ```
2. Initialize and apply the Terraform backend configuration:
   ```sh
   terraform init
   terraform plan
   terraform apply -auto-approve 
   ```
3. Return to the root directory:
   ```sh
   cd ..
   ```

### Step 3: Deploy the EKS Cluster
1. Initialize Terraform:
   ```sh
   terraform init
   ```
2. Preview the planned execution:
   ```sh
   terraform plan
   ```
3. Apply the Terraform configuration to provision the EKS cluster and Karpenter:
   ```sh
   terraform apply -auto-approve
   ```

### Step 4: Configure kubectl
1. Retrieve the EKS cluster name:
   ```sh
   aws eks list-clusters
   ```
2. Update kubeconfig to connect to the cluster:
   ```sh
   aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
   ```
3. Verify the connection:
   ```sh
   kubectl get nodes
   ```

### Step 5: Deploy a Test Pod
To validate x86 and ARM64 (Graviton) workloads:

#### x86 Deployment
```sh
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: x86-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: x86-test
  template:
    metadata:
      labels:
        app: x86-test
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64
      containers:
      - name: test-container
        image: public.ecr.aws/amazonlinux/amazonlinux:latest
EOF
```

#### ARM64 (Graviton) Deployment
```sh
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: arm64-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arm64-test
  template:
    metadata:
      labels:
        app: arm64-test
    spec:
      nodeSelector:
        kubernetes.io/arch: arm64
      containers:
      - name: test-container
        image: public.ecr.aws/amazonlinux/amazonlinux:latest
EOF
```

### Step 6: Verify Deployment
Check if pods are running on the correct instance types:
```sh
kubectl get pods -o wide
```
Ensure that:
- `x86-test` runs on an `amd64` node.
- `arm64-test` runs on an `arm64` (Graviton) node.

## Cleanup
To destroy all resources:
```sh
terraform destroy -auto-approve
```

---



# RESEARCH TASK
# GPU Slicing on Amazon EKS

## Introduction
This guide provides step-by-step instructions on enabling GPU slicing in EKS clusters and integrating it with Karpenter for autoscaling.

## Prerequisites

- **Amazon EKS Cluster** ([Set up EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html))
- **NVIDIA MIG-Compatible GPU Instances** (e.g., A100) ([MIG Overview](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html))
- **AWS CLI and kubectl installed** ([AWS CLI Setup](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html))
- **NVIDIA GPU Operator installed** ([GPU Operator Guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/overview.html))
- **Helm installed** ([Helm Installation Guide](https://helm.sh/docs/intro/install/))

## Step 1: Provision MIG-Capable GPU Instances

Start by launching Amazon EC2 instances with MIG-enabled GPUs, such as NVIDIA A100.

- **Instructions**: [Launch EC2 GPU Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html)

## Step 2: Enable MIG on GPU Nodes

Configure the GPU instances to enable MIG and partition the GPU into multiple instances.

```sh
sudo nvidia-smi mig -i 0 -cgi 9,9,9,9,9,9,9 -C
```

- **Instructions**: [NVIDIA MIG Configuration](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html#configuring)

## Step 3: Deploy the NVIDIA Device Plugin

The NVIDIA device plugin is required to expose GPU resources to Kubernetes. Deploy it with MIG support.

```sh
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/deployments/static/nvidia-device-plugin.yml
```

- **Instructions**: [NVIDIA Device Plugin](https://github.com/NVIDIA/k8s-device-plugin)

## Step 4: Schedule Workloads on MIG Instances

Define resource requests in pod configurations to allocate MIG instances efficiently.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
  - name: gpu-container
    image: nvidia/cuda:11.0-base
    resources:
      limits:
        nvidia.com/mig-1g.5gb: 1
```

- **Instructions**: [GPU Workload Scheduling](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/user-guide.html#gpu-sharing)

## Step 5: Install and Configure Karpenter
Deploy Karpenter and configure provisioners to support GPU nodes.

```sh
helm repo add karpenter https://charts.karpenter.sh/
helm install karpenter karpenter/karpenter --namespace karpenter --create-namespace
```

- **Instructions**: [Karpenter Setup](https://karpenter.sh/docs/getting-started/)

## Step 6: Define Provisioners for GPU Nodes

Create provisioners to specify instance requirements for GPU workloads.

```yaml
apiVersion: karpenter.k8s.aws/v1alpha5
kind: Provisioner
metadata:
  name: gpu-provisioner
spec:
  requirements:
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["p4d.24xlarge"]
```

- **Instructions**: [Karpenter GPU Provisioning](https://karpenter.sh/docs/provisioning-node/)

## Conclusion

By following these steps,and closely following instructions(official docs and github repos) under each step as well as utilizing the external references attached right at the bottom of this guide, you can enable GPU slicing on Amazon EKS clusters including the ones with the karpenter autoscaler and optimize your AI workloads cost.

## External References

- [AWS Blog on GPU Sharing](https://aws.amazon.com/blogs/containers/gpu-sharing-on-amazon-eks-with-nvidia-time-slicing-and-accelerated-ec2-instances/)
- [NVIDIA MIG Documentation](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html)
- [Karpenter Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/karpenter.html)
- [GitHub GPU Slicing Example](https://github.com/DiabloGCs/GPUSlicingEKS)
