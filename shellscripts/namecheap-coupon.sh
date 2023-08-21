#!/bin/bash

function getCouponCode(){
    url="https://www.namecheap.com/promos/coupons/"
    response=$(curl $url)
    echo $response > coupon.html
    result=$(xmllint --html -xpath "/html/body/fragment[2]/*/div/div/section[2]/div/div/div/div[1]/div/div[2]/div/div[1]/button/text()"  coupon.html)
    echo $result 
}


result=$(getCouponCode)
echo "result=$result"

