# Terraform CI/CD 

## Description:  

Create a CI/CD Pipeline(Using both Azure Devops pipeline and Github actions) and write a module to provision a VM instance and link the repo to the pipeline. 
<br> </br>
## Terrafom modules:

![](images/images/20220923122102.png)
- The file **“main.tf”** for provisioning a VM has been created in the module folder. 
```

resource "google_compute_instance" "default" {
  name = var.vm_name
  machine_type = var.machine_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network_name

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = "echo hi > /test.txt"
}
```

- **“backend.tf”** file for storing state file in GCS bucket. 

```terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
  }
  backend "gcs" {
    bucket = "$(bucket_name)"
    prefix = "$(backend_value)-statefile"
    credentials = "serviceaccount.json"

  }
}
```

- **“provider.tf”** consists of project and credentials details. 

```
provider "google" {
  version = "4.27.0"
  project = var.project_name
  credentials = file("serviceaccount.json")
}
```

- Variable data types were declared in **“variables.tf”** file and the values were declared in **“values.tfvars”** file.  

```
machine_type = "$(machine_type)"
vm_name = "$(vm_name)"
zone = "$(zone)"
boot_image = "$(boot_image)"
network_name = "$(network_name)"
project_name = "$(project_name)"
```

- **"main.tf"** consist of module that calls the compute instance resource block in module folder.
```
module "gce" {
  source = "./module"
  machine_type = var.machine_type
  vm_name = var.vm_name
  zone = var.zone
  image = var.boot_image
  network_name = var.network_name
}
```
<br> </br>

## Git:
- Git was initialized in the directory and remote origin of Azure Devops repo has been added to the master branch.  
  

![](images/20220923073527.png)  
<br> </br>
## Git repo in azure devops:
- The files were pushed into the repo in the master branch.  

![](images/20220923073912.png.png)  
<br> </br>
## Variable groups & secure files: 
- Variables required for terraform values were declared in the variable groups. 

- Multiple variables groups were created for build and each release stage. 

- The “serviceaccount.json” file was uploaded in the secure files. Sensitive files were uploaded in the secure files section for security.  

Variables groups:

![](images/20220923074351.png)  
<br> </br>
Variables in variable groups: 

![](images/20220923074545.png)  

<br> </br>
## Build Pipeline:  

- Variable group was linked to the build pipeline in Variables tab. 

![variable group linked to build pipeline](images/20220923102632.png)  
- Build pipeline was created with the following 7 tasks:

![](images/20220923074851.png)  


1.  Installed terraform with the required version with terraform tool installer. 

2.  The service account Json file was downloaded from the secure file's location.  

>![](images/20220923075231.png)  

3.  An artifact was built and published to the path of the project files.  

>![](images/20220923075343.png)  

4.  The backend variable and values were replaced with build variables which was declared in variables section. Changed target files to **".tf”** and **“.tfvars”**.   


> Variables in backend and values.tfvars to be replaced with variables in variable group:  
![](images/20220923103002.png)  
![](images/20220923103049.png)  


5. The downloaded secure file was added to the current working directory and terraform was initialized.  

>![](images/20220923104113.png) 

6. Terraform validate.

>![](images/20220923104241.png)   

7. Terraform plan.

>![](images/20220923104316.png)  

<br> </br>

## Build pipeline execution:
![](images/20220923105516.png)  




---
<br> </br>

## Release pipeline:
- A release pipeline was created with the following stages.

![](images/20220923110557.png)  
- The built artifact from the “terraform_build” pipeline was the selected in the artifacts section. 

![](images/20220923110748.png)  

- The variable groups were attached to respective stage scops in the pipeline variable groups. 

![](images/20220923112540.png)  
- The TEST stage consists of 7 tasks as follows:

![](images/20220923110838.png)  

1. Terraform was installed with the required version with terraform tool installer. 


2. The secure file was downloaded and copied to the current working directory. 

>![](images/20220923111757.png)  
3. The backend variable was replaced with build variable which was declared in variable groups. Changed target files to “.tf” and “.tfvars”.  
>![](images/20220923112044.png)  

4. The downloaded secure file was added to the current working directory and terraform was initialized. 

>![](images/20220923112158.png)  

5. Terraform validate.

>![](images/20220923112241.png)  
6. Terraform plan.

>![](images/20220923112308.png)  
7. Terraform apply.

>![](images/20220923112335.png)  
- The PROD stage also consists of the same tasks as TEST with different variable linked.

<br> </br>

## Release pipeline execution:
![](images/20220923112715.png)  

<br> </br>

## Results:
- Two VM’s were created in GCP from the two stages in release pipeline. 

![](images/20220923113027.png)  

<br> </br>

## Backend GCS bucket:
- The backend state files were created in a bucket with respective prefixes. 

![](images/20220923113119.png)  
---
<br> </br>
## Automation:
- Triggers can be set to trigger build and release pipelines.  

- Continuous integration triggers the pipeline whenever a new commit is made. 

- Scheduled trigger to schedule the trigger. 

- Build completion mode to trigger whenever a new version of dependent artifact is available. 

![](images/20220923113638.png)  

- Two types of triggers in release pipeline.

![](images/20220923113920.png)  

---

# Terraform CI using github actions:

- Create a folder in root directory **".github/workflows"** and create a file **"terraform.yml"**.
- Specify the name and the branches which acts as the trigger for pipeline to execute.
```
name: 'Terraform CI'

on:
  push:
    branches:
      - main
```

- In the job sections, create a test job with machine as "ubuntu-latest".
```
jobs:
  terraform_test:
    name: 'Terraform Test'
    runs-on: ubuntu-latest
    environment: test
```
- Now create steps in the job with steps which executes a sequence of steps that runs the terraform script.
- Add the actions **"checkout"** which checks-out the repository under $GITHUB_WORKSPACE, so the workflow can access it.
- Install the terraform package.
```
steps:
      # Checkout the repository to the GitHub Actions runner
      - name: Checkout
        uses: actions/checkout@v3
      
      # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1 
```
- Create a secret in git repo settings with "serviceaccount.json". make sure to convert json into single line while uploading the key.
<br></br>
![](images/secret.png)  

- Run terraform init,validate and plan commands in individual steps.
- Add the env variable serviceaccount.json secret to each step.

```
      # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
      - name: Terraform Init
        working-directory: ./Task-1_CI-CD-Terraform
        run: terraform init
        env:
          GOOGLE_CREDENTIALS: ${{secrets.GOOGLE_CREDENTIALS}}
      
      # format code
      - name: Terraform Format
        working-directory: ./Task-1_CI-CD-Terraform
        run: terraform fmt

      # terraform validate
      - name : terraform validate
        working-directory: Task-1_CI-CD-Terraform
        run: terraform validate
      
      # Generates an execution plan for Terraform
      - name: Terraform Plan
        working-directory: ./Task-1_CI-CD-Terraform
        run: terraform plan --var-file=values.tfvars
        env:
          GOOGLE_CREDENTIALS: ${{secrets.GOOGLE_CREDENTIALS}}
```
- Create another job "deployment" with same steps as "test" stage.
- Add "terraform apply" step to the deployment job which creates a VM.
- Specify "test" job in the "needs" steps which helps to run deployment job only when "test" job executes successfully.

```
terraform_deployment:
    name: 'Terraform Deployment'
    runs-on: ubuntu-latest
    needs:
      - terraform_test
    environment: deployment

    steps:
      ...  # terraform install,init,validate and plan steps.

      # applies terraform configuration
      - name: Terraform Apply
        working-directory: ./Task-1_CI-CD-Terraform
        run: terraform apply -auto-approve --var-file=values.tfvars
        env:
          GOOGLE_CREDENTIALS: ${{secrets.GOOGLE_CREDENTIALS}}  
```

### Execution:
![](images/completed_task.png)  

### Pipeline Completion
![](images/execution.png)  

### Results:
- VM got provisioned after pipeline completion.
![](images/vm.png)  