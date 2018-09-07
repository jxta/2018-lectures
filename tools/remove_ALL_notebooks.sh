#!/bin/bash
for i in `seq $1 $2`
do
  rm -r works/$i/*
done
