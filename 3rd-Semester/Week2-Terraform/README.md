 # Week 2 Terraform Project: AWS Infrastructure with Terraform Workspaces

## 1. Project Overview

This project demonstrates how to use Terraform to provision and manage AWS infrastructure across three environments:

- **Development (`dev`)**
- **Staging (`staging`)**
- **Production (`prod`)**

The main objective is to learn how to write reusable Terraform configurations instead of maintaining separate copies of the same infrastructure for different environments.

Terraform workspaces allow the same configuration to manage separate instances of infrastructure state. The selected workspace is available through `terraform.workspace`, which this project uses to customize resource names, tags, instance types, S3 versioning, and CloudWatch alarm creation.

This project also introduces variables, outputs, data sources, loops, conditional expressions, provider configuration, validation, and Terraform's planning workflow.

> **Important:** This repository is intended for learning and demonstration. A successful `terraform plan` does not mean that resources have been created in AWS. Always inspect the plan before applying it.

---

## 2. Learning Objectives

By completing this project, I should understand how to:

1. Configure Terraform to use AWS.
2. Separate Terraform configuration into multiple `.tf` files.
3. Define variables and provide values through a `.tfvars` file.
4. Use a provider version constraint.
5. Use Terraform workspaces to separate development, staging, and production configurations.
6. Use `terraform.workspace` to identify the selected environment.
7. Use `count` to create multiple EC2 instances and subnets.
8. Use `cidrsubnet()` to calculate subnet CIDR blocks.
9. Use conditional expressions to control resource behavior.
10. Use a map to select an EC2 instance type for each environment.
11. Use data sources to find an Amazon Linux AMI.
12. Configure an S3 bucket and environment-specific versioning.
13. Create a CloudWatch CPU alarm only in production.
14. Define outputs for important resource attributes.
15. Validate and review infrastructure changes before deployment.
16. Protect sensitive files and submit changes to GitHub through branches and pull requests.

---

## 3. Architecture and Resources

The Terraform configuration defines the following AWS resources:

| Resource | Purpose |
|---|---|
| VPC | Provides an isolated virtual network. |
| Subnets | Divide the VPC network across configured Availability Zones. |
| Internet Gateway | Provides a gateway attachment to the VPC. A route table and route are also needed for actual internet routing. |
| Security group | Controls inbound and outbound traffic for EC2 instances. |
| EC2 instances | Provide compute capacity for the project. |
| S3 bucket | Provides object storage. |
| S3 bucket versioning | Controls whether object versions are retained. |
| CloudWatch CPU alarm | Monitors EC2 CPU utilization in production. |

The project uses variables to control the region, CIDR ranges, instance count, bucket prefix, and other configuration values.

### Expected environment behavior

| Setting | dev | staging | prod |
|---|---|---|---|
| EC2 instance type | `t3.micro` | `t3.small` | `t3.medium` |
| EC2 instance count | 2 by default | 2 by default | 2 by default |
| S3 versioning | Suspended | Enabled | Enabled |
| CloudWatch CPU alarm | No | No | Yes |

These values come from the current configuration. Changing the variables or workspace logic may change the result.

---

## 4. Project File Structure

The project should contain the following files:

```text
Terraform project/
├── main.tf
├── variables.tf
├── provider.tf
├── versions.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.tfvars.example
├── .terraform.lock.hcl
├── .gitignore
└── README.md
```

Terraform may also create local directories and state files while working. Those files should not be committed to GitHub.

### What each file does

#### `main.tf`

Contains the main infrastructure resources, such as the VPC, subnets, security group, EC2 instances, S3 bucket, and CloudWatch alarm.

#### `variables.tf`

Defines the inputs that control the configuration. Variables make the project reusable without editing resource definitions every time a value changes.

#### `provider.tf`

Configures the AWS provider, including the AWS region and named AWS CLI profile.

#### `versions.tf`

Defines the minimum supported Terraform version and the permitted AWS provider version range.

#### `outputs.tf`

Defines values Terraform should display after a successful apply, such as the VPC ID, EC2 instance IDs, public IP addresses, S3 bucket name, and whether the CloudWatch alarm exists.

#### `terraform.tfvars`

Contains the actual values for this local environment. It may include a local AWS profile name and must not be uploaded to a public repository.

#### `terraform.tfvars.example`

Provides example variable values for another person to copy and customize. It should contain placeholders, not credentials.

#### `.terraform.lock.hcl`

Records the selected provider versions and checksums so Terraform can use consistent provider dependencies.

#### `.gitignore`

Tells Git which local files and directories to exclude from version control.

#### `README.md`

Documents the project's purpose, setup, commands, design decisions, and troubleshooting steps.

---

## 5. Prerequisites

Before recreating this project, install and configure:

- Terraform CLI
- AWS CLI
- Visual Studio Code
- Git
- An AWS account with appropriate permissions

Check that Terraform is installed:

```powershell
terraform --version
```

Check that AWS CLI is installed:

```powershell
aws --version
```

Check that Git is installed:

```powershell
git --version
```

If a command is not recognized, verify that the program is installed and that its executable directory is included in the Windows PATH.

---

## 6. Configure AWS CLI

Terraform needs a way to authenticate with AWS.

The AWS CLI can use a named profile. This project uses a profile named `terraform.lab` in the AWS CLI setup described during development.

### Step 1: Configure the profile

If the profile has not been configured, run:

```powershell
aws configure --profile terraform.lab
```

Enter the required AWS CLI values when prompted. Use your own AWS credentials and region.

Do not place access keys or secret keys inside Terraform resource definitions.

If your AWS environment uses temporary credentials or another authentication method, follow that environment's authentication procedure instead.

### Step 2: Verify the profile

Run:

```powershell
aws sts get-caller-identity --profile terraform.lab
```

This command checks whether AWS can identify the authenticated caller.

If it succeeds, the output should contain information such as the AWS account ID and caller ARN.

If authentication fails, check the profile name, credential configuration, and whether temporary credentials have expired.

### Step 3: Configure Terraform's profile

In `provider.tf`, the provider references variables:

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

The `var.` prefix tells Terraform to use the value of a variable. Do not put the variable name in quotation marks.

For example, `profile = var.aws_profile` references the variable. `profile = "var.aws_profile"` would pass the literal text instead.

**Note:** The profile configured for Terraform must actually exist and have usable credentials. Use the profile name that works in your own AWS environment.

---

## 7. Define Terraform Variables

Variables make the project easier to customize.

A variable has a name, a type, and optionally a default value, description, or validation rule.

For example:

```hcl
variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}
```

Here:

- `variable "aws_region"` declares the variable.
- `description` explains its purpose.
- `type = string` means the value should be text.
- `default` provides a value when another value is not supplied.

### Important project variables

| Variable | Purpose |
|---|---|
| `aws_region` | AWS region used by the provider. |
| `aws_profile` | Named AWS CLI profile used for authentication. |
| `project_week2` | Project naming prefix. |
| `bucket_prefix` | Prefix used to form the S3 bucket name. |
| `vpc_cidr` | CIDR block for the VPC. |
| `instance_count` | Number of EC2 instances to create. |
| `instance_types` | Map of instance types by workspace. |
| `availability_zones` | List of Availability Zones for subnet creation. |
| `ssh_allowed_cidrs` | Intended input for SSH source CIDR ranges. |
| `http_allowed_cidrs` | Intended input for HTTP source CIDR ranges. |

The `ssh_allowed_cidrs` and `http_allowed_cidrs` variables only control security group rules if the resource actually references them. In the current plan, the SSH and HTTP rules are still open to `0.0.0.0/0`; do not assume those variables are already restricting traffic.

### Why validation matters

Validation can reject invalid input before Terraform attempts to provision resources.

For example, the instance count should remain within the allowed range:

```hcl
validation {
  condition     = var.instance_count >= 1 && var.instance_count <= 10
  error_message = "instance_count must be between 1 and 10."
}
```

This prevents a value outside the specified range from being accepted.

The availability-zone list can also be validated to ensure that the project uses the intended number of zones.

### Example variable values

A local `terraform.tfvars` file supplies the actual values:

```hcl
aws_region     = "us-east-1"
aws_profile    = "your-working-profile"
project_week2  = "week2"
bucket_prefix  = "week2"
vpc_cidr       = "10.0.0.0/16"
instance_count = 2
```

Replace `your-working-profile` with a profile that exists on your computer.

---

## 8. Understand the Terraform Workspaces

Terraform workspaces provide separate state for different instances of the same configuration.

They do not automatically create different configurations or guarantee complete production isolation. In this project, workspace-aware expressions determine how resources differ between environments.

### List workspaces

```powershell
terraform workspace list
```

### Create workspaces

Create each workspace only if it does not already exist:

```powershell
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

If Terraform reports that a workspace already exists, do not create it again.

### Select a workspace

To work in development:

```powershell
terraform workspace select dev
```

To work in staging:

```powershell
terraform workspace select staging
```

To work in production:

```powershell
terraform workspace select prod
```

Check the selected workspace:

```powershell
terraform workspace show
```

Always verify the selected workspace before running a plan or applying changes.

### How `terraform.workspace` works

A resource name can include the selected workspace:

```hcl
Name = "${var.project_week2}-${terraform.workspace}-vpc"
```

If `terraform.workspace` is `dev`, the resulting name is:

```text
week2-dev-vpc
```

If the workspace is `staging`, the resulting name becomes:

```text
week2-staging-vpc
```

This approach helps make resource names unique across environments.

Workspace-based names do not guarantee that every resource will be unique. S3 bucket names, in particular, must be unique across AWS accounts and partitions.

---

## 9. Create Subnets with `count` and `cidrsubnet()`

The subnet resource uses a loop:

```hcl
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}
```

### What `count` does

`count` tells Terraform how many instances of a resource to create.

If the Availability Zone list contains two entries, Terraform creates two subnet instances:

- `aws_subnet.public[0]`
- `aws_subnet.public[1]`

### What `count.index` means

`count.index` is the zero-based index of the current resource instance.

The first instance has index `0`; the second has index `1`.

This index is used to select the corresponding Availability Zone and subnet number.

### What `cidrsubnet()` does

The function calculates a smaller network from a larger CIDR block.

For the configured VPC CIDR `10.0.0.0/16`, the expression `cidrsubnet(var.vpc_cidr, 8, count.index)` produces:

- Index `0`: `10.0.0.0/24`
- Index `1`: `10.0.1.0/24`
- Index `2`: `10.0.2.0/24`

The second argument adds eight network bits, changing `/16` into `/24`. The final argument chooses the subnet number.

This allows multiple subnets to be generated without manually writing a different CIDR for each subnet.

---

## 10. Create Multiple EC2 Instances

The EC2 resource uses `count`:

```hcl
resource "aws_instance" "web" {
  count = var.instance_count

  # Other EC2 configuration goes here.
}
```

If `instance_count` is `2`, Terraform creates two instances.

Their addresses are:

- `aws_instance.web[0]`
- `aws_instance.web[1]`

The instance type is selected from a map:

```hcl
instance_type = var.instance_types[terraform.workspace]
```

For example, when the workspace is `dev`, Terraform looks up `dev` in the `instance_types` map and selects `t3.micro`.

When the workspace is `prod`, it selects `t3.medium`.

Resource tags can also include the workspace:

```hcl
tags = {
  Name        = "${var.project_week2}-${terraform.workspace}-web-${count.index}"
  Environment = terraform.workspace
}
```

This makes it easier to distinguish instances in the AWS console.

The AMI data source looks up an Amazon Linux image. The AMI ID can vary as AWS publishes new images, so a successful plan should be checked for the intended operating system and region.

---

## 11. Configure the Security Group

The security group defines network traffic allowed to reach the instances.

The current configuration includes:

- Inbound SSH on TCP port `22`.
- Inbound HTTP on TCP port `80`.
- Outbound traffic using an unrestricted egress rule.

### Security warning

The current plan shows both inbound rules allowing `0.0.0.0/0`. This means SSH connection attempts can originate from any public IPv4 address.

For safer practice, restrict SSH to your own trusted IP range. Use variable-driven ingress rules if the configuration is updated to reference `ssh_allowed_cidrs` and `http_allowed_cidrs`.

A variable declaration alone does not change a security group rule.

Do not expose SSH broadly in a real deployment unless you have a deliberate and justified security design.

---

## 12. Configure the S3 Bucket and Versioning

The bucket name is built from the configured prefix and workspace:

```hcl
bucket = "${var.bucket_prefix}-${terraform.workspace}-cloud-lab-739284"
```

This produces a different bucket name for each workspace.

For example:

```text
week2-dev-cloud-lab-739284
```

The number in the example is a suffix used by this project. If the name is already taken globally, choose another unique suffix.

S3 versioning is controlled through a conditional expression:

```hcl
versioning_configuration {
  status = terraform.workspace == "dev" ? "Suspended" : "Enabled"
}
```

The conditional follows this structure:

```text
condition ? value_if_true : value_if_false
```

In this case:

- If the selected workspace is `dev`, versioning is suspended.
- Otherwise, versioning is enabled.

The bucket resource and its versioning resource are separate Terraform resources. Both are needed for the intended configuration.

---

## 13. Create the CloudWatch Alarm Only in Production

The alarm resource uses a conditional `count`:

```hcl
count = terraform.workspace == "prod" ? 1 : 0
```

The condition means:

- In `prod`, `count` is `1`, so Terraform plans one alarm.
- In `dev` or `staging`, `count` is `0`, so Terraform plans no alarm.

The alarm monitors the EC2 `CPUUtilization` metric and compares the average against a threshold.

The current configuration uses a threshold of 80, two evaluation periods, and a 120-second period.

Because the alarm resource uses `count`, its instances are indexed. For example, the production alarm is addressed as:

```hcl
aws_cloudwatch_metric_alarm.cpu_alarm[0]
```

The configuration uses the first EC2 instance for the alarm's `InstanceId` dimension.

---

## 14. Define Outputs

Outputs make important values available after Terraform applies a configuration.

The project defines outputs for:

- VPC ID
- EC2 instance IDs
- EC2 public IP addresses
- S3 bucket name
- Whether a CloudWatch alarm is configured

For example:

```hcl
output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}
```

The output refers directly to the VPC resource.

For a resource created with `count`, use a splat expression to retrieve values from all instances:

```hcl
value = aws_instance.web[*].id
```

The alarm output uses the length of the alarm resource collection:

```hcl
value = length(aws_cloudwatch_metric_alarm.cpu_alarm) > 0
```

This evaluates to `true` when an alarm instance is configured and `false` when the collection is empty.

Outputs may be unknown during planning because AWS resource IDs and public IP addresses are not available until resources are created.

---

## 15. Initialize and Validate the Project

Run these commands from the project directory.

### Step 1: Initialize Terraform

```powershell
terraform init
```

This initializes the working directory, downloads required providers, and prepares the dependency lock file.

### Step 2: Format the configuration

```powershell
terraform fmt -recursive
```

This formats Terraform files consistently.

### Step 3: Validate the configuration

```powershell
terraform validate
```

This checks whether the Terraform configuration is syntactically valid and internally consistent.

### Step 4: Confirm the workspace

```powershell
terraform workspace show
```

Ensure the intended environment is selected.

### Step 5: Review the plan

```powershell
terraform plan
```

Terraform calculates the changes it would make without creating the resources.

A plan showing `9 to add, 0 to change, 0 to destroy` means Terraform proposes adding nine resources, changing none, and destroying none. The exact count may differ if the configuration changes.

Do not assume a successful plan proves that every resource is fully configured for its intended use. Review the resource attributes and networking configuration too.

---

## 16. Test the Environment Differences Safely

Review the plan separately for each workspace.

### Development

```powershell
terraform workspace select dev
terraform plan
```

Expected behavior:

- `t3.micro` instances.
- S3 versioning suspended.
- No CloudWatch alarm.

### Staging

```powershell
terraform workspace select staging
terraform plan
```

Expected behavior:

- `t3.small` instances.
- S3 versioning enabled.
- No CloudWatch alarm.

### Production

```powershell
terraform workspace select prod
terraform plan
```

Expected behavior:

- `t3.medium` instances.
- S3 versioning enabled.
- One CloudWatch CPU alarm.

These are plans only. Switching workspaces and running `terraform plan` does not itself deploy the infrastructure.

> **Cost safety:** Do not run `terraform apply` just to complete these checks. EC2, S3, CloudWatch, and other AWS services can incur charges when resources are created or used.

---

## 17. Common Errors and Troubleshooting

### Terraform command is not recognized

Check installation:

```powershell
terraform --version
```

If it fails, verify the installation directory and Windows PATH, then reopen the terminal.

### AWS profile cannot be found

Check the profiles configured on the computer:

```powershell
aws configure list-profiles
```

Verify that the name in `terraform.tfvars` matches a real profile.

### AWS authentication fails

Run:

```powershell
aws sts get-caller-identity --profile terraform.lab
```

Use your actual profile name if it differs. If temporary credentials have expired, renew them using the authentication method required by your environment.

### Terraform reports a missing required argument or resource instance key

Check the resource definition and any references to it.

For resources using `count`, Terraform may require an index such as `[0]` or an expression such as `[*]`, depending on the context.

### Terraform reports a provider version issue

Check `versions.tf`, then run:

```powershell
terraform init
```

Do not delete the lock file simply to suppress a version problem. Review the provider constraints and the error message first.

### S3 bucket name is already taken

S3 bucket names must be globally unique. Update the suffix or prefix and review the plan again.

### A workspace already exists

Run:

```powershell
terraform workspace list
```

Select an existing workspace instead of trying to create it again.

### Plan shows unexpected changes or destruction

Stop and inspect the plan before applying anything. Check the selected workspace, variable values, resource names, and state configuration.

---

## 18. GitHub Submission Workflow

The assignment uses a staged branch workflow:

**Feature branch → `review` → `main`**

The purpose is to develop changes in a feature branch, review them before merging, and keep `main` as the final submission branch.

### Prepare Git safely

Before staging files, verify `.gitignore` excludes at least:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
!terraform.tfvars.example
crash.log
crash.*.log
```

Keep `.terraform.lock.hcl` in version control.

Do not commit AWS credentials, session tokens, real `.tfvars` files, or Terraform state files.

### Initialize the Git repository

If the folder is not already a Git repository:

```powershell
git init
```

Check the current status:

```powershell
git status
```

Review every file listed before staging it.

### Create a feature branch

Use the branch name required for the assignment. For example:

```powershell
git switch -c feature/terraform-workspaces
```

Stage and commit the intended changes:

```powershell
git add main.tf variables.tf provider.tf versions.tf outputs.tf .terraform.lock.hcl .gitignore README.md terraform.tfvars.example
git commit -m "Refactor Terraform project for workspaces"
```

Only stage files you have reviewed. Never add `terraform.tfvars` or state files.

### Push the feature branch

After connecting the local repository to the correct GitHub repository:

```powershell
git push -u origin feature/terraform-workspaces
```

Open a pull request from the feature branch to `review`, following the assignment instructions.

After the review changes are approved, merge them into `review`. Then open a pull request from `review` to `main` and merge according to the required workflow.

If the instructor requires multiple feature branches or incremental pull requests, create them according to the individual assignment milestones rather than putting all work into one final commit.

---

## 19. Repeat the Project from Scratch

To practice the project again without relying on memory, follow this sequence:

1. Create a new project directory.
2. Open it in VS Code.
3. Create `versions.tf` and define the required Terraform and AWS provider versions.
4. Create `provider.tf` and configure the AWS provider using variables.
5. Create `variables.tf` and define the inputs and validation rules.
6. Create `terraform.tfvars` locally with the values needed for your own AWS profile.
7. Create the VPC resource.
8. Create the subnet resource using `count`, the Availability Zone list, and `cidrsubnet()`.
9. Create the security group and review the allowed inbound traffic.
10. Add the AMI data source.
11. Create EC2 instances using `count` and the workspace-specific instance type map.
12. Create the S3 bucket and its versioning resource.
13. Add the production-only CloudWatch alarm.
14. Create `outputs.tf`.
15. Create `.gitignore`, `terraform.tfvars.example`, and this README.
16. Run `terraform init`.
17. Run `terraform fmt -recursive`.
18. Run `terraform validate`.
19. Create or select the `dev`, `staging`, and `prod` workspaces.
20. Run `terraform plan` in each workspace and compare the results.
21. Inspect the Git status and confirm sensitive files are excluded.
22. Submit the changes through the required GitHub branch and pull-request workflow.

The goal is to understand why each file and resource exists, not just to reproduce the commands.

---

## 20. Final Checklist

Before considering the assignment complete, verify the following:

- [ ] AWS CLI authentication works.
- [ ] The AWS provider uses variables rather than hardcoded profile and region strings.
- [ ] Terraform and provider version constraints are defined.
- [ ] Resource names and environment tags use the workspace appropriately.
- [ ] Subnets are generated from the Availability Zone list.
- [ ] EC2 instance count is controlled by a variable.
- [ ] EC2 instance type is selected from the environment map.
- [ ] S3 versioning is suspended in `dev` and enabled in `staging` and `prod`.
- [ ] CloudWatch alarm creation is limited to `prod`.
- [ ] Outputs are defined for the required resource values.
- [ ] `terraform fmt -recursive` completes.
- [ ] `terraform validate` succeeds.
- [ ] Plans have been reviewed in all three workspaces.
- [ ] `.gitignore` protects state files and real `.tfvars` files.
- [ ] `.terraform.lock.hcl` is included in version control.
- [ ] `README.md` and `terraform.tfvars.example` are included.
- [ ] GitHub branches and pull requests follow the assignment workflow.
- [ ] No AWS resources were created unintentionally.

## Final Reminder

Terraform workspaces separate state, but they are not a replacement for strong production isolation, access control, or separate AWS accounts where those are required.

For this learning project, prioritize understanding the configuration, checking each plan, protecting credentials, and documenting the decisions you make.
