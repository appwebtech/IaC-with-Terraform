import os

import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def handler(event, context):
    try:
        page_id = "homepage"
        response = table.update_item(
            Key={'page_id': page_id},
            UpdateExpression='ADD page_views :val',
            ExpressionAttributeValues={':val': 1},
            ReturnValues='UPDATED_NEW'
        )

        page_views = response['Attributes']['page_views']
        
        # Explicitly allow Origin and headers to enable resource fetching via API Gateway
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': f'Page views: {page_views}'
        }
    except Exception as e: # Create exception and parse error on CLI when I curl api gateway endpoint
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': 'Internal Server Error'
        }
