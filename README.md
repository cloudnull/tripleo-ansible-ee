# Ansible Execution Environment for TripleO

This repository is used as an example of what an Ansible execution environment
could look like within the TripleO context.

## Native Building

To build the execution environment natively run the following command.

``` shell
podman image build -t tripleo_ansible_ee -f Containerfile
```

This will produce a container image named `tripleo_ansible_ee`.

## Ansible Builder

To build the execution environment using the ansible-builder tool chain,
run the following command.

``` shell
ansible-builder build --tag tripleo_ansible_ee --container-runtime podman
```

> This build relies on the `execution-environment.yml` file, to customize
  the build all changes will need to go within this file.

## Running Ansible with the execution environment

Running Ansible within an execution environment requires the use of
`ansible-runner` 2.x+. Sadly, at the time of this writing,
`ansible-runner` 2.x is un-released and only exists within the `devel`
branch of the project. For the purpose of example, the required software
will be installed within a virtual-environment.

``` shell
python3 -m venv ansible-runner
./ansible-runner/bin/pip install --upgrade --force pip setuptools wheel
./ansible-runner/bin/pip install --upgrade --force git+https://github.com/ansible/ansible-runner#egg=ansible-runner
```

With everything installed run a test playbook.

``` shell
ansible-builder/bin/ansible-runner --debug playbook --container-image tripleo_ansible_ee test-playbook.yaml -i localhost,
```

#### Getting the image from GitHub Packages

To pull the pre-built image from github packages, you will need to login with an access token.

``` shell
podman login https://docker.pkg.github.com -u $USERNAME
podman pull docker.pkg.github.com/cloudnull/tripleo-ansible-ee/tripleo_ansible_ee:main
```

#### Getting the image from Docker Hub

The pre-built container image is available on docker hub.

``` shell
docker pull cloudnull/tripleo-ansible-ee
```

#### Getting the image from Quay

The pre-built container image is available on quay.

```
podman pull quay.io/cloudnull/tripleo-ansible-ee
```
