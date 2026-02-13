import boto3
import time
from botocore.exceptions import ClientError

def create_table():
    dynamodb = boto3.resource(
        'dynamodb',
        endpoint_url='http://localhost:4566',
        region_name='us-east-1',
        aws_access_key_id='test',
        aws_secret_access_key='test'
    )

    try:
        table = dynamodb.create_table(
            TableName='SnackTable',
            KeySchema=[
                {'AttributeName': 'PK', 'KeyType': 'HASH'},
                {'AttributeName': 'SK', 'KeyType': 'RANGE'}
            ],
            AttributeDefinitions=[
                {'AttributeName': 'PK', 'AttributeType': 'S'},
                {'AttributeName': 'SK', 'AttributeType': 'S'},
                {'AttributeName': 'GSI1PK', 'AttributeType': 'S'},
                {'AttributeName': 'GSI1SK', 'AttributeType': 'S'}
            ],
            GlobalSecondaryIndexes=[
                {
                    'IndexName': 'GSI1',
                    'KeySchema': [
                        {'AttributeName': 'GSI1PK', 'KeyType': 'HASH'},
                        {'AttributeName': 'GSI1SK', 'KeyType': 'RANGE'}
                    ],
                    'Projection': {
                        'ProjectionType': 'ALL'
                    },
                    'ProvisionedThroughput': {
                        'ReadCapacityUnits': 5,
                        'WriteCapacityUnits': 5
                    }
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
        )
        print("Creating table...")
        table.wait_until_exists()
        print("Table created successfully!")
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceInUseException':
            print("Table already exists.")
        else:
            print(f"Error creating table: {e}")

if __name__ == '__main__':
    # Wait for LocalStack to be ready
    print("Waiting for LocalStack...")
    time.sleep(5)
    create_table()
