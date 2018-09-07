#!/bin/bash
for i in `seq 101 103`
do
#        mkdir /home/jupyter/workspace/works/$i
        docker run  -d -p 10$i:8888 --hostname=$i --user root -e NB_UID=1003 -e GRANT_SUDO=yes -v "/home/jupyter/workspace/works/$i:/home/jovyan/work" -v "/home/jupyter/workspace/notebooks:/notebooks" jxta/datascience-notebook start-notebook.sh --NotebookApp.token='Gunma-u#'
  echo  launched $i
  sleep 60
done
