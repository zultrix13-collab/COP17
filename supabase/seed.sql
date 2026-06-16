-- Dev seed data — do not run in production.
-- Event: 18th SIOP Asia Congress 2026 · Ulaanbaatar · June 25–28, 2026 (Asia/Ulaanbaatar +08).
-- Venue: Corporate Convention Center Hotel, Ulaanbaatar.

insert into public.sponsors (name, tier, booth) values
  ('St. Jude Global', 'platinum', 'A-01'),
  ('Roche Mongolia', 'gold', 'B-12'),
  ('Mongolian National Cancer Center', 'silver', 'C-04')
on conflict do nothing;

insert into public.faq (question_mn, question_en, answer_mn, answer_en, ordering) values
  ('Congress-д хэрхэн бүртгүүлэх вэ?',
   'How do I register for the congress?',
   'Бүртгэлийг alban ёсны вэбсайт (siopasia-congress.org) дээрээс хийнэ. Бүртгэлтэй имэйл хаягаараа аппликейшнд нэвтэрнэ.',
   'Register via the official website (siopasia-congress.org). Use your registered email address to sign in to the app.', 1),
  ('Хурлын байр хаана байрлах вэ?',
   'Where is the congress venue?',
   'Бүх scientific session, exhibition, networking арга хэмжээ Corporate Convention Center Hotel-д болно.',
   'All scientific sessions, the exhibition and networking events take place at the Corporate Convention Center Hotel.', 2),
  ('Wallet-ийг хэрхэн цэнэглэх вэ?',
   'How do I top up my wallet?',
   'Services → Wallet → Цэнэглэх → QPay эсвэл карт.',
   'Services → Wallet → Top up → QPay or card.', 3),
  ('CME/CPD кредит хэрхэн авах вэ?',
   'How do I claim CME/CPD credits?',
   'My Agenda хэсэгт ирц бүртгэгдсэн session-уудаар хурлын дараа цахим гэрчилгээ илгээгдэнэ.',
   'A digital certificate covering your attended sessions (from My Agenda) will be emailed after the congress.', 4)
on conflict do nothing;

-- Sample sessions (Day 1 & Day 2 of the congress).
insert into public.sessions (title_mn, title_en, hall, starts_at, ends_at, capacity, access_tiers, description_mn, description_en) values
  ('Нээлтийн ёслол', 'Opening Ceremony',
   'Corporate Convention Center Hotel · Grand Ballroom', '2026-06-25 09:00+08', '2026-06-25 10:30+08',
   800, array['green','blue','vip','exhibitor','press']::user_tier[],
   '18 дугаар SIOP Asia Congress-ийн нээлт. "Together for Change: Science, Compassion, and Hope for Every Child" уриатай.',
   'Official opening of the 18th SIOP Asia Congress, themed "Together for Change: Science, Compassion, and Hope for Every Child".'),
  ('Leukemia Across Asia: Shared Protocols, Local Realities', 'Leukemia Across Asia: Shared Protocols, Local Realities',
   'Corporate Convention Center Hotel · Hall A', '2026-06-25 14:00+08', '2026-06-25 16:00+08',
   200, array['green','blue','vip']::user_tier[],
   'Хүүхдийн leukemia эмчилгээний эрэгтэй протокол, Азийн орнуудын бодит туршлага.',
   'Shared treatment protocols and real-world implementation challenges for paediatric leukemia across Asian centres.'),
  ('Mongolia Paediatric Oncology: Building Capacity', 'Mongolia Paediatric Oncology: Building Capacity',
   'Corporate Convention Center Hotel · Hall B', '2026-06-26 10:00+08', '2026-06-26 12:00+08',
   150, array['green','blue','vip']::user_tier[],
   'Монгол улсын хүүхдийн онкологийн тусламж үйлчилгээний хүчин чадлыг бэхжүүлэх чиглэл, түншлэлийн боломжууд.',
   'Strengthening paediatric oncology care capacity in Mongolia and emerging partnership opportunities.'),
  ('VIP Welcome Reception', 'VIP Welcome Reception',
   'Corporate Convention Center Hotel · VIP Lounge', '2026-06-25 19:00+08', '2026-06-25 22:00+08',
   80, array['vip']::user_tier[],
   'Зочдын хүндэтгэлийн оройн зоог — зөвхөн урилгаар.',
   'Welcome reception dinner — by invitation only.')
on conflict do nothing;

insert into public.products (kind, vendor, name_mn, name_en, price, active) values
  ('food', 'Mongolian BBQ', 'Хуушуур Combo', 'Khuushuur Combo', 12500, true),
  ('food', 'Cafe UB', 'Кофе', 'Coffee', 5000, true),
  ('esim', 'MobiCom', '5G · 7 хоног · Хязгааргүй', '5G · 7 days · Unlimited', 25000, true),
  ('esim', 'Unitel', '4G · 7 хоног · 10GB', '4G · 7 days · 10GB', 18000, true),
  ('shop', 'SIOP Asia 2026 Shop', 'SIOP Asia 2026 албан ёсны футболка', 'Official SIOP Asia 2026 T-shirt', 35000, true)
on conflict do nothing;

insert into public.announcements (title_mn, title_en, body_mn, body_en, severity, published_at) values
  ('Нээлтийн ёслол — 2026.06.25', 'Opening Ceremony — June 25, 2026',
   'Corporate Convention Center Hotel, Grand Ballroom, 09:00 цагт. Бүх оролцогчид 08:00-д бүртгэлд ирэх шаардлагатай.',
   'Corporate Convention Center Hotel, Grand Ballroom, 09:00. All participants must arrive for registration by 08:00.',
   'info', now())
on conflict do nothing;
