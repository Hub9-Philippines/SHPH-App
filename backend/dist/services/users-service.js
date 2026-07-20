import { AppDataSource } from '../db/data-source.js';
import { User } from '../db/entities/user.entity.js';
export class UsersService {
    static async getMe(userId) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(User);
        const user = await repo.findOneBy({ id: userId });
        if (!user) {
            throw new Error('User not found');
        }
        return user;
    }
    static async updateMe(userId, data) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(User);
        await repo.update(userId, data);
        const updated = await repo.findOneBy({ id: userId });
        if (!updated) {
            throw new Error('User not found');
        }
        return updated;
    }
    static async uploadPhoto(userId, payload) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const photoUrl = payload.url;
        if (!photoUrl) {
            throw new Error('Photo URL required');
        }
        const repo = AppDataSource.getRepository(User);
        await repo.update(userId, { photoUrl });
        const user = await repo.findOneBy({ id: userId });
        if (!user) {
            throw new Error('User not found');
        }
        return user;
    }
    static async deleteMe(userId) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(User);
        await repo.delete(userId);
    }
}
