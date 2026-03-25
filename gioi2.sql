-- Tạo View tổng hợp doanh thu theo khu vực:
create view v_revenue_by_region as
select c.region, sum(o.total_amount) as total_revenue
from customer c
join orders o on c.customer_id = o.customer_id
group by c.region;
--Viết truy vấn xem top 3 khu vực có doanh thu cao nhất
select region, total_revenue
from v_revenue_by_region
order by total_revenue desc
limit 3;
-- Tạo View chi tiết đơn hàng có thể cập nhật được:
create view v_updatable_orders as
select order_id, customer_id, total_amount, order_date, status
from orders
where status = 'pending'
with check option;

-- Cập nhật status của đơn hàng và kiểm tra vi phạm điều kiện WITH CHECK OPTION
update v_updatable_orders
set status = 'shipped'
where order_id = 1;

--Tạo View phức hợp: Khu vực có doanh thu lớn hơn trung bình toàn quốc
create view v_revenue_above_avg as
select region, total_revenue
from v_revenue_by_region
where total_revenue > (
    select avg(total_revenue) 
    from v_revenue_by_region
);