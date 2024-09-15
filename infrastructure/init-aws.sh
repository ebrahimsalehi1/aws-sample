
var_sqs_name = "ebi-sqs"
var_topic_name="ebi-topic"
var_region_name = "eu-west-1"
var_bucket_name = "ebi-bucket"
var_lambda_name = "test-function"

# echo "------------\t create SQS queue"
# awslocal sqs create-queue --queue-name "ebi-sqs"

echo "------------\t create SNS topic"
awslocal sns create-topic --name "ebi-topic"

echo "------------\t Create S3 bucket"
awslocal s3api create-bucket --bucket "ebi-bucket" --create-bucket-configuration LocationConstraint="eu-west-1"

# echo "------------\t Remove data from S3 bucket"
# awslocal s3 rm  s3://ebi-bucket/ --recursive

echo "------------\t Create a zip file and upload it"

rm lambda-package.zip
zip -r lambda-package.zip ./backend/dist

awslocal s3 cp lambda-package.zip  s3://ebi-bucket

# echo "------------\t Delete the lamda function"
# awslocal lambda delete-function \
#   --function-name test-function

echo "------------\t create lambda function"
awslocal lambda create-function \
  --function-name test-function \
  --runtime nodejs16.x \
  --role arn:aws:iam::000000000000:role/lambda-ex \
  --code S3Bucket="ebi-bucket",S3Key="lambda-package.zip" \
  --handler backend/dist/index.handler


# echo "------------\t update lambda function"
# awslocal lambda update-function-configuration \
#   --function-name test-function \
#   --handler backend/dist/index.handler

# awslocal lambda update-function-code \
  # --function-name test-function \
  # --s3-bucket ebi-bucket \
  # --s3-key lambda-package.zip

echo "------------\t Subscribe to the topic"
awslocal sns subscribe \
    --topic-arn arn:aws:sns:eu-west-1:000000000000:ebi-topic \
    --protocol lambda \
    --notification-endpoint arn:aws:lambda:eu-west-1:000000000000:function:test-function

echo "------------\t Sleep before invoke lambda function"
sleep 5s

echo "------------\t invoke lambda function"
awslocal lambda invoke \
    --function-name test-function \
    --cli-binary-format raw-in-base64-out output.txt

echo "------------\t Publish to the topic"
awslocal sns publish --topic-arn arn:aws:sns:eu-west-1:000000000000:ebi-topic --message 'Hello world'  


# echo "API Gateway"

# awslocal apigateway create-rest-api --name "MyLocalAPI"
# awslocal apigateway get-rest-apis
# awslocal apigateway get-resources --rest-api-id <API_ID>
# awslocal apigateway create-resource --rest-api-id <your-api-id> --parent-id <parent-id> --path-part myresource
# awslocal apigateway put-method --rest-api-id <API_ID> --resource-id <RESOURCE_ID> --http-method GET --authorization-type NONE
# awslocal apigateway put-integration --rest-api-id <API_ID> --resource-id <RESOURCE_ID> --http-method GET --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:local:lambda:path/2015-03-31/functions/arn:aws:lambda:local:region:000000000000:function:<LAMBDA_FUNCTION_NAME>/invocations

# echo "deploy API gateway"
# awslocal apigateway create-deployment --rest-api-id <API_ID> --stage-name dev
