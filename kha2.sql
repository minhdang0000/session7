-- Câu 1
create view v_order_summary as
select 
    c.full_name,
    o.total_amount,
    o.order_date
from customer c
join orders o on c.customer_id = o.customer_id;
-- Câu 2
select * from v_order_summary;
-- Tạo 1 view lấy về thông tin của tất cả các đơn hàng với điều kiện total_amount ≥ 1 triệu .
create view v_high_value_orders as
select 
    c.full_name,
    o.order_id,
    o.total_amount,
    o.order_date
from customer c
join orders o on c.customer_id = o.customer_id
where o.total_amount >= 1000000;
-- Cập nhật 1 bản ghi trong view
update v_high_value_orders
set total_amount = 1500000
where order_id = 5;
-- Tạo một View thứ hai v_monthly_sales thống kê tổng doanh thu mỗi tháng
create view v_monthly_sales as
select 
    date_trunc('month', order_date) as month,
    sum(total_amount) as total_revenue,
    count(*) as number_of_orders
from orders
group by date_trunc('month', order_date)
order by month;
-- Thử DROP View
drop view v_order_summary;
drop view v_high_value_orders;
drop view v_monthly_sales;
-- sự khác biệt giữa DROP VIEW và DROP MATERIALIZED VIEW trong PostgreSQL
--drop view chỉ dùng cho view thông thường 
--drop materialized view → chỉ dùng cho materialized view (view vật lý hóa, lưu dữ liệu thật).