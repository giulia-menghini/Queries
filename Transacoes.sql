SELECT
    LAST_DAY(tpv.TransactionDate) as referencedate,
    hub.SalesStructureNameLevel5,
    SUM(tpv.Transactions) as Transacoes
FROM `ctra-comercial-1554819299431.core_dw_replica.FactTPV` tpv
JOIN `ctra-comercial-1554819299431.core_dw_replica.DimAffiliation` aff
    ON tpv.ClientAlternateKey = aff.ClientAlternateKey
JOIN `ctra-comercial-1554819299431.core_dw_replica.ClientListHubs` hub
    ON aff.ClientKey = hub.ClientKey
WHERE 1=1
    AND LAST_DAY(tpv.TransactionDate) >= '2021-01-01'
    AND LAST_DAY(tpv.TransactionDate) <= '2021-12-31'
    AND hub.SalesStructureNameLevel2 = 'FRANQUIA'
GROUP BY
    LAST_DAY(tpv.TransactionDate),
    hub.SalesStructureNameLevel5
