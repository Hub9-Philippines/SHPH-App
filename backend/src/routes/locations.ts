import { Router } from 'express';
import { z } from 'zod';

const locationsRouter = Router();
const upstream = 'https://psgc.gitlab.io/api';
const codeSchema = z.string().regex(/^\d{9,10}$/);

async function proxy(res: import('express').Response, path: string) {
    const response = await fetch(`${upstream}${path}`);
    if (!response.ok)
        return res
            .status(502)
            .json({ error: 'Location directory is unavailable' });
    return res.json(await response.json());
}

locationsRouter.get('/regions/', async (_req, res) =>
    proxy(res, '/regions.json'),
);

locationsRouter.get('/provinces/', async (req, res) => {
    const region = req.query.region ? codeSchema.parse(req.query.region) : null;
    return proxy(
        res,
        region ? `/regions/${region}/provinces.json` : '/provinces.json',
    );
});

locationsRouter.get('/cities/', async (req, res) => {
    const province = req.query.province
        ? codeSchema.parse(req.query.province)
        : null;
    const region = req.query.region ? codeSchema.parse(req.query.region) : null;
    if (!province && !region)
        return res
            .status(400)
            .json({ error: 'province or region is required' });
    return proxy(
        res,
        province
            ? `/provinces/${province}/cities-municipalities.json`
            : `/regions/${region}/cities-municipalities.json`,
    );
});

locationsRouter.get('/barangays/', async (req, res) => {
    const city = codeSchema.parse(req.query.city);
    return proxy(res, `/cities-municipalities/${city}/barangays.json`);
});

export { locationsRouter };
