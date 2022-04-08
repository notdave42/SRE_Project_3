#!/bin/bash

function green_deploy {
 kubectl apply -f ./index_green_html.yml
 kubectl apply -f ./green.yml 
 attempts=0
 until [ $(kubectl get deploy | grep -c green ) -gt 0 ]||[ $attempts -eq 60 ];do
  attempts=$((attempts+1))
  sleep=1
 done
 echo "Green deployment successful"
}

while [ $(kubectl get deploy | grep -c green) -lt 1 ]
do
green_deploy
done 
            
