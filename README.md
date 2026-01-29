# Databricks on GCP - GitHub Actions OIDC Setup

This repository contains Terraform code to deploy Databricks workspaces on Google Cloud Platform using GitHub Actions with OIDC authentication (no service account keys required!).

## 🚀 Quick Start

### Prerequisites
- Databricks Account ID
- GCP Project with Workload Identity Federation configured
- GitHub repository with appropriate permissions

### Setup Steps

1. **Configure GitHub Secrets**
   ```
   GitHub Repo → Settings → Secrets → Actions
   Add: DATABRICKS_ACCOUNT_ID = your-databricks-account-id
   ```

2. **Add IAM Binding for Your Repository**
   ```bash
   gcloud iam service-accounts add-iam-policy-binding \
     iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com \
     --role=roles/iam.workloadIdentityUser \
     --member="principalSet://iam.googleapis.com/projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/attribute.repository/YOUR_ORG/YOUR_REPO"
   ```

3. **Update terraform.tfvars**
   ```bash
   cp terraform-workspace-only.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your configuration
   ```

4. **Create a Test PR**
   ```bash
   git checkout -b test/my-workspace
   # Make changes to terraform.tfvars
   git add terraform.tfvars
   git commit -m "feat: add new workspace"
   git push origin test/my-workspace
   # Create PR and review plan
   ```

## 📚 Documentation

- **[README-CICD.md](./README-CICD.md)** - Complete CI/CD setup guide
- **[provider.tf](./provider.tf)** - Terraform provider configuration with OIDC
- **[main.tf](./main.tf)** - Main Terraform configuration

## 🏗️ Architecture

- **Deployment Mode:** `workspace_only` (uses existing GCP infrastructure)
- **Authentication:** OIDC Workload Identity Federation
- **CI/CD:** GitHub Actions
- **State:** GCS bucket (`vz-iac-core-iac-stage-state`)

## 🔐 Security

- ✅ No service account keys stored
- ✅ Short-lived OIDC tokens (1 hour)
- ✅ Repository-specific IAM bindings
- ✅ Terraform state encryption at rest

## 🔄 Workflows

### Plan Workflow (PR)
Triggers on pull request to `main`:
- Authenticates via OIDC
- Runs `terraform plan`
- Posts plan to PR comments

### Apply Workflow (Merge)
Triggers on PR merge to `main`:
- Authenticates via OIDC
- Runs `terraform apply`
- Deploys Databricks workspaces

## 📝 Configuration

### Workspace Configuration Example

```hcl
workspaces = {
  "workspace1" = {
    workspace_name                     = "my-databricks-workspace"
    project_id                         = "my-gcp-project"
    region                             = "us-central1"
    vpc_name                           = "existing-vpc"
    subnet_name                        = "existing-subnet"
    subnet_region                      = "us-central1"
    enable_secure_cluster_connectivity = true
    
    workspace_admins = [
      {
        principal_name = "admin@company.com"
        type           = "user"
      }
    ]
    
    workspace_users = []
  }
}
```

## 🆘 Troubleshooting

### Authentication Failed
- Verify IAM binding includes your repository
- Check WIF provider configuration

### State Bucket Access Denied
- Verify service account has `storage.objectAdmin` on bucket

### Databricks Permission Denied
- Verify Google SA is added as Databricks account admin

## 📞 Support

See [README-CICD.md](./README-CICD.md) for detailed troubleshooting and setup instructions.

## 📄 License

Copyright 2026 - Internal Use Only
