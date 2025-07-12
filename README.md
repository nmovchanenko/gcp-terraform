# GCP Infrastructure for SvelteKit with Terraform

This project provides a complete, production-ready infrastructure setup on Google Cloud Platform (GCP) for a modern web application, such as one built with SvelteKit. The entire infrastructure is defined and managed using HashiCorp Terraform, enabling automation, version control, and easy replication across different environments.

The setup creates a secure, scalable, and private environment consisting of:
- A dedicated GCP Project per environment.
- A Virtual Private Cloud (VPC) for network isolation.
- A private Cloud SQL for PostgreSQL database.
- A serverless, auto-scaling Cloud Run service for hosting the application.
- An Artifact Registry repository for storing Docker images.

## Project Structure

-   `app/`: Contains the SvelteKit application source code, including its `Dockerfile` for containerization.
-   `terraform/`: Contains all the Terraform code for defining the GCP infrastructure.
-   `build-and-push.sh`: A helper script to build the application's Docker image and push it to GCP Artifact Registry.

## Prerequisites

Before you begin, you must have the following installed and configured:

1.  **Google Cloud Platform (GCP) Account:**
    *   You need an active GCP account with a valid Billing Account. The Free Trial is sufficient to get started.
    *   You can sign up here: [https://cloud.google.com/](https://cloud.google.com/)

2.  **Terraform:**
    *   This project uses Terraform to manage infrastructure as code.
    *   Follow the official instructions to install Terraform for your operating system: [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)

3.  **Google Cloud SDK (`gcloud` CLI):**
    *   The `gcloud` command-line tool is required for authenticating with your GCP account.
    *   Follow the official instructions to install the SDK: [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)

4.  **Docker:**
    *   Docker is required to build the application container image.
    *   Install Docker from the official website: [https://www.docker.com/get-started](https://www.docker.com/get-started)

## Setup and Authentication

1.  **Clone the Repository:**
    ```sh
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Authenticate with GCP:**
    Before running Terraform or Docker commands, you must authenticate your local machine with GCP. The simplest way to do this for development is by using Application Default Credentials (ADC).

    Run the following command and follow the prompts in your browser to log in to your Google account:
    ```sh
    gcloud auth application-default login
    ```
    Terraform will automatically use these credentials to provision resources on your behalf.

3.  **Configure Docker for GCP:**
    You also need to configure Docker to authenticate with Artifact Registry.
    ```sh
    gcloud auth configure-docker $(terraform -chdir=terraform output -raw project_region)-docker.pkg.dev
    ```
    *Note: You may need to run `terraform init` and `terraform apply` first to get the `project_region` output.*

## Usage

### Step 1: Provision the Infrastructure

The Terraform code is located in the `terraform/` directory.

1.  **Navigate to the Terraform directory:**
    ```sh
    cd terraform
    ```

2.  **Initialize Terraform:**
    This command downloads the necessary provider plugins.
    ```sh
    terraform init
    ```

3.  **Create a Workspace:**
    We use Terraform workspaces to manage separate environments (e.g., `development`, `staging`, `production`). Each workspace gets its own isolated set of resources.

    Create a new workspace (e.g., for development):
    ```sh
    terraform workspace new development
    ```
    *Note: You only need to do this once per environment.*

4.  **Configure Variables:**
    Before applying, you need to provide your GCP Billing Account ID. Open the `terraform/0-project.tf` file and replace the placeholder value for `billing_account` in the `google_project` resource with your actual Billing ID.

5.  **Plan the Changes:**
    Run a "dry run" to see what resources Terraform will create.
    ```sh
    terraform plan
    ```

6.  **Apply the Infrastructure:**
    This command will provision all the resources defined in the configuration.
    ```sh
    terraform apply
    ```

### Step 2: Build and Deploy the Application

Once the infrastructure is running, you can build and deploy the SvelteKit application.

1.  **Build and Push the Docker Image:**
    From the root of the project, run the helper script:
    ```sh
    ./build-and-push.sh
    ```
    This script builds the Docker image from the `app/` directory and pushes it to the Artifact Registry repository created by Terraform.

2.  **Deploy the New Image:**
    The `build-and-push.sh` script will output the new image URI. Update the `image` argument in the `google_cloud_run_v2_service` resource in `terraform/4-app-hosting.tf` with this new URI.

3.  **Apply the Update:**
    Navigate back to the `terraform/` directory and apply the change:
    ```sh
    terraform apply
    ```
    Terraform will detect the change to the Cloud Run service and deploy the new container image.

## Infrastructure Overview

Running `terraform apply` will create the following resources in your GCP account, organized by phase:

### Phase 1: Project Scaffolding and Networking
- **GCP Project:** A new, isolated project for your environment (e.g., `your-prefix-development-a1b2`).
- **APIs:** Enables essential APIs like Compute Engine.
- **VPC Network:** A private network (`development-vpc`) for your resources.

### Phase 2: Database Provisioning
- **Cloud SQL APIs:** Enables APIs for Cloud SQL and Service Networking.
- **VPC Peering:** Configures private service access to connect your VPC with Google services.
- **Cloud SQL for PostgreSQL:** A managed, private database instance, inaccessible from the public internet.
- **Database and User:** A specific database (schema) and a user for the SvelteKit application.

### Phase 3: Application Hosting
- **Cloud Run & VPC Access APIs:** Enables APIs for Cloud Run and VPC connectivity.
- **VPC Access Connector:** A bridge allowing Cloud Run to communicate with resources in the VPC (like the database).
- **Cloud Run Service:** A serverless, scalable environment to run your application container.
- **IAM Policies:** Sets public access for the Cloud Run invoker role, making the application accessible on the web.

### Phase 4: Application Containerization & Deployment
- **Artifact Registry:** A private Docker repository to store your application images.
- **IAM Permissions:** Grants the Cloud Run service account the necessary permissions (`roles/cloudsql.client`) to connect to the database.
