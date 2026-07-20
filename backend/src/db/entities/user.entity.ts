import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'profiles' })
export class User {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ unique: true, nullable: true })
    email?: string;

    @Column({ unique: true, nullable: true })
    phone?: string;

    @Column({ nullable: true })
    firstName?: string;

    @Column({ nullable: true })
    lastName?: string;

    @Column({ nullable: true })
    displayName?: string;

    @Column({ nullable: true })
    photoUrl?: string;

    @Column({ type: 'text', nullable: true })
    bio?: string;

    @Column({ default: 'client' })
    role!: string;

    @Column({ default: 'unverified' })
    verificationStatus!: string;

    @Column({ default: false })
    isVerified!: boolean;

    @Column({ default: false })
    isFaceVerified!: boolean;

    @Column({ default: false })
    isProfileComplete!: boolean;

    @CreateDateColumn({ type: 'timestamptz' })
    createdAt!: Date;

    @UpdateDateColumn({ type: 'timestamptz' })
    updatedAt!: Date;
}
