-- bagaimana performa penjualan 3 kuartal pertama di tahun 2026 ini, 
-- dan mengapa ada lonjakan penjualan yang terjadi tetapi tidak sebanding dengan pendapatan bersih yang SAMALARIS dapatkan?

--------------------------------------------- PROSES ANALISIS -----------------------------------------------

-- ---------------------- DATA OVERVIEW --------------------------
-- 1. Produk apa saja yang dijual
SELECT 
    category,
    COUNT(product_id) AS total_skus,
    MIN(price) AS lowest_price,
    MAX(price) AS highest_price,
    ROUND(AVG(price), 2) AS average_price
FROM 
    dim_products
GROUP BY 
    category
ORDER BY 
    total_skus DESC;

-- 2. Cakupan penjualan kemana saja?
SELECT 
    city,
    COUNT(customer_id) AS total_customers
FROM 
    dim_customers
GROUP BY 
    city
ORDER BY 
    total_customers DESC;

-- 3. Kerjasama dengan ekspedisi pengiriman apa saja?
SELECT 
    carrier_name,
    COUNT(order_id) AS total_orders_handled,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders_final), 2) AS workload_percentage
FROM 
    orders_final
GROUP BY 
    carrier_name
ORDER BY 
    total_orders_handled DESC;

-- 4. Metode pembayaran yang digunakan apa saja?
SELECT 
    payment_method,
    COUNT(order_id) AS total_transactions,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM shipping_final), 2) AS percentage_share
FROM 
    shipping_final
GROUP BY 
    payment_method
ORDER BY 
    total_transactions DESC;

-- ---------------------- VALIDASI FENOMENA --------------------------
-- 1. Bagaimana performa penjualan Q1-Q3 SAMALARIS 2026
SELECT 
    CASE 
        WHEN CAST(SUBSTRING(o.order_date, 6, 2) AS INTEGER) BETWEEN 1 AND 3 THEN 'Q1 2026'
        WHEN CAST(SUBSTRING(o.order_date, 6, 2) AS INTEGER) BETWEEN 4 AND 6 THEN 'Q2 2026'
        WHEN CAST(SUBSTRING(o.order_date, 6, 2) AS INTEGER) BETWEEN 7 AND 9 THEN 'Q3 2026'
        ELSE 'Other'
    END AS order_quarter,
    COUNT(o.order_id) AS total_orders,
    SUM(o.quantity) AS total_quantity,
    SUM(p.price * o.quantity) AS gross_revenue,
    SUM(s.total_logistics_cost) AS total_logistics_expense,
    SUM(CASE WHEN o.is_returned = 0 THEN (p.price * o.quantity) ELSE 0 END) - SUM(s.total_logistics_cost) AS net_revenue,
    SUM(p.price * o.quantity) - (SUM(CASE WHEN o.is_returned = 0 THEN (p.price * o.quantity) ELSE 0 END) - SUM(s.total_logistics_cost)) AS total_financial_loss
FROM 
    orders_final o
JOIN 
    dim_products p ON o.product_id = p.product_id
JOIN 
    shipping_final s ON o.order_id = s.order_id
GROUP BY 
    order_quarter
ORDER BY 
    order_quarter ASC;

-- 2. Analisis ketidakseimbangan lonjakan penjualan vs pendapatan bersih yang diperoleh
SELECT 
    CASE 
        WHEN CAST(SUBSTRING(o.order_date, 6, 2) AS INTEGER) BETWEEN 1 AND 3 THEN 'Q1 2026'
        WHEN CAST(SUBSTRING(o.order_date, 6, 2) AS INTEGER) BETWEEN 4 AND 6 THEN 'Q2 2026'
        WHEN CAST(SUBSTRING(o.order_date, 6, 2) AS INTEGER) BETWEEN 7 AND 9 THEN 'Q3 2026'
        ELSE 'Other'
    END AS order_quarter,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS total_returns,
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS return_rate_percentage
FROM 
    orders_final o
GROUP BY 
    order_quarter
ORDER BY 
    order_quarter ASC;

-- ---------------------- ROOT CAUSE ANALYSIS --------------------------
-- 1. Kategori apa yang paling banyak diretur?
SELECT 
    p.category, 
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS total_returns,
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS return_rate_percentage
FROM 
    orders_final o
JOIN 
    dim_products p ON o.product_id = p.product_id
WHERE 
    o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%'
GROUP BY 
    p.category
ORDER BY 
    return_rate_percentage DESC;

-- 2. Apa saja SKU produk yang sering diretur?
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS total_returns,
    STRING_AGG(DISTINCT o.return_reason, ', ') AS return_reasons
FROM 
    orders_final o
JOIN 
    dim_products p ON o.product_id = p.product_id
WHERE 
    o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%'
GROUP BY 
    p.product_id, p.product_name, p.category
ORDER BY 
    total_returns DESC
LIMIT 10;

-- 3. Alasan pengembaliannya paling banyak karena apa?
SELECT 
    return_reason,
    COUNT(order_id) AS total_cases,
    ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(), 2) AS percentage_share
FROM 
    orders_final
WHERE 
    (order_date LIKE '2026-07%' OR order_date LIKE '2026-08%' OR order_date LIKE '2026-09%')
    AND is_returned = 1
GROUP BY 
    return_reason
ORDER BY 
    total_cases DESC;

-- 4. Kurir mana yang memiliki total retur dengan alasan damage in transit terbanyak?
SELECT 
    o.carrier_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%damage%' THEN 1 ELSE 0 END) AS total_damage_returns,
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%damage%' THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS damage_return_rate_percentage
FROM 
    orders_final o
WHERE 
    o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%'
GROUP BY 
    o.carrier_name
ORDER BY 
    damage_return_rate_percentage DESC;

-- 5. Kategori apa saja yang sering di retur dengan alasan product quality/mismatch?
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%quality%' THEN 1 ELSE 0 END) AS total_qualitymismatch_returns,
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%quality%' THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS qualitymismatch_return_rate_percentage
FROM 
    orders_final o
JOIN 
    dim_customers c ON o.customer_id = c.customer_id
WHERE 
    -- Difokuskan pada periode Q3 2026
    o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%'
GROUP BY 
    c.city
ORDER BY 
    total_qualitymismatch_returns DESC;


-- 6. Kota mana saja yang sering melakukan retur karena keterlambatan pengiriman?
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%delay%' THEN 1 ELSE 0 END) AS total_delay_returns,
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%delay%' THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS delay_return_rate_percentage
FROM 
    orders_final o
JOIN 
    dim_customers c ON o.customer_id = c.customer_id
WHERE 
    -- Difokuskan pada periode Q3 2026
    o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%'
GROUP BY 
    c.city
ORDER BY 
    total_delay_returns DESC;

-- 7. Bandingkan performa kurir untuk pengiriman Medan dan Makassar
SELECT 
    c.city,
    o.carrier_name,
    COUNT(o.order_id) AS total_orders,
    
    -- Pesanan yang telat & diretur karena delay
    SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%delay%' THEN 1 ELSE 0 END) AS delayed_and_returned_orders,
    
    -- Pesanan yang sukses tepat waktu
    SUM(CASE WHEN o.is_returned = 0 AND o.delivery_delay_days <= 0 THEN 1 ELSE 0 END) AS success_on_time_orders,

    -- Persentase pesanan sukses tepat waktu dari total orderan kurir tersebut di kota tersebut (%)
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 0 AND o.delivery_delay_days <= 0 THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS success_on_time_percentage

FROM 
    orders_final o
JOIN 
    dim_customers c ON o.customer_id = c.customer_id
WHERE 
    -- Memilih Medan dan Makassar aja
	(c.city ILIKE '%Medan%' OR c.city ILIKE '%Makassar%')
    AND (o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%')
GROUP BY 
    c.city,
    o.carrier_name
ORDER BY 
    c.city ASC, 
    success_on_time_percentage DESC;

-- 8. Bandingkan performa kurir untuk pengiriman pulau jawa
SELECT 
    c.city,
    o.carrier_name,
    COUNT(o.order_id) AS total_orders,
    
    -- Pesanan yang telat & diretur karena delay
    SUM(CASE WHEN o.is_returned = 1 AND o.return_reason ILIKE '%delay%' THEN 1 ELSE 0 END) AS delayed_and_returned_orders,
    
    -- Pesanan yang sukses tepat waktu
    SUM(CASE WHEN o.is_returned = 0 AND o.delivery_delay_days <= 0 THEN 1 ELSE 0 END) AS success_on_time_orders,

    -- Persentase pesanan sukses tepat waktu dari total orderan kurir tersebut di kota tersebut (%)
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 0 AND o.delivery_delay_days <= 0 THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS success_on_time_percentage

FROM 
    orders_final o
JOIN 
    dim_customers c ON o.customer_id = c.customer_id
WHERE 
    -- Mengecualikan Medan dan Makassar (fokus pada kota-kota Pulau Jawa)
    c.city NOT ILIKE '%Medan%' 
    AND c.city NOT ILIKE '%Makassar%'
    AND (o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%')
GROUP BY 
    c.city,
    o.carrier_name
ORDER BY 
    c.city ASC, 
    success_on_time_percentage DESC;

-- 9. metode pembayaran apa yang digunakan untuk produk yang diretur?
SELECT 
    s.payment_method,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS total_returns,
    ROUND(
        CAST(SUM(CASE WHEN o.is_returned = 1 THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(o.order_id) * 100, 
        2
    ) AS return_rate_percentage
FROM 
    orders_final o
JOIN 
    shipping_final s ON o.order_id = s.order_id
WHERE 
    o.order_date LIKE '2026-07%' OR o.order_date LIKE '2026-08%' OR o.order_date LIKE '2026-09%'
GROUP BY 
    s.payment_method
ORDER BY 
    return_rate_percentage DESC;





























