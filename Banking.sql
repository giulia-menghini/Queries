SELECT
    reference_month,
    UPPER(REGEXP_REPLACE(NORMALIZE(str_franchise, NFD), r"\pM", '')) as franchise,
    stonecode__c,
    shippingcity,
    shippingstate,
    owner_document,
    SUM(gross_revenue_ex_floating) as gross_revenue_ex_floating,
    SUM(net_revenue_ex_floating) as net_revenue_ex_floating,
    SUM(prepaid_card_tpv) as prepaid_card_tpv,
    SUM(prepaid_card_trx) as prepaid_card_trx,
    SUM(prepaid_card_interchange_revenue) as prepaid_card_interchange_revenue,
    SUM(ted_out_charged_trx) as ted_out_charged_trx,
    SUM(ted_out_revenue) as ted_out_revenue,
    SUM(pix_in_total_tpv) as pix_in_total_tpv,
    SUM(pix_in_total_revenue) as pix_in_total_revenue,
    SUM(pix_in_transfer_tpv) as pix_in_transfer_tpv,
    SUM(pix_in_dynamic_account_tpv) as pix_in_dynamic_account_tpv,
    SUM(pix_in_dynamic_pos_tpv) as pix_in_dynamic_pos_tpv,
    SUM(pix_in_static_tpv) as pix_in_static_tpv,
    SUM(pix_out_tpv) as pix_out_tpv,
    SUM(pix_out_revenue) as pix_out_revenue,
    SUM(invoice_revenue) as invoice_revenue,
    SUM(payments_boleto_revenue) as payments_boleto_revenue,
    SUM(payments_gda_revenue) as payments_gda_revenue,
    SUM(withdrawal_revenue) as withdrawal_revenue,
    SUM(topups_revenue) as topups_revenue
FROM `dataplatform-prd.conta_stone_analytics.monthly_account_economics` bank
LEFT JOIN (WITH X AS
            (
            SELECT
                stonecode__c,
                cnpj_limpo__c,
                shippingcity,
                shippingstate,
                lastmodifieddate,
                ROW_NUMBER() OVER (PARTITION BY cnpj_limpo__c ORDER BY (CASE WHEN sales_channel_name__c = 'Link ABC' THEN 'Z' ELSE IFNULL(sales_channel_name__c, 'A') END), lastmodifieddate DESC) as rw
            FROM `dataplatform-prd.sop_salesforce.account`
            WHERE 1=1
                AND stonecode__c IS NOT NULL
                AND cnpj_limpo__c IS NOT NULL
            ORDER BY
                cnpj_limpo__c,
                stonecode__c,
                lastmodifieddate
            )

            SELECT
                *
            FROM X
            WHERE rw = 1
            ) sf ON sf.cnpj_limpo__c = bank.owner_document
JOIN `ssmgifw8a47t5jt04sg9hnp4uu24ja.franchise_operation.franchise_cities_relation` cities
    ON UPPER(REGEXP_REPLACE(NORMALIZE(sf.shippingcity, NFD), r"\pM", '')) = UPPER(REGEXP_REPLACE(NORMALIZE(cities.str_city, NFD), r"\pM", '')) AND UPPER(`ssmgifw8a47t5jt04sg9hnp4uu24ja.franchise_operation.ClearUF`(sf.shippingstate)) = cities.str_city_uf
WHERE 1=1
    AND reference_month = '2022-03-01' -- Primeiro dia do mês
    AND stonecode__c IS NOT NULL
    AND stonecode__c NOT LIKE '%bank%'
GROUP BY
    reference_month,
    str_franchise,
    owner_document,
    stonecode__c,
    shippingcity,
    shippingstate
