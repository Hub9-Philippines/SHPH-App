import { Router } from 'express';
import { z } from 'zod';
const supportRouter = Router();
const chatbotSchema = z.object({
    message: z.string().trim().min(1).max(4000),
    history: z
        .array(z.object({
        role: z.enum(['user', 'assistant']),
        content: z.string().trim().min(1).max(4000),
    }))
        .max(20)
        .default([]),
});
supportRouter.post('/chatbot/', async (req, res) => {
    const apiKey = process.env.OPENROUTER_API_KEY;
    if (!apiKey) {
        return res
            .status(503)
            .json({ error: 'Chat assistant is not configured' });
    }
    const body = chatbotSchema.parse(req.body);
    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
            Authorization: `Bearer ${apiKey}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': process.env.PUBLIC_APP_URL ?? 'https://shph.app',
            'X-Title': 'SHPH',
        },
        body: JSON.stringify({
            model: process.env.OPENROUTER_MODEL ??
                'deepseek/deepseek-v4-flash-free',
            messages: [
                {
                    role: 'system',
                    content: 'You are the SerbisyoHub PH customer support assistant. Give concise, accurate help about service booking, providers, payments, profiles, and notifications. Never invent account or booking details.',
                },
                ...body.history,
                { role: 'user', content: body.message },
            ],
            temperature: 0.7,
            max_tokens: 2048,
        }),
    });
    if (!response.ok) {
        console.error(`OpenRouter request failed with status ${response.status}`);
        return res
            .status(502)
            .json({ error: 'Chat assistant is temporarily unavailable' });
    }
    const data = (await response.json());
    const reply = data.choices?.[0]?.message?.content?.trim();
    if (!reply)
        return res
            .status(502)
            .json({ error: 'Chat assistant returned an empty response' });
    return res.json({ reply });
});
export { supportRouter };
