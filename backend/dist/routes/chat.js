import { Router } from 'express';
import { ChatService } from '../services/chat-service.js';
const chatRouter = Router();
chatRouter.get('/threads/', async (req, res) => {
    const page = req.query.page ? Number(req.query.page) : undefined;
    const threads = await ChatService.listThreads(req.userId, page);
    res.json(threads);
});
chatRouter.get('/threads/:id/', async (req, res) => {
    const thread = await ChatService.getThreadDetails(req.userId, req.params.id);
    res.json(thread);
});
chatRouter.get('/threads/:threadId/messages/', async (req, res) => {
    const page = req.query.page ? Number(req.query.page) : undefined;
    const messages = await ChatService.listMessages(req.userId, req.params.threadId, page);
    res.json(messages);
});
chatRouter.post('/threads/:threadId/send/', async (req, res) => {
    const result = await ChatService.sendMessage(req.userId, req.params.threadId, req.body.content);
    res.json(result);
});
chatRouter.post('/threads/:threadId/read/', async (req, res) => {
    await ChatService.markRead(req.userId, req.params.threadId);
    res.status(204).send();
});
chatRouter.post('/threads/booking/:bookingId/', async (req, res) => {
    const thread = await ChatService.getOrCreateThreadForBooking(req.userId, req.params.bookingId);
    res.json(thread);
});
export { chatRouter };
