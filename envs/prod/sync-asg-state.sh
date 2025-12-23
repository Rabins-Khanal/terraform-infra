#!/usr/bin/env bash
set -euo pipefail

TF_ASG_RESOURCE="module.asg.aws_autoscaling_group.blue"

echo "Rebinding Terraform ASG state to latest CodeDeploy ASG"

# Always removes ASG from Terraform state

echo "Removing any existing ASG from Terraform state..."
terraform state rm "$TF_ASG_RESOURCE" >/dev/null 2>&1 || true

# Discovering latest CodeDeploy-created ASG

echo "Discovering latest CodeDeploy ASG..."

ACTIVE_ASG=$(aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?starts_with(AutoScalingGroupName, 'CodeDeploy_')].AutoScalingGroupName | sort(@) | [-1]" \
  --output text)

if [[ -z "$ACTIVE_ASG" || "$ACTIVE_ASG" == "None" ]]; then
  echo "No CodeDeploy ASG found. Aborting."
  exit 1
fi

echo "Latest ASG detected: $ACTIVE_ASG"


# Importing latest ASG into Terraform state

echo "Importing ASG into Terraform state..."
terraform import "$TF_ASG_RESOURCE" "$ACTIVE_ASG"


# Final refresh 

echo "Refreshing Terraform state..."
terraform refresh -input=false

echo "✅ Terraform state now tracks ASG: $ACTIVE_ASG"
