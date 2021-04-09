import json
import boto3
import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('user-subscriptions')

s3 = boto3.client('s3')


def user_event_processing(data):
    response = None
    try:
        if data['operation'] == "create":
            response = table.put_item(
                Item={
                    'UserName': data['name'],
                    'FirstName': data['firstname'],
                    'LastName': data['lastname'],
                    'UserUUID': data['uuid'],
                    'Country': data['country'],
                    'Active': data['active'],
                    'Subscriptions': {}
                }
            )
        elif data['operation'] == "update":
            response = table.update_item(
                Key={
                    'UserUUID': data['uuid']
                },
                UpdateExpression='SET UserName = :UName, FirstName = :FName, LastName = :LName, Country = :Country, Active = :Active',
                ExpressionAttributeValues={
                    ':UName': data['name'],
                    ':FName': data['firstname'],
                    ':LName': data['lastname'],
                    ':Country': data['country'],
                    ':Active': data['active']
                },
                ReturnValues="UPDATED_NEW"
            )
    except Exception as e:
        print("Exception caught during user event processing->", e)
        return "Failed"

    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print("User event is successfuly processed -> ", response)
        return "Success"
    return "Failed"


def subscription_event_processing(data):
    response = None
    try:
        if data['operation'] == "create":
            response = table.update_item(
                Key={
                    'UserUUID': data['user_uuid']
                },
                UpdateExpression="set Subscriptions.#Lang = :SubName",
                ExpressionAttributeNames={
                    '#Lang': data['language']
                },
                ExpressionAttributeValues={
                    ':SubName': {
                        'SubscriptionName': data['name'],
                        'SubscriptionType': data['subscription_type'],
                        'SubscriptionPeriod': data['subscription_period'],
                        'SubscriptionStatus': data['subscription_status']
                    }
                },
                ReturnValues="UPDATED_NEW"
            )
        elif data['operation'] == "update":
            response = table.update_item(
                Key={
                    'UserUUID': data['user_uuid']
                },
                UpdateExpression="set Subscriptions.{} = :val".format(data['language']),
                ExpressionAttributeValues={
                    ':val': {'SubscriptionName': data['name'],
                             'SubscriptionType': data['subscription_type'],
                             'SubscriptionPeriod': data['subscription_period'],
                             'SubscriptionStatus': data['subscription_status']
                             }
                },
                ReturnValues="UPDATED_NEW"
            )
    except Exception as e:
        print("Exception caught subscription create/update -> ", e)
        return "Failed"

    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print("Subscription event is successfully processed -> ", response)
        return "Success"
    return "Failed"


def lesson_event_processing(data):
    try:
        response = table.get_item(
            Key={
                'UserUUID': data['properties']['user_uuid']
            }
        )

        if response['ResponseMetadata']['HTTPStatusCode'] == 200:
            language = data['properties']['language']
            result = response['Item']

            data['country'] = result['Country']
            data['subscription_status'] = result['Subscriptions'][language]['SubscriptionStatus']
            data['subscription_type'] = result['Subscriptions'][language]['SubscriptionType']

            print("lesson event is successfully processed -> :", data)
            return "Success"
        return "Failed"
    except Exception as e:
        print("Exception caught during lesson event processing -> ", e)
        return "Failed"


def post_events_process(body, bucket_name):
    try:
        response = s3.put_object(
            Body=str(json.dumps(body)),
            Bucket=bucket_name,
            Key='{}-event-{}'.format(body['title'], datetime.datetime.now())
        )

        if response['ResponseMetadata']['HTTPStatusCode'] == 200:
            print("{} event is successfully pushed to s3 -> {}".format(body['title'], response))
            return "Success"
        return "Failed"
    except Exception as e:
        print("Exception caught during S3 Upload -> ", e)
        return "Failed"


def lambda_handler(event, context):
    response = None
    body = None
    try:
        for i in event['Records']:
            body = json.loads(i['body'])
            if body['title'] == "user":
                response = user_event_processing(body['properties'])
                if response == "Success":
                    body['event_processed'] = True
                    post_events_process(body, bucket_name='sst-user-events')
                else:
                    body['event_processed'] = False
                    post_events_process(body, bucket_name='sst-user-events')

            elif body['title'] == "subscription":
                response = subscription_event_processing(body['properties'])
                if response == "Success":
                    body['event_processed'] = True
                    post_events_process(body, bucket_name='sst-subscription-events')
                else:
                    body['event_processed'] = False
                    post_events_process(body, bucket_name='sst-subscription-events')

            elif body['title'] == "lesson":
                response = lesson_event_processing(body)
                if response == "Success":
                    body['event_processed'] = True
                    post_events_process(body, bucket_name='sst-lesson-events')
                else:
                    body['event_processed'] = False
                    post_events_process(body, bucket_name='sst-lesson-events')

    except Exception as e:
        print("Exception caught in lambda handler->", e)
        return {'Exception': str(e)}





