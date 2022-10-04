#!/bin/bash
#### bash create_dns_record.sh game-test
url='https://api.cloudflare.com/client/v4/zones/c6c8be8e9c04948f486101b1b994c09c/dns_records'
email='infrastructure@rayprosoft.com'
apikey='ea16209785cb4fa06858c5571ff5b8057840f'
#prod_domain='a6c1116e0e2dc481981b9b39d0283c43-383156902.ap-east-1.elb.amazonaws.com'
prod_domain='ac14ad4ad050b4a71b144385e51a20f5-1241810226.ap-east-1.elb.amazonaws.com'
echo "input:$1"

responseId=$(curl -X GET "${url}?name=$1.rpgp.cc" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result | .[] | select(.name == "$1.rpgp.cc").id ')

responseType=$(curl -X GET "${url}?name=$1.rpgp.cc" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" | jq -r '.result |  .[] | select(.name == "$1.rpgp.cc").type')

if [[ "${responseId}" == "" ]]; then
	
  result=$(curl -X POST "${url}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"CNAME","name":"'$1'","content":"'$prod_domain'","proxied":false}')
	 
  echo "create result:${result}"
  
elif [[ "${responseType}" == "A" ]]; then
  result=$(curl -X PUT "${url}/${responseId}" \
     -H "X-Auth-Email: ${email}" \
     -H "X-Auth-Key: ${apikey}" \
     -H "Content-Type: application/json" \
     --data '{"type":"CNAME","name":"'$1'","content":"'$prod_domain'","proxied":false}')

  echo "update result:${result}"
fi