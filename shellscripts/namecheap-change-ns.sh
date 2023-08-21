#!/bin/bash
DomainName=$1
Nameservers=xxxxxxxx,xxxxxxxx
ApiUser=xxxxxxxx
UserName=xxxxxxxx
ApiKey=xxxxxxxx
ClientIp=xxxxxxxx
Address="Sec4WenxinRdBeitunDist"
NameCheapUrl="https://api.namecheap.com/xml.response?"
Email=ly.lester@rayprosoft.com
TelegramChatId="-xxxxxxxx"
#TelegramChatId=$2
TelegramToken="xxxxxxxx"

## https://www.namecheap.com/promos/coupons/
IFS='.' read -r -a array <<< "$DomainName"
TLD="${array[1]}"
SLD="${array[0]}"

Url="$NameCheapUrl&\
ApiUser=$ApiUser&\
ApiKey=$ApiKey&\
UserName=$UserName&\
DomainName=$DomainName&\
Command=namecheap.domains.dns.setCustom&\
ClientIp=$ClientIp&\
SLD=$SLD&\
TLD=$TLD&\
Nameservers=$Nameservers"

echo "Url=$Url"

response=$(curl -X GET $Url -H "Content-Type: application/xml" -d '')
echo $response | xmllint --format - > changens.xml
sed -i 's/xmlns=\"http:\/\/api.namecheap.com\/xml.response\" //g' changens.xml

Status=$(xmllint --xpath '//ApiResponse/@Status' changens.xml)

Message=""

if [[ "$Status" == *"OK"* ]]; then
    read -r -d '' Message <<EOT
    修改nameserver: $DomainName 成功
EOT

else
    ErrorMsg=$(xmllint --xpath '//ApiResponse/Errors/Error/text()' changens.xml)
    read -r -d '' Message <<EOT
    修改nameserver: $DomainName 失敗
原因: $ErrorMsg
EOT

fi

curl -s --data-urlencode "text=$Message" --data "chat_id=$TelegramChatId" "https://api.telegram.org/bot$TelegramToken/sendMessage" > /dev/null
