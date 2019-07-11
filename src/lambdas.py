import json
import logging
import os

import boto3
from boto3.dynamodb.conditions import Key

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

session = boto3.Session()
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('TABLE'))

pinpoint = session.client('pinpoint')

app_id = os.getenv('APP_ID')
channel = os.getenv('APP_NAME')
query_params = dict(KeyConditionExpression=Key('Channel').eq(channel))

number_results = table.query(**query_params)
lek = 'LastEvaluatedKey'
numbers = {}
while True:
    numbers = {**numbers, **{i['Number']: i for i in number_results['Items']}}
    if lek not in number_results:
        break
    query_params['ExclusiveStartKey'] = number_results[lek]
    number_results = table.query(**query_params)

logger.debug(f'Numbers: {numbers}')


def send_message(event, _):
    logger.info(f'Received Event: {event}')

    records = event['Records']
    for record in records:
        sns = record['Sns']
        message = json.loads(sns['Message'])
        message_body = message['messageBody']
        frm = message['originationNumber']
        body = f'{numbers[frm].get("Initials", frm)}: {message_body}'

        addresses = {
            number: dict(ChannelType='SMS', ) for number in numbers if number != frm
        }
        if len(addresses) == 0:
            logger.warning('No members in app! Exiting.')
            return

        message_request = dict(
            Addresses=addresses,
            MessageConfiguration=
            dict(SMSMessage=
                 dict(Body=body,
                      MessageType='TRANSACTIONAL')))
        logger.debug(f'MessageRequest: {message_request}')

        response = pinpoint.send_messages(ApplicationId=app_id,
                                          MessageRequest=message_request)

        logger.info(response)


