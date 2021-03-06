#!/usr/bin/env bash

set -e

eval "$(pcf-bosh-ci/scripts/director-environment bosh-vars-store/*-bosh-vars-store.yml terraform-state/metadata)"

cat <<AWSSBVARS > p-aws-sb-vars-template.yml
---
########################
# Cloud Foundry config #
########################
system_domain: $(jq -r .sys_domain terraform-state/metadata)
mysql_admin_password: $(jq -r .rds_password terraform-state/metadata)
mysql_host: $(jq -r .rds_address terraform-state/metadata)
aws_access_key_id: $(jq -r .bosh_iam_user_access_key terraform-state/metadata)
aws_secret_access_key_id: $(jq -r .bosh_iam_user_secret_access_key terraform-state/metadata)
skip_ssl_validation: true
AWSSBVARS

#TODO hack.. move to task
bosh upload-stemcell https://s3.amazonaws.com/bosh-aws-light-stemcells/light-bosh-stemcell-3312.20-aws-xen-hvm-ubuntu-trusty-go_agent.tgz

bosh -n deploy penguin-ci/manifests/aws-service-broker/aws-service-broker.yml \
  --deployment aws-service-broker \
  --vars-file p-aws-sb-vars-template.yml
