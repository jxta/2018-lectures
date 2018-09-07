#!/bin/bash
echo  > ~/work/data/notebook_size.csv
for i in `seq $1 $2`
do
  echo -n $i >> ~/work/data/notebook_size.csv
  echo -n ', ' >> ~/work/data/notebook_size.csv
  ls -l ~/work/works/$i/$3|cut -f5 -d ' '|tr '\n' ' ' >> ~/work/data/notebook_size.csv
  echo -n ', ' >> ~/work/data/notebook_size.csv
  ls -l ~/work/works/$i/$4|cut -f5 -d ' '|tr '\n' ' ' >> ~/work/data/notebook_size.csv
  echo -n ', ' >> ~/work/data/notebook_size.csv
  diff --ignore-matching-lines=execution_count ~/work/works/101/$3 ~/work/works/$i/$3|wc -l|tr '\n' ' ' >> ~/work/data/notebook_size.csv
  echo -n ', ' >> ~/work/data/notebook_size.csv
  diff --ignore-matching-lines=execution_count ~/work/works/101/$4 ~/work/works/$i/$4|wc -l|tr '\n' ' ' >> ~/work/data/notebook_size.csv
  echo >> ~/work/data/notebook_size.csv
done
