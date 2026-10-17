#!/bin/bash
set -e

dnf update -y

dnf install -y docker git

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

docker --version
git --version