export INS_ID=$1
export REGION=$2

aws ec2 modify-instance-attribute --instance-id=$INS_ID --no-disable-api-termination --region $REGION
aws ec2 terminate-instances --instance-ids $INS_ID --region $REGION