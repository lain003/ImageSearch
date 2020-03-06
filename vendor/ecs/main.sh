#aws iam --region ap-northeast-1 create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json
#aws iam --region ap-northeast-1 attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
ecs-cli configure --cluster imageSearch --default-launch-type FARGATE --config-name imageSearch --region ap-northeast-1
ecs-cli up --cluster-config imageSearch
aws ec2 describe-security-groups --filters Name=vpc-id,Values=~~~~
aws ec2 authorize-security-group-ingress --group-id ~~~~~ --protocol tcp --port 80 --cidr 0.0.0.0/0
ecs-cli compose --project-name imageSearch  --file docker-compose-ecs.yml --ecs-params ecs-params.yml service up --create-log-groups --cluster-config imageSearch
ecs-cli compose --project-name imageSearch  --file docker-compose-ecs.yml --ecs-params ecs-params.yml  service ps --cluster-config imageSearch
ecs-cli compose --project-name imageSearch  --file docker-compose-ecs.yml service down --cluster-config imageSearch