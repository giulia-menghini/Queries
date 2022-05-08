SELECT
    LAST_DAY(rav.ContractDate) as referencedate,
    hub.SalesStructureNameLevel5 as Polo,
    SUM(rav.FundingCost) as FundingCost,
    SUM(rav.GrossValue) as TpvAntecipado,
    SUM(rav.Revenue) as ReceitaRav

FROM `ctra-comercial-1554819299431.core_dw_replica.FactRav` rav
JOIN `ctra-comercial-1554819299431.core_dw_replica.DimAffiliation` aff
    ON rav.ClientAlternateKey = aff.ClientAlternateKey
JOIN `ctra-comercial-1554819299431.core_dw_replica.ClientListHubs` hub
    ON aff.ClientKey = hub.ClientKey
WHERE 1=1
    AND LAST_DAY(rav.ContractDate) >= '2022-04-01'
    AND LAST_DAY(rav.ContractDate) <= '2022-04-30'
    AND hub.SalesStructureNameLevel2 = 'FRANQUIA'
GROUP BY
    LAST_DAY(rav.ContractDate),
    hub.SalesStructureNameLevel5
