-- Dev seed data — do not run in production
insert into public.sponsors (name, tier, booth) values
  ('GreenTech Mongolia', 'platinum', 'G-14'),
  ('Solar Corp Germany', 'gold', 'B-22');

insert into public.faq (question_mn, question_en, answer_mn, answer_en, ordering) values
  ('Blue Zone нэвтрэх эрхийг хэрхэн авах вэ?',
   'How do I get Blue Zone access?',
   'Зохион байгуулагч admin таны tier-ийг Blue Zone болгож тохируулна.',
   'An organizer admin configures your tier to Blue Zone.', 1),
  ('Wallet-ийг хэрхэн цэнэглэх вэ?',
   'How do I top up my wallet?',
   'Services → Wallet → Цэнэглэх → QPay эсвэл карт.',
   'Services → Wallet → Top up → QPay or card.', 2);
