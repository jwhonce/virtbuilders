#!/bin/sh

instanceid=$1
name=$2

sh -c 'cat >meta-data <<-EOF
  instance-id: '$instanceid'
  local-hostname: '$instanceid'.vm
EOF'

sh -c 'cat >user-data <<-EOF
  #cloud-config
  ssh_pwauth: True
  user:
    - name: root
  chpasswd:
    list: |
      root:'$instanceid'
    expire: False
  runcmd:
    - sed -i -e "/PermitRootLogin/s/^.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
    - systemctl reload sshd
EOF'

genisoimage -output ./$name/init.iso -volid cidata -joliet -rock user-data meta-data
