# POC - dbt serverless on aws

## Index:

### [Pipeline architecture](#pipeline-architecture)
### [Network infrastructure and policies](#network-infrastructure-and-policies)
### [Set up the project](#set-up-the-project)
### [Implementation](#implementation)
### [AWS services](#aws-services)
- ###  [Roles](#roles)
- ###  [Costs](#costs)
###  [Resources](#resources)

------------------------------------------------------
## Pipeline architecture
<img src="images/data_pipeline_diagram_serverless.drawio.png" alt="pipeline architecture" width="650"/>

The above architecture depicts a simple ELT pipeline in which raw data are loaded directly from sources into an S3 bucket. These raw data are then used to populate external tables in the *Redshift* data warehouse, which serve as the source tables for our dbt project. All the transformation phases, including testing and documentation, are managed by *dbt*. We have implemented a serverless version of dbt using a dbt Docker image hosted in *ECR*. We can configure a cron schedule using the *AWS EventBridge* service to run *ECS tasks* that execute any dbt CLI command. Logs from ECS task execution can be monitored using *Cloudwatch*, and *Lambda functions* can be used to respond to any potential failures.

Once the data has been transformed and cleaned, it is ready to be displayed in *Quicksight*.

------------------------------------------------------

## Network infrastructure and policies 
<img src="images/AWS_network_and_policies.drawio.png" alt="pipeline architecture" width="650"/>

The above schema depicts the AWS VPC and all the internal subnets, security groups, and ACLs involved in the pipeline, including all the roles assumed by each service to operate within it.

-------------------------------------------------------

## Set up the project
- [Set up AWS](#set-up-aws)
- [Set up dbt](#set-up-dbt)

### Set up AWS
Before running dbt models we need to set-up the AWS environment
- Restart the Redshift cluster **redshift-cluster-dbt-project-demo**
- Schedule ECS Tasks (needed  only for dbt serverless)

### Set up dbt
Prerequisite of the system : 
    requires Python and git to successfully install and run dbt Core. 
    Install Git and Python version 3.7 or higher.

Clone the git-ub repository : https://github.com/fermic98/dbt-aws-project on VScode move on the dbt folder then execute 
- dbt deps
- dbt run
- dbt test

-------------------------------------------------------

## Implementation
### dbt with Redshift
**The sources** have not been implemented, instead data have been manually loaded in the s3 bucket as .txt files for semplicity.

The first important step is to upload the raw data in the Redshift cluster as external tables. To do so, **AWS Glue Data Catalogue** has been used to automatically crawl the files and collect metadata from them, and **external tables** have been created in the Redshift database to store them.
```sql
create external schema tickit_external
from data catalog
database 'tickit_dbt'
iam_role 'arn:aws:iam::<your_aws_acccount_id>:role/ClusterPermissionsRole'
create external database if not exists;
```

Then, those external tables have been configured as **source  tables** in [dbt sources](link) and matched with the ones created on Redshift thanks to the package **dbt-labs/dbt_external_tables** running the command :
```
dbt run-operation stage_external_sources
```

Once we execute the dbt run command, all the models are created in Redshift respecting the dependency order shown in the autogenerated DAG.


### dbt serverless
After we have configured the communication between dbt and Redshift, we have built a Docker image of the dbt project and loaded the container in ECR.

**WARNING :** The Docker image contains the profiles.yml file that should be encrypted and secured within AWS exploiting AWS Secrets Manager.

We can now define ECS tasks to run within AWS Fargate our container instance with a command that can be easily defined during task definition.

To react to any potential failures, it is possible to run Lambda functions setting both the command to be executed and environmental variables of the ECS Tasks.
The following is an exmaple of the Lambda functions used : 
```python
import boto3

def lambda_handler(event, context):
    # Define the ECS client
    ecs = boto3.client('ecs')

    # Define the parameters dictionary
    parameters = {
        "taskDefinition": "arn:aws:ecs:eu-west-1:999017169478:task-definition/dbt-models-building:2",
        "cluster": "arn:aws:ecs:eu-west-1:999017169478:cluster/dbt-project-cluster",
        "launchType": "FARGATE",
        "networkConfiguration": {
            "awsvpcConfiguration": {
              "subnets": ["subnet-07cb35768e2859c85", "subnet-0798c47d1a21868fc"],
              "securityGroups": ["sg-01bf05f38ffab1805"],
              "assignPublicIp": "ENABLED"
             }
        },
        "overrides": {
            "containerOverrides": [
                {
                    "name": "dbt-aws-project", 
                    "command": ["dbt", "run", "--select", "fct_sales", "--profile-dir", "."],
                    "environment": [
                        {
                            "name1": "variable",
                            "value1": "value"
                        },
                        {
                            "name2": "variable",
                            "value2": "value"
                        }
                    ] 
                }
            ]
        }
    }

    # Run the task in the cluster
    response = ecs.run_task(**parameters)
```

-------------------------------------------------------
## AWS services and costs 
### PAYING
 - Redshift : 7,20 euro al giorno per I dati presenti sul Tickit databases

### FREE TIER : 

 - S3 bucket : New clients receive 5GB os storage in S3 Standard, 20.000 GET, 2.000
               PUT, COPY, POST, or LIST requests per month
 - AWS Gule Data Catalogue : first million of memorized object is free
 - Quicksight : Used the first month free for new users
 - Cloudwatch 
 - Lambda 
 - EventBridge 
 - ECS 
 - ECR 

## Resources
- Configure a dbt project to run on Redshift [article on Programmatic Ponderings blog](https://programmaticponderings.com/2022/08/19/lakehouse-data-modeling-using-dbt-amazon-redshift-redshift-spectrum-and-aws-glue/) --> Sacro Graal
- [dbt docs](https://docs.getdbt.com/docs/introduction)
- [aws docs](https://docs.aws.amazon.com/)
- Documentazione dbt : 
    - dbt docs generate
    - dbt docs serve