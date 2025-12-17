# Architecture Diagram

## System Overview
```
┌─────────────────────────────────────────────────────────────────┐
│                         USER BROWSER                             │
│                    (React Frontend - Port 3000)                  │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTPS
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (REST API)                      │
│            https://qil1k2i04b.execute-api.us-east-1...          │
│                                                                  │
│  Routes:                                                         │
│  • POST /users  → Create User Lambda                            │
│  • GET  /users  → Get Users Lambda                              │
│  • POST /polly  → Polly TTS Lambda                              │
│  • POST /comprehend → Comprehend Sentiment Lambda               │
└───────┬──────────────┬──────────────┬────────────┬──────────────┘
        │              │              │            │
        ▼              ▼              ▼            ▼
┌──────────────┐ ┌──────────────┐ ┌─────────┐ ┌──────────────┐
│   Lambda:    │ │   Lambda:    │ │ Lambda: │ │   Lambda:    │
│ Create User  │ │  Get Users   │ │ Polly   │ │  Comprehend  │
│              │ │              │ │  TTS    │ │  Sentiment   │
└──────┬───────┘ └──────┬───────┘ └────┬────┘ └──────┬───────┘
       │                │              │              │
       │                │              │              │
       ▼                ▼              ▼              ▼
┌──────────────────────────┐  ┌────────────────────────────┐
│       DynamoDB           │  │     AWS AI Services        │
│   assessment-ii-users    │  │  • Amazon Polly (TTS)      │
│                          │  │  • Amazon Comprehend       │
│  Stores user records:    │  │    (Sentiment Analysis)    │
│  - userId (PK)           │  │                            │
│  - name                  │  └────────────────────────────┘
│  - email                 │
│  - createdAt             │
│  - updatedAt             │
└──────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE MANAGEMENT                     │
│                                                                  │
│  Terraform State:                                                │
│  • S3 Bucket: gvillanueva-assessment-ii-tfstate                 │
│  • DynamoDB Lock: assessment-ii-terraform-lock                  │
│                                                                  │
│  IAM Roles:                                                      │
│  • lambda-crud-role: DynamoDB access + CloudWatch logs          │
│  • lambda-ai-role: Polly + Comprehend access + CloudWatch logs  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### User Creation Flow
1. User fills form in React frontend
2. POST request to API Gateway `/users`
3. API Gateway invokes Create User Lambda
4. Lambda writes to DynamoDB
5. Returns success response
6. Frontend refreshes user list

### Text-to-Speech Flow
1. User enters text and selects voice
2. POST request to API Gateway `/polly`
3. API Gateway invokes Polly TTS Lambda
4. Lambda calls Amazon Polly service
5. Returns base64-encoded MP3 audio
6. Frontend decodes and plays audio

### Sentiment Analysis Flow
1. User enters text to analyze
2. POST request to API Gateway `/comprehend`
3. API Gateway invokes Comprehend Lambda
4. Lambda calls Amazon Comprehend service
5. Returns sentiment + confidence scores
6. Frontend displays visual results

## Technology Stack

**Frontend:**
- React 18
- JavaScript (ES6+)
- CSS3

**Backend:**
- AWS Lambda (Python 3.11)
- API Gateway (REST API)
- DynamoDB (NoSQL Database)

**AI Services:**
- Amazon Polly (Neural TTS)
- Amazon Comprehend (NLP/Sentiment Analysis)

**Infrastructure:**
- Terraform (IaC)
- S3 (State Storage)
- DynamoDB (State Locking)
- CloudWatch (Logging)

**IAM Security:**
- Least privilege access
- Separate roles for CRUD vs AI functions
- CloudWatch logging for all functions

## Key Features

**Fully Serverless:** No EC2 instances to manage
**Infrastructure as Code:** Everything defined in Terraform
**Scalable:** Auto-scales with Lambda + DynamoDB
**Cost-Effective:** Pay only for actual usage
**Secure:** IAM role-based access control
**Monitored:** CloudWatch logs for debugging
