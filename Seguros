SELECT
    ---- Informações do cliente

    str_client_name,
    str_client_document,
    str_status,
    DATE(EXTRACT(YEAR FROM dtm_signed), EXTRACT(MONTH FROM dtm_signed), EXTRACT(DAY FROM dtm_signed)) as dtm_signed,
    DATE(EXTRACT(YEAR FROM dtm_started), EXTRACT(MONTH FROM dtm_started), EXTRACT(DAY FROM dtm_started)) as dtm_started,
    str_product_name,
    str_user_email,
    str_hub_name

    ---- Informações valores

    --int_capital/100 as capital,
   -- int_premium/100 as premium,

FROM `ctra-comercial-1554819299431.sales_analytics.tb_new_insurance_contract` seg


LEFT JOIN (SELECT 
               document,
               name,
               customer_regional,
               customer_distrito,
               customer_polo
            FROM `dataplatform-prd.a_distancia.accounts`
            ) SF 
                ON seg.str_client_document = SF.document
WHERE 1=1
    AND dtm_signed <= '2022-02-28'
    AND str_status = 'ACTIVE'



