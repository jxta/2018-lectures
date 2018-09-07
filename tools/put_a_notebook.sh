#!/bin/bash
for i in `seq $1 $2`
do
  cp  notebooks/$3 works/$i/$3
done
