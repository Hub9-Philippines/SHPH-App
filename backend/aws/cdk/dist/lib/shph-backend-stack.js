"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ShphBackendStack = void 0;
const aws_cdk_lib_1 = require("aws-cdk-lib");
const aws_ec2_1 = require("aws-cdk-lib/aws-ec2");
const aws_ecs_1 = require("aws-cdk-lib/aws-ecs");
const aws_ecs_patterns_1 = require("aws-cdk-lib/aws-ecs-patterns");
const aws_rds_1 = require("aws-cdk-lib/aws-rds");
const aws_elasticache_1 = require("aws-cdk-lib/aws-elasticache");
const aws_secretsmanager_1 = require("aws-cdk-lib/aws-secretsmanager");
const aws_ecr_1 = require("aws-cdk-lib/aws-ecr");
const aws_certificatemanager_1 = require("aws-cdk-lib/aws-certificatemanager");
const aws_iam_1 = require("aws-cdk-lib/aws-iam");
class ShphBackendStack extends aws_cdk_lib_1.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);
        const domainName = props?.domainName ?? this.node.tryGetContext('domainName') ?? 'api.shph.com';
        const certificateArn = props?.certificateArn ?? this.node.tryGetContext('certificateArn') ?? 'arn:aws:acm:ap-southeast-2:888577050475:certificate/3246a249-a910-46f9-abb0-e1184cdad8ab';
        const vpc = new aws_ec2_1.Vpc(this, 'ShphVpc', {
            maxAzs: 2,
            natGateways: 1,
            subnetConfiguration: [
                {
                    name: 'Public',
                    subnetType: aws_ec2_1.SubnetType.PUBLIC,
                    cidrMask: 24,
                },
                {
                    name: 'Private',
                    subnetType: aws_ec2_1.SubnetType.PRIVATE_WITH_EGRESS,
                    cidrMask: 24,
                },
            ],
        });
        const dbCredentials = new aws_secretsmanager_1.Secret(this, 'DbCredentials', {
            secretName: 'shphBackendDbCredentials',
            generateSecretString: {
                secretStringTemplate: JSON.stringify({ username: 'shphadmin' }),
                generateStringKey: 'password',
                excludePunctuation: true,
                passwordLength: 32,
            },
        });
        const jwtSecret = new aws_secretsmanager_1.Secret(this, 'JwtSecret', {
            secretName: 'shphBackendJwtSecret',
            generateSecretString: {
                secretStringTemplate: JSON.stringify({ JWT_SECRET: '' }),
                generateStringKey: 'JWT_SECRET',
                excludePunctuation: true,
                passwordLength: 64,
            },
        });
        const dbSecurityGroup = new aws_ec2_1.SecurityGroup(this, 'DbSecurityGroup', {
            vpc,
            allowAllOutbound: true,
            description: 'Allow backend access to PostgreSQL',
        });
        const redisSecurityGroup = new aws_ec2_1.SecurityGroup(this, 'RedisSecurityGroup', {
            vpc,
            allowAllOutbound: true,
            description: 'Allow backend access to Redis',
        });
        const ecsSecurityGroup = new aws_ec2_1.SecurityGroup(this, 'EcsSecurityGroup', {
            vpc,
            allowAllOutbound: true,
            description: 'Allow ECS tasks to communicate with RDS and Redis',
        });
        dbSecurityGroup.addIngressRule(ecsSecurityGroup, aws_ec2_1.Port.tcp(5432), 'Allow ECS to connect to RDS');
        redisSecurityGroup.addIngressRule(ecsSecurityGroup, aws_ec2_1.Port.tcp(6379), 'Allow ECS to connect to Redis');
        const dbInstance = new aws_rds_1.DatabaseInstance(this, 'ShphPostgres', {
            engine: aws_rds_1.DatabaseInstanceEngine.postgres({ version: aws_rds_1.PostgresEngineVersion.VER_15 }),
            instanceType: aws_ec2_1.InstanceType.of(aws_ec2_1.InstanceClass.BURSTABLE3, aws_ec2_1.InstanceSize.MEDIUM),
            vpc,
            vpcSubnets: { subnetType: aws_ec2_1.SubnetType.PRIVATE_WITH_EGRESS },
            credentials: aws_rds_1.Credentials.fromSecret(dbCredentials, 'username'),
            allocatedStorage: 100,
            multiAz: false,
            publiclyAccessible: false,
            deletionProtection: false,
            securityGroups: [dbSecurityGroup],
            databaseName: 'shphdb',
            backupRetention: aws_cdk_lib_1.Duration.days(7),
        });
        const redisSubnetGroup = new aws_elasticache_1.CfnSubnetGroup(this, 'RedisSubnetGroup', {
            description: 'Subnet group for SHPH Redis cluster',
            subnetIds: vpc.privateSubnets.map((subnet) => subnet.subnetId),
            cacheSubnetGroupName: 'shph-redis-subnet-group',
        });
        const redisCluster = new aws_elasticache_1.CfnCacheCluster(this, 'ShphRedis', {
            cacheNodeType: 'cache.t4g.small',
            engine: 'redis',
            numCacheNodes: 1,
            clusterName: 'shph-backend-redis',
            cacheSubnetGroupName: redisSubnetGroup.ref,
            vpcSecurityGroupIds: [redisSecurityGroup.securityGroupId],
        });
        const databaseUrlSecret = new aws_secretsmanager_1.Secret(this, 'DatabaseUrlSecret', {
            secretName: 'shphBackendDatabaseUrl',
            secretStringValue: aws_cdk_lib_1.SecretValue.unsafePlainText(`postgresql://${dbCredentials.secretValueFromJson('username').toString()}:${dbCredentials.secretValueFromJson('password').toString()}@${dbInstance.instanceEndpoint.hostname}:${dbInstance.instanceEndpoint.port}/shphdb`),
        });
        const redisUrlSecret = new aws_secretsmanager_1.Secret(this, 'RedisUrlSecret', {
            secretName: 'shphBackendRedisUrl',
            secretStringValue: aws_cdk_lib_1.SecretValue.unsafePlainText(`redis://${redisCluster.attrRedisEndpointAddress}:${redisCluster.attrRedisEndpointPort}`),
        });
        const backendRepository = aws_ecr_1.Repository.fromRepositoryName(this, 'BackendRepository', 'shph-backend');
        const cluster = new aws_ecs_1.Cluster(this, 'ShphEcsCluster', {
            vpc,
        });
        const taskRole = new aws_iam_1.Role(this, 'ShphTaskRole', {
            assumedBy: new aws_iam_1.ServicePrincipal('ecs-tasks.amazonaws.com'),
            managedPolicies: [aws_iam_1.ManagedPolicy.fromAwsManagedPolicyName('service-role/AmazonECSTaskExecutionRolePolicy')],
        });
        const taskDefinition = new aws_ecs_1.FargateTaskDefinition(this, 'ShphTaskDef', {
            cpu: 512,
            memoryLimitMiB: 1024,
            taskRole,
        });
        const container = taskDefinition.addContainer('ShphContainer', {
            image: aws_ecs_1.ContainerImage.fromEcrRepository(backendRepository, 'latest'),
            logging: new aws_ecs_1.AwsLogDriver({ streamPrefix: 'shph-backend' }),
            environment: {
                PORT: '4000',
            },
            secrets: {
                DATABASE_URL: aws_ecs_1.Secret.fromSecretsManager(databaseUrlSecret),
                REDIS_URL: aws_ecs_1.Secret.fromSecretsManager(redisUrlSecret),
                JWT_SECRET: aws_ecs_1.Secret.fromSecretsManager(jwtSecret, 'JWT_SECRET'),
            },
        });
        container.addPortMappings({ containerPort: 4000, protocol: aws_ecs_1.Protocol.TCP });
        const albCertificate = aws_certificatemanager_1.Certificate.fromCertificateArn(this, 'AlbCertificate', certificateArn);
        new aws_ecs_patterns_1.ApplicationLoadBalancedFargateService(this, 'ShphAlbService', {
            cluster,
            taskDefinition,
            publicLoadBalancer: true,
            listenerPort: 443,
            certificate: albCertificate,
            redirectHTTP: true,
            desiredCount: 1,
            assignPublicIp: false,
            securityGroups: [ecsSecurityGroup],
            taskSubnets: { subnetType: aws_ec2_1.SubnetType.PRIVATE_WITH_EGRESS },
            circuitBreaker: { rollback: true },
            minHealthyPercent: 100,
            loadBalancerName: 'ShphBackendALB',
            serviceName: 'ShphBackendService',
            // domainName omitted to avoid automatic Route53 record creation;
            // DNS record can be created externally if desired.
        });
    }
}
exports.ShphBackendStack = ShphBackendStack;
