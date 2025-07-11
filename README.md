# GCP Infrastructure for SvelteKit with Terraform

This project provides a complete, production-ready infrastructure setup on Google Cloud Platform (GCP) for a modern web application, such as one built with SvelteKit. The entire infrastructure is defined and managed using HashiCorp Terraform, enabling automation, version control, and easy replication across different environments.

The setup creates a secure, scalable, and private environment consisting of:
- A dedicated GCP Project per environment.
- A Virtual Private Cloud (VPC) for network isolation.
- A private Cloud SQL for PostgreSQL database.
- A serverless, auto-scaling Cloud Run service for hosting the application.

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

## Setup and Authentication

1.  **Clone the Repository:**
    ```sh
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Authenticate with GCP:**
    Before running Terraform, you must authenticate your local machine with GCP. The simplest way to do this for development is by using Application Default Credentials (ADC).

    Run the following command and follow the prompts in your browser to log in to your Google account:
    ```sh
    gcloud auth application-default login
    ```
    Terraform will automatically use these credentials to provision resources on your behalf.

## Usage

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

## Infrastructure Overview

Running `terraform apply` will create the following resources in your GCP account:

- **GCP Project:** A new, isolated project for your environment.
- **APIs:** Enables all necessary APIs (Compute, Cloud SQL, Cloud Run, etc.).
- **VPC Network:** A private network for your resources.
- **VPC Peering:** Configures private service access for Cloud SQL.
- **Cloud SQL for PostgreSQL:** A managed, private database instance.
- **VPC Access Connector:** Allows Cloud Run to connect to the VPC.
- **Cloud Run Service:** A serverless environment to run your application container.
- **IAM Policies:** Sets public access for the Cloud Run invoker role.
