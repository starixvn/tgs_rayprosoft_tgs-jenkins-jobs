#!/bin/bash
metrics=$(aws cloudwatch get-metric-statistics --namespace AWS/DocDB --dimensions Name=DBInstanceIdentifier,Value=tgs-prod --metric-name CPUUtilization --start-time $(date -d '20 minutes ago' -u +"%Y-%m-%dT%H:%M:%SZ")  --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ")  --period 1200 --statistics Maximum --region ap-northeast-1 | grep Max)
prefix="\"Maximum\": "
suffix=","
declare -i count=0
for metric in ${metrics}; do
        count=${count}+1
        echo ${count}

        if [[ ${metric} = *"Max"*  ]];then
                continue;
        fi

        temp1=${metric#"$prefix"}
        temp1=${temp1%"$suffix"}

        echo "temp1=${temp1}"

        if [[ $temp1 > 14 ]]
        then
                echo ">14"
        else
                echo "<=14"
        fi
        echo "======"
done
