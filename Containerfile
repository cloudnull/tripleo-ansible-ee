ARG VERSION=0.0.0

FROM registry.access.redhat.com/ubi8/python-38 as BUILD

EXPOSE 8080

LABEL summary="Execution environment for TripleO Ansible." \
      description="This is the execution environment for TripleO Ansible." \
      io.k8s.description="This is the execution environment for TripleO Ansible." \
      io.k8s.display-name="TripleO Ansible Execution Container" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="tripleo,ansible" \
      com.redhat.component="tripleo-ansible-container" \
      name="tripleo_ansible_ee" \
      version="${VERSION}" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir=3.8/test/setup-test-app/ ubi8/python-38 python-sample-app" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI" \
      maintainer="openstack.org <kecarter@redhat.com>"

USER root

WORKDIR /build
RUN python3.8 -m venv /build/builder
RUN /build/builder/bin/pip install --force --upgrade pip setuptools bindep
ADD bindep.txt /build/bindep.txt
RUN dnf install -y $(/build/builder/bin/bindep -b -f /build/bindep.txt test)

ADD requirements.txt /build/requirements.txt
WORKDIR /ansible-runner
RUN /bin/python3.8 -m venv /ansible-runner
RUN /ansible-runner/bin/pip install --force --upgrade pip setuptools bindep
RUN /ansible-runner/bin/pip install -r /build/requirements.txt --force --upgrade
RUN /ansible-runner/bin/pip install git+https://github.com/ansible/ansible
RUN /ansible-runner/bin/pip install git+https://github.com/ansible/ansible-runner
RUN /ansible-runner/bin/pip install git+https://github.com/openstack/tripleo-ansible
RUN /ansible-runner/bin/pip install git+https://github.com/openstack/tripleo-common

ADD requirements.yaml /build/requirements.yaml
WORKDIR /usr/share/ansible/roles
RUN /ansible-runner/bin/ansible-galaxy role install -r /build/requirements.yaml --roles-path /usr/share/ansible/roles
WORKDIR /usr/share/ansible/collections
RUN /ansible-runner/bin/ansible-galaxy collection install -r /build/requirements.yaml --collections-path /usr/share/ansible/collections

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
RUN chmod +x /usr/local/bin/dumb-init

FROM registry.access.redhat.com/ubi8/ubi-minimal
RUN microdnf install -y openssh python3.8 && rm -rf /var/cache/{dnf,yum}
RUN /bin/python3.8 -m venv --upgrade /ansible-runner
COPY --from=BUILD /usr/share/ansible/roles /usr/share/ansible/roles
COPY --from=BUILD /usr/share/ansible/collections /usr/share/ansible/collections
COPY --from=BUILD /ansible-runner /ansible-runner
COPY --from=BUILD /usr/local/bin/dumb-init /usr/local/bin/dumb-init
ADD entrypoint /bin/entrypoint
RUN chmod +x /bin/entrypoint
USER 1001
CMD ["/ansible-runner/bin/ansible-runner", "run", "/runner"]
ENTRYPOINT ["entrypoint"]
