DECLARE		@startDate AS DATE = '2019-07-01'
DECLARE		@endDate AS DATE = '2019-12-31'

SELECT  	AttendingPhysician,
		PhysicianLastName,
		FORMAT(enc.DischargeDate, 'yyyy-MM') DischargeMonth ,
		EXP(AVG(LOG(LOS))) AS GMLOS

FROM		T_IP_ENCOUNTER enc
INNER JOIN	DSS.dbo.DATE dt
			ON enc.DischargeDate = dt.date
LEFT JOIN	T_PHYSICIAN ph
			ON enc.AttendingPhysician = ph.PhysicianID
			AND ph.FacilityID = '1'

WHERE		enc.TotalCharges <> 0
AND 		enc.LOS > 0
AND		enc.DischargeDate BETWEEN @startDate AND @endDate
		
GROUP BY 	enc.AttendingPhysician,
		ph.PhysicianLastName,
		FORMAT(enc.DischargeDate, 'yyyy-MM')
ORDER BY	FORMAT(enc.DischargeDate, 'yyyy-MM')
