#!/bin/bash
## https://developers.cloudflare.com/api/operations/zone-settings-change-ssl-setting
domain=$1
response=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?per_page=1000?name=$domain" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json")

declare -i index=0
declare -i dns_index=0
declare -i count=0

for zoneid in $(echo ${response} | jq '.result' | jq -r '.[].id'); do

        zone_name=$(echo ${response} | jq '.result' | jq -r ".[${index}].name")
        index=$((index+1))
        dns_index=$((0))
#       echo "ZONE_NAME=${zone_name}"

        response2=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/ssl" \
                        -H "Authorization: Bearer ${token}" \
                        -H "Content-Type: application/json")
        value=$(echo ${response2} | jq '.result.value')
        echo "${zone_name} = $value"

        #if [[  "${zone_name}" == *"skalaslot"* ]]; then

                echo "=====>  zone_name=${zone_name}"
                patchResponse=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zoneid}/settings/ssl" \
                        -H "Authorization: Bearer ${token}" \
                        -H "Content-Type: application/json" \
                        --data '{"value":"full"}')
                echo ${patchResponse} | jq '.result' | jq '.[]'
        #fi
done
