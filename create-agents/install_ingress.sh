#!/bin/bash
export brand=$1
export domain=$2
export domain_=$(echo ${domain} | sed -e "s/\./-/g")
export invite_code=$3

echo ${domain_}
envsubst <  /var/lib/jenkins/tgs-jenkins-jobs/create-agents/ingress-$1.yml | kubectl apply -f - 
