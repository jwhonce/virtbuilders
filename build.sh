#!/bin/sh

is_available() {
	available=( $(virsh list --all --name) )
	for i in "${available[@]}"
	do
	    if [ "$i" == "$1"  ] ; then
		    echo "domain $1 already imported, please destroy and undefine it first"
		    exit
	    fi
	done
}

check_root() {
	if [ -e ./$1.qcow2 ]; then
		echo "$1.qcow2 exists, please remove it"
		exit
	fi
}

case $1 in
	rawhide)
		is_available rawhide
		check_root rawhide
		name=${OSNAME:-rawhide}
		root_password=${PASSWORD:-rawhide}
		dist="fedora-23"
		# using fedora22 as os-variant becuse virt-install ins't updatd yet probably and errors out
		osvariant="fedora22"
		run="$RUN --run rawhide/torawhide.sh"
		options="$OPTS --selinux-relabel"
		hostname=${HOSTNAME:-rawhide}
		;;
	*)
		echo "os not supported"
		exit
		;;
esac

virt-builder $dist -o $name.qcow2 --format qcow2 --root-password password:$root_password --update $options --size 10G $run --hostname $hostname
virt-install --name $name --ram 2048 --vcpus=2 --network bridge=virbr0 --disk path=$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --import
