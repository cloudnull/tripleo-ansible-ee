ARG VERSION=0.1.0
ARG ANSIBLE_RUNNER=https://github.com/ansible/ansible-runner

FROM quay.io/ansible/ansible-runner:latest

LABEL summary="Execution environment for TripleO Ansible." \
      description="This is the execution environment for TripleO Ansible." \
      io.k8s.description="This is the execution environment for TripleO Ansible." \
      io.k8s.display-name="TripleO Ansible Execution Container" \
      io.openshift.tags="tripleo,ansible" \
      com.redhat.component="tripleo-ansible-container" \
      name="tripleo_ansible_ee" \
      version="${VERSION}" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir=3.8/test/setup-test-app/ ubi8/python-38 python-sample-app" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI" \
      maintainer="openstack.org <kecarter@redhat.com>"

USER root

ADD requirements.yaml /build/requirements.yaml

WORKDIR /usr/share/ansible/roles
RUN ansible-galaxy role install -r /build/requirements.yaml --roles-path /usr/share/ansible/roles

WORKDIR /usr/share/ansible/collections
RUN ansible-galaxy collection install -r /build/requirements.yaml --collections-path /usr/share/ansible/collections

USER 1001

CMD ["ansible-runner", "worker", "--private-data-dir=/runner"]
