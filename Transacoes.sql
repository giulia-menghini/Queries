SELECT
    LAST_DAY(tpv.TransactionDate) as referencedate,
    hub.SalesStructureNameLevel5 as Polo,
    SUM(tpv.Transactions) as Transacoes,
    SUM(tpv.DIA) as ReceitaMdr,
    SUM(tpv.TPV) as Tpv,

FROM `ctra-comercial-1554819299431.core_dw_replica.FactTPV` tpv
JOIN `ctra-comercial-1554819299431.core_dw_replica.DimAffiliation` aff
    ON tpv.ClientAlternateKey = aff.ClientAlternateKey
JOIN `ctra-comercial-1554819299431.core_dw_replica.ClientListHubs` hub
    ON aff.ClientKey = hub.ClientKey
WHERE 1=1
    AND LAST_DAY(tpv.TransactionDate) >= '2022-04-01'
    AND LAST_DAY(tpv.TransactionDate) <= '2022-04-30'
    AND hub.SalesStructureNameLevel2 = 'FRANQUIA'
GROUP BY
    LAST_DAY(tpv.TransactionDate),
    hub.SalesStructureNameLevel5
