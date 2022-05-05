select
    codcliente,
    COUNT(CASE WHEN tipoequipamento NOT IN ('SERIAL-USB', 'USB', 'SERIAL-USB') THEN 1 ELSE NULL END) AS POS,
    COUNT(CASE WHEN tipoequipamento IN ('SERIAL-USB', 'USB', 'SERIAL-USB') THEN 1 ELSE NULL END) AS Pinpad
from dataplatform-prd.sop_workfinity.stock
where tipoequipamento in ('BLUETOOTH','GPRS','SERIAL','GPRS-WIFI',
'SMART POS','ETHERNET-BLUETOOTH','POS TEF','ETHERNET','MPOS-TOUCH','SERIAL-USB','USB','BLUETOOTH-GPRS')
and contratante in ('STONE PAGAMENTOS')
and situacao = 'EM PRODUÇÃO'
and codcliente is not null
GROUP BY codcliente
ORDER BY 1
