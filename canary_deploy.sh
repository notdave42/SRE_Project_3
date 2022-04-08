#!/bin/bash

function manual_verification {
 read -p "Continue deployment? (y/n) " answer
 if [[ $answer =~ ^[Yy]$ ]] ;
 then
  echo "continuing deployment"
 else
  exit
 fi
}  

function count_pods {
 num_of_v1_pods=$(kubectl get pods -n udacity | grep -c canary-v1) 
 num_of_v2_pods=$(kubectl get pods -n udacity | grep -c canary-v2) 
 echo "v1 pods: "${num_of_v1_pods}" v2 pods: "${num_of_v2_pods}
 }

function canary_deploy {
 deploy_increment=1
 count_pods
 kubectl scale deployment canary-v2 --replicas=$(($num_of_v2_pods + $deploy_increment)) -n udacity
 kubectl scale deployment canary-v1 --replicas=$(($num_of_v1_pods - $deploy_increment)) -n udacity
 attempts=0
 rollout_status="kubectl rollout status deployment/canary-v2 -n udacity"
 until $rollout_status||[$attempts -eq 60 ];do
  if [ $num_of_v2_pod -eq 0 ]; then
   kubectl apply -f canary-v2.yml
   continue
   fi
  $rollout_status
  attempts=$((attempts+1))
  sleep=1
 done
 count_pods
 echo "Canary deployment of $deploy_increment replicas successful"
}

while [ $(kubectl get pods -n udacity | grep -c canary-v1) -gt 0 ]
do
canary_deploy
manual_verification
done 
            
