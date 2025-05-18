Here’s a **full GKE (Google Kubernetes Engine) project** that demonstrates deploying a containerized web application (Node.js backend and React frontend) with CI/CD integration using **Cloud Build**, **Artifact Registry**, and **Terraform for infrastructure provisioning**.

---

## ✅ Project Name: `gke-fullstack-app`

### 🎯 Features:

* React frontend + Node.js (Express) backend
* MongoDB (via Atlas or GCP-managed instance)
* GKE Cluster (Terraform)
* CI/CD via Cloud Build
* Dockerized microservices
* Public IP access via LoadBalancer service

---

## 📁 Project Structure:

```bash
gke-fullstack-app/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── frontend/
│   ├── Dockerfile
│   └── src/...
├── backend/
│   ├── Dockerfile
│   └── server.js
├── cloudbuild.yaml
├── .dockerignore
└── README.md
```

---

## ⚙️ 1. Terraform GKE Setup (`terraform/main.tf`)

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = var.region
  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
  }
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}
```

`variables.tf`

```hcl
variable "project_id" {}
variable "region" {
  default = "us-central1"
}
```

Initialize and apply:

```bash
cd terraform
terraform init
terraform apply
```

---

## 🐳 2. Dockerfile (Frontend)

```Dockerfile
# frontend/Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build
RUN npm install -g serve
CMD ["serve", "-s", "build"]
```

## 🐳 Dockerfile (Backend)

```Dockerfile
# backend/Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "server.js"]
```

---

## 🔧 3. `cloudbuild.yaml`

```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/artifacts/frontend', './frontend']
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/artifacts/backend', './backend']

- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/artifacts/frontend']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/artifacts/backend']

- name: 'gcr.io/cloud-builders/kubectl'
  args:
    - apply
    - -f
    - k8s/
  env:
    - 'CLOUDSDK_COMPUTE_REGION=us-central1'
    - 'CLOUDSDK_CONTAINER_CLUSTER=gke-cluster'
```

---

## ☸️ 4. Kubernetes Manifests (`k8s/` folder)

### `frontend-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: us-central1-docker.pkg.dev/YOUR_PROJECT_ID/artifacts/frontend
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
```

### `backend-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: us-central1-docker.pkg.dev/YOUR_PROJECT_ID/artifacts/backend
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 5000
    targetPort: 5000
```

---

## 🔄 5. CI/CD Setup

Enable:

* **Artifact Registry**
* **Cloud Build**
* **Kubernetes Engine API**

Then push the repo with `cloudbuild.yaml` to Cloud Source Repositories or GitHub connected to Cloud Build trigger.

---

## 🚀 Deploy

```bash
# Authenticate kubectl
gcloud container clusters get-credentials gke-cluster --region=us-central1

# Apply K8s manifests
kubectl apply -f k8s/
```

---

## ✅ Output

* Frontend accessible via LoadBalancer IP
* Backend accessible via internal ClusterIP
* CI/CD automated with Cloud Build

---

Would you like a **GitHub repository link**, a **downloadable ZIP**, or **deployment script for GCP Cloud Shell**?
