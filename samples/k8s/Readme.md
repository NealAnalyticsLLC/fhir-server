# Running FHIR Server On Kubernetes

This sample illustrates how to run a FHIR Server instance with SQL Server on Azure Stack Hub using the AKS engine. The below instructions guide through the infrastructure deployment process, the Kubernetes deployment, and deployment validation.

**Recommended Background Reading:**

- [AKS engine on Azure Stack Hub](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-overview?view=azs-2002)

- [Install AKS engine on Linux in Azure Stack Hub](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-linux?view=azs-2002)

- [Deploy a Kubernetes Cluster with AKS engine on Azure Stack Hub](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-cluster?view=azs-2002)


## Step 1: Infrastructure Deployment

1. Use [This Guide](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-quick-linux-portal?view=azs-2002) to create a Linux VM in your Azure Stack Hub environment

1. SSH into VM using the public key you created in previous step above

1. Create a service principal for managing AKS engine

    - Follow instructions [here](https://docs.microsoft.com/en-us/azure-stack/operator/azure-stack-create-service-principals?view=azs-2002) to create and configure app registration in your AD tenant

        - **NOTE:** you will need to have permissions in your Azure Active Directory to create app registration and sufficeint permissions in your Azure Stack Hub environment to add users to your subscription or resource group

    - Be sure to [assign Contributor access](https://docs.microsoft.com/en-us/azure-stack/operator/azure-stack-create-service-principals?view=azs-2002#assign-a-role) on the resource group / subscription to service principal you created above

1. Install the AKS engine on your VM
    - Follow the instructions [here](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-linux?view=azs-2002) to install a supported version of the AKS engine

1. Run through [instructions](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-cluster?view=azs-2002) to deploy a cluster with the AKS engine on Azure Stack Hub

    - AKS engine command to create cluster (also provided in referenced instructions above)
        ```
        $ aks-engine deploy \
            --azure-env AzureStackCloud \
            --location <your azure stack region> \
            --resource-group <your resource group> \
            --api-model ./kubernetes-azurestack.json \
            --output-directory FHIR-ASH \
            --client-id <your app registration id> \
            --client-secret <your app client secret> \
            --subscription-id <your azure stack subscription id>
        ```
    ### AKS Engine Troubleshooting

    See this [Troubleshooting Guide](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-troubleshoot?view=azs-2002) for troubleshooting common scenarios on Azure Stack Hub


## Step 2: Manifest Deployment

- SSH into one of your master nodes

- Clone this repo on the master

- Navigate to this directory in a new Terminal instance (i.e. /samples/k8s)

- Create .env file to match your environment using the .env.template file included here
    - These variables will be used to generate a secret to manage your deployment environment variables
    - Variables to update:
    
        |Variable:|Description:|
        |---------|------------|
        |**SAPASSWORD**| Password to use for SQL Server service account|
        |**SqlServer__ConnectionString**| Connection string for FHIR api to use to connect to backend. NOTE: The password in this connection string must match the SAPASSWORD above|
        |**ApplicationInsights__InstrumentationKey**| This is the instrumentation key used for audit logging|


- Run the create_namespace.sh file here to create the namcespace and populate with secrets
    ```
    $ ./create_namespace.sh
    ```

- Execute the below command to deploy the FHIR Server and SQL Server to the AKS cluster

    ```
    $ kubectl apply -f ./deployment_manifest.yaml
    ```

- Wait for the deployment to complete
    - NOTE: the deployment will take some time as it needs to pull the container images and run the initial configuration.

## Step 3: Deployment Testing

- Get the External IP of your FHIR Server
    ```
    $ kubectl get services -namespace fhir-server
    ```    

- Test your service using Postman
