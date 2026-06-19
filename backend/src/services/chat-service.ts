import { AppDataSource } from '../db/data-source.js';
import { ChatRoom } from '../db/entities/chat-room.entity.js';
import { ChatMessage } from '../db/entities/chat-message.entity.js';

export class ChatService {
    static async listThreads(userId: string | undefined, page?: number) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ChatRoom);
        const query = repo.createQueryBuilder('room').where('room.clientId = :userId OR room.providerId = :userId', { userId });
        if (page != null) {
            query.skip((page - 1) * 20).take(20);
        }
        return query.getMany();
    }

    static async getThreadDetails(userId: string | undefined, id: string) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ChatRoom);
        const room = await repo.findOne({ where: { id, clientId: userId } });
        if (!room) {
            throw new Error('Thread not found');
        }
        return room;
    }

    static async listMessages(userId: string | undefined, threadId: string, page?: number) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const roomRepo = AppDataSource.getRepository(ChatRoom);
        const room = await roomRepo.findOne({ where: { id: threadId, clientId: userId } });
        if (!room) {
            throw new Error('Thread not found');
        }
        const repo = AppDataSource.getRepository(ChatMessage);
        const query = repo.createQueryBuilder('message').where('message.chatRoom = :threadId', { threadId }).orderBy('message.createdAt', 'ASC');
        if (page != null) {
            query.skip((page - 1) * 50).take(50);
        }
        return query.getMany();
    }

    static async sendMessage(userId: string | undefined, threadId: string, content: string) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const roomRepo = AppDataSource.getRepository(ChatRoom);
        const room = await roomRepo.findOne({ where: { id: threadId, clientId: userId } });
        if (!room) {
            throw new Error('Thread not found');
        }

        const repo = AppDataSource.getRepository(ChatMessage);
        const message = repo.create({
            chatRoom: room,
            senderId: userId,
            content,
        });
        await repo.save(message);

        room.lastMessage = content;
        room.lastMessageTime = new Date();
        await roomRepo.save(room);

        return message;
    }

    static async markRead(userId: string | undefined, threadId: string) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ChatRoom);
        const room = await repo.findOne({ where: { id: threadId, clientId: userId } });
        if (!room) {
            throw new Error('Thread not found');
        }
        room.unreadCount = 0;
        await repo.save(room);
    }

    static async getOrCreateThreadForBooking(userId: string | undefined, bookingId: string) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ChatRoom);
        let room = await repo.findOne({ where: { clientId: userId, providerId: bookingId } });
        if (!room) {
            room = repo.create({ clientId: userId, providerId: bookingId });
            room = await repo.save(room);
        }
        return room;
    }
}
