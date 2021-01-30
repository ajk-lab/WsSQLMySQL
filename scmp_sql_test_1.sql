select 

Vendor_Fact_table.VENDOR,
Vendor_Fact_table.platform,
sum(CAST(Vendor_Fact_table.Sold_Impressions as float)) as Sold_Impressions,
sum(CAST(Vendor_Fact_table.est_revenue AS FLOAT)) AS est_revenue,

((sum(CAST(Vendor_Fact_table.est_revenue AS FLOAT))/ sum(CAST(Vendor_Fact_table.Sold_Impressions as float))) * 1000) as CAL_CPM

from (
  
 SELECT 
Table_1.VENDOR,
Table_1.Date as 'Date',
Table_1.Ad_request,
Table_1.Sold_Impressions,
Table_1.No_Clicks,
cast(Table_1.Ratio AS FLOAT) * CAST(Table_2.est_revenue AS FLOAT) AS est_revenue,
case when Table_1.Device = 'Mobile & Tablet' then 'Mobile Web' 
when Table_1.Device = 'Desktop' then 'Desktop'
else Table_1.Device end as 'Platform'
FROM (select 
TABLE_M.VENDOR,
TABLE_M.Date,
TABLE_M.Ad_request,
TABLE_M.Sold_Impressions,
TABLE_M.No_Clicks,
TABLE_M.est_revenue,
(CAST(TABLE_M.Sold_Impressions AS FLOAT) / CAST(TABLE_S.Impression AS FLOAT)) as Ratio,
TABLE_M.Device
from (SELECT 
'U' as VENDOR, 
date as Date ,
0 AS Ad_request,
video_impressions as Sold_Impressions,
clicks AS No_Clicks,
CAST(earnings AS FLOAT) AS est_revenue ,
device_type as Device
from vendor_u where device_type in ('Desktop','Mobile & Tablet')) AS TABLE_M
LEFT JOIN 
(select Date, sum(video_impressions) as Impression from vendor_u where device_type in ('Desktop','Mobile & Tablet') group by Date) AS TABLE_S
ON
TABLE_M.Date = TABLE_S.Date) AS Table_1
LEFT JOIN 
(SELECT * FROM (SELECT 
'U' as VENDOR, 
date as Date ,
0 AS Ad_request,
video_impressions as Sold_Impressions,
clicks AS No_Clicks,
CAST(earnings AS FLOAT) AS est_revenue ,
device_type as Device
from vendor_u where device_type = '[UNKNOWN]')) as Table_2
ON 
Table_1.DATE = Table_2.DATE
  
union ALL
  
SELECT 
'B' as 'VENDOR', 
DATE_INTERVAL as 'Date' ,
received_imps AS Ad_request,
imps as Sold_Impressions,
clicks AS No_Clicks,
revenue AS est_revenue,
CASE 
WHEN TAGS ='scmp.com_Dkt (21895)' then 'Desktop'
WHEN TAGS in ('scmp.com_Dkt (21895)','scmp.com_Mob (21917)') THEN 'Mobile Web' 
ELSE TAGS END AS 'Platform'
from vendor_b
  
union ALL
  
SELECT 
'S' as 'VENDOR', 
updated_date as 'Date' ,
requests AS Ad_request,
impressions as Sold_Impressions,
0 AS No_Clicks,
earnings AS est_revenue,
CASE 
WHEN TAG_ID in ( '482944','501047','464637','464635','467644','490370','463809','482939','482946','492924','468681','463808','467649') then 'Desktop'
WHEN TAG_ID IN ('467645','467646','463814','496179','463812','504560') THEN 'Mobile Web' 
ELSE TAG_ID END AS 'Platform'
from vendor_s
  
UNION ALL

SELECT 
'T' as 'VENDOR', 
day as Date ,
0 AS Ad_request,
publisher_billable_volume as Sold_Impressions,
click AS No_Clicks,
CAST(substring(teads_billing_usd,1,(CHARINDEX(' ',teads_billing_usd)-1)) AS float) AS est_revenue,
CASE 
WHEN placement in ('48539 - MS-inRead-Desktop-scmp.com' ,'80056 - MS-inRead-Desktop-onlyHP-scmp.com','79052 - MS-inRead-ros-cross devices-scmp.com/magazines/style','79052 - MS-inRead-Desktop-scmp.com/magazines/style','58983-SS-inBoard-Desktop-ROS-scmp.com','58988 - CP-inBoard-Desktop-ROS-scmp.com') then 'Desktop'
WHEN placement IN ('48540 - MS-inRead-Mobile-scmp.com','80266-SS-inRead-mobile-scmp.com--AMP') THEN 'Mobile Web' 
ELSE placement END AS 'Platform'
from vendor_t  
 
 ) AS Vendor_Fact_table
                   
where 
Vendor_Fact_table.vendor in ('S','U','T') and 
substr(Vendor_Fact_table.date,1,7) = '2017-10'

group by 
Vendor_Fact_table.VENDOR,
Vendor_Fact_table.platform
