#!/bin/bash
for i in `seq $1 $2`
do
  rm  works/$i/$3
done
