SELECT
    hub.SalesStructureNameLevel5,
    COUNT(numeroserie) AS POS,
    COUNT(CASE WHEN tipoequipamento IN ('SERIAL-USB', 'USB', 'SERIAL-USB') THEN 1 ELSE NULL END) AS Pinpad
FROM `dataplatform-prd.sop_workfinity.stock` maq
JOIN `ctra-comercial-1554819299431.core_dw_replica.DimAffiliation` aff
    ON aff.ClientAlternateKey = maq.codcliente
JOIN `ctra-comercial-1554819299431.core_dw_replica.ClientListHubs` hub
    ON aff.ClientKey = hub.ClientKey
WHERE tipoequipamento in ('BLUETOOTH','GPRS','SERIAL','GPRS-WIFI','SMART POS','ETHERNET-BLUETOOTH','POS TEF','ETHERNET','MPOS-TOUCH','SERIAL-USB','USB','BLUETOOTH-GPRS')
    AND contratante IN ('STONE PAGAMENTOS')
    AND situacao = 'EM PRODUÇÃO'
    AND codcliente IS NOT NULL
    AND hub.SalesStructureNameLevel2 = 'FRANQUIA'
GROUP BY
    hub.SalesStructureNameLevel5
