#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("source-map-support/register");
const aws_cdk_lib_1 = require("aws-cdk-lib");
const shph_backend_stack_1 = require("../lib/shph-backend-stack");
const app = new aws_cdk_lib_1.App();
new shph_backend_stack_1.ShphBackendStack(app, 'ShphBackendStack', {
    env: {
        account: process.env.CDK_DEFAULT_ACCOUNT,
        region: process.env.CDK_DEFAULT_REGION ?? 'us-east-1',
    },
});
