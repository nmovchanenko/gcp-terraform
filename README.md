# GCP Infrastructure for SvelteKit with Terraform

This project provides a complete, production-ready infrastructure setup on Google Cloud Platform (GCP) for a modern web application. The entire infrastructure is defined and managed using HashiCorp Terraform, enabling automation, version control, and easy replication across different environments.

## Core Concepts

### Remote State Backend
This project is configured to use a **GCS remote backend**. This is a best practice that provides:
- **Security:** The state file, which contains sensitive information, is stored securely in a Google Cloud Storage bucket.
- **Collaboration:** A remote backend allows multiple team members to work on the same infrastructure safely.
- **Locking:** Terraform automatically locks the state file during operations, preventing concurrent runs from corrupting the state.

Before you can initialize Terraform, you must first create a GCS bucket for this purpose. This is a one-time setup task.

### Workspaces
We use Terraform workspaces to manage separate environments (e.g., `development`, `staging`). Each workspace gets its own isolated set of resources and its own state file within the GCS backend.

## Prerequisites
- [Google Cloud SDK (`gcloud` CLI)](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Docker](https://www.docker.com/get-started)

## Onboarding a New Developer
Here is the step-by-step guide for any developer to get started with this project.

### Step 1: Get the Code
Clone the repository to your local machine.
```sh
git clone <your-repository-url>
cd <repository-directory>
```

### Step 2: Authenticate with GCP
You must authenticate your local machine with GCP. This allows Terraform and other tools to manage resources on your behalf.
```sh
gcloud auth application-default login
```
Follow the prompts in your browser to log in to your Google account.

### Step 3: Configure Local Variables
This project uses a `terraform.tfvars` file for variables, which is ignored by Git to keep secrets safe.

1.  **Copy the example file:**
    ```sh
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    ```
2.  **Edit `terraform/terraform.tfvars`:**
    Open the new `terraform.tfvars` file and fill in the secret values (e.g., `billing_account_id`). You will get these from your team lead.

### Step 4: Initialize Terraform
Navigate to the `terraform` directory and run `init`. This downloads the necessary plugins and connects to the GCS remote backend defined in `backend.tf`.
```sh
cd terraform
terraform init
```

### Step 5: Select a Workspace
If you are working on an existing environment, select the corresponding workspace.
```sh
terraform workspace select development
```
If you are creating a brand new environment, create a new workspace:
```sh
terraform workspace new <environment_name>
```

You are now ready to plan and apply changes!

## Day-to-Day Workflow

### Provisioning or Updating Infrastructure
1.  **Navigate to the Terraform directory:** `cd terraform`
2.  **Ensure you are in the correct workspace:** `terraform workspace select <environment_name>`
3.  **Plan the changes:** `terraform plan`
4.  **Apply the changes:** `terraform apply`

### Deploying the Application
1.  **Configure Docker:**
    You only need to do this once per region. This command configures Docker to authenticate with Artifact Registry.
    ```sh
    gcloud auth configure-docker $(terraform output -raw project_region)-docker.pkg.dev
    ```
2.  **Build and Push the Docker Image:**
    From the **root of the project**, run the helper script:
    ```sh
    ./build-and-push.sh
    ```
3.  **Update the Image in Terraform:**
    The script will output the new image URI. Update the `image` argument in the `google_cloud_run_v2_service` resource in `terraform/4-app-hosting.tf` with this new URI.
4.  **Apply the Update:**
    ```sh
    terraform apply
    ```
    Terraform will detect the change to the Cloud Run service and deploy the new container image.

## Infrastructure Overview
Running `terraform apply` creates the following resources:
- **GCP Project:** A new, isolated project for your environment.
- **VPC Network:** A private network for your resources.
- **Cloud SQL for PostgreSQL:** A managed, private database instance.
- **Cloud Run Service:** A serverless, scalable environment to run your application container.
- **Artifact Registry:** A private Docker repository to store your application images.
- **And all necessary IAM bindings and APIs.**
