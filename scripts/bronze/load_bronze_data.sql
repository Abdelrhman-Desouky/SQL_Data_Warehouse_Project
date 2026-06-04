create or alter procedure bronze.load_bronze as
begin
declare @start_time datetime , @end_time datetime
 
	set @start_time = GETDATE();
truncate table  bronze.crm_cust_info
bulk insert bronze.crm_cust_info
from 'Y:\data eng\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
with(
	firstrow=2,
	fieldterminator =',',
	tablock
);
	
truncate table  bronze.crm_prd_info
bulk insert bronze.crm_prd_info
from 'Y:\data eng\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
with(
	firstrow=2,
	fieldterminator =',',
	tablock
);


truncate table  bronze.crm_sales_details
bulk insert bronze.crm_sales_details
from 'Y:\data eng\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
with(
	firstrow=2,
	fieldterminator =',',
	tablock
);
	
truncate table  bronze.erp_cust_az12
bulk insert bronze.erp_cust_az12
from 'Y:\data eng\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
with(
	firstrow=2,
	fieldterminator =',',
	tablock
);
	
truncate table  bronze.erp_loc_a101
bulk insert bronze.erp_loc_a101
from 'Y:\data eng\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
with(
	firstrow=2,
	fieldterminator =',',
	tablock
)
truncate table  bronze.erp_px_cat_g1v2
bulk insert bronze.erp_px_cat_g1v2
from 'Y:\data eng\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
with(
	firstrow=2,
	fieldterminator =',',
	tablock
);
set @end_time= GETDATE();
	print '>> .. total load durction :'+ cast( datediff(second , @start_time , @end_time) as varchar) + 'second';
	print '>>---------------------------------------------------------';
	
end
