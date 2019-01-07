#!/bin/bash
SCRIPT_VERSION=0.1

echo "############ Date     : $(date)"
echo "############ Job name : $JOB_NAME"
echo "############ Version  : $SCRIPT_VERSION"

# Add script version job
azmon_log_field version $SCRIPT_VERSION

echo "## Task: source functions"

# Source functions.sh
source /azmon/azurecli/common/functions.sh \
  && echo "Sourced functions.sh" \
  || { echo "Failed to source functions.sh" ; exit ; }

echo "## Task: connect"

openssl s_client -connect management.$(cat /run/secrets/fqdn):443 \
  && azmon_log_status armtenant_openssl_connect pass \
  || azmon_log_status armtenant_openssl_connect fail

echo "## Task: auth"

# Login to cloud ("adminmanagement" for admin endpoint, "management" for tenant endpoint)
azmon_login management

echo "## Task: get resources"

$(az resource list) \
  && azmon_log_status armadmin_list_resources pass \
  || azmon_log_status armadmin_list_resources fail

# Update log with runtime for job
azmon_log_runtime job
# Update log with completed job 
azmon_log_field job 1