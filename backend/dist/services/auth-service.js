import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { AppDataSource } from '../db/data-source.js';
import { User } from '../db/entities/user.entity.js';
import dotenv from 'dotenv';
import crypto from 'node:crypto';
import { redis } from '../db/redis.js';
import { SmsService } from './sms-service.js';
dotenv.config();
const JWT_SECRET = process.env.JWT_SECRET ?? 'secret';
const JWT_EXPIRES_IN = '7d';
const OTP_TTL_SECONDS = Number(process.env.SMS_OTP_TTL_SECONDS ?? 300);
const OTP_RESEND_SECONDS = Number(process.env.SMS_OTP_RESEND_SECONDS ?? 60);
const OTP_MAX_ATTEMPTS = 5;
class AuthError extends Error {
    status;
    constructor(message, status) {
        super(message);
        this.status = status;
    }
}
export class AuthService {
    static async login(payload) {
        const repo = AppDataSource.getRepository(User);
        const email = payload.email;
        const phone = payload.phone;
        const password = payload.password;
        const otp = payload.otp;
        if (!password && !otp) {
            throw new Error('Password or OTP required');
        }
        const user = await repo.findOne({ where: [{ email }, { phone }] });
        if (!user) {
            throw new Error('User not found');
        }
        if (password) {
            const validPassword = await bcrypt.compare(password, payload.password);
            if (!validPassword) {
                throw new Error('Invalid credentials');
            }
        }
        // OTP handling should be implemented separately.
        const token = jwt.sign({ sub: user.id }, JWT_SECRET, {
            expiresIn: JWT_EXPIRES_IN,
        });
        return { access: token, refresh: token };
    }
    static async registerInitiate(payload) {
        const repo = AppDataSource.getRepository(User);
        const email = payload.email;
        const phone = payload.phone;
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
        const token = jwt.sign({ sub: user.id }, JWT_SECRET, {
            expiresIn: JWT_EXPIRES_IN,
        });
        return { access: token, refresh: token };
    }
    static async registerVerify(payload) {
        const token = payload['token'];
        if (!token) {
            throw new Error('Token is required');
        }
        // For a simple stub, accept the existing token as verified.
        try {
            jwt.verify(token, JWT_SECRET);
            return { access: token, refresh: token };
        }
        catch (error) {
            throw new Error('Invalid token');
        }
    }
    static async sendPhoneOtp(payload, purpose) {
        const phone = normalizePhone(payload.phone_number ?? payload.phone);
        const repo = AppDataSource.getRepository(User);
        const user = await repo.findOne({ where: { phone } });
        if (purpose === 'login' && !user)
            throw new AuthError('No account exists for this phone number', 404);
        if (purpose === 'register' && user)
            throw new AuthError('An account already exists for this phone number', 409);
        const cooldownKey = `auth:otp:cooldown:${purpose}:${phone}`;
        const allowed = await redis.set(cooldownKey, '1', 'EX', OTP_RESEND_SECONDS, 'NX');
        if (allowed !== 'OK')
            throw new AuthError('Please wait before requesting another code', 429);
        const testOtp = process.env.SMS_TEST_OTP;
        const code = process.env.NODE_ENV !== 'production' && testOtp
            ? testOtp
            : crypto.randomInt(100000, 1000000).toString();
        const record = {
            hash: hashOtp(phone, purpose, code),
            attempts: 0,
        };
        const otpKey = `auth:otp:${purpose}:${phone}`;
        await redis.set(otpKey, JSON.stringify(record), 'EX', OTP_TTL_SECONDS);
        try {
            await SmsService.sendOtp(phone, code);
        }
        catch (error) {
            await redis.del(otpKey, cooldownKey);
            throw error;
        }
    }
    static async verifyPhoneOtp(payload, purpose) {
        const phone = normalizePhone(payload.phone_number ?? payload.phone);
        const code = String(payload.pin ?? payload.code ?? '');
        if (!/^\d{6}$/.test(code))
            throw new AuthError('A valid 6-digit code is required', 400);
        const otpKey = `auth:otp:${purpose}:${phone}`;
        const raw = await redis.get(otpKey);
        if (!raw)
            throw new AuthError('The verification code has expired', 400);
        const record = JSON.parse(raw);
        const actual = Buffer.from(record.hash, 'hex');
        const expected = Buffer.from(hashOtp(phone, purpose, code), 'hex');
        if (actual.length !== expected.length ||
            !crypto.timingSafeEqual(actual, expected)) {
            record.attempts += 1;
            if (record.attempts >= OTP_MAX_ATTEMPTS)
                await redis.del(otpKey);
            else {
                const ttl = await redis.ttl(otpKey);
                await redis.set(otpKey, JSON.stringify(record), 'EX', Math.max(ttl, 1));
            }
            throw new AuthError('Invalid verification code', 400);
        }
        await redis.del(otpKey);
        const repo = AppDataSource.getRepository(User);
        let user = await repo.findOne({ where: { phone } });
        if (purpose === 'login' && !user)
            throw new AuthError('User not found', 404);
        if (purpose === 'register' && !user) {
            user = repo.create({
                phone,
                role: normalizeRole(payload.role),
                verificationStatus: 'verified',
                isVerified: true,
                isFaceVerified: false,
                isProfileComplete: false,
            });
            await repo.save(user);
        }
        if (!user)
            throw new AuthError('User not found', 404);
        const token = jwt.sign({ sub: user.id }, JWT_SECRET, {
            expiresIn: JWT_EXPIRES_IN,
        });
        return { access: token, refresh: token, user_id: user.id };
    }
    static async logout() {
        return;
    }
}
function normalizePhone(value) {
    const phone = String(value ?? '').replace(/[\s()-]/g, '');
    if (!/^\+[1-9]\d{6,14}$/.test(phone)) {
        throw new AuthError('Phone number must use E.164 format, for example +639171234567', 400);
    }
    return phone;
}
function hashOtp(phone, purpose, code) {
    return crypto
        .createHmac('sha256', JWT_SECRET)
        .update(`${purpose}:${phone}:${code}`)
        .digest('hex');
}
function normalizeRole(value) {
    const role = String(value ?? 'client').toLowerCase();
    if (role !== 'client' && role !== 'provider') {
        throw new AuthError('Role must be client or provider', 400);
    }
    return role;
}
