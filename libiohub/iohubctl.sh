#! /bin/bash

set -ex
DIR=$(dirname $0)

. $DIR/iohub.sh


function usage
{
	echo "$0:"
	echo "	create"
	echo "	delete id"
	exit 1
}

case "$1" in
	create)
		id=$(gen_id)
		echo "id: $id"
		create_iohub $id
		## TEST
		port=`$KUBECTL get svc/iohub-$id -o jsonpath={.spec.ports[].nodePort}`
		nodename=`$KUBECTL get po/iohub-$id -o jsonpath="{.spec.nodeName}"`
		echo "ssh -p $port -i /tmp/$id/key root@$nodename"
		;;
	delete)
		id=$2
		rm_iohub $id
		;;
	*)
		usage
		;;
esac

