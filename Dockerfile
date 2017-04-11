# Creates a tiny SSH and rsync server
#

FROM alpine
MAINTAINER Dmitry Monakhov <dmonakhov@gmail.com>

# Set up rsyncd and openSSH, set local time UTC
RUN apk --no-cache add \
  bash \
  rsync \
  openssh \
  openrc && \
  rc-update add rsyncd boot && \
  sed -i \
    -e 's/^UsePAM yes/#UsePAM yes/g' \
    -e 's/^PasswordAuthentication yes/PasswordAuthentication no/g' \
    -e 's/^#UseDNS yes/UseDNS no/g' \
  /etc/ssh/sshd_config && \
  mkdir -p /root/.ssh  && \
  ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Ssh key injenction performed via volumes
# or via k8s api https://kubernetes.io/docs/concepts/configuration/secret

# Open SSH port
#EXPOSE 22

ADD entrypoint.sh  /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# Run SSHd as a daemonize process to keep container running.
#CMD ["/usr/sbin/sshd", "-D"]
