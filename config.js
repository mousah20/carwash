// ═══════════════════════════════════════════════════════════════
//  إدارة مغاسل — ملف الإعدادات
//  ✏️  عدّل هذا الملف فقط عند إعداد نسخة لعميل جديد
// ═══════════════════════════════════════════════════════════════
const APP_CONFIG = {
  APP_NAME:        'إدارة مغاسل',
  APP_NAME_EN:     'Admin',
  APP_TAGLINE:     'خدمة غسيل متميزة',
  SUPABASE_URL:    'https://fhhfhgczuvtikxdgstoh.supabase.co',
  SUPABASE_KEY:    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoaGZoZ2N6dXZ0aWt4ZGdzdG9oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwNDE0NTYsImV4cCI6MjA4OTYxNzQ1Nn0.9qFTalj2D6cGLIMYt_19O8VJHp4A19CufMieJdgVG6o',
  PACKAGES: {
    basic: {
      name_ar:  'الباقة الأساسية',
      name_en:  'Basic',
      icon:     '🥉',
      color:    '#cd7f32',
      duration: 50,
      prices:   { small: 50, medium: 55, large: 65 }
    },
    gold: {
      name_ar:  'الباقة الفضية',
      name_en:  'Silver',
      icon:     '�',
      color:    '#d4af37',
      duration: 110,
      prices:   { small: 160, medium: 180, large: 190 }
    },
    silver: {
      name_ar:  'الباقة الذهبية',
      name_en:  'Gold',
      icon:     '🥇',
      color:    '#a8a9ad',
      duration: 110,
      prices:   { small: 410, medium: 430, large: 450 }
    }
  },
  COLORS: {
    primary:      '#d4af37',
    primary2:     '#c9a227',
    primary_glow: 'rgba(212,175,55,0.12)',
    bg_dark:      '#07090f',
    bg_dark2:     '#0d1018',
    bg_dark3:     '#12151e',
  },
  MIN_BOOKING_HOURS:  2,
  CANCEL_HOURS:       1,
  RESEND_API_KEY:  '',
  FROM_EMAIL:      '',
  ADMIN_EMAIL:     '',
  LIMITS: {
    max_workers:     10,
    max_admins:      3,
    max_supervisors: 5,
  },
  FEATURES: {
    coupons:      true,
    ratings:      true,
    whatsapp:     true,
    daily_report: true,
    reports:      true,
  }
};
