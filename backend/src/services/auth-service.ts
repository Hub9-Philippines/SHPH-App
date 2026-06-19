import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { AppDataSource } from '../db/data-source.js';
import { User } from '../db/entities/user.entity.js';
import dotenv from 'dotenv';

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET ?? 'secret';
const JWT_EXPIRES_IN = '7d';

export class AuthService {
    static async login(payload: Record<string, unknown>) {
        const repo = AppDataSource.getRepository(User);
        const email = payload.email as string | undefined;
        const phone = payload.phone as string | undefined;
        const password = payload.password as string | undefined;
        const otp = payload.otp as string | undefined;

        if (!password && !otp) {
            throw new Error('Password or OTP required');
        }

        const user = await repo.findOne({ where: [{ email }, { phone }] });
        if (!user) {
            throw new Error('User not found');
        }

        if (password) {
            const validPassword = await bcrypt.compare(password, payload.password as string);
            if (!validPassword) {
                throw new Error('Invalid credentials');
            }
        }

        // OTP handling should be implemented separately.
        const token = jwt.sign({ sub: user.id }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
        return { access: token, refresh: token };
    }

    static async registerInitiate(payload: Record<string, unknown>) {
        const repo = AppDataSource.getRepository(User);
        const email = payload.email as string | undefined;
        const phone = payload.phone as string | undefined;

        if (!email && !phone) {
            throw new Error('Email or phone is required');
        }

        const existing = await repo.findOne({ where: [{ email }, { phone }] });
        if (existing) {
            throw new Error('User already exists');
        }

        const user = repo.create({
            email,
            phone,
            role: 'client',
            verificationStatus: 'unverified',
            isVerified: false,
            isFaceVerified: false,
            isProfileComplete: false,
        });
        await repo.save(user);

        const token = jwt.sign({ sub: user.id }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
        return { access: token, refresh: token };
    }

    static async registerVerify(payload: Record<string, unknown>) {
        const token = payload['token'] as string | undefined;
        if (!token) {
            throw new Error('Token is required');
        }

        // For a simple stub, accept the existing token as verified.
        try {
            jwt.verify(token, JWT_SECRET);
            return { access: token, refresh: token };
        } catch (error) {
            throw new Error('Invalid token');
        }
    }

    static async verifyOtpPin(payload: Record<string, unknown>) {
        const phone = payload.phone as string | undefined;
        if (!phone) {
            throw new Error('Phone is required');
        }
        const repo = AppDataSource.getRepository(User);
        const user = await repo.findOne({ where: { phone } });
        if (!user) {
            throw new Error('User not found');
        }
        const token = jwt.sign({ sub: user.id }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
        return { access: token, refresh: token };
    }

    static async logout() {
        return;
    }
}
