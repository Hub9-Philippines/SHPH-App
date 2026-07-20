import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity.js';

@Entity({ name: 'service_listings' })
export class ServiceListing {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column()
    title!: string;

    @Column({ nullable: true })
    description?: string;

    @Column({ nullable: true })
    category?: number;

    @Column({ nullable: true })
    provider?: string;

    @Column({ type: 'decimal', nullable: true })
    basePrice?: string;

    @Column({ nullable: true })
    priceUnit?: string;

    @Column({ nullable: true })
    status?: string;

    @Column({ default: 'true' })
    isAvailable?: string;

    @Column({ nullable: true })
    thumbnail?: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'provider' })
    providerUser?: User;
}
