import { Router } from 'express';
import { UsersService } from '../services/users-service.js';

const usersRouter = Router();

usersRouter.get('/me/', async (req, res) => {
    const user = await UsersService.getMe(req.userId);
    res.json(user);
});

usersRouter.patch('/me/update/', async (req, res) => {
    const user = await UsersService.updateMe(req.userId, req.body);
    res.json(user);
});

usersRouter.post('/me/photo/', async (req, res) => {
    const user = await UsersService.uploadPhoto(req.userId, req.body);
    res.json(user);
});

usersRouter.delete('/me/delete/', async (req, res) => {
    await UsersService.deleteMe(req.userId);
    res.status(204).send();
});

export { usersRouter };
