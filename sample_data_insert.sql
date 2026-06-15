-- Sample Data Insert Script for SHPH (SerbisyoHub PH)
-- This script inserts sample categories and service listings for testing


-- Insert Sample Categories (matching original FlutterFlow design)
INSERT INTO categories (name, description, icon, image_url, sort_order, is_active) VALUES
('Home Improvement', 'Professional home improvement and renovation services', 'home', 'assets/images/15.png', 1, true),
('Safety & Security', 'Security systems and safety services', 'security', 'assets/images/14.png', 2, true),
('Electrical Services', 'Licensed electrical work and repairs', 'electrical_services', 'assets/images/vnimc_1.png', 3, true),
('Cleaning Services', 'Professional cleaning services for homes and offices', 'cleaning_services', 'assets/images/49svh_2.png', 4, true),
('Landscape Design', 'Landscaping and garden design services', 'landscape', 'assets/images/3a9k2_3.png', 5, true),
('Handyman Services', 'General home repairs and maintenance', 'handyman', 'assets/images/fijek_4.png', 6, true),
('Painting & Decorating', 'Interior and exterior painting services', 'format_paint', 'assets/images/2emqy_5.png', 7, true),
('Home Pest Protection', 'Pest control and protection services', 'pest_control', 'assets/images/dfjsb_6.png', 8, true),
('HVAC Services', 'Heating, ventilation, and air conditioning', 'hvac', 'assets/images/x7hc1_7.png', 9, true),
('Plumbing Services', 'Expert plumbing repairs and installations', 'plumbing', 'assets/images/k7eg7_8.png', 10, true),
('Auto & Transport', 'Automotive and transportation services', 'directions_car', 'assets/images/nswz3_9.png', 11, true),
('Wellness Spa Services', 'Spa and wellness services', 'spa', 'assets/images/10.png', 12, true),
('Business Services', 'Professional business services', 'business', 'assets/images/11.png', 13, true),
('Tech & Gadgets', 'Technology and gadget repair services', 'computer', 'assets/images/13.png', 14, true)
ON CONFLICT (name) DO NOTHING;

-- Insert Sample Service Listings
-- Note: provider and provider_id should reference actual user IDs from auth.users
-- For testing, you may need to update these with real user IDs after creating test users

INSERT INTO service_listings (id, category, category_name, provider, provider_name, provider_photo, title, description, base_price, price_unit, status, is_available, rating, thumbnail, review_count) VALUES
-- Home Improvement
(1, 1, 'Home Improvement', 1, 'Juan Dela Cruz', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', 'General Home Maintenance', 'Complete home maintenance including minor repairs, fixture replacements, and general upkeep.', 500.00, 'per hour', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400', 12),
(2, 1, 'Home Improvement', 1, 'Juan Dela Cruz', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', 'Door and Window Repair', 'Expert repair for doors, windows, locks, and security fixtures.', 350.00, 'per hour', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 8),

-- Safety & Security
(3, 2, 'Safety & Security', 2, 'Ramon Torres', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100', 'Security Camera Installation', 'Professional installation of security cameras and monitoring systems.', 1500.00, 'per setup', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1557597774-9d273605dfa9?w=400', 14),
(4, 2, 'Safety & Security', 2, 'Ramon Torres', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100', 'Alarm System Setup', 'Complete alarm system installation and configuration.', 800.00, 'per setup', 'active', 'true', '4.6', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 11),

-- Electrical Services
(5, 3, 'Electrical Services', 3, 'Jose Rodriguez', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100', 'Wiring Installation', 'Safe and code-compliant electrical wiring for homes and offices.', 550.00, 'per hour', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400', 14),
(6, 3, 'Electrical Services', 3, 'Jose Rodriguez', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100', 'Light Fixture Installation', 'Installation of ceiling lights, chandeliers, and outdoor lighting.', 350.00, 'per fixture', 'active', 'true', '4.6', 'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400', 11),
(7, 3, 'Electrical Services', 4, 'Carlos Garcia', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', 'Electrical Inspection', 'Comprehensive electrical safety inspection and reporting.', 800.00, 'per inspection', 'active', 'true', '5.0', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 9),

-- Cleaning Services
(8, 4, 'Cleaning Services', 5, 'Maria Santos', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'Deep House Cleaning', 'Thorough cleaning of all rooms including kitchen and bathroom deep clean.', 800.00, 'per visit', 'active', 'true', '4.9', 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400', 25),
(9, 4, 'Cleaning Services', 5, 'Maria Santos', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'Office Cleaning', 'Professional office cleaning for small to medium businesses.', 1200.00, 'per visit', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400', 15),
(10, 4, 'Cleaning Services', 6, 'Ana Reyes', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 'Move-in/Move-out Cleaning', 'Specialized cleaning for moving in or out of properties.', 1500.00, 'per visit', 'active', 'true', '4.6', 'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=400', 10),

-- Landscape Design
(11, 5, 'Landscape Design', 7, 'Diego Flores', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100', 'Lawn Care', 'Regular lawn mowing, edging, and maintenance.', 400.00, 'per visit', 'active', 'true', '4.6', 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400', 21),
(12, 5, 'Landscape Design', 7, 'Diego Flores', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100', 'Landscaping', 'Complete landscape design and installation.', 3000.00, 'per project', 'active', 'true', '4.9', 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400', 11),
(13, 5, 'Landscape Design', 8, 'Ricardo Ortiz', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', 'Tree Trimming', 'Professional tree pruning and maintenance services.', 600.00, 'per hour', 'active', 'true', '4.4', 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400', 9),

-- Handyman Services
(14, 6, 'Handyman Services', 9, 'Antonio Cruz', 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=100', 'General Repairs', 'Complete home maintenance including minor repairs and fixture replacements.', 500.00, 'per hour', 'active', 'true', '4.9', 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400', 8),
(15, 6, 'Handyman Services', 9, 'Antonio Cruz', 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=100', 'Door & Window Repair', 'Expert repair for doors, windows, locks, and security fixtures.', 350.00, 'per hour', 'active', 'true', '4.6', 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400', 12),
(16, 6, 'Handyman Services', 10, 'Francisco Castillo', 'https://images.unsplash.com/photo-1568602471122-7832955cc4c5?w=100', 'Furniture Assembly', 'Professional assembly of furniture and home fixtures.', 400.00, 'per hour', 'active', 'true', '4.4', 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400', 6),

-- Painting & Decorating
(17, 7, 'Painting & Decorating', 11, 'Javier Morales', 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=100', 'Interior Painting', 'Professional interior painting with premium finishes.', 400.00, 'per square meter', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400', 19),
(18, 7, 'Painting & Decorating', 11, 'Javier Morales', 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=100', 'Exterior Painting', 'Weather-resistant exterior painting for homes.', 500.00, 'per square meter', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400', 15),
(19, 7, 'Painting & Decorating', 12, 'Roberto Guerrero', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', 'Wallpaper Installation', 'Professional wallpaper hanging and removal.', 300.00, 'per square meter', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400', 7),

-- Home Pest Protection
(20, 8, 'Home Pest Protection', 13, 'Pedro Mendoza', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'General Pest Control', 'Complete pest control treatment for homes and offices.', 600.00, 'per visit', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', 20),
(21, 8, 'Home Pest Protection', 13, 'Pedro Mendoza', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Termite Treatment', 'Professional termite inspection and treatment services.', 1500.00, 'per treatment', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400', 7),

-- HVAC Services
(22, 9, 'HVAC Services', 14, 'Luis Fernandez', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', 'AC Installation', 'Professional air conditioning installation for homes and offices.', 2500.00, 'per unit', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', 22),
(23, 9, 'HVAC Services', 14, 'Luis Fernandez', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', 'AC Repair & Maintenance', 'Diagnosis and repair of air conditioning systems.', 500.00, 'per visit', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', 13),
(24, 9, 'HVAC Services', 15, 'Miguel Ramos', 'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=100', 'Heating System Service', 'Heating system maintenance and repair services.', 600.00, 'per visit', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', 16),

-- Plumbing Services
(25, 10, 'Plumbing Services', 16, 'Carlos Garcia', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', 'Leak Repair', 'Quick and reliable leak detection and repair services.', 450.00, 'per visit', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', 20),
(26, 10, 'Plumbing Services', 16, 'Carlos Garcia', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100', 'Pipe Installation', 'New pipe installation for renovations and new construction.', 600.00, 'per hour', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400', 7),
(27, 10, 'Plumbing Services', 17, 'Diego Flores', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100', 'Drain Cleaning', 'Professional drain cleaning and unclogging services.', 400.00, 'per visit', 'active', 'true', '4.9', 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400', 18),

-- Auto & Transport
(28, 11, 'Auto & Transport', 18, 'Eduardo Ramos', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Car Repair', 'General automotive repair and maintenance services.', 800.00, 'per visit', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?w=400', 17),
(29, 11, 'Auto & Transport', 18, 'Eduardo Ramos', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Towing Service', 'Emergency towing and roadside assistance.', 500.00, 'per tow', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?w=400', 13),

-- Wellness Spa Services
(30, 12, 'Wellness Spa Services', 19, 'Sofia Martinez', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'Massage Therapy', 'Relaxing and therapeutic massage services.', 600.00, 'per hour', 'active', 'true', '4.9', 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=400', 28),
(31, 12, 'Wellness Spa Services', 19, 'Sofia Martinez', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'Facial Treatment', 'Professional facial and skincare services.', 450.00, 'per session', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=400', 22),

-- Business Services
(32, 13, 'Business Services', 20, 'Isabella Rodriguez', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 'Accounting Services', 'Professional accounting and bookkeeping for small businesses.', 1000.00, 'per month', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400', 15),
(33, 13, 'Business Services', 20, 'Isabella Rodriguez', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 'Business Consulting', 'Strategic business consulting and planning services.', 1500.00, 'per consultation', 'active', 'true', '4.6', 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400', 10),

-- Tech & Gadgets
(34, 14, 'Tech & Gadgets', 21, 'Alejandro Reyes', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Computer Repair', 'Diagnosis and repair of desktop and laptop computers.', 500.00, 'per visit', 'active', 'true', '4.7', 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=400', 18),
(35, 14, 'Tech & Gadgets', 21, 'Alejandro Reyes', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 'Phone Repair', 'Screen replacement and repair for mobile devices.', 400.00, 'per repair', 'active', 'true', '4.5', 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=400', 16),
(36, 14, 'Tech & Gadgets', 22, 'Fernando Castillo', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', 'Network Setup', 'Home and office network installation and troubleshooting.', 700.00, 'per setup', 'active', 'true', '4.8', 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=400', 12)
ON CONFLICT DO NOTHING;

-- Note: The provider IDs (1-23) in service_listings should match actual user IDs from auth.users
-- After creating test users in Supabase Auth, update the provider column with their actual UUIDs
-- You can get user IDs from: SELECT id, email FROM auth.users;

-- Insert Sample Bookings
-- Note: user_id and provider_id reference actual UUIDs from profiles table
-- Client UUID: 3ea054ef-fe0b-451e-bacc-042c47e986c9
-- Pro UUID: e1c72ed0-dd68-462b-a80f-2fe646653f78

INSERT INTO bookings (id, user_id, service_listing_id, provider_id, booking_date, booking_time, notes, status, total_price, created_at, updated_at) VALUES
-- Completed bookings
('00000000-0000-0000-0000-000000000001', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 1, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-01-15', '09:00 AM', 'Please bring your own tools.', 'completed', 500.00, '2024-01-10 10:00:00', '2024-01-15 12:00:00'),
('00000000-0000-0000-0000-000000000002', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 4, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-01-20', '02:00 PM', 'Need deep cleaning for 3-bedroom house.', 'completed', 800.00, '2024-01-15 14:00:00', '2024-01-20 05:00:00'),
('00000000-0000-0000-0000-000000000003', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 7, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-02-05', '10:00 AM', 'Kitchen sink is leaking badly.', 'completed', 450.00, '2024-02-01 09:00:00', '2024-02-05 11:30:00'),

-- Confirmed bookings
('00000000-0000-0000-0000-000000000004', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 10, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-12-20', '09:00 AM', 'Need wiring for new room addition.', 'confirmed', 550.00, '2024-12-15 10:00:00', '2024-12-15 10:00:00'),
('00000000-0000-0000-0000-000000000005', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 13, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-12-22', '01:00 PM', 'Refrigerator not cooling properly.', 'confirmed', 500.00, '2024-12-18 15:00:00', '2024-12-18 15:00:00'),

-- Pending bookings
('00000000-0000-0000-0000-000000000006', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 16, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-12-25', '08:00 AM', 'Custom bookshelf for home office.', 'pending', 2000.00, '2024-12-19 11:00:00', '2024-12-19 11:00:00'),
('00000000-0000-0000-0000-000000000007', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 19, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-12-28', '10:00 AM', 'Full lawn care and garden maintenance.', 'pending', 400.00, '2024-12-20 09:00:00', '2024-12-20 09:00:00'),

-- In-progress bookings
('00000000-0000-0000-0000-000000000008', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 22, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-12-18', '09:00 AM', 'Local move within the city.', 'in_progress', 2500.00, '2024-12-10 08:00:00', '2024-12-18 09:00:00'),

-- Cancelled bookings
('00000000-0000-0000-0000-000000000009', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 25, 'e1c72ed0-dd68-462b-a80f-2fe646653f78', '2024-12-10', '03:00 PM', 'Hair styling appointment.', 'cancelled', 350.00, '2024-12-05 14:00:00', '2024-12-09 10:00:00')
ON CONFLICT DO NOTHING;

-- Insert Sample Reviews
-- Note: user_id references actual UUID from profiles table
-- Client UUID: 3ea054ef-fe0b-451e-bacc-042c47e986c9

INSERT INTO reviews (id, user_id, service_listing_id, rating, comment, created_at, updated_at) VALUES
-- 5-star reviews
('00000000-0000-0000-0000-000000000010', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 1, 5, 'Excellent service! Very professional and completed the job on time.', '2024-01-15 13:00:00', '2024-01-15 13:00:00'),
('00000000-0000-0000-0000-000000000011', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 4, 5, 'My house has never been cleaner! Highly recommend Maria.', '2024-01-20 18:00:00', '2024-01-20 18:00:00'),
('00000000-0000-0000-0000-000000000012', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 7, 5, 'Fixed the leak quickly and professionally. Great work!', '2024-02-05 12:00:00', '2024-02-05 12:00:00'),
('00000000-0000-0000-0000-000000000013', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 13, 5, 'Expert diagnosis and repair. Refrigerator works perfectly now.', '2024-12-18 16:00:00', '2024-12-18 16:00:00'),
('00000000-0000-0000-0000-000000000014', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 16, 5, 'Beautiful custom furniture! Exactly what I wanted.', '2024-12-15 14:00:00', '2024-12-15 14:00:00'),

-- 4-star reviews
('00000000-0000-0000-0000-000000000015', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 10, 4, 'Good electrical work. Slight delay but quality was excellent.', '2024-12-17 11:00:00', '2024-12-17 11:00:00'),
('00000000-0000-0000-0000-000000000016', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 19, 4, 'Lawn looks great. Will definitely book again.', '2024-12-10 15:00:00', '2024-12-10 15:00:00'),
('00000000-0000-0000-0000-000000000017', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 22, 4, 'Smooth moving experience. Team was professional.', '2024-12-18 17:00:00', '2024-12-18 17:00:00'),

-- 3-star reviews
('00000000-0000-0000-0000-000000000018', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 25, 3, 'Service was okay but arrived a bit late.', '2024-12-09 16:00:00', '2024-12-09 16:00:00'),
('00000000-0000-0000-0000-000000000019', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 28, 3, 'Average grooming service. Could be more detailed.', '2024-12-12 13:00:00', '2024-12-12 13:00:00')
ON CONFLICT DO NOTHING;

-- Insert Sample Notifications
-- Note: user_id references actual UUID from profiles table
-- Client UUID: 3ea054ef-fe0b-451e-bacc-042c47e986c9

INSERT INTO notifications (id, user_id, title, body, type, is_read, image_url, action_url, metadata, created_at) VALUES
-- Booking notifications
('00000000-0000-0000-0000-000000000020', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Booking Confirmed', 'Your booking for "General Home Maintenance" has been confirmed for Dec 20, 2024 at 09:00 AM.', 'booking', true, 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=100', '/services', '{"booking_id": "00000000-0000-0000-0000-000000000004"}', '2024-12-15 10:30:00'),
('00000000-0000-0000-0000-000000000021', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Booking Pending', 'Your booking for "Custom Furniture" is awaiting provider confirmation.', 'booking', false, 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=100', '/services', '{"booking_id": "00000000-0000-0000-0000-000000000006"}', '2024-12-19 11:30:00'),
('00000000-0000-0000-0000-000000000022', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Booking In Progress', 'Your booking for "Local Moving" is now in progress.', 'booking', false, 'https://images.unsplash.com/photo-1600518464441-9154a4dea21b?w=100', '/services', '{"booking_id": "00000000-0000-0000-0000-000000000008"}', '2024-12-18 09:30:00'),
('00000000-0000-0000-0000-000000000023', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Booking Completed', 'Your booking for "Deep House Cleaning" has been completed. Please leave a review!', 'booking', true, 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=100', '/services', '{"booking_id": "00000000-0000-0000-0000-000000000002"}', '2024-01-20 17:00:00'),
('00000000-0000-0000-0000-000000000024', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Booking Cancelled', 'Your booking for "Hair Styling" has been cancelled.', 'booking', true, 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=100', '/services', '{"booking_id": "00000000-0000-0000-0000-000000000009"}', '2024-12-09 10:00:00'),

-- Review notifications
('00000000-0000-0000-0000-000000000025', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'New Review Received', 'You received a 5-star review for "General Home Maintenance"!', 'review', true, 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=100', '/services', '{"review_id": "00000000-0000-0000-0000-000000000010"}', '2024-01-15 13:30:00'),
('00000000-0000-0000-0000-000000000026', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'New Review Received', 'You received a 4-star review for "Wiring Installation".', 'review', false, 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=100', '/services', '{"review_id": "00000000-0000-0000-0000-000000000015"}', '2024-12-17 11:30:00'),

-- System notifications
('00000000-0000-0000-0000-000000000027', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Welcome to SerbisyoHub PH', 'Thank you for joining! Start exploring services in your area.', 'system', true, 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=100', '/home', '{}', '2024-12-01 09:00:00'),
('00000000-0000-0000-0000-000000000028', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Profile Verification', 'Complete your profile verification to unlock provider features.', 'system', false, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', '/profile', '{}', '2024-12-05 10:00:00'),

-- Promotion notifications
('00000000-0000-0000-0000-000000000029', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'Special Offer', 'Get 20% off on your first cleaning service! Use code: CLEAN20', 'promotion', false, 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=100', '/services', '{"code": "CLEAN20", "discount": 20}', '2024-12-15 08:00:00'),
('00000000-0000-0000-0000-000000000030', '3ea054ef-fe0b-451e-bacc-042c47e986c9', 'New Services Available', 'Check out our new Tech Support services for computer and phone repairs.', 'promotion', true, 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=400', '/services', '{}', '2024-12-10 12:00:00')
ON CONFLICT DO NOTHING;

-- Note: Replace 'e1c72ed0-dd68-462b-a80f-2fe646653f78' and similar placeholder UUIDs
-- with actual user UUIDs from the profiles table after creating test users
-- You can get user IDs from: SELECT id, email FROM profiles;

-- UPDATE EXISTING DATA TO USE LOCAL ASSETS
-- Run this if you already inserted data with Unsplash URLs
UPDATE categories SET image_url = 'assets/images/15.png' WHERE name = 'Home Improvement';
UPDATE categories SET image_url = 'assets/images/14.png' WHERE name = 'Safety & Security';
UPDATE categories SET image_url = 'assets/images/vnimc_1.png' WHERE name = 'Electrical Services';
UPDATE categories SET image_url = 'assets/images/49svh_2.png' WHERE name = 'Cleaning Services';
UPDATE categories SET image_url = 'assets/images/3a9k2_3.png' WHERE name = 'Landscape Design';
UPDATE categories SET image_url = 'assets/images/fijek_4.png' WHERE name = 'Handyman Services';
UPDATE categories SET image_url = 'assets/images/2emqy_5.png' WHERE name = 'Painting & Decorating';
UPDATE categories SET image_url = 'assets/images/dfjsb_6.png' WHERE name = 'Home Pest Protection';
UPDATE categories SET image_url = 'assets/images/x7hc1_7.png' WHERE name = 'HVAC Services';
UPDATE categories SET image_url = 'assets/images/k7eg7_8.png' WHERE name = 'Plumbing Services';
UPDATE categories SET image_url = 'assets/images/nswz3_9.png' WHERE name = 'Auto & Transport';
UPDATE categories SET image_url = 'assets/images/10.png' WHERE name = 'Wellness Spa Services';
UPDATE categories SET image_url = 'assets/images/11.png' WHERE name = 'Business Services';
UPDATE categories SET image_url = 'assets/images/13.png' WHERE name = 'Tech & Gadgets';
