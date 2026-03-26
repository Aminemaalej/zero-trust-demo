# Zero Trust Access Demo with Google Cloud IAP

A Terraform demo that proves Zero Trust access works by granting SSH access to a **completely private VM** based on **identity, not network location**. No VPN, no public IP, no firewall exceptions — just your Google identity.

## How It Works

Traditional security puts a wall (VPN/firewall) around your network. Zero Trust flips this: **every request is verified by identity**, regardless of where it comes from.

This demo creates:

1. **A private VPC** — an isolated network with no internet-facing entry points.
2. **A private VM** (`top-secret-db-server`) — a server with **no public IP**, invisible to the internet.
3. **A firewall rule** — allows only Google's [Identity-Aware Proxy (IAP)](https://cloud.google.com/iap) range (`35.235.240.0/20`) to reach the VM on port 22.
4. **An IAM binding** — grants the `roles/iap.tunnelResourceAccessor` role to a specific email address, like handing a hotel keycard directly to a person.

The result: you SSH into the private server seamlessly. Google validates your identity in the background, establishes a secure tunnel, and drops you in — no VPN required.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Google Cloud                       │
│                                                     │
│  ┌──────────── zero-trust-network (VPC) ──────────┐ │
│  │                                                 │ │
│  │  ┌─────────── private-subnet ────────────────┐  │ │
│  │  │          10.0.1.0/24                      │  │ │
│  │  │                                           │  │ │
│  │  │  ┌─────────────────────────────────────┐  │  │ │
│  │  │  │  top-secret-db-server (e2-micro)    │  │  │ │
│  │  │  │  NO public IP                       │  │  │ │
│  │  │  └─────────────────────────────────────┘  │  │ │
│  │  │              ▲                            │  │ │
│  │  └──────────────┼────────────────────────────┘  │ │
│  │                 │ port 22                       │ │
│  │  ┌──────────────┼────────────────────────────┐  │ │
│  │  │  Firewall: allow only 35.235.240.0/20     │  │ │
│  │  │  (Google IAP range)                       │  │ │
│  │  └──────────────┼────────────────────────────┘  │ │
│  └─────────────────┼──────────────────────────────┘ │
│                    │                                 │
│         ┌──────────┴──────────┐                     │
│         │  Identity-Aware     │                     │
│         │  Proxy (IAP)        │                     │
│         │  ✓ Verify identity  │                     │
│         │  ✓ Establish tunnel │                     │
│         └──────────┬──────────┘                     │
└────────────────────┼────────────────────────────────┘
                     │
            ┌────────┴────────┐
            │  Developer      │
            │  (your email)   │
            │  Any network    │
            └─────────────────┘
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) installed and authenticated
- A GCP project with billing enabled

## Quick Start

1. **Authenticate with Google Cloud:**

   ```bash
   gcloud auth application-default login
   ```

2. **Configure your variables** by creating a `terraform.tfvars` file:

   ```hcl
   project_id      = "your-gcp-project-id"
   developer_email = "you@example.com"
   ```

3. **Deploy the infrastructure:**

   ```bash
   terraform init
   terraform apply
   ```

4. **Connect to the private server** using the output command:

   ```bash
   gcloud compute ssh top-secret-db-server \
     --zone=us-central1-a \
     --tunnel-through-iap \
     --project=your-gcp-project-id
   ```

   Google validates your identity, creates a secure tunnel, and drops you into the server — no VPN needed.

## File Structure

```
zero-trust-demo/
├── main.tf            # Provider configuration and API enablement
├── variables.tf       # Input variable declarations
├── terraform.tfvars   # Your variable values (git-ignored)
├── network.tf         # VPC, subnet, and firewall rules
├── compute.tf         # Private VM instance
├── iam.tf             # IAP identity-based access binding
└── outputs.tf         # SSH connect command output
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `project_id` | GCP project ID | — (required) |
| `region` | GCP region | `us-central1` |
| `zone` | GCP zone | `us-central1-a` |
| `developer_email` | Google email to grant access to | — (required) |

## Cleanup

```bash
terraform destroy
```

## Key Takeaway

The server has **no public IP**. There is **no VPN**. Access is granted to a **specific identity** — not a network range. This is Zero Trust in action: verify the person, not the perimeter.
