CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'worker',
  email TEXT,
  phone TEXT,
  avatar TEXT,
  color TEXT DEFAULT '#9b7ff7',
  perms JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS workers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  role TEXT DEFAULT 'worker',
  avatar TEXT,
  color TEXT DEFAULT '#9b7ff7',
  is_active BOOLEAN DEFAULT true,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS appointments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_ref TEXT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  date DATE NOT NULL,
  time TEXT,
  time_label TEXT,
  status TEXT DEFAULT 'pending',
  package TEXT,
  package_id TEXT,
  clean_type TEXT,
  service_type TEXT,
  car_brand TEXT,
  car_type TEXT,
  car_size TEXT,
  car TEXT,
  car_count INT DEFAULT 1,
  price NUMERIC DEFAULT 0,
  payment_method TEXT,
  worker_id UUID REFERENCES workers(id) ON DELETE SET NULL,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  maps_url TEXT,
  address TEXT,
  notes TEXT,
  is_edited BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS available_slots (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  time TEXT NOT NULL,
  label TEXT,
  capacity INT DEFAULT 1,
  booked INT DEFAULT 0,
  slot_type TEXT DEFAULT 'basic',
  duration_minutes INT DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (date, time, slot_type)
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT
);

CREATE TABLE IF NOT EXISTS system_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT,
  action TEXT,
  details TEXT,
  by_user TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE,
  stars INT,
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS coupons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name_ar TEXT,
  name_en TEXT,
  type TEXT DEFAULT 'percent',
  value NUMERIC DEFAULT 0,
  customer_phone TEXT,
  max_uses INT,
  discount_type TEXT DEFAULT 'percent',
  discount_value NUMERIC DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  usage_limit INT,
  used_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS wa_templates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT UNIQUE NOT NULL,
  content_ar TEXT DEFAULT '',
  content_en TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS loyalty (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  phone TEXT UNIQUE NOT NULL,
  total_bookings INT DEFAULT 0,
  last_booking_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name_ar TEXT NOT NULL,
  name_en TEXT,
  price NUMERIC DEFAULT 0,
  duration_minutes INT DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(date);
CREATE INDEX IF NOT EXISTS idx_appointments_worker_id ON appointments(worker_id);
CREATE INDEX IF NOT EXISTS idx_appointments_phone ON appointments(phone);
CREATE INDEX IF NOT EXISTS idx_available_slots_date ON available_slots(date);
CREATE INDEX IF NOT EXISTS idx_workers_active ON workers(is_active);
CREATE INDEX IF NOT EXISTS idx_loyalty_phone ON loyalty(phone);

INSERT INTO users (username, password, name, role, is_active)
VALUES ('admin', '1234', 'المدير', 'admin', true)
ON CONFLICT (username) DO NOTHING;

INSERT INTO settings (key, value)
VALUES
  ('auto_confirm', 'false'),
  ('auto_distribute', 'false'),
  ('notify_email', 'false'),
  ('min_booking_hours', '2'),
  ('cancel_hours', '1'),
  ('business_name', 'إدارة مغاسل'),
  ('business_phone', ''),
  ('welcome_message', ''),
  ('wa_provider', 'greenapi'),
  ('wa_key', ''),
  ('wa_phone', ''),
  ('wa_instance', ''),
  ('wa_api_url', 'https://api.green-api.com'),
  ('app_name', 'إدارة مغاسل'),
  ('app_name_en', 'Car Wash Admin'),
  ('loyalty_threshold', '5'),
  ('loyalty_discount', '20')
ON CONFLICT (key) DO NOTHING;

INSERT INTO wa_templates (type, content_ar, content_en)
VALUES
  ('confirm', 'مرحباً {name}، تم تأكيد حجزك لدى {biz} بتاريخ {date} الساعة {time}.', 'Hello {name}, your booking at {biz} has been confirmed for {date} at {time}.'),
  ('edit', 'مرحباً {name}، تم تعديل موعد حجزك إلى {date} الساعة {time}.', 'Hello {name}, your booking has been updated to {date} at {time}.'),
  ('cancel', 'مرحباً {name}، تم إلغاء حجزك لدى {biz}.', 'Hello {name}, your booking at {biz} has been cancelled.'),
  ('done', 'شكراً {name}، تم إنهاء الخدمة. يسعدنا تقييمك: {rating_url}', 'Thank you {name}, your service is complete. Please rate us: {rating_url}'),
  ('loyalty', 'مبروك {name}، حصلت على كوبون خصم {discount}%: {code}', 'Congrats {name}, you received a {discount}% coupon: {code}')
ON CONFLICT (type) DO NOTHING;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE available_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE wa_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_write_policy ON users;
DROP POLICY IF EXISTS workers_public_policy ON workers;
DROP POLICY IF EXISTS appointments_public_policy ON appointments;
DROP POLICY IF EXISTS slots_public_policy ON available_slots;
DROP POLICY IF EXISTS settings_public_policy ON settings;
DROP POLICY IF EXISTS logs_public_policy ON system_logs;
DROP POLICY IF EXISTS ratings_public_policy ON ratings;
DROP POLICY IF EXISTS coupons_public_policy ON coupons;
DROP POLICY IF EXISTS wa_templates_public_policy ON wa_templates;
DROP POLICY IF EXISTS loyalty_public_policy ON loyalty;
DROP POLICY IF EXISTS services_public_policy ON services;

CREATE POLICY users_select_policy ON users FOR SELECT TO anon USING (is_active = true);
CREATE POLICY users_write_policy ON users FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY workers_public_policy ON workers FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY appointments_public_policy ON appointments FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY slots_public_policy ON available_slots FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY settings_public_policy ON settings FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY logs_public_policy ON system_logs FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY ratings_public_policy ON ratings FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY coupons_public_policy ON coupons FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY wa_templates_public_policy ON wa_templates FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY loyalty_public_policy ON loyalty FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY services_public_policy ON services FOR ALL TO anon USING (true) WITH CHECK (true);
