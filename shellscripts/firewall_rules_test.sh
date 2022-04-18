#!/bin/bash
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
declare -a arr=("srvptt.com" "srvttt.com" "yydsgo.xyz" "rpgp.cc" "mess888.com");


response2=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/43d010a66f6d6176d6a56cbde8a0e95b/firewall/rules" \
     -H "X-Auth-Email: ${auth_email}" \
	 -H "X-Auth-Key: ${auth_key}" \
     -H "Content-Type: application/json" \
     --data '[{"action":"block","paused":false,"description":"Block Taiwan","filter":{"expression":"(ip.geoip.countryin{\"TW\"} and not ip.src in {220.132.206.70})","paused":false}}]')


 echo ${response2} | jq '.result'