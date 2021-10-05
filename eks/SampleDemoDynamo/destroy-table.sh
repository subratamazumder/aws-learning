export STACK_NAME=dynamo-eprescription-user-profile-stack
export AWS_CLI_PROFILE=devtest
export AWS_DEFAULT_REGION=eu-west-2

aws cloudformation delete-stack --stack-name $STACK_NAME \
  --profile $AWS_CLI_PROFILE \
  --region $AWS_DEFAULT_REGION