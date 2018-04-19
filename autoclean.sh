#!/bin/bash

rm result/* -rf &> /dev/null
rm runtime/* -rf &> /dev/null

eval $(awk '($1 == "specjvmins:"){printf("specjvmins=%s",$2)}' paraconfig)

rm software/iozone3_326/ -rf  &> /dev/null
rm software/lmbench/ -rf  &>  /dev/null
rm software/specjvm2008/ -rf  &>  /dev/null
rm ${specjvmins}/SPECjvm2008/ -rf &>  /dev/null
rm software/stream/ -rf  &> /dev/null
rm software/UnixBench/ -rf  &> /dev/null
rm software/ttytest/ -rf  &>  /dev/null
