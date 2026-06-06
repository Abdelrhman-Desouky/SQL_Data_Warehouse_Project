create or alter procedure silver.load_silver as
begin
	--- load data into silver.crm_cust_info
	truncate table silver.crm_cust_info;
	insert into silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_Status,
	cst_gender,
	cst_create_date

	)
	select 
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname ,
	trim(cst_lastname) as cst_lastname,

	case upper(trim(cst_marital_Status)) 
		when 'S'then 'Single'
		when 'M'then 'Married'
		else 'n/a'
	end cst_marital_Status,
	case when upper(trim(cst_gender))='M'then 'Male'
		when upper(trim(cst_gender))='F'then 'Female'
		else 'n/a'
	end cst_gender,
	cst_create_date
	from (
	select *, 
		row_number()over (partition by cst_id order by cst_create_Date desc) as flag_list
		from bronze.crm_cust_info
		where cst_id is not null
	)t

	where flag_list = 1

	---- load data into silver.crm_prd_info 
	truncate table silver.crm_prd_info ;
	insert into silver.crm_prd_info (
		prd_id ,
		cat_id ,
		prd_key ,
		prd_nm ,
		prd_cost ,
		prd_line ,
		prd_start_dt ,
		prd_end_dt
	)
	select 
	prd_id,
	replace(substring(prd_key,1,5),'-','_') as cat_id,
	substring(prd_key,7,len(prd_key)) as prd_id,
	prd_nm,
	isnull(prd_cost,0)as prd_cost,
	case upper(trim(prd_line))
		when 'S'then 'Other sales'
		when 'M'then 'Mountain'
		when 'R'then 'Road'
		when 'T'then 'Touring'
		else 'n/a'
	end prd_line,

	prd_start_dt,
	dateadd (day, -1 , lead(prd_start_dt) over (partition by prd_key order by prd_start_dt))  as prd_end_dt

	from bronze.crm_prd_info

	---- load data into silver.crm_sales_details
	truncate table silver.crm_sales_details;
	insert into silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when sls_order_dt =0 or len(sls_order_dt) !=8 then null
		else cast(cast(sls_order_dt as varchar(50))as date)
	end	as sls_order_dt,
	case when sls_ship_dt =0 or len(sls_ship_dt) !=8 then null
		else cast(cast(sls_ship_dt as varchar(50))as date) 
	end as sls_ship_dt,

	case when sls_due_dt =0 or len(sls_due_dt) !=8 then null
		else cast(cast(sls_due_dt as varchar(50))as date)
	end as sls_due_dt,

	CASE
		WHEN sls_sales <= 0
			 OR sls_sales IS NULL
			 OR sls_sales != sls_quantity * sls_price
		THEN sls_quantity * sls_price
		ELSE sls_sales
	END AS sls_sales,

	CASE
		WHEN sls_quantity <= 0
			 OR sls_quantity IS NULL
			 OR sls_quantity <> sls_sales / NULLIF(sls_price, 0)
		THEN sls_sales / NULLIF(sls_price, 0)
		ELSE sls_quantity
	END AS sls_quantity,

	CASE
		WHEN sls_price <= 0
			 OR sls_price IS NULL
			 OR sls_price <> sls_sales / NULLIF(sls_quantity, 0)
		THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
	from bronze.crm_sales_details


	---- load data into silver.erp_cust_az12
	truncate table silver.erp_cust_az12;
	insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen)
	select 
	case when cid like 'NAS%' then substring (cid,4,len(cid))
		else cid
	end as cid,
	case when bdate > getdate() then null
		else bdate
	end as bdate,
	case
		when trim(gen) in ('F' ,'Female' ) then 'Female'
		when trim(gen)in ('M' , 'Male')  then 'Male'
		else 'n/a'
	end as gen
	from bronze.erp_cust_az12


	---- load data into silver.erp_loc_a101
	truncate table silver.erp_loc_a101;
	insert into silver.erp_loc_a101 (cid,cntry)
	select  
	replace (cid,'-','')cid,
	case when trim(cntry) is null or cntry= '' then 'n/a'
		when trim(cntry) = 'DE' then 'Germany'
		when trim(cntry) in ('US','USA') then 'United States'
		else trim(cntry)
	end as cntry
	from bronze.erp_loc_a101

	---- load data into silver.erp_px_cat_g1v2
	truncate table silver.erp_px_cat_g1v2;
	insert into silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
	select * from bronze.erp_px_cat_g1v2
end
