#!/bin/bash

#==============================================================================
# Script name   : 0_1_Startup.sh
# Description   : Script to startup all VMs and other resources for demos
# Author        : Carlos Robles
# Email         : crobles@dbamastery.com
# Twitter       : @dbamastery
# Date          : 20191106
# 
# Version       : 2.0   
# Usage         : bash 0_1_Startup.sh
#
# Notes         : This script assumes AZ CLI & Docker is installed
#==============================================================================

# Beginning startup
echo -e "\nBeginning startup process ...\n"

# Starting docker daemon
echo -e "\nStarting docker daemon locally ...\n"
open --background -a Docker

# Waiting for docker daemon to start
echo -e "\nWaiting for docker to start ...\n"

# Getting number of docker processes
docker_ps=`ps -elf | grep docker | grep -v grep | wc -l`

# Waiting until number of processes is 5
while [ $docker_ps -ne 5 ]
do
    sleep 1
    unset docker_ps
	docker_ps=`ps -elf | grep docker | grep -v grep | wc -l`
    echo "Docker is still starting ..."
done

# Waiting for docker daemon to start
echo -e "\nDocker is up and running:"
ps -elf | grep docker | grep -v grep

# Listing azure account names
echo -e "\nListing azure subscription names"
az account list --output table

# Set account to use specific subscription
echo -e "\nSet account to use specific Microsoft Azure Sponsorship subscription"
az account set --subscription "Microsoft Azure Sponsorship"

# Checking subscription set to account
echo -e "\nListing azure subscription names"
az account list --output table

# Getting list of running VMs
echo -e "\nListing all VMs in Summit2019 resource group"
az vm list --resource-group Summit2019 | grep name

# Starting VMs
echo -e "\nStarting all VMs in Summit2019 resource group"
az vm start --name HumanResources --resource-group Summit2019
az vm start --name Jenkins --resource-group Summit2019

# Checking status of VMs
echo -e "\nChecking status all VMs in Summit2019 resource group"
echo -e "\n Human resources VM status:"
az vm show --name HumanResources --resource-group Summit2019 | grep provisioningState
echo -e "\n Jenkins VM status:"
az vm show --name Jenkins --resource-group Summit2019 | grep provisioningState

# Checking status of VMs
echo -e "\nSetting AKS credentials to adonis-stage cluster"
az aks get-credentials --resource-group Summit2019 --name apollo-stage
kubectl config use-context apollo-stage

# Starting status of ACI's
echo -e "\nStarting ACI's"
az container start -n hr-dev-sql01 -g Summit2019

# Checking status of ACI's
echo -e "\nChecking status for ACI's"
az container show --resource-group Summit2019 --name hr-dev-sql01 --query "{Status:instanceView.state}" --out table

# Getting list of AKS nodepool VMs
echo -e "\nListing all AKS nodepool VMs ..."
az vm list --resource-group MC_Summit2019_apollo-stage_southcentralus | grep name

# Starting AKS compute (VMs)
echo -e "\nStarting AKS compute (VMs)..."
az vm start --name aks-agentpool-14999759-0 --resource-group MC_Summit2019_apollo-stage_southcentralus
az vm start --name aks-agentpool-14999759-1 --resource-group MC_Summit2019_apollo-stage_southcentralus

# Checking status of VMs
echo -e "\n Nodepool status:"
az vm list -d -o table --resource-group MC_Summit2019_apollo-stage_southcentralus

# Checking Kubernetes client context
echo -e "\n Checking Kubernetes client context"
kubectl config get-contexts

# Finishing script
echo -e "\nStartup process complete.\n"