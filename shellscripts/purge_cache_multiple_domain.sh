#!/bin/bash
auth_email=xxxxxxxx
auth_key=xxxxxxxx
account_id=xxxxxxxx
content=xxxxxxxx

response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000" \
    -H "X-Auth-Email: ${auth_email}" \
    -H "X-Auth-Key: ${auth_key}" \
    -H "Content-Type: application/json") 

#echo ${response} | jq '.result'

declare -i index=0

# FOR PURGE
for zone in $(echo ${response} | jq '.result' | jq  '.[] | .id+","+.name'); do
	IFS=','
    read -a zone_array <<< ${zone}
	zoneid=${zone_array[0]/\"}
    zonename=${zone_array[1]/\"}
	echo "${zonename}=${zoneid}"
	
	IFS=' '
        read -a domain_array <<< "$@"

        for i in "${domain_array[@]}"
        do
                echo "$i"
                if [[ "${zonename}" == *"$i"* ]]; then
			echo "purge ${zonename}"
	                response_purge=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/purge_cache" \
        	                 -H "X-Auth-Email: ${auth_email}" \
                	         -H "X-Auth-Key: ${auth_key}" \
                        	 -H "Content-Type: application/json" \
                        	 --data '{"purge_everything":true}')
               		echo ${response_purge}
        curl -s --data "text=${zonename} has purged." --data "chat_id=-1001915538838" 'https://api.telegram.org/bot6137223098:AAEeQiBaQ1G1Gj5pO7p9q_FVwvXViM1BMcg/sendMessage' 
	        fi
        done
done


