IF OBJECT_ID('tempdb..#afs') IS NOT NULL DROP TABLE #afs;
SELECT

	a.AffiliationKey,
	a.ClientAlternateKey AS Stonecode,
	s.SalesStructureNameLevel3 AS Regional,
	s.SalesStructureNameLevel4 AS Distrito,
	s.SalesStructureNameLevel5 AS Polo,
	ad.TpvEstimate AS TpvEstimado,
	ad.ExpectedMigration AS MigracaoPrometida,
	VEN.VendorName as Vendedor,
	VEN.EmailAddress as Email,
	CI.city,
	CI.UF,
	CONVERT(DATE, CONVERT(VARCHAR, CreateDate)) AS DataCredenciamento,
	EOMONTH(CONVERT(DATE, CONVERT(VARCHAR, CreateDate))) AS MesCredenciamento,
	dt1.[CalendarYearMonth]
	
INTO #afs

FROM [StoneDWv0].[dbo].[DimAffiliation] (NOLOCK) a
	LEFT JOIN [StoneDWv0].[dbo].[DimAffiliationData] (NOLOCK) ad on a.AffiliationKey = ad.AffiliationKey
	INNER JOIN [StoneDWv0].[dbo].[DimSalesStructure] (NOLOCK) s ON a.SalesStructureKey = s.SalesStructureKey
	left join [StoneDWv0].[dbo].[DimVendor] (NOLOCK) VEN ON a.VendorKey=VEN.vendorkey
	left join [StoneDWv0].[dbo].[DimGeography] (NOLOCK) CI ON a.GeographyKey=CI.GeographyKey
	left join [StoneDWv0].[dbo].[DimDate] (NOLOCK) dt1 ON dt1.[DateKey] = a.CreateDate
WHERE 1=1
    --AND VEN.EmailAddress like '%@querostone.com.br'
	--AND VEN.VendorName not like 'Link ABC'
	AND a.CompanyKey IN (1,2)
    AND s.SalesStructureNameLevel4 = 'FRANQUIA PIRIPIRI';



WITH 
	dates AS (
	SELECT 
		DateKey,
		FullDate,
		CalendarYearMonth,
		DATEDIFF(MONTH, EOMONTH(GETDATE()-1), FullDate)	AS MX
	FROM [StoneDWv0].[dbo].[DimDate] (NOLOCK)
	WHERE 1=1
		AND FullDate <= EOMONTH(GETDATE()-1)
		AND FullDate >= DATEADD(MONTH, -24, EOMONTH(GETDATE()-1)) -- Ultimos X Meses
		AND IsLastDayOfMonth = 'Y'
	)
	,rav AS (
	SELECT
	   r.AffiliationKey,
	   r.ContractDate,
	   SUM(r.GrossValue) AS rav_amount_m0,
	   SUM(r.Revenue) AS rav_m0,
	   SUM(r.GrossValue*r.Duration) AS dx_m0,
	   SUM(r.Duration) as duration,
	   count(r.ravtypekey) as Tipo_de_antecipação
    FROM [StoneDWv0].[dbo].[FactMonthlyRAV] (NOLOCK)  r
		INNER JOIN dates dt ON r.ContractDate = dt.DateKey
		INNER JOIN #afs afs ON r.AffiliationKey = afs.AffiliationKey
	WHERE 1=1
	GROUP BY r.AffiliationKey, r.ContractDate,r.RavTypeKey
	)

	,rent AS (
	SELECT
	   r.AffiliationKey,
	   r.DateKey,
	   SUM(r.ReceivedRent) AS rent_m0
    FROM [StoneDWv0].[dbo].[FactRental] (NOLOCK) r
		INNER JOIN dates dt ON r.DateKey = dt.DateKey
		INNER JOIN #afs afs ON r.AffiliationKey = afs.AffiliationKey
	WHERE 1=1
	GROUP BY r.AffiliationKey, r.DateKey
	)


	,tpv AS (
	SELECT 
		afs.AffiliationKey,
		dates.CalendarYearMonth AS mes,
		dates.MX,
		t.TPV AS tpv_m0,
		LEAD(t.TPV) OVER (PARTITION BY afs.AffiliationKey ORDER BY dates.FullDate DESC) tpv_m1,
    	t.DIA AS mdr_m0,
		LEAD(t.DIA) OVER (PARTITION BY afs.AffiliationKey ORDER BY dates.FullDate DESC) mdr_m1,
		rav.rav_m0,
	    LEAD(rav.rav_m0) OVER (PARTITION BY afs.AffiliationKey ORDER BY dates.FullDate DESC) rav_m1,
		rav.dx_m0,
		rav.Tipo_de_antecipação,
		rav.rav_amount_m0,
		rent.rent_m0,
		rav.duration,
	    LEAD(rent.rent_m0) OVER (PARTITION BY afs.AffiliationKey ORDER BY dates.FullDate DESC) rent_m1
	FROM #afs afs INNER JOIN dates ON 1=1
		LEFT JOIN [StoneDWv0].[dbo].[FactMonthlyTPV] (NOLOCK) t
			ON t.AffiliationKey = afs.AffiliationKey AND dates.DateKey = t.TransactionDate
		LEFT JOIN rav
			ON rav.AffiliationKey = afs.AffiliationKey AND dates.DateKey = rav.[ContractDate]
		LEFT JOIN rent
			ON rent.AffiliationKey = afs.AffiliationKey AND dates.DateKey = rent.[DateKey]
	WHERE 1=1
	 AND afs.MesCredenciamento <= dates.FullDate
	 )

SELECT 
	a.Stonecode,
	a.Distrito as Franquia,
	a.UF,
	a.city as Cidade,
	a.DataCredenciamento,
	a.CalendarYearMonth as MesCred,
	a.Vendedor,
	ISNULL(a.Email,0) AS Email_Vendedor,
	t.mes as MesRef,
	t.MX,
	CONVERT(REAL, isnull(a.TpvEstimado,0)) as TPV_Estimado,
	ISNULL(t.Tipo_de_antecipação,0) as Tipo_de_Antecipacao,
	CONVERT(REAL, ISNULL(t.duration,0)) as Duration,
	CONVERT(REAL, isnull(t.tpv_m0,0)) as tpv_m0,
	CONVERT(REAL, isnull(t.mdr_m0,0)) as mdr_m0,
	CONVERT(REAL, isnull(t.rav_m0,0)) as rav_m0,
	CONVERT(REAL, isnull((t.dx_m0),0)) as dx_m0,
	CONVERT(REAL, isnull(t.rav_amount_m0, 0)) as tpv_antecipado,
	CONVERT(REAL, isnull(t.rav_m0*30/nullif(t.dx_m0, 0),0)) as taxa_rav_m0,
	CONVERT(REAL, isnull(t.rent_m0,0)) as rent_m0,
	CONVERT(REAL, IIF(tpv_m0>1, 1, 0)) AS base_ativa_m0,
	CONVERT(REAL, IIF(tpv_m1>1, 1, 0)) AS base_ativa_m1,
	CONVERT(REAL, IIF(isnull(tpv_m0, 0)<1 AND tpv_m1>1, 1, 0)) AS churn_m0,
	CONVERT(REAL, isnull((t.rav_m0+t.mdr_m0+t.rent_m0),0)) AS Receita_Total
	
FROM tpv t

	LEFT JOIN #afs a ON a.AffiliationKey = t.AffiliationKey;
