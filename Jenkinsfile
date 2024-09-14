pipeline {
    agent any
    
    environment {
        ARM_CLIENT_ID = credentials('azure-sp-client-id')
        ARM_CLIENT_SECRET = credentials('azure-sp-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID = credentials('azure-tenant-id')
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository containing Terraform files
                git branch: 'main', url: 'https://github.com/setthapong4u/aztf.git'
            }
        }
        
        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                // Terraform plan to show the resources that will be created
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                // Apply the changes
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression {
                    return params.DESTROY_ENV == true
                }
            }
            steps {
                // Destroy resources
                sh 'terraform destroy -auto-approve'
            }
        }
    }
    
}