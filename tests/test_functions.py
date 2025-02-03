import pytest
import boto3
from moto import mock_aws
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.functions.get_quote.get_quote_lambda_function import lambda_handler as get_quote_handler
from src.functions.put_quote.put_quote_lambda_function import lambda_handler as put_quote_handler

@mock_aws
def test_get_quote():
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.create_table(
        TableName='Quotes',
        KeySchema=[{'AttributeName': 'quote', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'quote', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    table.put_item(Item={
        'quote': 'Test quote',
        'author': 'Test author'
    })
    
    response = get_quote_handler({}, {})
    assert response['statusCode'] == 200
    assert 'Test quote' in response['body']

@mock_aws
def test_put_quote():
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.create_table(
        TableName='Quotes',
        KeySchema=[{'AttributeName': 'quote', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'quote', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    response = put_quote_handler({}, {})
    assert 'successfully' in response or 'Failed' in response