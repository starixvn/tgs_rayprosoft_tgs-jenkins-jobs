#!/bin/bash
minReplicas=$(kubectl get hpa game-gamerecord-awc-workservice -n prod -o jsonpath='{.spec.minReplicas}')
metrics=$(aws cloudwatch get-metric-statistics --namespace AWS/DocDB --dimensions Name=DBInstanceIdentifier,Value=tgs-prod --metric-name CPUUtilization --start-time $(date -d '20 minutes ago' -u +"%Y-%m-%dT%H:%M:%SZ")  --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ")  --period 1200 --statistics Maximum --region ap-northeast-1 | grep Max)
prefix="            \"Maximum\": "
suffix=","
declare -i count=0
echo "minReplicas=${minReplicas}"
echo "metrics=${metrics}"
temp1=${metric//            "Maximum": /}
temp1=${temp1//,/}
echo "temp1=${temp1}"
if [[ $temp1 > 98 &&  $minReplicas < 10 ]]
then
	echo "add minReplicas"
	cat << EOF | helm template workservice-autoscaling -f - \
	| kubectl apply -f -
		{
			"autoscaling": {"enabled":true,"minReplicas":10,"maxReplicas":20,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80}
		}
EOF
elif [[ $temp1 <90 &&  $minReplicas >= 10 ]] 
then 
	echo "minus minReplicas"
	cat << EOF | helm template workservice-autoscaling -f - \
	| kubectl apply -f -
		{
			"autoscaling": {"enabled":true,"minReplicas":5,"maxReplicas":10,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80}
		}
EOF		
else
	echo "Normal"
fi