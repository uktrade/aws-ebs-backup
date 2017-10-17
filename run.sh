#!/bin/bash -xe

env -
export $(cat /.env | xargs)

DATE=$(date +%F)
export EXPIRE_DATE=$(date -d "-$EBS_RETENTION days" +%s)

aws ec2 create-snapshot --volume-id $EBS_ID --description "$EBS_ID-$DATE"

EXIPRED=$(aws ec2 describe-snapshots | jq -rC '.Snapshots[] | select(.VolumeId==env.EBS_ID) | select((.StartTime|strptime("%Y-%m-%dT%H:%M:%S.000Z")|mktime) < (env.EXPIRE_DATE|tonumber)) | .SnapshotId')

for X in $EXIPRED; do
  aws ec2 delete-snapshot --snapshot-id $X
done
