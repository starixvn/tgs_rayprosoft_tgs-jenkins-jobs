#!/bin/bash
auth_email=infrastructure@rayprosoft.com
auth_key=ea16209785cb4fa06858c5571ff5b8057840f
account_id=bca33f2713e936cee007fa34f24a773f
content=ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com
zone=$1

CreateDnsRecord(){
        dns_record=$1
        zone_id=$2

        result=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$2/dns_records" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
             --data '{"type":"CNAME","name":"'$1'","content":"'${content}'","proxied":true}')

	echo ${result}
}


echo ${zone}
result2=$(curl -X POST "https://api.cloudflare.com/client/v4/zones" \
	 -H "X-Auth-Email: ${auth_email}" \
	 -H "X-Auth-Key: ${auth_key}" \
	 -H "Content-Type: application/json" \
	 --data "{\"name\":\"${zone}\",\"account\":{\"id\":\"${account_id}\"},\"jump_start\":false,\"type\":\"full\"}")
echo ${result2}

zoneid=$(echo ${result2} | cut -c18-49)
 
result_automatic_https_rewrites=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/automatic_https_rewrites" \
	 -H "X-Auth-Email: ${auth_email}" \
	 -H "X-Auth-Key: ${auth_key}" \
	 -H "Content-Type: application/json" \
	--data "{\"value\":\"on\"}")
 
echo ${result_automatic_https_rewrites}
 
result_always_use_https=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/always_use_https" \
	 -H "X-Auth-Email: ${auth_email}" \
	 -H "X-Auth-Key: ${auth_key}" \
	 -H "Content-Type: application/json" \
	--data "{\"value\":\"on\"}")

echo ${result_always_use_https}
 
result_minify=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/minify" \
	-H "X-Auth-Email: ${auth_email}" \
	-H "X-Auth-Key: ${auth_key}" \
	-H "Content-Type: application/json" \
	--data "{\"value\":{\"css\":\"on\",\"html\":\"on\",\"js\":\"on\"}}")
 
echo ${result_minify}

result_brotli=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/brotli" \
	 -H "X-Auth-Email: user@example.com" \
	 -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
	 -H "Content-Type: application/json" \
	 --data '{"value":"on"}')
	 
echo ${result_brotli} 
 
dns_record_result=$(CreateDnsRecord ${zone} ${zoneid})
dns_record_result=$(CreateDnsRecord "www" ${zoneid})
echo ${dns_record_result};
