FROM rockylinux:8
LABEL maintainer="Jeff Geerling"
ENV container=docker

# See: https://github.com/geerlingguy/docker-rockylinux8-ansible/issues/6
ENV pip_packages="ansible<10.0"

# Install systemd -- See https://hub.docker.com/_/centos/
RUN rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements.
RUN yum -y install rpm dnf-plugins-core \
 && yum -y update \
 && yum -y config-manager --set-enabled powertools \
 && yum -y install \
      epel-release \
      initscripts \
      sudo \
      which \
      hostname \
      libyaml-devel \
      python3.12 \
      python3.12-pip \
      python3.12-pyyaml \
      iproute \
 && yum clean all

# Upgrade pip to latest version.
RUN pip3.12 install --upgrade pip

# Install Ansible via Pip.
RUN pip3.12 install $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
