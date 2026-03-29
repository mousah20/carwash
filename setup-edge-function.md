# إعداد Edge Function + Database Webhook لمشروع جديد
# ═══════════════════════════════════════════════════════

## الخطوة 1: رفع Edge Function

### الملف: `supabase/functions/booking-notify/index.ts`
الملف موجود جاهز في المشروع. ارفعه عبر Supabase CLI:

```bash
supabase functions deploy booking-notify
```

أو ارفعه يدوياً من لوحة Supabase:
- Dashboard → Edge Functions → New Function
- الاسم: `booking-notify`
- انسخ كود الملف `supabase/functions/booking-notify/index.ts`


## الخطوة 2: إعداد Environment Variables

من لوحة Supabase:
- Dashboard → Edge Functions → booking-notify → Settings

المتغيرات المطلوبة (SUPABASE_URL و SUPABASE_SERVICE_ROLE_KEY موجودين تلقائياً):

| المتغير | الوصف | مثال |
|---|---|---|
| `SUPABASE_URL` | تلقائي ✅ | — |
| `SUPABASE_SERVICE_ROLE_KEY` | تلقائي ✅ | — |
| `SITE_URL` | رابط الموقع (لرابط التقييم) | `https://yoursite.com` |


## الخطوة 3: إعداد Database Webhook (مهم جداً!)

هذا اللي يخلّي Supabase يستدعي الـ Edge Function تلقائياً لما يصير تغيير في جدول appointments.

### الطريقة 1: من لوحة Supabase (الأسهل)

1. Dashboard → Database → Webhooks
2. اضغط **Create a new webhook**
3. الإعدادات:
   - **Name:** `booking-notify-webhook`
   - **Table:** `appointments`
   - **Events:** ✅ INSERT + ✅ UPDATE
   - **Type:** Supabase Edge Functions
   - **Edge Function:** `booking-notify`
   - **HTTP Headers:** اتركها فاضية
4. اضغط **Create webhook**

### الطريقة 2: عبر SQL (للأتمتة)

شغّل هذا في SQL Editor في Supabase:

```sql
-- ═══ تفعيل pg_net للطلبات HTTP ═══
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ═══ دالة تستدعي Edge Function ═══
CREATE OR REPLACE FUNCTION notify_booking_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  edge_url TEXT;
  payload JSONB;
  service_key TEXT;
BEGIN
  -- رابط Edge Function (غيّره لكل مشروع)
  edge_url := current_setting('app.settings.supabase_url', true)
    || '/functions/v1/booking-notify';

  -- مفتاح الـ service role (غيّره لكل مشروع)
  service_key := current_setting('app.settings.service_role_key', true);

  -- بناء payload
  IF TG_OP = 'INSERT' THEN
    payload := jsonb_build_object(
      'type', 'INSERT',
      'record', row_to_json(NEW)::jsonb,
      'old_record', NULL
    );
  ELSIF TG_OP = 'UPDATE' THEN
    payload := jsonb_build_object(
      'type', 'UPDATE',
      'record', row_to_json(NEW)::jsonb,
      'old_record', row_to_json(OLD)::jsonb
    );
  END IF;

  -- إرسال الطلب (غير متزامن)
  PERFORM net.http_post(
    url := edge_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_key
    ),
    body := payload::text
  );

  RETURN NEW;
END;
$$;

-- ═══ ربط الدالة بجدول appointments ═══
DROP TRIGGER IF EXISTS trg_booking_notify ON appointments;

CREATE TRIGGER trg_booking_notify
  AFTER INSERT OR UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION notify_booking_change();
```

⚠️ ملاحظة: الطريقة 1 (من الداشبورد) أسهل وأضمن. الطريقة 2 تحتاج pg_net مفعّل + إعداد المتغيرات.


## الخطوة 4: إعدادات الواتساب في قاعدة البيانات

هذي موجودة في `setup.sql` لكن هنا نسخة مستقلة:

```sql
INSERT INTO settings (key, value)
VALUES
  ('wa_provider', 'greenapi'),
  ('wa_key', ''),
  ('wa_phone', ''),
  ('wa_instance', ''),
  ('wa_api_url', 'https://api.green-api.com'),
  ('wa_notify_new', 'true'),
  ('wa_notify_remind', 'false')
ON CONFLICT (key) DO NOTHING;
```

بعدين العميل يعبّي بيانات Green API من صفحة الإعدادات في لوحة التحكم.


## الخطوة 5: قوالب رسائل الواتساب

```sql
INSERT INTO wa_templates (type, content_ar, content_en)
VALUES
  ('confirm', 'مرحباً {name}، تم تأكيد حجزك لدى {biz} بتاريخ {date} الساعة {time}.', 'Hello {name}, your booking at {biz} has been confirmed for {date} at {time}.'),
  ('edit', 'مرحباً {name}، تم تعديل موعد حجزك إلى {date} الساعة {time}.', 'Hello {name}, your booking has been updated to {date} at {time}.'),
  ('cancel', 'مرحباً {name}، تم إلغاء حجزك لدى {biz}.', 'Hello {name}, your booking at {biz} has been cancelled.'),
  ('done', 'شكراً {name}، تم إنهاء الخدمة. يسعدنا تقييمك: {rating_url}', 'Thank you {name}, your service is complete. Please rate us: {rating_url}'),
  ('loyalty', 'مبروك {name}، حصلت على كوبون خصم {discount}%: {code}', 'Congrats {name}, you received a {discount}% coupon: {code}')
ON CONFLICT (type) DO NOTHING;
```


## ✅ قائمة مراجعة لمشروع جديد:

- [ ] رفع Edge Function `booking-notify`
- [ ] إعداد SITE_URL في Environment Variables
- [ ] إنشاء Database Webhook على جدول appointments (INSERT + UPDATE)
- [ ] التأكد من وجود إعدادات الواتساب في جدول settings
- [ ] التأكد من وجود قوالب الرسائل في جدول wa_templates
- [ ] اختبار: سوي حجز تجريبي وشيك إذا وصلت رسالة واتساب
