import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ChatRoom } from './chat-room.entity.js';

@Entity({ name: 'chat_messages' })
export class ChatMessage {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @ManyToOne(() => ChatRoom)
    @JoinColumn({ name: 'chat_room_id' })
    chatRoom!: ChatRoom;

    @Column()
    senderId!: string;

    @Column({ type: 'text' })
    content!: string;

    @CreateDateColumn({ type: 'timestamptz' })
    createdAt!: Date;
}
