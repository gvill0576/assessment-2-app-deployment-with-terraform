# Create bootstrap script for S3 and DynamoDB backend
#!/bin/bash
# Bootstrap script for Terraform backend resources

REGION="us-east-1"
BUCKET_NAME="gvillalta-assessment-ii-tfstate"  # Must be globally unique
TABLE_NAME="assessment-ii-terraform-lock"

echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

echo "Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $REGION

echo ""
echo "Backend resources created successfully!"
echo ""
echo "Update your backend.tf with these values:"
echo "  bucket = \"$BUCKET_NAME\""
echo "  dynamodb_table = \"$TABLE_NAME\""