
FROM ubuntu:18.04
LABEL maintainer="Matthew McCann"

ENV pip_packages "ansible"
ENV php_version=7.0
ENV DEBIAN_FRONTEND noninteractive

# install dependencies
RUN apt-get update \
    # ubuntu
    && apt-get install -y --no-install-recommends \
       apt-utils \
       locales \
       python-setuptools \
       python-pip \
       software-properties-common \
       rsyslog systemd systemd-cron sudo iproute2 \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    # php
    &&  add-apt-repository ppa:ondrej/php -y \
    &&  apt-get install -y php${php_version} \
#    && apt-get install -y php${php_version}-mysql php${php_version}-curl php${php_version}-json php${php_version}-cgi php${php_version}-xsl \
    && apt-get clean
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Install Ansible via Pip.
RUN pip install $pip_packages

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]