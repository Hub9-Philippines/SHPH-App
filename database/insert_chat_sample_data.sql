-- Insert sample chat rooms
INSERT INTO chat_rooms (client_id, provider_id, provider_name, provider_photo, last_message, last_message_time, unread_count) VALUES
-- Chat with Maria Santos (Cleaning Services)
('00000000-0000-0000-0000-000000000001', 1, 'Maria Santos', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'Thank you for the booking! See you tomorrow.', NOW() - INTERVAL '2 hours', 2),
-- Chat with Anna Cruz (Painting Services)
('00000000-0000-0000-0000-000000000001', 10, 'Anna Cruz', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'The paint colors look great!', NOW() - INTERVAL '1 day', 0),
-- Chat with Jose Reyes (Plumbing Services)
('00000000-0000-0000-0000-000000000001', 4, 'Jose Reyes', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Is the leak fixed?', NOW() - INTERVAL '3 days', 1);

-- Insert sample chat messages
INSERT INTO chat_messages (chat_room_id, sender_id, message_text, created_at) VALUES
-- Messages for Maria Santos chat (assuming first chat room ID)
-- Get the first chat room ID dynamically
WITH first_room AS (
  SELECT id FROM chat_rooms WHERE provider_name = 'Maria Santos' LIMIT 1
)
SELECT 
  (SELECT id FROM first_room),
  'provider',
  'Hello! I received your booking request for home cleaning.',
  NOW() - INTERVAL '3 hours'
UNION ALL
SELECT 
  (SELECT id FROM first_room),
  'client',
  'Hi Maria! Yes, I need my place cleaned by Friday.',
  NOW() - INTERVAL '2 hours 50 minutes'
UNION ALL
SELECT 
  (SELECT id FROM first_room),
  'provider',
  'Friday works perfectly for me. What time would you prefer?',
  NOW() - INTERVAL '2 hours 40 minutes'
UNION ALL
SELECT 
  (SELECT id FROM first_room),
  'client',
  'Around 10 AM would be great.',
  NOW() - INTERVAL '2 hours 30 minutes'
UNION ALL
SELECT 
  (SELECT id FROM first_room),
  'provider',
  'Perfect! 10 AM it is. Thank you for the booking! See you tomorrow.',
  NOW() - INTERVAL '2 hours';

-- Messages for Anna Cruz chat
WITH second_room AS (
  SELECT id FROM chat_rooms WHERE provider_name = 'Anna Cruz' LIMIT 1
)
SELECT 
  (SELECT id FROM second_room),
  'client',
  'Hi Anna, how is the painting coming along?',
  NOW() - INTERVAL '1 day 2 hours'
UNION ALL
SELECT 
  (SELECT id FROM second_room),
  'provider',
  'It is going very well! The living room is almost done.',
  NOW() - INTERVAL '1 day 1 hour'
UNION ALL
SELECT 
  (SELECT id FROM second_room),
  'client',
  'That sounds great! Can you send me a photo?',
  NOW() - INTERVAL '1 day'
UNION ALL
SELECT 
  (SELECT id FROM second_room),
  'provider',
  'Sure! I will send it shortly. The paint colors look great!',
  NOW() - INTERVAL '23 hours';

-- Messages for Jose Reyes chat
WITH third_room AS (
  SELECT id FROM chat_rooms WHERE provider_name = 'Jose Reyes' LIMIT 1
)
SELECT 
  (SELECT id FROM third_room),
  'client',
  'Jose, I think there is still a small leak in the kitchen.',
  NOW() - INTERVAL '3 days 2 hours'
UNION ALL
SELECT 
  (SELECT id FROM third_room),
  'provider',
  'I will come by tomorrow to check it again.',
  NOW() - INTERVAL '3 days 1 hour'
UNION ALL
SELECT 
  (SELECT id FROM third_room),
  'client',
  'Is the leak fixed?',
  NOW() - INTERVAL '3 days';

-- Insert sample call history
INSERT INTO call_history (provider_name, provider_photo, call_type, call_status, duration_seconds, created_at) VALUES
-- Missed call from Maria Santos
('Maria Santos', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'voice', 'missed', 0, NOW() - INTERVAL '5 hours'),
-- Incoming video call from Anna Cruz
('Anna Cruz', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', 'video', 'incoming', 180, NOW() - INTERVAL '1 day'),
-- Outgoing voice call to Jose Reyes
('Jose Reyes', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'voice', 'outgoing', 45, NOW() - INTERVAL '2 days'),
-- Missed video call from Carlos Mendoza (Electrical Services)
('Carlos Mendoza', 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=100', 'video', 'missed', 0, NOW() - INTERVAL '4 days'),
-- Incoming voice call from Roberto Tan (HVAC Services)
('Roberto Tan', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', 'voice', 'incoming', 300, NOW() - INTERVAL '5 days');
