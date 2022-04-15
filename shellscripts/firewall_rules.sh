#!/bin/bash
## https://api.cloudflare.com/#firewall-access-rule-for-a-zone-list-access-rules
## https://api.cloudflare.com/#firewall-rules-get-individual-firewall-rule

auth_email=infrastructure@rayprosoft.com
auth_key=ea16209785cb4fa06858c5571ff5b8057840f
account_id=bca33f2713e936cee007fa34f24a773f
content=ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json") 

#echo ${response} | jq '.result'

declare -i index=0
declare -a arr=("srvptt.com" "srvttt.com" "yydsgo.xyz" "rpgp.cc");

# FOR PURGE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
	IFS=','
    read -a zone_array <<< ${zone}
	zoneid=${zone_array[0]/\"}
    zonename=${zone_array[1]/\"}
	echo "${zonename}=${zoneid}"
	
	if [[ ! ${arr[*]} =~ "${zonename}" ]]; then
		response_purge=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/rules?page=1&per_page=20" \
			 -H "X-Auth-Email: ${auth_email}" \
			 -H "X-Auth-Key: ${auth_key}" \
			 -H "Content-Type: application/json")
		echo ${response_purge}
		break
	fi
done