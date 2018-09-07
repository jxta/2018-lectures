#!/bin/bash
for i in `seq 160 281`
do
        mkdir -p /home/jupyter/workspace/works/$i
        docker run  -d -p 18$i:80 -p 10$i:8888 --hostname=$i --user root -e NB_UID=1003 -e GRANT_SUDO=yes -v "/home/jupyter/workspace/works/$i:/home/jovyan/work" -v "/home/jupyter/workspace/notebooks:/notebooks"  jupyter/base-notebook start-notebook.sh --NotebookApp.token='Gunma-u#'
  echo  launched $i
  sleep 50
done
