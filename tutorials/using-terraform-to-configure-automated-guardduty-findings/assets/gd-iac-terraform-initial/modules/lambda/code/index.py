from __future__ import print_function
from botocore.exceptions import ClientError
import boto3
import json
import os

def handler(event, context):

  # Log out event
  print("log -- Event: %s " % json.dumps(event))

  # Create generic function response
  response = "Error auto-remediating the finding."
  
  try:
    ec2 = boto3.client('ec2')

    # Set Variables
    #vpc_id = event["detail"]["resource"]["instanceDetails"]["networkInterfaces"][0]["vpcId"]
    instanceID = event["detail"]["resource"]["instanceDetails"]["instanceId"]
    security_group_id = os.environ['FORENSICS_SG']

    if instanceID == os.environ['INSTANCE_ID']:

      #print("log -- Security Group Created %s in vpc %s." % (security_group_id, vpc_id))
      print("log -- Security Group Created %s." % (security_group_id))

      # Isolate Instance
      ec2 = boto3.resource('ec2')
      instance = ec2.Instance(instanceID)
      print("log -- %s, %s" % (instance.id, instance.instance_type))
      instance.modify_attribute(Groups=[security_group_id])

      # Send Response Email
      response = "GuardDuty Remediation for the GuardDuty Tutorial. | ID:%s: GuardDuty discovered an EC2 instance (Instance ID: %s) that is communicating outbound with an IP Address on a threat list that you uploaded.  All security groups have been removed and it has been isolated. Please follow up with any additional remediation actions." % (event['detail']['id'], event['detail']['resource']['instanceDetails']['instanceId'])
      sns = boto3.client('sns')
      sns.publish(
        TopicArn=os.environ['TOPIC_ARN'],
        Message=response
      )
      print("log -- Response: %s " % response)
    else:
      print("log -- Instance unrelated to GuardDuty-Hands-On environment.")

  except ClientError as e:
    print(e)
    
  print("log -- Response: %s " % response)
  return response  