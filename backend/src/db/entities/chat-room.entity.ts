import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'chat_rooms' })
export class ChatRoom {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column()
    clientId!: string;

    @Column()
    providerId!: string;

    @Column({ nullable: true })
    lastMessage?: string;

    @Column({ type: 'int', default: 0 })
    unreadCount!: number;

    @Column({ type: 'timestamp with time zone', nullable: true })
    lastMessageTime?: Date;

    @CreateDateColumn({ type: 'timestamptz' })
    createdAt!: Date;

    @UpdateDateColumn({ type: 'timestamptz' })
    updatedAt!: Date;
}
