-- نظام قائمة الطعام والطلبات: انسخ هذا الملف كاملاً والصقه في Supabase > SQL Editor ثم اضغط Run
create table if not exists settings(id int primary key, name text, hours text, addr text, wa text, cur text default 'أوقية', fee numeric default 0, demo boolean default false);
create table if not exists menu_cats(k text primary key, name text not null, sort int default 0);
create table if not exists menu_items(id bigint primary key, c text, n text not null, d text default '', p numeric default 0, e text default '', ok boolean default true, sort int default 0);
create table if not exists orders(id uuid primary key default gen_random_uuid(), no text not null, items jsonb not null default '[]', fee numeric default 0, total numeric default 0, type text default 'dine', where_ text default '', name text default '', phone text default '', note text default '', status text default 'new', pay text default 'unpaid', src text default 'qr', ts timestamptz default now());
create unique index if not exists orders_no_key on orders(no);
create index if not exists orders_ts on orders(ts desc);
create table if not exists expenses(id uuid primary key default gen_random_uuid(), cat text, amt numeric default 0, note text default '', ts timestamptz default now());

alter table settings enable row level security; alter table menu_cats enable row level security; alter table menu_items enable row level security; alter table orders enable row level security; alter table expenses enable row level security;

-- الزبائن (بلا تسجيل دخول): قراءة القائمة وإرسال طلب جديد فقط
create policy "قراءة الإعدادات" on settings for select to anon, authenticated using (true);
create policy "قراءة التصنيفات" on menu_cats for select to anon, authenticated using (true);
create policy "قراءة الأصناف" on menu_items for select to anon, authenticated using (true);
create policy "الزبون يرسل طلباً" on orders for insert to anon with check (status='new' and pay='unpaid' and total>=0 and length(no)<=8);
-- المالك (بعد تسجيل الدخول): كل شيء
create policy "المالك الإعدادات" on settings for all to authenticated using (true) with check (true);
create policy "المالك التصنيفات" on menu_cats for all to authenticated using (true) with check (true);
create policy "المالك الأصناف" on menu_items for all to authenticated using (true) with check (true);
create policy "المالك الطلبات" on orders for all to authenticated using (true) with check (true);
create policy "المالك المصاريف" on expenses for all to authenticated using (true) with check (true);

-- بيانات القائمة التجريبية (يمكنك تعديلها لاحقاً من لوحة المالك)
insert into settings(id,name,hours,addr,wa,cur,fee,demo) values (1,'برد الشام','يومياً من 11 صباحاً إلى 11 مساءً','نواكشوط','22234088495','أوقية',0,true) on conflict (id) do nothing;
insert into menu_cats(k,name,sort) values
('main','الأطباق الرئيسية',0),
('start','المقبلات',1),
('sweet','الحلويات',2),
('drink','المشروبات',3)
on conflict (k) do nothing;
insert into menu_items(id,c,n,d,p,e,ok,sort) values
(1,'main','أرز بالسمك','أرز بالخضار والسمك الطازج',150,'🐟',true,0),
(2,'main','دجاج مشوي','ربع دجاجة مشوية مع الأرز والسلطة',120,'🍗',true,1),
(3,'main','لحم ضأن مشوي','قطع مشوية على الفحم مع الخبز',200,'🥩',true,2),
(4,'main','كسكس بالخضار','كسكس مع الخضار ولحم الضأن',140,'🥘',false,3),
(5,'start','شوربة عدس','شوربة ساخنة بالكمون والليمون',40,'🍲',true,4),
(6,'start','سلطة خضراء','خضار طازجة بصلصة الليمون',35,'🥗',true,5),
(7,'start','حمص','حمص بالطحينة وزيت الزيتون',45,'🧆',true,6),
(8,'sweet','كنافة','كنافة بالجبن والقطر',60,'🍮',true,7),
(9,'sweet','بقلاوة','طبقات رقيقة بالمكسرات والعسل',55,'🍯',true,8),
(10,'drink','أتاي بالنعناع','الشاي الموريتاني بثلاث كؤوس',20,'🫖',true,9),
(11,'drink','عصير ليمون بالنعناع','عصير منعش يُقدَّم بارداً',30,'🍋',true,10),
(12,'drink','زريق','حليب مخفوق مبرّد',40,'🥛',true,11)
on conflict (id) do nothing;
