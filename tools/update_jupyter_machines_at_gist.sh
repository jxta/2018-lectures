#!/bin/bash
curl https://etherpad.openstack.org/p/2017-jupyter-machines/export/txt|head -186|tail -180|cut -f2 -d : > /tmp/user_name
paste /tmp/machine_name /tmp/user_name /tmp/CR > /tmp/jupyter_machines.md
gist -p -u https://gist.github.com/jxta/1d7d8be8a8fa92adcc15c0fd6c3ead08 /tmp/jupyter_machines.md
