-- Dev seed data — do not run in production.
-- Event: UNCCD COP17 · Ulaanbaatar · Aug 17–28, 2026 (Asia/Ulaanbaatar +08).

insert into public.sponsors (name, tier, booth) values
  ('GreenTech Mongolia', 'platinum', 'G-14'),
  ('Solar Corp Germany', 'gold', 'B-22'),
  ('UNDP Mongolia', 'silver', 'A-05')
on conflict do nothing;

insert into public.faq (question_mn, question_en, answer_mn, answer_en, ordering) values
  ('Blue Zone нэвтрэх эрхийг хэрхэн авах вэ?',
   'How do I get Blue Zone access?',
   'Party delegate, accredited observer, press-д зориулсан. 2026.05.01-нээс бүртгэл эхэлнэ. Mobile → Profile → Accreditation request.',
   'For Party delegates, accredited observers and press. Registration opens May 1, 2026. Mobile → Profile → Accreditation request.', 1),
  ('Green Zone хаанаа байрлах вэ?',
   'Where is the Green Zone?',
   'Үзэсгэлэнгийн төвд (Exhibition Center). Үзэгчид, CSO, оюутан, олон нийтэд нээлттэй.',
   'At the Exhibition Center. Open to public, CSOs and students.', 2),
  ('Wallet-ийг хэрхэн цэнэглэх вэ?',
   'How do I top up my wallet?',
   'Services → Wallet → Цэнэглэх → QPay эсвэл карт.',
   'Services → Wallet → Top up → QPay or card.', 3),
  ('Үндсэн venue хаана байна?',
   'What are the main venues?',
   'Plenary-г Төрийн ордонд, technical summit-уудыг Үзэсгэлэнгийн төвд. Хоёулаа хотын төвөөс 15 мин радиуст.',
   'Plenaries at the State Palace, technical summits at the Exhibition Center. Both within 15 minutes of city centre.', 4)
on conflict do nothing;

-- Sample sessions (Day 1 & Day 2 of the event).
insert into public.sessions (title_mn, title_en, hall, starts_at, ends_at, capacity, access_tiers, description_mn, description_en) values
  ('Нээлтийн ёслол', 'Opening Ceremony',
   'Төрийн ордон · Plenary Hall', '2026-08-17 09:00+08', '2026-08-17 11:00+08',
   800, array['green','blue','vip','exhibitor','press']::user_tier[],
   'COP17 албан ёсны нээлт. Монгол Улсын Ерөнхийлөгч, UNCCD Executive Secretary үг хэлнэ.',
   'Official COP17 opening. Remarks by the President of Mongolia and the UNCCD Executive Secretary.'),
  ('Land Degradation Panel', 'Land Degradation Panel',
   'Үзэсгэлэнгийн төв · Hall A', '2026-08-17 14:00+08', '2026-08-17 16:00+08',
   150, array['green','blue','vip']::user_tier[],
   'Газрын доройтлыг сэргээх арга зам, Монголын туршлага (Green Wall, White Gold, Blue Horse).',
   'Land degradation recovery strategies — Mongolia case studies (Green Wall, White Gold, Blue Horse).'),
  ('Mongolia Desert Strategy', 'Mongolia Desert Strategy',
   'Үзэсгэлэнгийн төв · Hall B', '2026-08-18 10:00+08', '2026-08-18 12:00+08',
   120, array['green','blue','vip']::user_tier[],
   'Говь цөлжилтийн асуудал, төрөөс хэрэгжүүлж буй бодлого.',
   'Gobi desertification issues and state policy response.'),
  ('VIP Welcome Reception', 'VIP Welcome Reception',
   'Төрийн ордон · VIP Lounge', '2026-08-17 19:00+08', '2026-08-17 22:00+08',
   80, array['vip']::user_tier[],
   'Зочдын хүндэтгэлийн оройн зоог — зөвхөн урилгаар.',
   'Welcome reception dinner — by invitation only.')
on conflict do nothing;

insert into public.products (kind, vendor, name_mn, name_en, price, active) values
  ('food', 'Mongolian BBQ', 'Хуушуур Combo', 'Khuushuur Combo', 12500, true),
  ('food', 'Cafe UB', 'Кофе', 'Coffee', 5000, true),
  ('esim', 'MobiCom', '5G · 7 хоног · Хязгааргүй', '5G · 7 days · Unlimited', 25000, true),
  ('esim', 'Unitel', '4G · 7 хоног · 10GB', '4G · 7 days · 10GB', 18000, true),
  ('shop', 'COP17 Shop', 'COP17 албан ёсны футболка', 'Official COP17 T-shirt', 35000, true)
on conflict do nothing;

insert into public.announcements (title_mn, title_en, body_mn, body_en, severity, published_at) values
  ('Нээлтийн ёслол — 2026.08.17', 'Opening Ceremony — Aug 17, 2026',
   'Төрийн ордон, 09:00 цагт. Бүх оролцогчид 08:00-д security check-д ирэх шаардлагатай.',
   'State Palace, 09:00. All participants must arrive for security check by 08:00.',
   'info', now())
on conflict do nothing;
