#!/bin/bash

STACK_NAME=eks-a
INFERENCE_NODE_GROUP_NAME=inference
NODE_GROUP_NAME=standard

CLUSTER_NAME=$STACK_NAME

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

AZ_0=us-east-1a
AZ_1=us-east-1b
AZ_2=us-east-1c

NODE_INSTANCE_TYPE=m5.large
INFERENCE_NODE_INSTANCE_TYPE=c5.large

KEY_NAME=SOMETHING

INFERENCE_BOOTSTRAP="--kubelet-extra-args --node-labels=inference=true,nodegroup=elastic-inference"

BOOTSTRAP="--kubelet-extra-args --node-labels=inference=false,nodegroup=standard"

# https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
AMI_ID=ami-0abcb9f9190e867ab # us-east-1

# This is the role used to create the stack - needs a trust relationship
# for CloudFormation and Lambda
CREATE_ROLE_ARN=arn:aws:iam::$ACCOUNT_ID:role/CreateEks

USERNAME=$(aws sts get-caller-identity --output text --query 'Arn' | awk -F'/' '{print $2}')

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://stack.cfn.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --role-arn $CREATE_ROLE_ARN \
  --parameters \
  ParameterKey=EksClusterName,ParameterValue=$CLUSTER_NAME \
  ParameterKey=AvailabilityZone0,ParameterValue=$AZ_0 \
  ParameterKey=AvailabilityZone1,ParameterValue=$AZ_1 \
  ParameterKey=AvailabilityZone2,ParameterValue=$AZ_2 \
  ParameterKey=AdminUser,ParameterValue=$USERNAME \
  ParameterKey=CreateRoleArn,ParameterValue=$CREATE_ROLE_ARN \
  ParameterKey=KeyName,ParameterValue=$KEY_NAME \
  ParameterKey=NodeImageId,ParameterValue=$AMI_ID \
  ParameterKey=InferenceNodeGroupName,ParameterValue=$INFERENCE_NODE_GROUP_NAME \
  ParameterKey=NodeGroupName,ParameterValue=$NODE_GROUP_NAME \
  ParameterKey=InferenceBootstrapArguments,ParameterValue="'$INFERENCE_BOOTSTRAP'" \
  ParameterKey=BootstrapArguments,ParameterValue="'$BOOTSTRAP'" \
  ParameterKey=NodeInstanceType,ParameterValue=$NODE_INSTANCE_TYPE \
  ParameterKey=InferenceNodeInstanceType,ParameterValue=$INFERENCE_NODE_INSTANCE_TYPE


