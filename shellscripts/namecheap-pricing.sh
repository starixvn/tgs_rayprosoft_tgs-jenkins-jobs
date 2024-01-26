#!/bin/bash
DomainName=$1
ApiUser=
UserName=
ApiKey=
ClientIp=
Address="Sec4WenxinRdBeitunDist"
NameCheapUrl="https://api.namecheap.com/xml.response?"
Email=
#TelegramChatId="-1001985229002"
#TelegramChatId="-866679594"
TelegramChatId=$2
TelegramToken=""

## https://www.namecheap.com/promos/coupons/
IFS='.' read -r -a array <<< "$DomainName"
TLD="${array[1]}"
SLD="${array[0]}"

Url="$NameCheapUrl&\
ApiUser=$ApiUser&\
ApiKey=$ApiKey&\
UserName=$UserName&\
Command=namecheap.users.getPricing&\
ClientIp=$ClientIp&\
ProductCategory=register&\
ProductName=$TLD&\
ProductType=DOMAIN"

echo "Url=$Url"

CheckDomainAvailableUrl="$NameCheapUrl&\
ApiUser=$ApiUser&\
ApiKey=$ApiKey&\
UserName=$UserName&\
Command=namecheap.domains.check&\
ClientIp=$ClientIp&\
DomainList=$DomainName"

## 確認 domain 有沒有辦法使用
responseDomainCheck=$(curl -X GET $CheckDomainAvailableUrl -H "Content-Type: application/xml" -d '')
echo $responseDomainCheck | xmllint --format - > available.xml
sed -i 's/xmlns=\"http:\/\/api.namecheap.com\/xml.response\" //g' available.xml
available=$(xmllint --xpath '//ApiResponse/CommandResponse/DomainCheckResult/@Available' available.xml)
echo "$available"

Message=""
if [[ "$available" == *"false"*  ]]; then
    read -r -d '' Message <<EOT
[Get Domain Price]
domain: $DomainName
domain 無法使用.
EOT

curl -s --data-urlencode "text=$Message" --data "chat_id=$TelegramChatId" "https://api.telegram.org/bot$TelegramToken/sendMessage" > /dev/null
exit 0
fi

## 執行domain 的費用
response=$(curl -X GET $Url -H "Content-Type: application/xml" -d '')

echo $response | xmllint --format - > price.xml
sed -i 's/xmlns=\"http:\/\/api.namecheap.com\/xml.response\" //g' price.xml

count=$(xmllint --xpath "count(//ApiResponse/CommandResponse/UserGetPricingResult/ProductType/ProductCategory)" price.xml)

echo "count=$count"

regular_price=$(xmllint --xpath '//ApiResponse/CommandResponse/UserGetPricingResult/ProductType/ProductCategory[@Name="register"]/Product/Price[@Duration="1"]/@RegularPrice' price.xml)
price=$(xmllint --xpath '//ApiResponse/CommandResponse/UserGetPricingResult/ProductType/ProductCategory[@Name="register"]/Product/Price[@Duration="1"]/@Price' price.xml)
echo "$regular_price"
echo "$price"


if [[ "$count" != "0" ]]; then
    read -r -d '' Message <<EOT
[Get Domain Price]
 domain: $DomainName
$regular_price
$price
EOT

else
    read -r -d '' Message <<EOT
[Get Domain Price]
domain: $DomainName
domain 無法註冊.
EOT

fi

curl -s --data-urlencode "text=$Message" --data "chat_id=$TelegramChatId" "https://api.telegram.org/bot$TelegramToken/sendMessage" > /dev/null
