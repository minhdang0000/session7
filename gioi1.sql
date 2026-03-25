--Tối ưu hóa truy vấn tìm kiếm bài đăng công khai theo từ khóa:
create index idx_post_content_lower on post using btree (lower(content));

explain analyze
select * from post
where lower(content) like '%k%';

-- Tối ưu hóa truy vấn lọc bài đăng theo thẻ (tags):
create index idx_post_tags_gin on post using gin (tags);

explain analyze
select * from post
where tags @> array['game']::text[];
--Tối ưu hóa truy vấn tìm bài đăng mới trong 7 ngày gần nhất:
-- Tạo Partial Index cho bài viết công khai gần đây:
create index idx_post_recent_public on post (created_at)
where is_public = true
and created_at > now() - interval '7 days';

--Kiểm tra hiệu suất với truy vấn:
explain analyze
select * from post
where is_public = true
and created_at >= now() - interval '7 days'
order by created_at desc;

-- Phân tích chỉ mục tổng hợp (Composite Index):
create index idx_post_user_created on post (user_id, created_at desc);

explain analyze
select * from post
where user_id = 42
order by created_at desc
limit 20;