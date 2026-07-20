var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity.js';
let ServiceListing = class ServiceListing {
    id;
    title;
    description;
    category;
    provider;
    basePrice;
    priceUnit;
    status;
    isAvailable;
    thumbnail;
    providerUser;
};
__decorate([
    PrimaryGeneratedColumn(),
    __metadata("design:type", Number)
], ServiceListing.prototype, "id", void 0);
__decorate([
    Column(),
    __metadata("design:type", String)
], ServiceListing.prototype, "title", void 0);
__decorate([
    Column({ nullable: true }),
    __metadata("design:type", String)
], ServiceListing.prototype, "description", void 0);
__decorate([
    Column({ nullable: true }),
    __metadata("design:type", Number)
], ServiceListing.prototype, "category", void 0);
__decorate([
    Column({ nullable: true }),
    __metadata("design:type", String)
], ServiceListing.prototype, "provider", void 0);
__decorate([
    Column({ type: 'decimal', nullable: true }),
    __metadata("design:type", String)
], ServiceListing.prototype, "basePrice", void 0);
__decorate([
    Column({ nullable: true }),
    __metadata("design:type", String)
], ServiceListing.prototype, "priceUnit", void 0);
__decorate([
    Column({ nullable: true }),
    __metadata("design:type", String)
], ServiceListing.prototype, "status", void 0);
__decorate([
    Column({ default: 'true' }),
    __metadata("design:type", String)
], ServiceListing.prototype, "isAvailable", void 0);
__decorate([
    Column({ nullable: true }),
    __metadata("design:type", String)
], ServiceListing.prototype, "thumbnail", void 0);
__decorate([
    ManyToOne(() => User),
    JoinColumn({ name: 'provider' }),
    __metadata("design:type", User)
], ServiceListing.prototype, "providerUser", void 0);
ServiceListing = __decorate([
    Entity({ name: 'service_listings' })
], ServiceListing);
export { ServiceListing };
