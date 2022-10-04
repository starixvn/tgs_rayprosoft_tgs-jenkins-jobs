#!/bin/bash
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule
## https://api.cloudflare.com/#firewall-rules-create-firewall-rules

auth_email=infrastructure@rayprosoft.com
auth_key=ea16209785cb4fa06858c5571ff5b8057840f
account_id=bca33f2713e936cee007fa34f24a773f
content=ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com
officeip=114.33.41.237

DeleteFilters(){
	zone_id=$1
	zone_name=$2
	IFS=$'\n' ### important
	result=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$1/filters" \
		 -H "X-Auth-Email: ${auth_email}" \
		 -H "X-Auth-Key: ${auth_key}" \
		 -H "Content-Type: application/json" | jq  -r '.result' | jq -r '.[] | .id')
	echo "result:${result}"
	for filter_id in ${result}; do

			respons_delete_filter=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/filters?id=${filter_id}" \
				 -H "X-Auth-Email: ${auth_email}" \
				 -H "X-Auth-Key: ${auth_key}" \
				 -H "Content-Type: application/json")
			echo "delete result:"
			echo ${respons_delete_filter} | jq
	done
	
	echo "DeleteFilters: ${zone_name}"
}

CreateRule(){
	zone_id=$1
	response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
		 -H "X-Auth-Email: ${auth_email}" \
		 -H "X-Auth-Key: ${auth_key}" \
		 -H "Content-Type: application/json" \
		 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')

	echo ${response_create_rule}
}

UpdateRule(){
	zone_id=$1
	rule_id=$2
	filter_id=$3
	
	#test1 = '[{"id": \""$rule_id"\","action": "block","paused": false,"description": "Block Taiwan", "filter":{"id":\""${filter_id}"\","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]'
	#echo "test1:" 
	#echo "test1" | jq
	
	response_create_rule=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id}" \
		 -H "X-Auth-Email: ${auth_email}" \
		 -H "X-Auth-Key: ${auth_key}" \
		 -H "Content-Type: application/json" \
		 --data '[{"id": ""$rule_id"","action": "block","paused": false,"description": "Block Taiwan", "filter":{"id":""${filter_id}"","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')

	echo ${response_create_rule}
}



response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0
#declare -a arr=("atinbet.vip" "atinbet.club" "atinbet.app" "atinbet.net" "atinbet.org" "atingbet.com");
declare -a arr=("0063po.com");


# FOR PURGE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
        IFS=','
        read -a zone_array <<< ${zone}
        zoneid=${zone_array[0]/\"}
        zonename=${zone_array[1]/\"}
        echo "${zonename}=${zoneid}"

        if [[ ${arr[*]} =~ "${zonename}" ]]; then
				#DeleteFilters ${zoneid} ${zonename}
		
                response_rule=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules?page=1&per_page=20" \
                         -H "X-Auth-Email: ${auth_email}" \
                         -H "X-Auth-Key: ${auth_key}" \
                         -H "Content-Type: application/json")
						 
				#echo "rule response:"		 
				#echo ${response_rule}
				
                IFS=''
                rules=$(echo ${response_rule} | jq '.result' | jq '.[] .id')
                if [ -z "$rules" ]; then
                        echo "$zonename 未設定"	

						CreateRuleResult=$(CreateRule ${zoneid})
						
                        echo ${CreateRuleResult} | jq
                else
                        echo "$zonename 已設定"
						
                        for rule in $(echo ${response_rule} | jq '.result' | jq  '.[] | .id+","+.description+","+.filter.id'); do
						        IFS=','
								read -a zone_array <<< ${rule}
								rule_id=${zone_array[0]/\"}
								desc=${zone_array[1]/\"}
								filter_id=${zone_array[2]/\"}
								
                                echo "rule_id=${rule_id//\"/}"
								echo "desc=${desc}"
								echo "filter_id=${filter_id}"
								
								if [[ ${desc} == "Block Taiwan" ]]; then 
								    echo "Executing"
									#UpdateRuleResult=$(UpdateRule ${zoneid} ${rule_id} ${filter_id})
														
									response_update_rule=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id}" \
										 -H "X-Auth-Email: ${auth_email}" \
										 -H "X-Auth-Key: ${auth_key}" \
										 -H "Content-Type: application/json" \
										 --data '[{"id": ""$rule_id"","action": "block","paused": false,"description": "Block Taiwan", "filter":{"id":""${filter_id}"","expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')

									echo ${response_update_rule} | jq
								fi
														
								
								#response_delete_rule=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id//\"/}" \
									# -H "X-Auth-Email: ${auth_email}" \
									# -H "X-Auth-Key: ${auth_key}" \
									# -H "Content-Type: application/json" \
									 #--data '{}')
								#echo "delete result:"
								#echo ${response_delete_rule} | jq
						done
						
						#CreateRuleResult=$(CreateRule ${zoneid})
						
                        #echo ${CreateRuleResult} | jq
                fi
        fi
done
