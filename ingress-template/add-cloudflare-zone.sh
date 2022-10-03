#!/bin/bash
auth_email=infrastructure@rayprosoft.com
auth_key=ea16209785cb4fa06858c5571ff5b8057840f
account_id=bca33f2713e936cee007fa34f24a773f
content=ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com
officeip=114.33.41.237
rpgp_cc_zone_id=c6c8be8e9c04948f486101b1b994c09c

CreateCNameDnsRecord(){
        dns_record=$1
        zone_id=$rpgp_cc_zone_id

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"CNAME","name":"'$1'","content":"'${content}'","proxied":true}')

	echo "CreateDnsRecord: ${result}"
}

CreateADnsRecord(){
        dns_record=$1
        zone_id=$rpgp_cc_zone_id

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"A","name":"'$1'","content":"'${content}'","proxied":true}')

	echo "CreateDnsRecord: ${result}"
}

if [[ $1 == "staging" || $1 == "prod" ]]; then 
	dns_record_result=$(CreateCNameDnsRecord $2)
	echo "dns_record_result:"
	echo ${dns_record_result}
else 
	dns_record_result=$(CreateADnsRecord $2)
	echo "dns_record_result:"
	echo ${dns_record_result}
fi
