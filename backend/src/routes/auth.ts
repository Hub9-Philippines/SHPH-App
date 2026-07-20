import { Router } from 'express';
import { z } from 'zod';
import { AuthService } from '../services/auth-service.js';

const authRouter = Router();

const loginSchema = z.object({
    email: z.string().email().optional(),
    phone: z.string().optional(),
    password: z.string().optional(),
    otp: z.string().optional(),
});

authRouter.post('/login/', async (req, res) => {
    const body = loginSchema.parse(req.body);
    const tokens = await AuthService.login(body);
    res.json(tokens);
});

authRouter.post('/register/initiate/', async (req, res) => {
    const body = req.body;
    const tokens = await AuthService.registerInitiate(body);
    res.json(tokens);
});

authRouter.post('/register/verify/', async (req, res) => {
    const body = req.body;
    const tokens = await AuthService.registerVerify(body);
    res.json(tokens);
});

authRouter.post('/otp/send-pin/', async (req, res) => {
    const body = req.body;
    await AuthService.verifyOtpPin(body);
    res.status(204).send();
});

authRouter.post('/otp/verify-pin/', async (req, res) => {
    const body = req.body;
    const tokens = await AuthService.verifyOtpPin(body);
    res.json(tokens);
});

authRouter.post('/logout/', async (req, res) => {
    await AuthService.logout();
    res.status(204).send();
});

export { authRouter };
