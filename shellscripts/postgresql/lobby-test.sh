#!/bin/bash
export lobby=lobby-test1
echo $lobby
envsubst <  lobby-demo.yml 
envsubst <  lobby-demo.yml | kubectl apply -f -
export lobby=lobby-gpi
echo $lobby
envsubst <  lobby-demo.yml 
envsubst <  lobby-demo.yml | kubectl apply -f -
export lobby=lobby-ufa01
echo $lobby
envsubst <  lobby-demo.yml 
envsubst <  lobby-demo.yml | kubectl apply -f -