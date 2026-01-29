# 🚀 Push to New GitHub Repository - Step-by-Step Guide

## 📋 Prerequisites

Before pushing, you need:
1. ✅ A new GitHub repository created (can be empty)
2. ✅ Repository URL (HTTPS or SSH)
3. ✅ Git access to that repository

---

## 🧹 STEP 1: Clean Up (Already Done!)

The following files have been prepared:
- ✅ `.gitignore` - Prevents committing sensitive files
- ✅ `README.md` - Updated with OIDC instructions
- ✅ `.github/workflows/` - GitHub Actions workflows
- ✅ `README-CICD.md` - Complete setup documentation

---

## 📦 STEP 2: Stage and Commit All Changes

Run these commands in your terminal:

```bash
cd /Users/shubham.pachori/Desktop/Customers/vizio/workspace_deployment/gcp-databricks

# Add all new files
git add .github/
git add .gitignore
git add README.md
git add README-CICD.md
git add provider.tf

# Check what will be committed
git status

# Commit the changes
git commit -m "feat: add GitHub Actions OIDC workflows

- Add OIDC-based authentication for GitHub Actions
- Add terraform plan workflow for PRs
- Add terraform apply workflow for deployments
- Update provider.tf with OIDC support
- Add comprehensive CI/CD documentation
"
```

---

## 🔄 STEP 3: Push to New Repository

### **Option A: Push to a Brand New Repository**

```bash
# Get your new repository URL from GitHub
# Example: https://github.com/your-org/databricks-gcp-deployment.git

# Add new remote (if not already added)
git remote add testing https://github.com/YOUR_ORG/YOUR_REPO.git

# Or if you want to rename origin:
# git remote rename origin old-origin
# git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git

# Push current branch to new remote
git push testing feature/cicd-oidc-setup

# Or push to main/master:
# git checkout main  # or master
# git merge feature/cicd-oidc-setup
# git push testing main
```

### **Option B: Push to Existing Repository (as new branch)**

```bash
# Add the testing repository as a remote
git remote add testing https://github.com/YOUR_ORG/YOUR_REPO.git

# Fetch existing branches (if any)
git fetch testing

# Push your feature branch
git push testing feature/cicd-oidc-setup

# Create PR in the new repository
```

### **Option C: Clone and Copy (Clean Start)**

If you want a completely clean repository without history:

```bash
# Create a new directory
mkdir /tmp/databricks-gcp-clean
cd /tmp/databricks-gcp-clean

# Initialize new git repo
git init
git checkout -b main  # or master

# Copy files from current directory (excluding .git)
cp -r /Users/shubham.pachori/Desktop/Customers/vizio/workspace_deployment/gcp-databricks/* .
cp /Users/shubham.pachori/Desktop/Customers/vizio/workspace_deployment/gcp-databricks/.github . -r
cp /Users/shubham.pachori/Desktop/Customers/vizio/workspace_deployment/gcp-databricks/.gitignore .

# Remove example/reference directories if desired
rm -rf reexternalredatabricksdeploymentvizio/

# Stage all files
git add .

# Initial commit
git commit -m "Initial commit: Databricks on GCP with OIDC

- Terraform configuration for workspace deployment
- GitHub Actions workflows with OIDC authentication
- Comprehensive documentation
"

# Add your new repository as remote
git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git

# Push to new repository
git push -u origin main
```

---

## 🔐 STEP 4: Configure New Repository

Once pushed, configure the new GitHub repository:

### **A. Add Repository Secrets**

Go to: `Settings → Secrets and variables → Actions → New repository secret`

Add:
- **Name:** `DATABRICKS_ACCOUNT_ID`
- **Value:** Your Databricks account ID

### **B. Add IAM Binding for New Repository**

```bash
# Replace YOUR_ORG and YOUR_REPO with your new repository details
gcloud iam service-accounts add-iam-policy-binding \
  iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/attribute.repository/YOUR_ORG/YOUR_REPO"
```

**Example:**
```bash
# If new repo is: github.com/vizio-internal/databricks-test
gcloud iam service-accounts add-iam-policy-binding \
  iac-databricks-workspace@vz-iac-core.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/1005751860978/locations/global/workloadIdentityPools/databricks-workspace/attribute.repository/vizio-internal/databricks-test"
```

### **C. Enable GitHub Actions (if needed)**

Go to: `Settings → Actions → General`
- Enable: "Allow all actions and reusable workflows"

---

## ✅ STEP 5: Test the Setup

### **Create a Test PR:**

```bash
# Create test branch (in new repository)
git checkout -b test/verify-cicd

# Make a small change
echo "# Testing CI/CD" >> README.md

# Commit and push
git add README.md
git commit -m "test: verify OIDC workflow"
git push origin test/verify-cicd  # or 'testing' if using that remote
```

### **Verify in GitHub:**

1. Go to new repository on GitHub
2. Create PR from `test/verify-cicd` to `main`
3. Check "Actions" tab - should see "Databricks Workspace - Plan" running
4. Wait for workflow to complete
5. Check PR comments for plan output

**Expected outcome:**
- ✅ Workflow runs successfully
- ✅ Authentication succeeds
- ✅ `terraform plan` executes
- ✅ Plan posted to PR comments

---

## 🗑️ OPTIONAL: Clean Up Current Repository

If you want to remove sensitive data before pushing:

```bash
# Check what's in terraform.tfvars (might contain sensitive data)
cat terraform.tfvars

# Either:
# A) Don't commit it (already in .gitignore)
# B) Create a sanitized example version:
cp terraform.tfvars terraform.tfvars.example
# Edit terraform.tfvars.example to remove sensitive values
# Delete actual terraform.tfvars (it's gitignored)
rm terraform.tfvars
```

---

## 📋 QUICK COMMAND REFERENCE

### **For Quick Push to New Repo:**

```bash
# Navigate to project
cd /Users/shubham.pachori/Desktop/Customers/vizio/workspace_deployment/gcp-databricks

# Stage all changes
git add .

# Commit
git commit -m "feat: add OIDC CI/CD workflows"

# Add new remote
git remote add testing https://github.com/YOUR_ORG/YOUR_REPO.git

# Push
git push testing feature/cicd-oidc-setup

# Or push main:
# git checkout main
# git merge feature/cicd-oidc-setup  
# git push testing main
```

### **Verify What Will Be Pushed:**

```bash
# See all tracked files
git ls-files

# See what's in staging
git status

# See commit history
git log --oneline -10

# See what will be pushed
git diff origin/main..HEAD  # if pushing to main
```

---

## 🎯 WHAT TO PROVIDE ME

To give you the exact commands, I need:

1. **New GitHub repository URL**  
   Example: `https://github.com/vizio-internal/databricks-test`
   
2. **Repository org and name**  
   Example: `vizio-internal/databricks-test`
   
3. **Which branch to push to?**  
   Example: `main` or create new `feature/cicd-oidc-setup`

**Once you provide these, I'll give you the exact copy-paste commands!** 🚀

---

## 🚨 IMPORTANT REMINDERS

### **Before Pushing:**
- ✅ Remove any sensitive data from `terraform.tfvars`
- ✅ Ensure `.gitignore` is committed first
- ✅ Review `git status` to see what will be pushed
- ✅ Check no JSON key files are being committed

### **After Pushing:**
- ✅ Add `DATABRICKS_ACCOUNT_ID` secret to new repo
- ✅ Add IAM binding for new repository
- ✅ Test with a draft PR

---

## 📞 READY WHEN YOU ARE!

**Provide:**
1. New repository URL
2. Repository org/name  
3. Branch preference

**I'll give you:**
1. Exact git commands
2. IAM binding command with your repo name
3. Testing instructions

**Let's do this! 🎉**

