# Terraform Infrastructure Setup: Progress Log

This document tracks the progress of setting up our GCP infrastructure using Terraform.

## Phase 1: Project Scaffolding and Networking

Our initial goal was to establish a foundational GCP environment managed by Terraform, capable of supporting multiple environments (e.g., development, staging).

### Key Accomplishments:

1.  **Terraform Workspaces for Environments:**
    *   We configured our Terraform setup to use **workspaces** (`development`, `staging`, etc.). This allows us to use the same code to manage separate, isolated environments, each with its own state file.

2.  **Dynamic GCP Project Creation:**
    *   The Terraform configuration now automatically **creates a new GCP Project** for each environment.
    *   Project IDs are generated dynamically with a random suffix to ensure uniqueness (e.g., `your-prefix-development-a1b2`).
    *   This process is linked to a specific **Billing Account ID**.
    *   We solved a dependency cycle by using an **aliased provider (`google.project_creator`)** to separate the action of creating the project from managing resources within it.

3.  **Automated API Enablement:**
    *   The configuration automatically enables the **Compute Engine API** (`compute.googleapis.com`) on the newly created project.
    *   We solved a race condition by adding an explicit `depends_on` block to ensure resources are not created before their required APIs are fully enabled.

4.  **Virtual Private Cloud (VPC) Creation:**
    *   A dedicated **VPC network** is created within the new project.
    *   The VPC is named based on the current workspace (e.g., `development-vpc`), providing a secure and isolated networking environment for our application's resources.

### Current State:

As of now, running `terraform apply` will:
- Create a new GCP Project.
- Enable the Compute Engine API on it.
- Provision a VPC network inside the project.

This provides the fundamental building blocks for deploying our application's database and compute resources.

## Phase 2: Database Provisioning

With the networking in place, we've provisioned a secure and private database for our application.

### Key Accomplishments:

1.  **Enabled Cloud SQL APIs:**
    *   The configuration now automatically enables the `sqladmin.googleapis.com` and `servicenetworking.googleapis.com` APIs, which are prerequisites for creating a Cloud SQL instance and connecting it to our VPC.

2.  **Configured Private Service Access:**
    *   We successfully set up **VPC Peering** between our network and the Google services network.
    *   This was achieved by reserving an internal IP range (`google_compute_global_address`) and creating a `google_service_networking_connection`. This ensures that our Cloud SQL instance is only accessible via private IP addresses, not over the public internet.

3.  **Provisioned Cloud SQL for PostgreSQL:**
    *   A `google_sql_database_instance` has been created.
    *   It is configured to use a private network, disabling public IP access for enhanced security.
    *   We also created a specific database (schema) and a dedicated user for our SvelteKit application.

### Current State:

Our infrastructure now consists of a GCP Project containing a VPC network and a private Cloud SQL PostgreSQL database. The next step is to deploy our application and connect it to this database.

## Phase 3: Application Hosting with Cloud Run

We have deployed the serving layer for our application using Cloud Run, a serverless and scalable container hosting service.

### Key Accomplishments:

1.  **Enabled Cloud Run & VPC Access APIs:**
    *   The configuration now enables the `run.googleapis.com` and `vpcaccess.googleapis.com` APIs.

2.  **Created a Serverless VPC Access Connector:**
    *   We provisioned a `google_vpc_access_connector`, which acts as a bridge, allowing Cloud Run to communicate with resources inside our VPC using private IPs.

3.  **Deployed a Cloud Run Service:**
    *   A `google_cloud_run_v2_service` is now running.
    *   It is configured to use the VPC Access Connector, enabling it to securely reach the Cloud SQL database without any public IP exposure.
    *   For now, it runs a placeholder "hello world" container.

4.  **Configured Public Access:**
    *   An IAM binding was created to allow public, unauthenticated invocations of the Cloud Run service, making the web application accessible to everyone.

### Current State:

Our Terraform setup is now feature-complete for the core infrastructure. It automatically provisions a GCP Project with a VPC, a private PostgreSQL database, and a scalable Cloud Run service to host our application. The final step is to replace the placeholder container with our actual SvelteKit application.
