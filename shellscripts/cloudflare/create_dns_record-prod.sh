#!/bin/bash
#### bash create_dns_record.sh game-test
url='https://api.cloudflare.com/client/v4/zones/10f05709c7cfb730ef46a95bdefc6387/dns_records'
email='infrastructure@rayprosoft.com'
apikey='ea16209785cb4fa06858c5571ff5b8057840f'
content='ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com'
domain='.yydsgo.xyz'

echo "input:$1"

responseId=$(curl -X GET "${url}?name=$1${domain}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result | length')

if [[ "${responseId}" == "0" ]]; then
	
  result=$(curl -X POST "${url}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"CNAME","name":"'$1'","content":"'$content'","proxied":false}')
	 
  echo "create result:${result}"
fi