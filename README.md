```markdown
# Quotes Service

A serverless service that manages inspirational quotes using AWS Lambda and DynamoDB.

## Features

- Fetch random quotes from zenquotes.io
- Store quotes in DynamoDB
- Retrieve random quotes from the database

## Prerequisites

- AWS CLI configured
- Python 3.9+
- Terraform
- Make (optional)

## Setup

1. Clone the repository
```bash
git clone 
cd quotes-service
```

2. Create and activate virtual environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
```

3. Install dependencies
```bash
pip install -r requirements.txt
```

4. Copy environment variables
```bash
cp .env.example .env
```

5. Deploy infrastructure
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

## Testing

Run the tests using pytest:
```bash
pytest tests/
```

## Infrastructure

The service uses the following AWS resources:

- DynamoDB table for storing quotes
- Two Lambda functions (get_quote and put_quote)
- IAM roles and policies
- API Gateway (optional)
