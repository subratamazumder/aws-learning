export AWS_DEFAULT_PROFILE=devtest
export AWS_DEFAULT_REGION=eu-west-2
for region in `aws ec2 describe-regions --region us-east-1 --output text | cut -f4`
do
     echo -e "\nListing Instances in region:'$region'..."
     aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name]' --region $region
done
# [InstanceId,ImageId,Tags[*]]
#aws ec2 describe-instances --filters  --query 'Reservations[].Instances[].[InstanceId,State.Name]'
#aws ec2 describe-instances --filters  "Name=instance-state-name,Values=stopped" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value[]'
