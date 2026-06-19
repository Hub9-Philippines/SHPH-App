import { Duration, SecretValue, Stack, StackProps, RemovalPolicy } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Vpc, SecurityGroup, Port, SubnetType, InstanceClass, InstanceSize, InstanceType } from 'aws-cdk-lib/aws-ec2';
import { Cluster, AwsLogDriver, FargateTaskDefinition, ContainerImage, Protocol, Secret as EcsSecret } from 'aws-cdk-lib/aws-ecs';
import { ApplicationLoadBalancedFargateService } from 'aws-cdk-lib/aws-ecs-patterns';
import { DatabaseInstance, DatabaseInstanceEngine, PostgresEngineVersion, Credentials } from 'aws-cdk-lib/aws-rds';
import { CfnCacheCluster, CfnSubnetGroup } from 'aws-cdk-lib/aws-elasticache';
import { Secret as SecretsManagerSecret } from 'aws-cdk-lib/aws-secretsmanager';
import { Repository } from 'aws-cdk-lib/aws-ecr';
import { Role, ServicePrincipal, ManagedPolicy } from 'aws-cdk-lib/aws-iam';

export class ShphBackendStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props);

        const vpc = new Vpc(this, 'ShphVpc', {
            maxAzs: 2,
            natGateways: 1,
            subnetConfiguration: [
                {
                    name: 'Public',
                    subnetType: SubnetType.PUBLIC,
                    cidrMask: 24,
                },
                {
                    name: 'Private',
                    subnetType: SubnetType.PRIVATE_WITH_EGRESS,
                    cidrMask: 24,
                },
            ],
        });

        const dbCredentials = new SecretsManagerSecret(this, 'DbCredentials', {
            secretName: 'shphBackendDbCredentials',
            removalPolicy: RemovalPolicy.DESTROY,
            generateSecretString: {
                secretStringTemplate: JSON.stringify({ username: 'shphadmin' }),
                generateStringKey: 'password',
                excludePunctuation: true,
                passwordLength: 32,
            },
        });

        const jwtSecret = new SecretsManagerSecret(this, 'JwtSecret', {
            secretName: 'shphBackendJwtSecret',
            removalPolicy: RemovalPolicy.DESTROY,
            generateSecretString: {
                secretStringTemplate: JSON.stringify({ username: 'shph' }),
                generateStringKey: 'JWT_SECRET',
                excludePunctuation: true,
                passwordLength: 64,
            },
        });

        const dbSecurityGroup = new SecurityGroup(this, 'DbSecurityGroup', {
            vpc,
            allowAllOutbound: true,
            description: 'Allow backend access to PostgreSQL',
        });

        const redisSecurityGroup = new SecurityGroup(this, 'RedisSecurityGroup', {
            vpc,
            allowAllOutbound: true,
            description: 'Allow backend access to Redis',
        });

        const ecsSecurityGroup = new SecurityGroup(this, 'EcsSecurityGroup', {
            vpc,
            allowAllOutbound: true,
            description: 'Allow ECS tasks to communicate with RDS and Redis',
        });

        dbSecurityGroup.addIngressRule(ecsSecurityGroup, Port.tcp(5432), 'Allow ECS to connect to RDS');
        redisSecurityGroup.addIngressRule(ecsSecurityGroup, Port.tcp(6379), 'Allow ECS to connect to Redis');

        // FIXED: Added absolute destruction rules to prevent stuck deployment rollbacks
        const dbInstance = new DatabaseInstance(this, 'ShphPostgres', {
            engine: DatabaseInstanceEngine.postgres({ version: PostgresEngineVersion.VER_15 }),
            instanceType: InstanceType.of(InstanceClass.BURSTABLE3, InstanceSize.MEDIUM),
            vpc,
            vpcSubnets: { subnetType: SubnetType.PRIVATE_WITH_EGRESS },
            credentials: Credentials.fromSecret(dbCredentials, 'username'),
            allocatedStorage: 100,
            multiAz: false,
            publiclyAccessible: false,
            deletionProtection: false,
            removalPolicy: RemovalPolicy.DESTROY, // Completely drops database on rollbacks/deletions
            deleteAutomatedBackups: true,         // Avoids backup locking issues
            backupRetention: Duration.days(0),    // Set to 0 days for immediate safe rollbacks
            securityGroups: [dbSecurityGroup],
            databaseName: 'shphdb',
        });

        const redisSubnetGroup = new CfnSubnetGroup(this, 'RedisSubnetGroup', {
            description: 'Subnet group for SHPH Redis cluster',
            subnetIds: vpc.privateSubnets.map((subnet) => subnet.subnetId),
            cacheSubnetGroupName: 'shph-redis-subnet-group',
        });

        const redisCluster = new CfnCacheCluster(this, 'ShphRedis', {
            cacheNodeType: 'cache.t4g.small',
            engine: 'redis',
            numCacheNodes: 1,
            clusterName: 'shph-backend-redis',
            cacheSubnetGroupName: redisSubnetGroup.ref,
            vpcSecurityGroupIds: [redisSecurityGroup.securityGroupId],
        });
        redisCluster.applyRemovalPolicy(RemovalPolicy.DESTROY);

        const databaseUrlSecret = new SecretsManagerSecret(this, 'DatabaseUrlSecret', {
            secretName: 'shphBackendDatabaseUrl',
            removalPolicy: RemovalPolicy.DESTROY,
            secretStringValue: SecretValue.unsafePlainText(
                `postgresql://${dbCredentials.secretValueFromJson('username').toString()}:${dbCredentials.secretValueFromJson('password').toString()}@${dbInstance.instanceEndpoint.hostname}:${dbInstance.instanceEndpoint.port}/shphdb`,
            ),
        });

        const redisUrlSecret = new SecretsManagerSecret(this, 'RedisUrlSecret', {
            secretName: 'shphBackendRedisUrl',
            removalPolicy: RemovalPolicy.DESTROY,
            secretStringValue: SecretValue.unsafePlainText(
                `redis://${redisCluster.attrRedisEndpointAddress}:${redisCluster.attrRedisEndpointPort}`,
            ),
        });

        const backendRepository = new Repository(this, 'BackendRepository', {
            repositoryName: 'shph-backend',
        });

        const cluster = new Cluster(this, 'ShphEcsCluster', {
            vpc,
        });

        const taskRole = new Role(this, 'ShphTaskRole', {
            assumedBy: new ServicePrincipal('ecs-tasks.amazonaws.com'),
            managedPolicies: [ManagedPolicy.fromAwsManagedPolicyName('service-role/AmazonECSTaskExecutionRolePolicy')],
        });

        const taskDefinition = new FargateTaskDefinition(this, 'ShphTaskDef', {
            cpu: 512,
            memoryLimitMiB: 1024,
            taskRole,
        });

        const container = taskDefinition.addContainer('ShphContainer', {
            image: ContainerImage.fromEcrRepository(backendRepository, 'latest'),
            logging: new AwsLogDriver({ streamPrefix: 'shph-backend' }),
            environment: {
                PORT: '4000',
            },
            secrets: {
                DATABASE_URL: EcsSecret.fromSecretsManager(databaseUrlSecret),
                REDIS_URL: EcsSecret.fromSecretsManager(redisUrlSecret),
                JWT_SECRET: EcsSecret.fromSecretsManager(jwtSecret, 'JWT_SECRET'),
            },
        });

        container.addPortMappings({ containerPort: 4000, protocol: Protocol.TCP });

        new ApplicationLoadBalancedFargateService(this, 'ShphAlbService', {
            cluster,
            taskDefinition,
            publicLoadBalancer: true,
            listenerPort: 80,
            redirectHTTP: false,
            desiredCount: 1,
            assignPublicIp: false,
            securityGroups: [ecsSecurityGroup],
            taskSubnets: { subnetType: SubnetType.PRIVATE_WITH_EGRESS },
            circuitBreaker: { rollback: true },
            minHealthyPercent: 100,
            loadBalancerName: 'ShphBackendALB',
            serviceName: 'ShphBackendService',
        });
    }
}
