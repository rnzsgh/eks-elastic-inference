#!/bin/bash

STACK_NAME=eks-a
NODE_GROUP_NAME=compute

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

AZ_0=us-east-1a
AZ_1=us-east-1b
AZ_2=us-east-1c

KEY_NAME=rnzdev

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
  ParameterKey=AvailabilityZone0,ParameterValue=$AZ_0 \
  ParameterKey=AvailabilityZone1,ParameterValue=$AZ_1 \
  ParameterKey=AvailabilityZone2,ParameterValue=$AZ_2 \
  ParameterKey=AdminUser,ParameterValue=$USERNAME \
  ParameterKey=CreateRoleArn,ParameterValue=$CREATE_ROLE_ARN \
  ParameterKey=KeyName,ParameterValue=$KEY_NAME \
  ParameterKey=NodeImageId,ParameterValue=$AMI_ID \
  ParameterKey=NodeGroupName,ParameterValue=$NODE_GROUP_NAME

