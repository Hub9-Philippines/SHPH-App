-- Create chat_rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  provider_id INTEGER NOT NULL REFERENCES service_listings(id) ON DELETE CASCADE,
  provider_name VARCHAR(255) NOT NULL,
  provider_photo TEXT,
  last_message TEXT,
  last_message_time TIMESTAMP WITH TIME ZONE,
  unread_count INTEGER DEFAULT 0,
  unread_provider_count INTEGER DEFAULT 0,
  last_message_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id VARCHAR(50) NOT NULL CHECK (sender_id IN ('client', 'provider')),
  message_text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create call_history table
CREATE TABLE IF NOT EXISTS call_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  provider_name VARCHAR(255) NOT NULL,
  provider_photo TEXT,
  call_type VARCHAR(20) NOT NULL CHECK (call_type IN ('voice', 'video')),
  call_status VARCHAR(20) NOT NULL CHECK (call_status IN ('incoming', 'outgoing', 'missed')),
  duration_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_chat_rooms_client_id ON chat_rooms(client_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_provider_id ON chat_rooms(provider_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages(chat_room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_call_history_created_at ON call_history(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_history ENABLE ROW LEVEL SECURITY;

-- Create policies for chat_rooms
CREATE POLICY "Users can view their own chat rooms" ON chat_rooms
  FOR SELECT USING (client_id = auth.uid());

CREATE POLICY "Users can insert their own chat rooms" ON chat_rooms
  FOR INSERT WITH CHECK (client_id = auth.uid());

CREATE POLICY "Users can update their own chat rooms" ON chat_rooms
  FOR UPDATE USING (client_id = auth.uid());

-- Policy for providers to view chat rooms
CREATE POLICY "Providers can view chat rooms where they are the provider" ON chat_rooms
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM service_listings sl
      WHERE sl.id = provider_id AND sl.pro_id = auth.uid()
    )
  );

-- Create policies for chat_messages
CREATE POLICY "Users can view messages in their chat rooms" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_rooms 
      WHERE chat_rooms.id = chat_messages.chat_room_id 
      AND chat_rooms.client_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert messages in their chat rooms" ON chat_messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_rooms 
      WHERE chat_rooms.id = chat_messages.chat_room_id 
      AND chat_rooms.client_id = auth.uid()
    )
  );

-- Policies for providers
CREATE POLICY "Providers can view messages in their chat rooms" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_rooms cr
      JOIN service_listings sl ON sl.id = cr.provider_id
      WHERE cr.id = chat_messages.chat_room_id 
      AND sl.pro_id = auth.uid()
    )
  );

CREATE POLICY "Providers can insert messages in their chat rooms" ON chat_messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_rooms cr
      JOIN service_listings sl ON sl.id = cr.provider_id
      WHERE cr.id = chat_messages.chat_room_id 
      AND sl.pro_id = auth.uid()
    )
  );

-- Create policies for call_history
CREATE POLICY "Users can view their call history" ON call_history
  FOR SELECT USING (true); -- Adjust based on auth requirements

CREATE POLICY "Users can insert their call history" ON call_history
  FOR INSERT WITH CHECK (true); -- Adjust based on auth requirements

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_chat_rooms_updated_at
  BEFORE UPDATE ON chat_rooms
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
