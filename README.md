
# Overview

This project have a terraform folder named `iac-app`, a simple rails application is under `app` folder. Finally, the helm charts are in `helm` folder. 

## Table of Contents
1. [Structure](#structure)
   - [IaC Infrastructure](#iac-infrastructure)
   - [GitHub Actions](#github-actions)
   - [K8s Definitions](#k8s-definitions)
2. [Test](#test)
3. [Improvements](#improvements)
4. [Prerequisites](#prerequisites)

## Structure

### IaC Infrastructure

This is a 3 layers structure. The main folder is `environment`. We have:
```
environment
└── prod
    └── us-east-1
        ├── argocd
        │   ├── data.tf
        │   └── main.tf
        ├── eks-infra
        │   ├── backend.tf
        │   ├── data.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── providers.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   ├── terraform.tfvars
        │   └── variables.tf
        ├── helm-charts
        └── tf-remote-backend
            ├── data.tf
            ├── main.tf
            ├── outputs.tf
            ├── providers.tf
            ├── terraform.tfstate
            ├── terraform.tfstate.backup
            ├── terraform.tfvars
            └── variables.tf
```

The `tf-remote-backend` contains the initial setup for the remote backend storage. Which in this case is s3. 
The `eks-infra` is where all we have a more abstract definitions. This calls the `infra-modules`, and this is where we actual define the modules,
```
infra-modules
├── argocd
│   ├── argocd.tf
│   ├── helm-provider.tf
│   ├── values
│   │   ├── argocd.yaml
│   │   └── image-updater.yaml
│   └── variables.tf
├── ecr
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── eks
│   ├── alb_iam_policy.json
│   ├── alb_role.tf
│   ├── bastion.tf
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── helm_charts
│   ├── helm-provider.tf
│   ├── main.tf
│   ├── values
│   │   └── aws-loadbalancer-controller.yml
│   └── variables.tf
├── rds
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── tf_remote_backend
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── vpc
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── variables.tf
    └── versions.tf
```

and lastly the `resource-modules`is where we have the single resources definition. There are only few there. Most of the modules used is from the `terraform-aws-modules`.
```
resource-modules
├── compute
│   └── ec2_key_pair
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── container
│   └── ecr
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── database
    └── dynamodb
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

### GiHub Actions

There is two workflows. 
```
.
├── dependabot.yml
└── workflows
    ├── build_and_push.yaml
    └── ruby_test_ci.yml
```
`ruby_test_ci.yml` runs on pull request (PR) and check and test the code for syntax and security vulnerabilities. 
Note: it doesn't have a test coverage. In order to avoid merge in case of failure, this have to be set in repo settings. 

`build_and_push.yml` runs on merge (main), this workflow trigger image buil and push it to AWS ECR repo. I have hardoded the name of the repo `app` for simplicity, this can be added as variable. 
The workflos authenticate using OpenID Connect (OIDC), and for this we need to update the role name (`L#26`). Account id can also be added as variable in the repo with `${{ env.ACCOUNT_ID }}`. Moreover, it uses only `latest` tag, tag version should be implemented in a prod environment.

### K8s definitions

The k8s definitions are under `k8s_definitions` folder. This solution implements Aplication Load Balancer (ALB), and for this we need the Service Account (SA) definitions `aws-load-balancer-controller-service-account.yaml`. 

In the `app_helm` folder we have the helm charts for the rail application:
- deployment
- service
- ingress

## Test

1. Clone the repo and go to `tf-remote-backend` to create the intial s3 bucket:
```bash
git clone <repo_url>
cd ./iac-app/environment/prod/us-east-1/tf-remote-backend
```

2. Configure AWS Credentials
Export your AWS credentials:
```bash
export AWS_ACCESS_KEY_ID=<acces_key>
export AWS_SECRET_ACCESS_KEY=<secret_key>
```
Alternatively, use `aws configure` or `aws-vault` for better security.

3. Initialize and Apply Terraform for Remote Backend
```bash
terraform init
terraform apply # -auto-approve
```
Verify the S3 bucket was created in the AWS console.

4. Deploy the infrastructure.
    
    4.1 Add your SSH key to `iac-app/infra_modules/eks/data.tf` (line 5).

    4.2 Navigate to the eks-infra folder:
```bash
cd ../eks-infra/
```
    4.3 Initialize and apply Terraform:
```bash
terraform init
terraform apply
```
    4.5 Verify the EKS cluster and other resources were created successfully.

5. Change the role name in `.github/workflows/build_and_push.yml` line 26. 
```bash
role-to-assume: arn:aws:iam::<account_id>:role/github-oidc-provider-aws
```
Note: terraform output (`oidc_role`).

6. Create a PR, this will trigger the `Test CI` workflow (`ruby_test_ci.yml`).

7. Merge the PR, this will trigger the `Docker image build and publish` workflow (`ruby_test_ci.yml`). 

8. After cluster has been created. Uncomment `iac-app/prod/us-east-1/eks-infra/maint.tf` (#L137-L143)

9. Re-run terraform apply to add the service account and aws load balancer controller.

10. Deploy the rails application, add the values from the ecr repo, rds endpoint and password from the secret manager.
```
cd ./k8s_definitions
aws eks update-kubeconfig --region us-east-1 --name eks-use1-prod-eks-infra # This will generate the kubeconfig file
helm install app ./helm_app \
  --set image.repository= \
  --set env.APP_DATABASE_PASSWORD= \
  --set env.APP_DATABASE_HOST= 
```

11. Go to aws console ec2 > Load balancers and copy the DNS name of the load balancer. Access from the browser `<alb_dns>/tasks`

## Improvements

1. The application dockerfile is not for production.
2. There is no test coverage for the application. That would need to be added in the github workflow when there is a PR.
3. The versioning tag of the image.
4. The cluster is set for public access. We should access the cluster connecting through the bastion EC2 with ssm manager. I was thinking to add a `Makefile` to automate this.
5. The ALB that connects to the application is internet facing. I believe would be more secure if set internal and use cloudfront to redirect to the internal alb.
6. Set up secret SCI driver to render the passwods.
6. Need to add ArgoCD to monitor the ECR for new image tag and automate the deployment.
7. Need to add monitoring. 

## Prerequisites
Before proceeding, ensure you have the following installed and configured:
- **Terraform** (v1.3.0 or higher)
- **AWS CLI** (v2.0 or higher)
- **kubectl** (v1.25 or higher)
- **Helm** (v3.10 or higher)
- **Docker** (v20.10 or higher)
- **GitHub CLI** (optional, for managing workflows)

Ensure your AWS account has the necessary permissions to create resources like EKS, RDS, ECR, etc.