#!/usr/bin/env node
import 'source-map-support/register';
import { App } from 'aws-cdk-lib';
import { ShphBackendStack } from '../lib/shph-backend-stack';

const app = new App();
new ShphBackendStack(app, 'ShphBackendStack', {
    env: {
        account: process.env.CDK_DEFAULT_ACCOUNT,
        region: process.env.CDK_DEFAULT_REGION ?? 'ap-southeast-2',
    },
});
