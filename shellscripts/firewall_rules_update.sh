#!/bin/bash
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule
## https://api.cloudflare.com/#firewall-rules-create-firewall-rules

auth_email=infrastructure@rayprosoft.com
auth_key=ea16209785cb4fa06858c5571ff5b8057840f
account_id=bca33f2713e936cee007fa34f24a773f
content=ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com
officeip=220.132.206.70


DeleteFilters(){
	zone_id=$1
	zone_name=$2
	IFS=$'\n'
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

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json")

#echo ${response} | jq '.result'

declare -i index=0
declare -a arr=("srvptt.com" "srvttt.com" "yydsgo.xyz" "rpgp.cc" "mess888.com");

# FOR PURGE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
        IFS=','
        read -a zone_array <<< ${zone}
        zoneid=${zone_array[0]/\"}
        zonename=${zone_array[1]/\"}
        echo "${zonename}=${zoneid}"

        #if [[ ! ${arr[*]} =~ "${zonename}" ]]; then
		if [[ "21gen.com" == "${zonename}" ]]; then
				
				DeleteFilters ${zoneid} ${zonename}
		
                response_rule=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules?page=1&per_page=20" \
                         -H "X-Auth-Email: ${auth_email}" \
                         -H "X-Auth-Key: ${auth_key}" \
                         -H "Content-Type: application/json")
                IFS=''
                rules=$(echo ${response_rule} | jq '.result' | jq '.[] .id')
                if [ -z "$rules" ]; then
                        echo "$zonename 未設定"			
						response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
							 -H "X-Auth-Email: ${auth_email}" \
							 -H "X-Auth-Key: ${auth_key}" \
							 -H "Content-Type: application/json" \
							 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')
						echo "create result:"
                        echo ${response_create_rule} | jq
                else
                        echo "$zonename 已設定"
						
                        for rule_id in $(echo ${response_rule} | jq '.result' | jq  '.[] | .id'); do
                                echo "ruleid=${rule_id//\"/}"
								response_delete_rule=$(curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules/${rule_id//\"/}" \
									 -H "X-Auth-Email: ${auth_email}" \
									 -H "X-Auth-Key: ${auth_key}" \
									 -H "Content-Type: application/json" \
									 --data '{}')
								echo "delete result:"
								echo ${response_delete_rule} | jq
						done
						
						response_create_rule=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules" \
							 -H "X-Auth-Email: ${auth_email}" \
							 -H "X-Auth-Key: ${auth_key}" \
							 -H "Content-Type: application/json" \
							 --data '[{"action": "block","paused": false,"description": "Block Taiwan", "filter":{"expression": "(ip.geoip.country in {\"TW\"} and not ip.src in {'"${officeip}"'})","paused": false }}]')
						echo "create result:"
                        echo ${response_create_rule} | jq
                fi
				break;
        fi
done
