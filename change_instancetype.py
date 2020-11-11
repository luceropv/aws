"""
###################################################################
#Script Name    : change_instancetype.py
#Description    : Script to change instance type for a given instance
                  tested on python 3.7.6
#Variables      : Make sure you are running on valid
                  region_name  line 19
                  instance-id  line 21
                  instanceType line 31
#How-to run     : /usr/bin/python3 change_instancetype.py
#Author         : Maria de la Luz Perez
#Email          : luceropv@gmail.com
###################################################################
"""

import boto3
import time

ec2 = boto3.client('ec2',region_name='us-east-2')
# choose an EC2 instance with id
instance_id = 'i-xxxxxxx'

# Stop the instance
print ('Stopping',instance_id)
ec2.stop_instances(InstanceIds=[instance_id])
waiter=ec2.get_waiter('instance_stopped')
waiter.wait(InstanceIds=[instance_id])

# Change the instance type
print ('Changing instance type...')
ec2.modify_instance_attribute(InstanceId=instance_id, Attribute='instanceType', Value='t2.small')

# Start the instance
print ('Starting instance',instance_id)
ec2.start_instances(InstanceIds=[instance_id])

# Print instance status
ec2 = boto3.resource('ec2')
instance = ec2.Instance(instance_id)

status = instance.state['Name']
time.sleep(10) # Sleeping for one second
print(' ')

print('Status of the instance is:',instance_id,status)
print('Be patient, good things take time... ')
print(' ')

#while instance.state = 'running':
#       print ('...instance is %s' % instance.state)

instance.wait_until_running()
instance.reload()
print('Status of instance',instance_id,instance.state,instance.instance_type)
