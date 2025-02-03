# Quotes Service

A Serverless AWS Web Application that fetches and stores inspirational quotes using Lambda functions and DynamoDB

## Features

- Fetch random quotes from zenquotes.io API
- Store quotes in DynamoDB
- Random quote retrieval from DynamoDB
- Automated testing with moto
- Infrastructure as Code with Terraform

## Prerequisites

- AWS CLI configured
- Python 3.12+
- Terraform
- Windows PowerShell

## Project Structure
Copyquotes-service/
├── src/
│   └── functions/
│       ├── get_quote/
│       │   └── get_quote_lambda_function.py
│       └── put_quote/
│           └── put_quote_lambda_function.py
├── infrastructure/
│   └── main.tf
├── tests/
│   └── test_functions.py
└── make.bat

## Setup

1. Clone the repository
```bash
git clone https://github.com/Saketh1702/quotes-service.git
cd quotes-service
```

2. Install dependencies
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
```

3. Install dependencies
```bash
.\make.bat setup
```

4. Run tests
```bash
.\make.bat test
```

5. Deploy to AWS
```bash
.\make.bat deploy
```

## AWS Resources Created
- DynamoDB table for quote storage
- Lambda functions:
-- get-quote: Retrieves random quote
-- put-quote: Stores new quotes
- API Gateway endpoints
- IAM roles and policies
- CloudWatch logging
  
## Test Endpoints
### After deployment
```
curl -X GET https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/quotes
curl -X POST https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/quotes
```

