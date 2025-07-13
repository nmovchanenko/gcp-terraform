# GCP Infrastructure for SvelteKit with Terraform

This project provides a complete, production-ready infrastructure setup on Google Cloud Platform (GCP) for a modern web application. The entire infrastructure is defined and managed using HashiCorp Terraform, enabling automation, version control, and easy replication across different environments.

## Core Concepts

### CI/CD with GitHub Actions
This project is configured with a complete CI/CD pipeline using GitHub Actions to automate infrastructure management.
- **Plan on Pull Request:** When a pull request is opened, the workflow automatically runs `terraform plan` and posts the output as a comment on the PR for review.
- **Apply on Merge:** When a pull request is merged to the `main` branch, the workflow automatically runs `terraform apply` to deploy the changes to the `development` environment.
- **Authentication:** The pipeline uses a secure, passwordless OIDC connection between GitHub Actions and GCP via Workload Identity Federation.

### Remote State Backend
Terraform state is stored securely in a GCS remote backend, which enables team collaboration and state locking.

### Workspaces
We use Terraform workspaces to manage separate environments (e.g., `development`, `staging`). Each workspace gets its own isolated set of resources.

## Prerequisites
- [Google Cloud SDK (`gcloud` CLI)](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Docker](https://www.docker.com/get-started)

## Initial Project Setup (First-Time Use Only)
These steps are for the very first person setting up this project.

1.  **Configure Workload Identity Federation:** Follow the internal documentation to set up the GCS backend bucket, the `github-actions-deployer` service account, and the Workload Identity Federation trust between GCP and the GitHub repository.
2.  **Create GitHub Secrets:** In the GitHub repository settings (`Settings > Secrets and variables > Actions`), create the following repository secrets:
    - `TF_VAR_billing_account_id`: Your GCP Billing Account ID.
    - `TF_VAR_db_password`: The desired password for the Cloud SQL database.

## Onboarding a New Developer
Here is the step-by-step guide for any new developer to get started with local development.

1.  **Get the Code:** `git clone <your-repository-url>`
2.  **Authenticate with GCP:** `gcloud auth application-default login`
3.  **Configure Local Variables:**
    - `cp terraform/terraform.tfvars.example terraform/terraform.tfvars`
    - Edit `terraform/terraform.tfvars` and fill in the secret values provided by your team lead.
4.  **Initialize Terraform:** `cd terraform && terraform init`
5.  **Select Workspace:** `terraform workspace select development`

You are now ready to make changes locally.

## Day-to-Day Workflow

### Making Infrastructure Changes
1.  **Create a new branch:** `git checkout -b my-feature`
2.  **Make your changes** to the `.tf` files in the `terraform/` directory.
3.  **Commit and push** your branch.
4.  **Open a Pull Request** against the `main` branch.
5.  **Review the Plan:** The GitHub Actions bot will automatically run `terraform plan` and add the output as a comment on your PR. Verify that the changes are what you expect.
6.  **Merge:** Once approved, merge the pull request. The GitHub Actions bot will automatically run `terraform apply` to deploy your changes.

### Deploying the Application
1.  **Build and Push the Docker Image:**
    - Configure Docker for GCP (one-time setup): `gcloud auth configure-docker $(terraform -chdir=terraform output -raw project_region)-docker.pkg.dev`
    - From the project root, run: `./build-and-push.sh`
2.  **Update the Image in Terraform:**
    - In `terraform/4-app-hosting.tf`, update the `image` argument in the `google_cloud_run_v2_service` resource with the new image URI from the script output.
3.  **Commit and push** this change through the PR workflow described above.

## Infrastructure Overview
- **GCP Project:** A new, isolated project for your environment.
- **VPC Network:** A private network for your resources.
- **Cloud SQL for PostgreSQL:** A managed, private database instance.
- **Cloud Run Service:** A serverless, scalable environment to run your application container.
- **Artifact Registry:** A private Docker repository to store your application images.
- **And all necessary IAM bindings and APIs.**
