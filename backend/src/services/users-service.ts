import { AppDataSource } from '../db/data-source.js';
import { User } from '../db/entities/user.entity.js';

export class UsersService {
    static async getMe(userId: string | undefined) {
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

    static async updateMe(userId: string | undefined, data: Record<string, unknown>) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(User);
        await repo.update(userId, data as Partial<User>);
        const updated = await repo.findOneBy({ id: userId });
        if (!updated) {
            throw new Error('User not found');
        }
        return updated;
    }

    static async uploadPhoto(userId: string | undefined, payload: Record<string, unknown>) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const photoUrl = payload.url as string | undefined;
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

    static async deleteMe(userId?: string) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(User);
        await repo.delete(userId);
    }
}
