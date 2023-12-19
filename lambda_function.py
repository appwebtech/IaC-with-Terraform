import os

import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def handler(event, context):
    page_id = "landing-page"
    response = table.update_item(
        Key={'page_id': page_id},
        UpdateExpression='ADD page_views :val',
        ExpressionAttributeValues={':val': 1},
        ReturnValues='UPDATED_NEW'
    )

    page_views = response['Attributes']['page_views']
    
    return {
        'statusCode': 200,
        'body': f'Page views: {page_views}'
    }
