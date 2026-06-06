--create dim_customer view
create view gold.dim_customer as
select 
	row_number()over(order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	ci.cst_marital_Status as marital_Status,
	ca.cntry as country,
	case when ci.cst_gender != 'n/a' then ci.cst_gender
		else coalesce (cz.gen,'n/a') 
	end as gender,
	ci.cst_create_date as create_date,
	cz.bdate as birth_Date
	
from silver.crm_cust_info ci
	left join silver.erp_cust_az12 cz
	on ci.cst_key = cz.cid
	left join silver.erp_loc_a101 ca
	on ci.cst_key = ca.cid
----------------------------------------------------------------------
----create dim_product view
create view gold.dim_product as
select 
	row_number()over(order by prd_key ,prd_start_dt ) as product_key,
	p.prd_id as product_id,
	p.prd_key as product_number,
	p.prd_nm as product_name,
	p.cat_id as catogry_id,
	px.cat as catogry,
	px.subcat as sub_catogry,
	px.maintenance,
	p.prd_cost as cost,
	p.prd_line as product_line,
	p.prd_start_dt as product_Start_date
from silver.crm_prd_info p
	left join silver.erp_px_cat_g1v2 px
	on p.cat_id = px.id
where p.prd_end_dt is null -- current data

-------------------------------------------------------------------
--create fact_sales view
create view gold.fact_sales as
select 
	s.sls_ord_num as order_number,
	p.product_key,
	c.customer_key,
	s.sls_order_dt as order_Date,
	s.sls_ship_dt as ship_date,
	s.sls_due_dt as due_date,
	s.sls_sales as sales,
	s.sls_quantity as quantity,
	s.sls_price as price

from silver.crm_sales_details  s 
	left join gold.dim_product p
	on s.sls_prd_key= p.product_number
	left join gold.dim_customer c
	on s.sls_cust_id =c.customer_id
