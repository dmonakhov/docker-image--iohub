#! /bin/sh

IOHUB_TEMPLATE=$DIR/iohub.pod.j2

KUBECTL=
ADMIN_KEY="~/.ssh/id_rsa.pub"
IMAGE="dmonakhov/iohub"


function gen_id
{
	uuidgen --time
}

function gen_ssh_key
{
	local okey=$1
	local msg=""
	
	if test -n "$2"; then
	    msg="$2"
	else
		local key_id=$(gen_id)
		msg="iohub-tmp-key-$key_id"
	fi
	
	ssh-keygen  -t rsa -N "" -C $msg -f $okey
	
}

function gen_authorized
{}

function create_ssh_secret
{
	local key=$1
	local secname=$2
	local ak_tmpl=$3
	local akeys=`mktemp /tmp/XXXXXXX.authorized_keys`
	if test -n "$ak_tmpl"; then
	    cat $ak_tmpl > $akeys
	fi
	cat $key.pub >> $akeys
	
	$KUBECTL create secret generic $secname \
		 --from-file=id_rsa=$key --from-file=id_rsa.pub=$key.pub \
		 --from-file=authorized_keys=$akeys
	unlink $akeys
}

function rm_secret
{
	$KUBECTL delete secred $1
}

function gen_job
{
	
	local id=$1
	local key=$2
	local jobfile=$3
	local tmpl=$IOHUB_TEMPLATE
	if test -n "$4"; then
	    tmpl=$4
	fi
       
	local env=`mktemp /tmp/XXXXXXX.env`

	echo "JOB_NAME=$id" > $env
	echo "JOB_GROUP=iohub-bot" >> $env
	echo "JOB_SSH_SECRET=$key" >> $env
	echo "JOB_IMAGE=$IMAGE" >> $env
	j2 --format=env $tmpl  > $jobfile
	unlink $env
}

function create_iohub
{
	local job_id=$1
	local wdir=/tmp/$job_id

	mkdir -p $wdir
	gen_ssh_key $wdir/key
	create_ssh_secret $wdir/key sshkey-$job_id $ADMIN_KEY
	gen_job $job_id $wdir/key $wdir/iohub-pod.yaml
	$KUBECTL create -f $wdir/iohub-pod.yaml
}

function rm_iohub
{
	local job_id=$1
	local wdir=/tmp/$job_id

	$KUBECTL delete -f $wdir/iohub-pod.yaml
	$KUBECTL delete secret sshkey-$job_id
	rm -rf $wdir
}
