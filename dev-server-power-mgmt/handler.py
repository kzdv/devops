
import logging
import boto3
from os import getenv

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
ec2 = boto3.client('ec2')

def start(event, context):
    response = ec2.start_instances(InstanceIds=[getenv('DEV_INSTANCE_ID')], DryRun=False)
    logger.info(response)

def stop(event, context):
    response = ec2.stop_instances(InstanceIds=[getenv('DEV_INSTANCE_ID')], DryRun=False)
    logger.info(response)