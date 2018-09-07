#!/bin/bash
curl https://etherpad.openstack.org/p/med-grad-jupyter-machines/export/txt|head -56|tail -50|cut -f2 -d : > /tmp/med_grad_user_name
paste /tmp/med_grad_machine_name /tmp/med_grad_user_name /tmp/CR > /tmp/med_grad_jupyter_machines.md
gist -p -u https://gist.github.com/jxta/0ec8fca493512a3f8b7766164b3c9c48 /tmp/med_grad_jupyter_machines.md
