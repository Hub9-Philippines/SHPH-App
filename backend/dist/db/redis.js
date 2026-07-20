import Redis from 'ioredis';
import dotenv from 'dotenv';
dotenv.config();
const redisUrl = process.env.REDIS_URL;
if (!redisUrl) {
    throw new Error('REDIS_URL is required');
}
export const redis = new Redis(redisUrl);
export async function connectToRedis() {
    await redis.ping();
    console.log('Connected to Redis');
}
