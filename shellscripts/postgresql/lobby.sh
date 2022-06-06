#!/bin/bash
export lobby=lobby-test1
envsubst <  lobby-demo.yml | kubectl apply -f - 

export lobby=lobby-gpi
envsubst <  lobby-demo.yml | kubectl apply -f - 

export lobby=lobby-ufa01
envsubst <  lobby-demo.yml | kubectl apply -f - 