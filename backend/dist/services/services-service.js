import { AppDataSource } from '../db/data-source.js';
import { Category } from '../db/entities/category.entity.js';
import { ServiceListing } from '../db/entities/service-listing.entity.js';
export class ServicesService {
    static async listCategories(page) {
        const repo = AppDataSource.getRepository(Category);
        return repo.find({ take: page != null ? 20 : undefined });
    }
    static async listListings(params) {
        const repo = AppDataSource.getRepository(ServiceListing);
        const query = repo.createQueryBuilder('listing');
        if (params.search && typeof params.search === 'string') {
            query.where('listing.title ILIKE :search OR listing.description ILIKE :search', {
                search: `%${params.search}%`,
            });
        }
        if (params.ordering && typeof params.ordering === 'string') {
            query.orderBy(`listing.${params.ordering}`, 'ASC');
        }
        if (params.page && typeof params.page === 'number') {
            query.skip((params.page - 1) * (params.pageSize || 20));
            query.take(params.pageSize || 20);
        }
        return query.getMany();
    }
    static async getListing(id) {
        const repo = AppDataSource.getRepository(ServiceListing);
        const listing = await repo.findOneBy({ id });
        if (!listing) {
            throw new Error('Listing not found');
        }
        return listing;
    }
    static async listMyListings(userId, page) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ServiceListing);
        const listings = await repo.find({ where: { provider: userId }, take: page != null ? 20 : undefined });
        return listings;
    }
    static async createListing(userId, payload) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ServiceListing);
        const listing = repo.create({
            title: payload.title,
            description: payload.description,
            category: payload.category,
            provider: userId,
            basePrice: payload.base_price,
            priceUnit: payload.price_unit,
            status: payload.status,
            isAvailable: payload.is_available,
            thumbnail: payload.thumbnail,
        });
        return repo.save(listing);
    }
    static async updateListing(userId, id, payload) {
        if (!userId) {
            throw new Error('Missing user id');
        }
        const repo = AppDataSource.getRepository(ServiceListing);
        await repo.update({ id, provider: userId }, payload);
        const listing = await repo.findOneBy({ id, provider: userId });
        if (!listing) {
            throw new Error('Listing not found');
        }
        return listing;
    }
}
