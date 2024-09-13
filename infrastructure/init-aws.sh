
echo "start localstack"
localstack start --env ./infrastructure/.env -d

echo "create SQS queue"
awslocal sqs create-queue --queue-name ebi-queue

echo "create SNS topic"
awslocal sns create-topic --name ebi-topic

echo "Subscribe to the topic"
awslocal sns subscribe --topic-arn arn:aws:sns:us-east-1:123456789012:ebi-topic --protocol sqs --notification-endpoint arn:aws:sns:us-east-1:123456789012:ebi-queue

echo "Create S3 bucket"
 awslocal s3api create-bucket \
  --bucket ebi-bucket \
  --create-bucket-configuration LocationConstraint=eu-west-1



zip -r|-j lambda-package.zip ./backend/dist

awslocal s3 cp lambda-package.zip  s3://ebi-bucket
awslocal s3 rm  s3://ebi-bucket/ --recursive

echo "Delete the lamda function"
awslocal lambda delete-function \
  --function-name test-function

echo "create lambda function"
awslocal lambda create-function \
  --function-name test-function \
  --runtime nodejs16.x \
  --role arn:aws:iam::000000000000:role/lambda-ex \
  --code S3Bucket="ebi-bucket",S3Key="lambda-package.zip" \
  --handler backend/dist/index.handler


echo "update lambda function"
awslocal lambda update-function-configuration \
  --function-name test-function \
  --handler dist/index.handler


echo "invoke lambda function"
awslocal lambda invoke \
    --function-name test-function \
    --cli-binary-format raw-in-base64-out output.txt

