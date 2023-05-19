---
sidebar_position: 10
data : Internal Only
---

# Run xl-release in ECS cluster.

## Prerequisites
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)   
* [Install AWS ecs-cli](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI.html)

## Setup AWS ECS Cluster

### 1. Configure profile for ecs-cli.
```shell   
   ecs-cli configure profile --profile-name XLD-PowerUser-932770550094 --access-key <access-key> --secret-key <secret-key>
```
```shell
[ishwarya@worker01 ~] $ ecs-cli configure profile --profile-name XLD-PowerUser-932770550094 --access-key ******** --secret-key ******
INFO[0000] Saved ECS CLI profile configuration XLD-PowerUser-932770550094.
```

### 2. Configure the Cluster with launch type
```shell
   ecs-cli configure --cluster devXlrCluster --default-launch-type EC2 --region us-west-2 --config-name XLD-PowerUser-932770550094
```
```shell
[ishwarya@worker01 ~] $ ecs-cli configure --cluster devXlrCluster --default-launch-type EC2 --region us-west-2 --config-name XLD-PowerUser-932770550094
INFO[0000] Saved ECS CLI cluster configuration XLD-PowerUser-932770550094. 
```

### 3. Create ssh key pair
```shell
   aws ec2 create-key-pair --key-name devxlrCluster-key --query 'KeyMaterial' --profile XLD-PowerUser-932770550094 --output text > ~/.ssh/devxlrCluster.pem
```
```shell
[ishwarya@worker01 ~] $ aws ec2 create-key-pair --key-name devxlrCluster-key --query 'KeyMaterial' --profile XLD-PowerUser-932770550094 --output text > ~/.ssh/devxlrCluster.pem
[ishwarya@worker01 ~] $ ls -lrt ~/.ssh |grep devxlrCluster-key
-r-------- 1 ishwarya ishwarya 1678 Apr 18 10:22 devxlrCluster-key.pem
```
   
### 4. Create an ECS cluster with an EC2 instance
```shell
   ecs-cli up --aws-profile default --keypair devxlrCluster-key --capability-iam --size 2 --instance-type t3.medium --tags project=devxlrCluster --cluster-config XLD-PowerUser-932770550094 --ecs-profile XLD-PowerUser-932770550094
```
```shell
[ishwarya@worker01 ~] $ ecs-cli up --aws-profile default --keypair devxlrCluster-key --capability-iam --size 2 --instance-type t3.medium --tags project=devxlrCluster --cluster-config XLD-PowerUser-932770550094 --ecs-profile XLD-PowerUser-932770550094
WARN[0002] Enabling container instance tagging because containerInstanceLongArnFormat is enabled for your identity, arn:aws:iam::932770550094:root. If this is not your account default setting, your instances will fail to join your cluster. You can use the PutAccountSettingDefault API to change your account default. 
INFO[0005] Using recommended Amazon Linux 2 AMI with ECS Agent 1.70.2 and Docker version 20.10.17 
INFO[0006] Created cluster                               cluster=devXlrCluster region=us-west-2
INFO[0007] Waiting for your cluster resources to be created... 
INFO[0007] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
INFO[0072] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
INFO[0136] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
VPC created: vpc-0a118df4a7c660cbb
Security Group created: sg-001220d7a1d3a08a1
Subnet created: subnet-0c311d3d52ecc52c9
Subnet created: subnet-00af543e7d66ce6e6
Cluster creation succeeded.
```

### 5. Create EFS. 
```shell
   aws efs create-file-system --profile XLD-PowerUser-932770550094 --performance-mode generalPurpose --throughput-mode bursting --encrypted --tags Key=Name,Value=efs-xlr
```
```shell
[ishwarya@worker01 ~] $ aws efs create-file-system --profile XLD-PowerUser-932770550094 --performance-mode generalPurpose --throughput-mode bursting --encrypted --tags Key=Name,Value=efs-xlr
{
    "OwnerId": "932770550094",
    "CreationToken": "1f0a0cf5-43ac-4723-adf2-dce8e3955cb6",
    "FileSystemId": "fs-05667c80331401c1f",
    "FileSystemArn": "arn:aws:elasticfilesystem:us-west-2:932770550094:file-system/fs-05667c80331401c1f",
    "CreationTime": "2023-04-25T13:01:06+05:30",
    "LifeCycleState": "creating",
    "Name": "efs-xlr",
    "NumberOfMountTargets": 0,
    "SizeInBytes": {
        "Value": 0,
        "ValueInIA": 0,
        "ValueInStandard": 0
    },
    "PerformanceMode": "generalPurpose",
    "Encrypted": true,
    "KmsKeyId": "arn:aws:kms:us-west-2:932770550094:key/99d54b71-53e3-4251-8d7a-69212f4b71d5",
    "ThroughputMode": "bursting",
    "Tags": [
        {
            "Key": "Name",
            "Value": "efs-xlr"
        }
    ]
}


``` 
### 6. Add mount points to each subnet of the VPC in created EFS.
* Note: Use File system created in step 5.
```shell  
   aws ec2 describe-subnets --profile XLD-PowerUser-932770550094 --filters Name=tag:project,Values=devxlrCluster | jq ".Subnets[].SubnetId" | xargs -ISUBNET aws efs create-mount-target --file-system-id fs-0d97cb4112fabddc2 --subnet-id SUBNET
```
```shell
[ishwarya@worker01 ~] $ aws ec2 describe-subnets --profile XLD-PowerUser-932770550094 --filters Name=tag:project,Values=devxlrCluster | jq ".Subnets[].SubnetId" | xargs -ISUBNET aws efs create-mount-target --file-system-id fs-05667c80331401c1f --subnet-id SUBNET
{
    "OwnerId": "932770550094",
    "MountTargetId": "fsmt-0e1732b3c0529639a",
    "FileSystemId": "fs-05667c80331401c1f",
    "SubnetId": "subnet-0c311d3d52ecc52c9",
    "LifeCycleState": "creating",
    "IpAddress": "10.0.0.118",
    "NetworkInterfaceId": "eni-0f6c9c239f0e78da7",
    "AvailabilityZoneId": "usw2-az1",
    "AvailabilityZoneName": "us-west-2a",
    "VpcId": "vpc-0a118df4a7c660cbb"
}
{
    "OwnerId": "932770550094",
    "MountTargetId": "fsmt-08e64f776f7e3f064",
    "FileSystemId": "fs-05667c80331401c1f",
    "SubnetId": "subnet-00af543e7d66ce6e6",
    "LifeCycleState": "creating",
    "IpAddress": "10.0.1.218",
    "NetworkInterfaceId": "eni-01dba16345b4d55f7",
    "AvailabilityZoneId": "usw2-az2",
    "AvailabilityZoneName": "us-west-2b",
    "VpcId": "vpc-0a118df4a7c660cbb"
}

```
### 7. Allow NFS connection.
* Note: Use File system created in step 5.
```shell
   efs_sg=$(aws efs describe-mount-targets --profile XLD-PowerUser-932770550094 --file-system-id fs-0d97cb4112fabddc2 | jq ".MountTargets[0].MountTargetId" | xargs -IMOUNTG aws efs describe-mount-target-security-groups --mount-target-id MOUNTG | jq ".SecurityGroups[0]" | xargs echo)
   vpc_sg=$(aws ec2 describe-security-groups --profile XLD-PowerUser-932770550094 --filters Name=tag:project,Values=devxlrCluster | jq '.SecurityGroups[].GroupId' | xargs echo)
   aws ec2 authorize-security-group-ingress --profile XLD-PowerUser-932770550094 --group-id $efs_sg --protocol tcp --port 2049 --source-group $vpc_sg --region us-west-2
```
```shell
[ishwarya@worker01 ~] $ efs_sg=$(aws efs describe-mount-targets --profile XLD-PowerUser-932770550094 --file-system-id fs-05667c80331401c1f | jq ".MountTargets[0].MountTargetId" | xargs -IMOUNTG aws efs describe-mount-target-security-groups --mount-target-id MOUNTG | jq ".SecurityGroups[0]" | xargs echo)
[ishwarya@worker01 ~] $    vpc_sg=$(aws ec2 describe-security-groups --profile XLD-PowerUser-932770550094 --filters Name=tag:project,Values=devxlrCluster | jq '.SecurityGroups[].GroupId' | xargs echo)
[ishwarya@worker01 ~] $    aws ec2 authorize-security-group-ingress --profile XLD-PowerUser-932770550094 --group-id $efs_sg --protocol tcp --port 2049 --source-group $vpc_sg --region us-west-2
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-09f046f06ff354f2c",
            "GroupId": "sg-0bcab80bd4476abac",
            "GroupOwnerId": "932770550094",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 2049,
            "ToPort": 2049,
            "ReferencedGroupInfo": {
                "GroupId": "sg-001220d7a1d3a08a1",
                "UserId": "932770550094"
            }
        }
    ]
}
```

### 8. Open port 22 to connect to the EC2 instances of the cluster.
```shell
  * # Get my IP
  myip=$(curl ifconfig.me.)
  * # Get the security group
  sg=$(aws ec2 describe-security-groups   --filters Name=tag:project,Values=devxlrCluster | jq '.SecurityGroups[].GroupId' | xargs echo)
  * # Add port 22 to the Security Group of the VPC
  aws ec2 authorize-security-group-ingress --profile XLD-PowerUser-932770550094 --group-id $sg --protocol tcp --port 22 --cidr "$myip/32" | jq '.'
```
```shell
[ishwarya@worker01 ~] $ myip=$(curl ifconfig.me.)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    12  100    12    0     0     29      0 --:--:-- --:--:-- --:--:--    29
[ishwarya@worker01 ~] $ sg=$(aws ec2 describe-security-groups   --filters Name=tag:project,Values=devxlrCluster | jq '.SecurityGroups[].GroupId' | xargs echo)
[ishwarya@worker01 ~] $ aws ec2 authorize-security-group-ingress --profile XLD-PowerUser-932770550094 --group-id $sg --protocol tcp --port 22 --cidr "$myip/32" | jq '.'
{
  "Return": true,
  "SecurityGroupRules": [
    {
      "SecurityGroupRuleId": "sgr-003f3ae6ca325369d",
      "GroupId": "sg-001220d7a1d3a08a1",
      "GroupOwnerId": "932770550094",
      "IsEgress": false,
      "IpProtocol": "tcp",
      "FromPort": 22,
      "ToPort": 22,
      "CidrIpv4": "49.37.195.36/32"
    }
  ]
}

```
### 9. Update the VPC security group to allow All traffic to Myip
```shell
  * # Get my IP
  myip=$(curl ifconfig.me.)
  * # Get the security group
  vpc_sg=$(aws ec2 describe-security-groups --profile XLD-PowerUser-932770550094 --filters Name=tag:project,Values=devxlrCluster | jq '.SecurityGroups[].GroupId' | xargs echo)
  * # Add port 22 to the Security Group of the VPC
  aws ec2 authorize-security-group-ingress --profile XLD-PowerUser-932770550094 --group-id $vpc_sg --protocol all --cidr "$myip/32 | jq '.'
```

```shell
[ishwarya@worker01 ~] $ myip=$(curl ifconfig.me.)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    12  100    12    0     0     29      0 --:--:-- --:--:-- --:--:--    29
[ishwarya@worker01 ~] $ vpc_sg=$(aws ec2 describe-security-groups --profile XLD-PowerUser-932770550094 --filters Name=tag:project,Values=devxlrCluster | jq '.SecurityGroups[].GroupId' | xargs echo)
[ishwarya@worker01 ~] $ aws ec2 authorize-security-group-ingress --profile XLD-PowerUser-932770550094 --group-id $vpc_sg --protocol all --cidr "$myip/32" | jq '.'
{
  "Return": true,
  "SecurityGroupRules": [
    {
      "SecurityGroupRuleId": "sgr-004759c1bb932c3c7",
      "GroupId": "sg-001220d7a1d3a08a1",
      "GroupOwnerId": "932770550094",
      "IsEgress": false,
      "IpProtocol": "-1",
      "FromPort": -1,
      "ToPort": -1,
      "CidrIpv4": "49.37.195.36/32"
    }
  ]
}


```
### 10. Create Access point for the volume mount directory with POSIX user permission.
* Note: Use File system created in step 5.
```shell 
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/archive,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/repository,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/ext,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/conf,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/plugins,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/hotfix,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";
  aws efs create-access-point --file-system-id fs-0d97cb4112fabddc2 --posix-user "Gid=0,Uid=10001" --root-directory "Path=/xlr-ap1/reports,CreationInfo={OwnerUid=10001,OwnerGid=0,Permissions=755}";   
```

## Create ECS - Service and Task definition using docker-compose.
  Note : if we need specific configuration related to Task-definition creation, that needs to be included in ecs-params.yml file.
```shell
ecs-cli compose --aws-profile default --project-name devxlrCluster --file docker-compose.yaml --debug service up --deployment-max-percent 100 --deployment-min-healthy-percent 0 --region us-west-2 --ecs-profile XLD-PowerUser-932770550094 --cluster-config XLD-PowerUser-932770550094 --create-log-groups
```
### docker-compose.yaml
```yaml
version: "2"
services:
  xl-release:
    image: xebialabsunspported/xl-release:22.3.9
    container_name: xl-release
    ports:
     - "5516:5516"
    volumes:
     - efs-xlr-repository:/opt/xebialabs/xl-release-server/repository
     - efs-xlr-archive:/opt/xebialabs/xl-release-server/archive
     - efs-xlr-reports:/opt/xebialabs/xl-release-server/reports
     - efs-xlr-ext:/opt/xebialabs/xl-release-server/ext
     - efs-xlr-plugins:/opt/xebialabs/xl-release-server/plugins
     - efs-xlr-hotfix:/opt/xebialabs/xl-release-server/hotfix
     - efs-xlr-conf:/opt/xebialabs/xl-release-server/conf
    environment:
     - ADMIN_PASSWORD=admin
     - ACCEPT_EULA=Y
    logging:
      driver: awslogs
      options:
         awslogs-group: devXlrCluster
         awslogs-region: us-west-2
         awslogs-stream-prefix: devXlrCluster
    mem_limit: 3Gi
    mem_reservation: 1Gi
    cpu_shares: 2
volumes:
  efs-xlr-repository:
  efs-xlr-archive:
  efs-xlr-reports:
  efs-xlr-ext:
  efs-xlr-plugins:
  efs-xlr-hotfix:
  efs-xlr-conf: 
```

### ecs_params.yml
```yaml
version: 1 
task_definition:
  ecs_network_mode: bridge
  container_definitions: 
    mount_points:
    - source_volume: efs-xlr-repository
      container_path: "/opt/xebialabs/xl-release-server/repository"
    - source_volume: efs-xlr-archive
      container_path: "/opt/xebialabs/xl-release-server/archive"
    - source_volume: efs-xlr-reports
      container_path: "/opt/xebialabs/xl-release-server/reports"
    - source_volume: efs-xlr-plugins
      container_path: "/opt/xebialabs/xl-release-server/plugins"
    - source_volume: efs-xlr-ext
      container_path: "/opt/xebialabs/xl-release-server/ext"
    - source_volume: efs-xlr-hotfix
      container_path: "/opt/xebialabs/xl-release-server/hotfix"
    - source_volume: efs-xlr-conf
      container_path: "/opt/xebialabs/xl-release-server/conf"
  efs_volumes:
  - name: efs-xlr-archive
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-0b778a27cb786b051"  
  - name: efs-xlr-reports
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-0fb8f98c380fb2cb2"
  - name: efs-xlr-repository
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-0a3c87f7708058cd8"
  - name: efs-xlr-plugins
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-0a0a43fa752df7562"
  - name: efs-xlr-ext
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-0eb825f30c9368fa4"
  - name: efs-xlr-conf
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-0e9185af1ccc7b5b7"
  - name: efs-xlr-hotfix
    filesystem_id: fs-05667c80331401c1f
    transit_encryption: ENABLED
    access_point: "fsap-07b53c7d5e330bcbd"
```
```shell
[ishwarya@worker01 ~] $ ecs-cli compose --aws-profile default --project-name devxlrCluster --file docker-compose.yaml --debug service up --deployment-max-percent 100 --deployment-min-healthy-percent 0 --region us-west-2 --ecs-profile XLD-PowerUser-932770550094 --cluster-config XLD-PowerUser-932770550094 --create-log-groups
DEBU[0000] Parsing the compose yaml...                  
DEBU[0000] Docker Compose version found: 2              
DEBU[0000] Parsing v1/2 project...                      
DEBU[0000] Opening compose files: docker-compose.yaml   
DEBU[0000] [0/0] [efs-xlr-archive]: EventType: 31       
DEBU[0000] [0/0] [efs-xlr-conf]: EventType: 31          
DEBU[0000] [0/0] [efs-xlr-ext]: EventType: 31           
DEBU[0000] [0/0] [efs-xlr-hotfix]: EventType: 31        
DEBU[0000] [0/0] [efs-xlr-plugins]: EventType: 31       
DEBU[0000] [0/0] [efs-xlr-reports]: EventType: 31       
DEBU[0000] [0/0] [efs-xlr-repository]: EventType: 31    
DEBU[0000] [0/0] [xl-release]: Adding                   
DEBU[0000] [0/1] [default]: EventType: 32               
WARN[0000] Skipping unsupported YAML option for service...  option name=container_name service name=xl-release
DEBU[0000] Parsing the ecs-params yaml...               
DEBU[0000] Parsing the ecs-registry-creds yaml...       
DEBU[0000] Transforming yaml to task definition...      
DEBU[0001] Finding task definition in cache or creating if needed  TaskDefinition="{\n  ContainerDefinitions: [{\n      Command: [],\n      Cpu: 2,\n      DnsSearchDomains: [],\n      DnsServers: [],\n      DockerLabels: {\n\n      },\n      DockerSecurityOptions: [],\n      EntryPoint: [],\n      Environment: [{\n          Name: \"ADMIN_PASSWORD\",\n          Value: \"admin\"\n        },{\n          Name: \"ACCEPT_EULA\",\n          Value: \"Y\"\n        }],\n      Essential: true,\n      ExtraHosts: [],\n      Image: \"xebialabsunsupported/xl-release:22.3.9\",\n      Links: [],\n      LinuxParameters: {\n        Capabilities: {\n\n        },\n        Devices: []\n      },\n      LogConfiguration: {\n        LogDriver: \"awslogs\",\n        Options: {\n          awslogs-stream-prefix: \"devXlrCluster\",\n          awslogs-group: \"devXlrCluster\",\n          awslogs-region: \"us-west-2\"\n        }\n      },\n      Memory: 3072,\n      MemoryReservation: 1024,\n      MountPoints: [\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/repository\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-repository\"\n        },\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/archive\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-archive\"\n        },\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/reports\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-reports\"\n        },\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/ext\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-ext\"\n        },\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/plugins\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-plugins\"\n        },\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/hotfix\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-hotfix\"\n        },\n        {\n          ContainerPath: \"/opt/xebialabs/xl-release-server/conf\",\n          ReadOnly: false,\n          SourceVolume: \"efs-xlr-conf\"\n        }\n      ],\n      Name: \"xl-release\",\n      PortMappings: [{\n          ContainerPort: 5516,\n          HostPort: 5516,\n          Protocol: \"tcp\"\n        }],\n      Privileged: false,\n      PseudoTerminal: false,\n      ReadonlyRootFilesystem: false,\n      Ulimits: [],\n      VolumesFrom: []\n    }],\n  Cpu: \"\",\n  ExecutionRoleArn: \"\",\n  Family: \"devxlrCluster\",\n  Memory: \"\",\n  NetworkMode: \"bridge\",\n  RequiresCompatibilities: [\"EC2\"],\n  TaskRoleArn: \"\",\n  Volumes: [\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-0eb825f30c9368fa4\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-ext\"\n    },\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-07b53c7d5e330bcbd\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-hotfix\"\n    },\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-0a0a43fa752df7562\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-plugins\"\n    },\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-0fb8f98c380fb2cb2\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-reports\"\n    },\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-0a3c87f7708058cd8\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-repository\"\n    },\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-0b778a27cb786b051\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-archive\"\n    },\n    {\n      EfsVolumeConfiguration: {\n        AuthorizationConfig: {\n          AccessPointId: \"fsap-0e9185af1ccc7b5b7\"\n        },\n        FileSystemId: \"fs-05667c80331401c1f\",\n        TransitEncryption: \"ENABLED\"\n      },\n      Name: \"efs-xlr-conf\"\n    }\n  ]\n}"
INFO[0003] Using ECS task definition                     TaskDefinition="devxlrCluster:53"
WARN[0004] Failed to create log group devXlrCluster in us-west-2: The specified log group already exists 
INFO[0004] Auto-enabling ECS Managed Tags               
INFO[0016] (service devxlrCluster) has started 1 tasks: (task 190f2f3c2b564f2bb9aeb5824d1a74ef).  timestamp="2023-04-25 08:04:47 +0000 UTC"
INFO[0047] Service status                                desiredCount=1 runningCount=1 serviceName=devxlrCluster
INFO[0047] ECS Service has reached a stable state        desiredCount=1 runningCount=1 serviceName=devxlrCluster
INFO[0047] Created an ECS service                        deployment-max-percent=100 deployment-min-healthy-percent=0 service=devxlrCluster taskDefinition="devxlrCluster:53"
```

## Check logs of generated task
```shell
  ecs-cli logs --task-id f2f3c2b564f2bb9aeb5824d1a74ef --aws-profile default
```

## Check the docker container status
```shell
 ecs-cli ps --aws-profile default
```
```shell
[ishwarya@worker01 ~] $ ecs-cli ps --aws-profile default
Name                                                       State    Ports                          TaskDefinition    Health
devXlrCluster/190f2f3c2b564f2bb9aeb5824d1a74ef/xl-release  RUNNING  54.186.204.208:5516->5516/tcp  devxlrCluster:53  UNKNOWN
```