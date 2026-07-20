import { DataSource } from 'typeorm';
import dotenv from 'dotenv';
import { User } from './entities/user.entity.js';
import { Category } from './entities/category.entity.js';
import { ServiceListing } from './entities/service-listing.entity.js';
import { ChatRoom } from './entities/chat-room.entity.js';
import { ChatMessage } from './entities/chat-message.entity.js';
dotenv.config();
export const AppDataSource = new DataSource({
    type: 'postgres',
    url: process.env.DATABASE_URL,
    synchronize: false,
    logging: false,
    entities: [User, Category, ServiceListing, ChatRoom, ChatMessage],
    migrations: ['./src/db/migrations/*.ts'],
});
export async function connectToDatabase() {
    if (!AppDataSource.isInitialized) {
        await AppDataSource.initialize();
        console.log('Connected to PostgreSQL');
    }
}
