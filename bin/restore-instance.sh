#!/bin/bash
#
# start an EC2 instance, with the latest backup snapshot mounted at /mnt
#
# restore-instance.sh [<snap_id>]

set -e

amazon_dir=$(dirname "$(readlink -f "$0")")
. "${amazon_dir}/functions.sh"

[ -f /etc/backup/config ] && . /etc/backup/config

if [ $# -lt 1 ]; then
    snapid=`read_snapid`
else
    snapid="$1"
fi


# faith's backup device is a disk; buffy's is a partition...
BACKUP_DEVICE=${BACKUP_DEVICE:-/dev/sdc}
out=`"${amazon_dir}/start-instance.sh" -u "${etc_dir}/userdata/ssh-server.yaml" -- -b "${BACKUP_DEVICE}=$snapid"`

cd "$out"
instance_id=`cat instance_id`
ip=`cat ip`

echo "mounting backup drive"
ssh -o StrictHostKeyChecking=yes -oUserKnownHostsFile=known_hosts -iid_rsa ubuntu@$ip sudo mount /dev/xvdc1 /mnt


echo "EC2 instance started at $ip; ssh via \"${amazon_dir}/amazon-ssh.sh\" $out."
echo "shut it down with \"${amazon_dir}/terminate-instance.sh\" $out."
