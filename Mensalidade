SELECT
    stone_code,
    document,
    chargeable,
    SUM(amount) as amount,
    LAST_DAY(charge_date) as charge_date
FROM `dataplatform-prd.billing_charges.taxman`
WHERE 1=1
    AND LAST_DAY(charge_date) = '2022-04-30'
    AND chargeable IN ('stone.rent', 'stone.rent.volume-exemption')
GROUP BY
    stone_code,
    document,
    chargeable,
    LAST_DAY(charge_date)
