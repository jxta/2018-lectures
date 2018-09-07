#!/bin/bash
for i in `seq 100 129`
do
        mkdir -p /home/jupyter/workspace/works/$i
        docker run  -d -p 18$i:80 -p 10$i:8888 --hostname=$i --user root -e NB_UID=1003 -e GRANT_SUDO=yes -v "/home/jupyter/workspace/works/$i:/home/jovyan/work" -v "/home/jupyter/workspace/notebooks:/notebooks"  jupyter/scipy-notebook:23dbbebddc3d start-notebook.sh --NotebookApp.token='Gunma-u#'
  echo  launched $i
  sleep 50
done
