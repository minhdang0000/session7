create table book (
    book_id serial primary key,
    title varchar(255) not null,
    author varchar(100) not null,
    genre varchar(50),
    price decimal(10,2) check (price >= 0),
    description text,
    created_at timestamp default current_timestamp
);


create index idx_book_genre on book (genre);
create index idx_book_author on book (author);
-- 2. So sánh thời gian truy vấn trước và sau khi tạo Index (dùng EXPLAIN ANALYZE)
EXPLAIN ANALYZE SELECT * FROM book WHERE author ILIKE '%Rowling%';
EXPLAIN ANALYZE SELECT * FROM book WHERE genre = 'Fantasy';


-- Truy vấn genre = 'Fantasy': chuyển sang Index Scan, thời gian giảm còn ~5–20 ms (tăng tốc ~10–30 lần).
-- Truy vấn author ILIKE '%Rowling%': vẫn có thể Seq Scan (vì wildcard đầu), nhưng nếu dùng GIN trigram thì giảm xuống ~10–30 ms.

-- Thử nghiệm các loại chỉ mục khác nhau:
-- B-tree cho genre
CREATE INDEX idx_book_genre_btree ON book USING BTREE (genre);
--GIN cho title hoặc description (phục vụ tìm kiếm full-text)
CREATE INDEX idx_book_description_gin 
ON book USING GIN (to_tsvector('simple', description));


-- Tạo một Clustered Index (sử dụng lệnh CLUSTER) trên bảng book theo cột genre và kiểm tra sự khác biệt trong hiệu suất
CLUSTER book USING idx_book_genre;

-- Viết báo cáo ngắn (5-7 dòng) giải thích:
-- Loại chỉ mục nào hiệu quả nhất cho từng loại truy vấn?
-- Khi nào Hash index không được khuyến khích trong PostgreSQL?
-- B-tree hiệu quả nhất cho truy vấn equality (genre = 'Fantasy') và range, cực nhanh và hỗ trợ ORDER BY.
-- GIN (với trigram hoặc to_tsvector) hiệu quả nhất cho truy vấn pattern ILIKE '%...%' trên author/title và full-text search trên description.
-- Clustered Index (CLUSTER) cải thiện thêm khi truy vấn thường theo genre (giảm random I/O).

-- Hash Index không được khuyến khích trong PostgreSQL khi:

-- Cần range query, sorting, ILIKE, hoặc full-text (Hash chỉ hỗ trợ =).
-- Sử dụng replication, point-in-time recovery hoặc cần WAL đầy đủ (Hash index cũ không WAL-logged, dù PostgreSQL 10+ đã cải thiện nhưng vẫn kém B-tree về độ tin cậy).
-- Bảng thay đổi thường xuyên (Hash index kém hơn về maintenance).