# Assessment II: AWS Serverless Application with AI Services

**Author:** George Villanueva  
**Program:** Code Platoon - AI Cloud & DevOps Bootcamp  
**Date:** December 2024

## Project Overview

A fully serverless application demonstrating modern cloud architecture using AWS Lambda, API Gateway, DynamoDB, and AI services. The application features a React frontend for user management, text-to-speech conversion, and sentiment analysis.

## Live Demo

**API Gateway URL:** `https://qil1k2i04b.execute-api.us-east-1.amazonaws.com/prod`

**Frontend:** Run locally with `npm start` in the `frontend/` directory

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture diagram and data flow.

### High-Level Components

- **Frontend:** React application with user management and AI service integrations
- **API Gateway:** REST API routing requests to Lambda functions
- **Lambda Functions:** 4 serverless functions (CRUD + AI services)
- **DynamoDB:** NoSQL database for user storage
- **AI Services:** Amazon Polly (TTS) + Amazon Comprehend (Sentiment Analysis)
- **Infrastructure:** Terraform for infrastructure as code

## Features

### 1. User Management (CRUD Operations)
- Create new users with name and email
- View all users in real-time
- Data persisted in DynamoDB
- Automatic UUID generation

### 2. Text-to-Speech (Amazon Polly)
- Convert text to natural-sounding speech
- Multiple voice options (Male/Female, US/UK accents)
- Neural voice engine for high quality
- Audio playback in browser

### 3. Sentiment Analysis (Amazon Comprehend)
- Analyze text sentiment (Positive/Negative/Neutral/Mixed)
- Confidence scores for each sentiment category
- Visual representation with color-coded results
- Real-time analysis

## Technology Stack

**Frontend:**
- React 18
- JavaScript (ES6+)
- Responsive CSS

**Backend:**
- AWS Lambda (Python 3.11)
- API Gateway (REST API)
- DynamoDB (NoSQL)

**AI Services:**
- Amazon Polly (Neural TTS)
- Amazon Comprehend (NLP)

**Infrastructure:**
- Terraform 1.0+
- S3 (Remote State)
- DynamoDB (State Locking)
- CloudWatch (Logging)

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Node.js >= 14
- Python >= 3.11
- Git

## Deployment Instructions

### 1. Clone Repository
```bash
git clone https://github.com/gvill0576/assessment-2-app-deployment-with-terraform.git
cd assessment-2-app-deployment-with-terraform
```

### 2. Deploy Infrastructure with Terraform
```bash
cd terraform

# Create S3 bucket and DynamoDB table for remote state
./bootstrap.sh

# Package Lambda functions
./package_lambdas.sh

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
# Type 'yes' when prompted

# Save the API Gateway URL from outputs
```

**Expected Output:**
```
api_gateway_url = "https://xxxxx.execute-api.us-east-1.amazonaws.com/prod"
```

### 3. Configure and Run Frontend
```bash
cd ../frontend

# Create .env file with your API URL
echo "REACT_APP_API_URL=<YOUR_API_GATEWAY_URL>" > .env

# Install dependencies
npm install

# Start development server
npm start
```

The app will open at `http://localhost:3000`

## API Endpoints

### User Management

**GET /users**
- Returns all users from DynamoDB
- Response: `{"users": [...], "count": n}`

**POST /users**
- Creates a new user
- Request: `{"name": "string", "email": "string"}`
- Response: `{"message": "User created successfully", "user": {...}}`

### AI Services

**POST /polly**
- Converts text to speech
- Request: `{"text": "string", "voiceId": "string"}`
- Response: `{"audioContent": "base64_encoded_audio", "contentType": "audio/mpeg"}`

**POST /comprehend**
- Analyzes sentiment of text
- Request: `{"text": "string"}`
- Response: `{"sentiment": "POSITIVE|NEGATIVE|NEUTRAL|MIXED", "scores": {...}}`

## Testing

### Test API Endpoints
```bash
API_URL="https://qil1k2i04b.execute-api.us-east-1.amazonaws.com/prod"

# Test GET /users
curl $API_URL/users

# Test POST /users
curl -X POST $API_URL/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'

# Test Polly TTS
curl -X POST $API_URL/polly \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello world","voiceId":"Joanna"}'

# Test Comprehend
curl -X POST $API_URL/comprehend \
  -H "Content-Type: application/json" \
  -d '{"text":"I love this project!"}'
```

### Verify DynamoDB
```bash
aws dynamodb scan --table-name assessment-ii-users --region us-east-1
```

### Check Lambda Logs
```bash
aws logs tail /aws/lambda/assessment-ii-create-user --follow
```

## Project Structure
```
assessment-2-app-deployment-with-terraform/
├── README.md
├── ARCHITECTURE.md
├── .gitignore
├── terraform/
│   ├── backend.tf              # Remote state configuration
│   ├── main.tf                 # Main Terraform config
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── dynamodb.tf             # DynamoDB table
│   ├── iam.tf                  # IAM roles and policies
│   ├── lambda.tf               # Lambda function resources
│   ├── api_gateway.tf          # API Gateway configuration
│   ├── bootstrap.sh            # Create backend resources
│   ├── package_lambdas.sh      # Package Lambda functions
│   └── lambda_functions/
│       ├── create_user/
│       ├── get_users/
│       ├── polly_tts/
│       └── comprehend_sentiment/
└── frontend/
    ├── package.json
    ├── public/
    └── src/
        ├── App.js              # Main React component
        ├── App.css             # Styling
        └── index.js
```

## AWS Resources Created

**Compute:**
- 4 Lambda Functions (Python 3.11)

**API:**
- 1 API Gateway REST API
- 4 API Gateway Resources (/users, /polly, /comprehend)
- Multiple Methods (GET, POST, OPTIONS for CORS)

**Database:**
- 1 DynamoDB Table (Pay-per-request)

**IAM:**
- 2 IAM Roles (CRUD + AI)
- Custom policies for least privilege access
- CloudWatch Logs permissions

**Monitoring:**
- 4 CloudWatch Log Groups

**State Management:**
- 1 S3 Bucket (Terraform state)
- 1 DynamoDB Table (State locking)

## Security Features

- IAM role-based access control
- Separate roles for CRUD vs AI operations
- Least privilege permissions
- CORS enabled for frontend access
- No hardcoded credentials
- Encrypted S3 bucket for state storage
- CloudWatch logging for audit trails

## Cost Optimization

- Serverless architecture (pay per use)
- DynamoDB on-demand pricing
- Lambda free tier (1M requests/month)
- CloudWatch log retention (7 days)
- No EC2 instances to manage

## Troubleshooting

### CORS Errors
- Verify API Gateway OPTIONS methods are configured
- Check Lambda functions return proper CORS headers

### Lambda Timeout
- Increase timeout in `lambda.tf` if needed (current: 30s)

### Permission Errors
- Verify IAM roles have correct policies
- Check Lambda execution role permissions

### Region Mismatch
- Ensure all services use `us-east-1`

## Cleanup

To remove all AWS resources:
```bash
cd terraform
terraform destroy
# Type 'yes' when prompted

# Manually delete backend resources
aws s3 rb s3://gvillanueva-assessment-ii-tfstate --force
aws dynamodb delete-table --table-name assessment-ii-terraform-lock --region us-east-1
```

## Future Enhancements

- Add UPDATE and DELETE user operations
- Implement Amazon Lex chatbot
- Add Amazon Rekognition image analysis
- Deploy frontend to S3 + CloudFront
- Add authentication with Cognito
- Implement CI/CD pipeline
- Add automated testing

## Lessons Learned

- Terraform simplifies infrastructure management
- Serverless architecture reduces operational overhead
- IAM roles require careful planning for security
- API Gateway + Lambda is powerful for REST APIs
- AWS AI services are easy to integrate

## Acknowledgments

- Code Platoon instructors and curriculum
- AWS Documentation
- Terraform Registry

## License

This project is for educational purposes as part of Code Platoon's bootcamp assessment.

---

**Contact:** George Villanueva  
**GitHub:** https://github.com/gvill0576/assessment-2-app-deployment-with-terraform
