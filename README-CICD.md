# GitHub Actions CI/CD Setup Guide
**Databricks Workspace Deployment with OIDC Authentication**

---

## ✅ IMPLEMENTATION COMPLETE

The following GitHub Actions workflows have been created:

1. **`.github/workflows/databricks-workspace-plan.yml`**  
   - Runs on: Pull Request open/update
   - Action: `terraform plan` (read-only)
   - Posts plan results to PR comments

2. **`.github/workflows/databricks-workspace-apply.yml`**  
   - Runs on: PR merged to `main` OR manual trigger
   - Action: `terraform apply` (deploys changes)
   - Posts apply results to PR comments

---

## 🔧 SETUP INSTRUCTIONS

### **Step 1: Configure GitHub Repository Secrets**

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DATABRICKS_ACCOUNT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Your Databricks Account ID from accounts.gcp.databricks.com |

**Note:** No service account keys needed! OIDC handles authentication securely. 🎉

---

### **Step 2: Verify WIF Configuration**

Ensure your Workload Identity Federation is properly configured:

```bash
# Verify WIF pool exists
gcloud iam workload-identity-pools describe databricks-workspace \
  --project=vz-iac-core \
  --location=global

# Verify WIF provider exists
gcloud iam workload-identity-pools providers describe github-default \
  --project=vz-iac-core \
  --location=global \
  --workload-identity-pool=databricks-workspace

# Verify service account IAM binding
gcloud iam service-accounts get-iam-policy \
  iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com
```

**Required IAM binding:**
```yaml
bindings:
- members:
  - principalSet://iam.googleapis.com/projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/attribute.repository/YOUR_ORG/YOUR_REPO
  role: roles/iam.workloadIdentityUser
```

**To add the binding (if missing):**
```bash
# Replace YOUR_ORG and YOUR_REPO with your GitHub org and repository name
gcloud iam service-accounts add-iam-policy-binding \
  iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/attribute.repository/YOUR_ORG/YOUR_REPO"
```

---

### **Step 3: Verify GCS State Bucket Access**

Ensure the service account can access the Terraform state bucket:

```bash
# Check bucket IAM
gsutil iam get gs://vz-iac-core-iac-stage-state

# Add permission if needed
gsutil iam ch \
  serviceAccount:iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com:roles/storage.objectAdmin \
  gs://vz-iac-core-iac-stage-state
```

---

### **Step 4: Verify Databricks Account Admin**

Confirm the Google Service Account is added as Databricks account admin:

1. Go to: https://accounts.gcp.databricks.com
2. Click **User management**
3. Search for: `iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com`
4. Verify role: **Account admin**

**If not added:**
- Click "Add user"
- Enter: `iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com`
- Select role: "Account admin"
- Click "Send invite" (it will auto-accept for service accounts)

---

### **Step 5: Update Terraform Variables**

Ensure your `terraform.tfvars` file has all required variables:

```hcl
# Required
databricks_account_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Will be provided via GitHub secret
deployment_mode       = "workspace_only"  # or "full"

# GCP Configuration
google_project = "your-gcp-project-id"
google_region  = "us-central1"

# Workspaces configuration
workspaces = {
  "workspace1" = {
    workspace_name                     = "vizio-prod-workspace"
    project_id                         = "vizio-workspace-prod"
    region                             = "us-central1"
    vpc_name                           = "existing-vpc-name"
    subnet_name                        = "existing-subnet-name"
    subnet_region                      = "us-central1"
    enable_secure_cluster_connectivity = true
    
    workspace_admins = [
      {
        principal_name = "admin@vizio.com"
        type           = "user"
      }
    ]
    
    workspace_users = []
  }
}
```

---

### **Step 6: Test the Workflow**

**Option A: Test with a Draft PR (Recommended)**

1. Create a new branch:
   ```bash
   git checkout -b test/cicd-workflow
   ```

2. Make a small change (e.g., add a comment to `main.tf`):
   ```bash
   echo "# Testing CI/CD workflow" >> main.tf
   ```

3. Commit and push:
   ```bash
   git add main.tf
   git commit -m "test: CI/CD workflow"
   git push origin test/cicd-workflow
   ```

4. Open a **Draft PR** on GitHub

5. Check the "Actions" tab - you should see:
   - ✅ "Databricks Workspace - Plan" workflow running
   - ✅ Plan posted as PR comment

6. If successful, convert to regular PR and merge to test apply

**Option B: Manual Trigger (for apply workflow)**

1. Go to Actions → "Databricks Workspace - Apply"
2. Click "Run workflow"
3. Type "apply" in the confirmation field
4. Click "Run workflow"

---

## 🔄 WORKFLOW BEHAVIOR

### **On Pull Request:**

```
PR Opened/Updated
    ↓
Workflow: databricks-workspace-plan.yml
    ↓
1. Authenticate via OIDC (no keys!)
2. Setup Terraform
3. terraform init
4. terraform validate
5. terraform plan (with -lock=false)
6. Post plan to PR comment
    ↓
Developer reviews plan
```

### **On PR Merge to Main:**

```
PR Merged
    ↓
Workflow: databricks-workspace-apply.yml
    ↓
1. Authenticate via OIDC
2. Setup Terraform
3. terraform init
4. terraform validate
5. terraform plan -out=tfplan
6. terraform apply tfplan
7. Post results to PR comment
    ↓
Databricks workspaces deployed/updated
```

---

## 🔐 SECURITY FEATURES

✅ **No Service Account Keys**  
- Uses OIDC token exchange instead of static keys
- Tokens are short-lived (1 hour)
- No secrets to rotate or leak

✅ **Least Privilege**  
- Plan workflow: Read-only (`-lock=false`)
- Apply workflow: Only runs on merged PRs or manual approval

✅ **Audit Trail**  
- All deployments logged in GitHub Actions
- PR comments show what changed
- Terraform state tracks history

✅ **Branch Protection**  
- Recommend enabling: "Require status checks to pass before merging"
- Add check: "Databricks Workspace - Plan"

---

## 📋 TROUBLESHOOTING

### **Error: "Workload Identity Federation authentication failed"**

**Cause:** IAM binding is missing or incorrect

**Fix:**
```bash
gcloud iam service-accounts add-iam-policy-binding \
  iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/attribute.repository/YOUR_ORG/YOUR_REPO"
```

---

### **Error: "Error loading state: Failed to get existing workspaces"**

**Cause:** Service account can't access GCS state bucket

**Fix:**
```bash
gsutil iam ch \
  serviceAccount:iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com:roles/storage.objectAdmin \
  gs://vz-iac-core-iac-stage-state
```

---

### **Error: "PERMISSION_DENIED: User is not authenticated"**

**Cause:** Google SA not added as Databricks account admin

**Fix:**
1. Go to https://accounts.gcp.databricks.com
2. User management → Add user
3. Add: `iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com`
4. Role: Account admin

---

### **Error: "workspace not found" during apply**

**Cause:** Terraform state mismatch or workspace was deleted manually

**Fix:**
```bash
# Option 1: Import existing workspace
terraform import 'module.databricks_workspaces["workspace1"].databricks_mws_workspaces.this' <workspace_id>

# Option 2: Remove from state if workspace is truly deleted
terraform state rm 'module.databricks_workspaces["workspace1"].databricks_mws_workspaces.this'
```

---

## 🎯 BEST PRACTICES

### **1. Use Draft PRs for Testing**
- Create draft PRs to test plans without triggering reviews
- Convert to regular PR when ready for review

### **2. Review Plans Carefully**
- Always review the plan output in PR comments
- Look for unexpected changes (deletions, recreations)

### **3. Small, Incremental Changes**
- Deploy one workspace at a time when possible
- Easier to troubleshoot if something goes wrong

### **4. Enable Branch Protection**
```yaml
Settings → Branches → Add rule for "main":
✅ Require a pull request before merging
✅ Require status checks to pass before merging
   - Select: "Databricks Workspace - Plan"
✅ Require conversation resolution before merging
```

### **5. Monitor Apply Workflows**
- Watch the GitHub Actions logs during apply
- Check for any warnings or errors
- Verify workspace URLs in the output

---

## 🔄 LOCAL DEVELOPMENT

For local Terraform runs (not CI/CD):

### **Option 1: Use Application Default Credentials**

```bash
gcloud auth application-default login
terraform plan
```

### **Option 2: Impersonate Service Account**

Update `provider.tf` (uncomment):
```hcl
provider "google" {
  project                     = var.google_project
  region                      = var.google_region
  impersonate_service_account = "iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com"
}
```

Then run:
```bash
terraform plan
```

### **Option 3: Use Service Account Key (Not Recommended)**

```bash
export GOOGLE_CREDENTIALS="path/to/key.json"
terraform plan
```

---

## 📊 WORKFLOW CONFIGURATION

### **Current Configuration:**

| Setting | Value |
|---------|-------|
| **WIF Provider** | `projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/providers/github-default` |
| **Service Account** | `iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com` |
| **State Bucket** | `vz-iac-core-iac-stage-state` |
| **State Prefix** | `databricks-workspace` |
| **Terraform Version** | `1.14.2` |
| **Main Branch** | `main` |

### **To Modify:**

Edit the `env` section in workflow files:
- `.github/workflows/databricks-workspace-plan.yml`
- `.github/workflows/databricks-workspace-apply.yml`

---

## ✅ VERIFICATION CHECKLIST

Before first deployment:

- [ ] GitHub secret `DATABRICKS_ACCOUNT_ID` configured
- [ ] WIF provider exists and is properly configured
- [ ] Service account has `workloadIdentityUser` role for your repo
- [ ] Service account has access to GCS state bucket
- [ ] Service account is Databricks account admin
- [ ] `terraform.tfvars` is configured with your workspaces
- [ ] Branch protection rules configured (optional but recommended)
- [ ] Test PR created and plan workflow succeeded

---

## 🚀 READY TO DEPLOY

Once all checks pass:

1. Create a feature branch
2. Update `terraform.tfvars` with your workspace configuration
3. Open a Pull Request
4. Review the plan in PR comments
5. Request review from team
6. Merge to `main`
7. Watch the apply workflow deploy your workspaces! 🎉

---

## 📚 ADDITIONAL RESOURCES

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Databricks on GCP](https://docs.databricks.com/gcp/index.html)
- [Terraform Databricks Provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs)

---

**Need help?** Check the troubleshooting section or review workflow logs in GitHub Actions tab.

