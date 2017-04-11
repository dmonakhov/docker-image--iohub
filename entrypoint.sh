#! /bin/sh -e

if test -z "$SSH_KEY";then
    echo "Env 'SSH_KEY' not defined"
    exit 1
fi
if test -n "$SSH_KEY" ;then
    cat "$SSH_KEY".pub >> /root/.ssh/authorized_keys
fi

echo "$MOTD_MSG" > /etc/motd

/usr/sbin/sshd -h $SSH_KEY -E /tmp/sshd.log -D
