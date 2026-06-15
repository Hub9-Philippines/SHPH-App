-- Insert mock chat rooms to match the app's UUIDs
-- Replace 'YOUR_USER_ID' with the actual authenticated user's UUID

INSERT INTO chat_rooms (id, client_id, provider_id, provider_name, provider_photo, last_message, last_message_time, unread_count)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'YOUR_USER_ID', 1, 'Maria Santos', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'Thank you for the booking! See you tomorrow.', NOW() - INTERVAL '2 hours', 2),
  ('00000000-0000-0000-0000-000000000002', 'YOUR_USER_ID', 2, 'Anna Cruz', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'The paint colors look great!', NOW() - INTERVAL '1 day', 0),
  ('00000000-0000-0000-0000-000000000003', 'YOUR_USER_ID', 3, 'Jose Reyes', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Is the leak fixed?', NOW() - INTERVAL '3 days', 1)
ON CONFLICT (id) DO NOTHING;
