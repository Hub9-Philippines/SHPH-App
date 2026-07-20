import { Request, Response, NextFunction } from 'express';

export function errorHandler(error: unknown, req: Request, res: Response, next: NextFunction) {
    console.error(error);
    const status = (error as any)?.status ?? 500;
    const message = (error as any)?.message ?? 'Internal server error';
    res.status(status).json({ error: message });
}
