#!/bin/bash -xe

env -
export $(cat /.env | xargs)

DATE=%(date +%F)
EXPIRE_DATE=%(date -d "+$EBS_RETENTION days")

aws ec2 create-snapshot --volume-id $EBS_ID --description "$EBS_ID-$DATE"

EXIPRED=$(aws ec2 describe-snapshots | jq -rC '.Snapshots[] | select(.VolumeId=="$ENV.EBS_ID") | select(.StartTime < "$ENV.EXPIRE_DATE").SnapshotId')

for X in $EXIPRED; do
  aws ec2 delete-snapshot --snapshot-id $X
done
