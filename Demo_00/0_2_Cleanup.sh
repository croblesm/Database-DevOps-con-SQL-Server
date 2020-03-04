#!/bin/bash

#==============================================================================
# Script name   : 0_2_Cleanup.sh
# Description   : Script to cleanup the environment for the demos
# Author        : Carlos Robles
# Email         : crobles@dbamastery.com
# Twitter       : @dbamastery
# Date          : 20191106
# 
# Version       : 2.0   
# Usage         : bash 0_2_Cleanup.sh
#
# Notes         : This script assumes Docker is installed and configured
#==============================================================================

# Starting cleanup
echo -e "\nStarting cleanup process ...\n"

# Deleting old active containers
echo -e "\nDeleting old containers"
docker rm -f demo_01 hr_dev_sql hr-frontend hr-backend hr_sql_dev hr_dev hr_stg_sql

# Listing existing volumes
echo -e "\nListing existing volumes"
docker volume ls

# Deleting old docker volumes
echo -e "\nDeleting old docker volumes"
docker volume rm vlm_Data vlm_Log vlm_Backup

# Listing active containers
echo -e "\nListing active containers"
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}"

# Deleting old docker images
echo -e "\nDeleting old docker images"
docker rmi hr_dev hr-database hr-db-dev_stg

# Deleting old azure backups
echo -e "\nDeleting old azure backups"
rm -rf /Users/carlos/Documents/Summit_2019/Backups/*

# Reverting changes for Demo 04
echo -e "Reverting changes for Demo 04\n"
mv ~/Documents/Summit_2019/Demo_04/DBA/sql_deployment.sh ~/Documents/Summit_2019/Demo_04/DBA/sql_deployment.sh.v2
mv ~/Documents/Summit_2019/Demo_04/DBA/sql_deployment.sh.old ~/Documents/Summit_2019/Demo_04/DBA/sql_deployment.sh 

# Reverting changes for Demo 05
echo -e "Reverting changes for Demo 05\n"
sed -i '' "s/CU16/CU15/g" ~/Documents/Summit_2019/Demo_05/Dockerfile

# Stopping status of ACI's
echo -e "\nStopping ACI's"
az container stop -n hr-dev-sql01 -g Summit2019

# Checking status of ACI's
echo -e "\nChecking status for ACI's"
az container show --resource-group Summit2019 --name hr-dev-sql01 --query "{Status:instanceView.state}" --out table

# Deleting old Kubernetes deployment
echo -e "\nDeleting old Kubernetes deployment ..."
kubectl delete deployment hr-sql-dev --grace-period=0 --force

# Deleting old Kubernetes pvc
echo -e "\nDeleting old Kubernetes pvc ..."
kubectl delete pvc hr-sql-dev-pvc --grace-period=0 --force

# Waiting for delete to complete
sleep 300

# Re-creating PVC
echo -e "\nRe-creating PVC ..."
kubectl apply -f ~/Documents/Summit_2019/Demo_05/persistent_volumes/pvc_database.yaml

# Getting list of AKS nodepool VMs
echo -e "\nListing all VMs in Summit2019 resource group"
az vm list --resource-group MC_Summit2019_apollo-stage_southcentralus | grep name

# Stopping AKS compute (VMs)
echo -e "\nStopping AKS compute (VMs)..."
az vm stop --name aks-agentpool-14999759-0 --resource-group MC_Summit2019_apollo-stage_southcentralus
az vm stop --name aks-agentpool-14999759-1 --resource-group MC_Summit2019_apollo-stage_southcentralus

echo -e "\nDeallocating AKS compute (VMs)..."
az vm deallocate --name aks-agentpool-14999759-0 --resource-group MC_Summit2019_apollo-stage_southcentralus
az vm deallocate --name aks-agentpool-14999759-1 --resource-group MC_Summit2019_apollo-stage_southcentralus

# Checking status of VMs
echo -e "\n Nodepool status:"
az vm list -d -o table --resource-group MC_Summit2019_apollo-stage_southcentralus

# Finishing script
echo -e "\nCleanup process complete.\n"