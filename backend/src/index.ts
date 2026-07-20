import 'reflect-metadata';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import 'express-async-errors';
import { errorHandler } from './middleware/error-handler.js';
import { authRouter } from './routes/auth.js';
import { usersRouter } from './routes/users.js';
import { chatRouter } from './routes/chat.js';
import { servicesRouter } from './routes/services.js';
import { authenticateJwt } from './middleware/auth.js';
import { json } from 'express';
import { connectToDatabase } from './db/data-source.js';
import { connectToRedis } from './db/redis.js';

dotenv.config();

const app = express();
const port = Number(process.env.PORT ?? 4000);

app.use(helmet());
app.use(cors());
app.use(json({ limit: '10mb' }));

app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
});

app.use('/api/auth', authRouter);
app.use('/api/users', authenticateJwt, usersRouter);
app.use('/api/chat', authenticateJwt, chatRouter);
app.use('/api/services', authenticateJwt, servicesRouter);

app.use(errorHandler);

async function start() {
    await connectToDatabase();
    await connectToRedis();
    app.listen(port, () => {
        console.log(`SHPH backend listening on http://localhost:${port}`);
    });
}

start().catch((error) => {
    console.error('Failed to start server:', error);
    process.exit(1);
});
