#!/bin/bash
export auth_email=infrastructure@rayprosoft.com
export auth_key=ea16209785cb4fa06858c5571ff5b8057840f
export account_id=bca33f2713e936cee007fa34f24a773f
export zoneid=10f05709c7cfb730ef46a95bdefc6387
export filterid=f5ea6f7484f54a7ab69d46d1af184a47

ip=$1

result=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/filters/$filterid" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json")

echo $result | jq -r .result

result=$(echo $result | jq -r .result)
request=${result/\})/ $ip\})};

echo "request"
echo "$request" | jq

result2=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/filters/$filterid" \
             -H "X-Auth-Email: ${auth_email}" \
             -H "X-Auth-Key: ${auth_key}" \
             -H "Content-Type: application/json" \
                         --data "$request")

echo $result2 | jq -r .result
