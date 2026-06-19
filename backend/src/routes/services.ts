import { Router } from 'express';
import { ServicesService } from '../services/services-service.js';

const servicesRouter = Router();

servicesRouter.get('/categories/', async (req, res) => {
    const page = req.query.page ? Number(req.query.page) : undefined;
    const categories = await ServicesService.listCategories(page);
    res.json(categories);
});

servicesRouter.get('/listings/', async (req, res) => {
    const params = {
        search: typeof req.query.search === 'string' ? req.query.search : undefined,
        ordering: typeof req.query.ordering === 'string' ? req.query.ordering : undefined,
        page: req.query.page ? Number(req.query.page) : undefined,
        pageSize: req.query.page_size ? Number(req.query.page_size) : undefined,
    };
    const listings = await ServicesService.listListings(params);
    res.json(listings);
});

servicesRouter.get('/listings/:id/', async (req, res) => {
    const listing = await ServicesService.getListing(Number(req.params.id));
    res.json(listing);
});

servicesRouter.get('/listings/mine/', async (req, res) => {
    const page = req.query.page ? Number(req.query.page) : undefined;
    const listings = await ServicesService.listMyListings(req.userId, page);
    res.json(listings);
});

servicesRouter.post('/listings/', async (req, res) => {
    const listing = await ServicesService.createListing(req.userId, req.body);
    res.json(listing);
});

servicesRouter.patch('/listings/:id/', async (req, res) => {
    const listing = await ServicesService.updateListing(req.userId, Number(req.params.id), req.body);
    res.json(listing);
});

export { servicesRouter };
