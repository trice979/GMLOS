DECLARE @startdate AS DATE
DECLARE @enddate AS DATE
DECLARE @facility AS VARCHAR(50)
SET @startdate = '2015-07-01'
SET @enddate = '2016-06-30'
SET @facility = 'Adult IP'

/* 30 Day Readmissions by Payor and D/C Status */
SELECT	Admit.MedicalRecordNumber,
		Admit.PatientAccount as AdmitAcctNumber,
		Admit.Division,
		Admit.Specialty,
		Admit.AttendingPhysician,
		Admit.AttendingPhysicianName,
		Admit.ICD10DxCode as AdmitDxCode,
		T_ICD10DX_CODES.Description AS AdmitDxDescription,
		Admit.DischargeDate,
		DischargeStatus = CASE WHEN Admit.DischargeStatus = '01' THEN 'Home'
							   WHEN Admit.DischargeStatus IN ('03' , '83') THEN 'SNF'
							   WHEN Admit.DischargeStatus = '04' THEN 'NH'
							   WHEN Admit.DischargeStatus = '63' THEN 'LTACH'
							   ELSE 'Other'
							   END,
		Admit.Facility AS AdmitFacility,
		Readmit.PatientAccount as ReadmitAcctNumber,
		Readmit.ICD10DxCode as ReadmitDxCode,
		T_ICD10DX_CODES_2.Description AS ReadmitDxDescription,
		Readmit.AdmissionDate as ReadmissionDate,
		Readmit.Facility as ReadmitFacility,
		Payor = CASE WHEN Readmit.UserField2 = '1001' AND Readmit.PayorCode <> '649' THEN 'MEDICARE'
				   WHEN Readmit.PayorCode = '649' THEN 'WELLCARE/WINDSOR'
				   WHEN Readmit.FinancialClass = '3' AND  Readmit.PayorPlanCode <> '10703' AND Readmit.PayorPlanCode <> '104' THEN 'MEDICAID'
				   WHEN Readmit.PayorPlanCode = '10703' THEN 'MEDICAID W/ MSCAN UNITED'
				   WHEN Readmit.PayorPlanCode = '104' THEN 'MEDICAID W/ MSCAN MAGNOLIA'
				   WHEN Readmit.PayorCode = '105' THEN 'BCBS'
				   WHEN Readmit.UserField2 = '1005' THEN 'SELF PAY'
				   ELSE 'ALL OTHER'
				   END
				   
FROM   	(SELECT T_IP_ENCOUNTER.MedicalRecordNumber,
				T_IP_ENCOUNTER.PatientAccount,
				T_ENCOUNTER_ICD10DX.ICD10DxCode,
				T_ENCOUNTER_ICD10DX.ICD10DXSequence,
				T_IP_ENCOUNTER.AdmissionDate,
				T_IP_ENCOUNTER.DischargeDate,
				T_IP_ENCOUNTER.PayorCode,
				T_IP_ENCOUNTER.FinancialClass,
				T_IP_ENCOUNTER.PayorPlanCode,
				T_IP_ENCOUNTER.userfield2,
				T_IP_ENCOUNTER.DischargeStatus,
			    T_PLM_ASSIGNMENT.ProductCode AS Facility,
			    DSS.dbo.PHYSICIAN.Division,
			    DSS.dbo.PHYSICIAN.Specialty,
			    T_IP_ENCOUNTER.AttendingPhysician,
			    DSS.dbo.PHYSICIAN.last_name + ', ' + DSS.dbo.PHYSICIAN.first_name as AttendingPhysicianName
		 
		 FROM	T_IP_ENCOUNTER
				INNER JOIN T_PLM_ASSIGNMENT ON T_IP_ENCOUNTER.PatientAccount = T_PLM_ASSIGNMENT.PatientAccount AND T_PLM_ASSIGNMENT.ProductLine = 'Hospital'
				LEFT OUTER JOIN T_ENCOUNTER_ICD10DX ON T_IP_ENCOUNTER.PatientAccount = T_ENCOUNTER_ICD10DX.PatientAccount AND T_ENCOUNTER_ICD10DX.ICD10DXSequence = '1'
				LEFT OUTER JOIN DSS.dbo.PHYSICIAN ON T_IP_ENCOUNTER.AttendingPhysician = DSS.dbo.PHYSICIAN.physician_number
				
		 WHERE	TotalCharges <> 0

		 GROUP BY T_IP_ENCOUNTER.MedicalRecordNumber,
				T_IP_ENCOUNTER.PatientAccount,
				T_ENCOUNTER_ICD10DX.ICD10DxCode,
				T_ENCOUNTER_ICD10DX.ICD10DXSequence,
				T_IP_ENCOUNTER.AdmissionDate,
				T_IP_ENCOUNTER.DischargeDate,
				T_IP_ENCOUNTER.PayorCode,
				T_IP_ENCOUNTER.FinancialClass,
				T_IP_ENCOUNTER.PayorPlanCode,
				T_IP_ENCOUNTER.userfield2,
				T_IP_ENCOUNTER.DischargeStatus,
			    T_PLM_ASSIGNMENT.ProductCode,
			    DSS.dbo.PHYSICIAN.Division,
			    DSS.dbo.PHYSICIAN.Specialty,
			    T_IP_ENCOUNTER.AttendingPhysician,
			    DSS.dbo.PHYSICIAN.last_name + ', ' + DSS.dbo.PHYSICIAN.first_name) AS Admit
		 
		 INNER JOIN
		 
		(SELECT T_IP_ENCOUNTER.MedicalRecordNumber,
				T_IP_ENCOUNTER.PatientAccount,
				T_IP_ENCOUNTER.AdmissionDate,
				T_IP_ENCOUNTER.DischargeDate,
				T_IP_ENCOUNTER.TotalCharges,
				T_IP_ENCOUNTER.UserField2,
				T_IP_ENCOUNTER.FinancialClass,
				T_IP_ENCOUNTER.PayorCode,
				T_IP_ENCOUNTER.PayorPlanCode,
				T_ENCOUNTER_ICD10DX.ICD10DxCode,
			    T_PLM_ASSIGNMENT.ProductCode as Facility

		 FROM	T_IP_ENCOUNTER
				INNER JOIN T_PLM_ASSIGNMENT ON T_IP_ENCOUNTER.PatientAccount = T_PLM_ASSIGNMENT.PatientAccount AND T_PLM_ASSIGNMENT.ProductLine = 'Hospital'
				LEFT OUTER JOIN T_ENCOUNTER_ICD10DX ON T_IP_ENCOUNTER.PatientAccount = T_ENCOUNTER_ICD10DX.PatientAccount AND T_ENCOUNTER_ICD10DX.ICD10DXSequence = '1'
				
		 WHERE	TotalCharges <> 0

		 GROUP BY 
				T_IP_ENCOUNTER.MedicalRecordNumber,
				T_IP_ENCOUNTER.PatientAccount,
				T_IP_ENCOUNTER.UserField2,
				T_IP_ENCOUNTER.AdmissionDate,
				T_IP_ENCOUNTER.DischargeDate,
				T_IP_ENCOUNTER.TotalCharges,
				T_ENCOUNTER_ICD10DX.ICD10DxCode,	
				T_IP_ENCOUNTER.FinancialClass,
				T_IP_ENCOUNTER.PayorCode,
				T_IP_ENCOUNTER.PayorPlanCode,
				T_PLM_ASSIGNMENT.ProductCode) AS Readmit
		 
		 ON		Admit.MedicalRecordNumber = Readmit.MedicalRecordNumber AND Admit.DischargeDate < Readmit.AdmissionDate AND DATEDIFF(day,Admit.DischargeDate, Readmit.AdmissionDate) <= 30

LEFT OUTER JOIN T_ICD10DX_CODES ON Admit.ICD10DxCode = T_ICD10DX_CODES.ICD10DXCode AND Admit.DischargeDate BETWEEN T_ICD10DX_CODES.ICD10DXEffectiveDateFrom AND T_ICD10DX_CODES.ICD10DXEffectiveDateTo
LEFT OUTER JOIN T_ICD10DX_CODES AS T_ICD10DX_CODES_2 ON Readmit.ICD10DxCode = T_ICD10DX_CODES_2.ICD10DXCode AND Readmit.AdmissionDate BETWEEN T_ICD10DX_CODES_2.ICD10DXEffectiveDateFrom AND T_ICD10DX_CODES_2.ICD10DXEffectiveDateTo

INNER JOIN

		(SELECT MedicalRecordNumber, DischargeDate
		 FROM T_IP_ENCOUNTER INNER JOIN T_PLM_ASSIGNMENT
		 ON T_IP_ENCOUNTER.PatientAccount = T_PLM_ASSIGNMENT.PatientAccount AND T_PLM_ASSIGNMENT.ProductLine = 'Hospital'
		 WHERE TotalCharges <> 0) AS IndexAdmit ON IndexAdmit.MedicalRecordNumber = Admit.MedicalRecordNumber AND IndexAdmit.DischargeDate < Readmit.AdmissionDate
		 
WHERE	Readmit.TotalCharges <> 0
AND		Readmit.AdmissionDate BETWEEN @startdate AND @enddate
AND		Admit.PatientAccount <> Readmit.PatientAccount
AND		Readmit.Facility = @facility

GROUP BY
Admit.MedicalRecordNumber, 
Admit.PatientAccount,
Admit.Division,
Admit.Specialty,
Admit.AttendingPhysician,
Admit.AttendingPhysicianName,
Admit.ICD10DxCode,
Admit.DischargeDate,
Admit.ICD10DXSequence,


		CASE WHEN Readmit.UserField2 = '1001' AND Readmit.PayorCode <> '649' THEN 'MEDICARE'
				   WHEN Readmit.PayorCode = '649' THEN 'WELLCARE/WINDSOR'
				   WHEN Readmit.FinancialClass = '3' AND  Readmit.PayorPlanCode <> '10703' AND Readmit.PayorPlanCode <> '104' THEN 'MEDICAID'
				   WHEN Readmit.PayorPlanCode = '10703' THEN 'MEDICAID W/ MSCAN UNITED'
				   WHEN Readmit.PayorPlanCode = '104' THEN 'MEDICAID W/ MSCAN MAGNOLIA'
				   WHEN Readmit.PayorCode = '105' THEN 'BCBS'
				   WHEN Readmit.UserField2 = '1005' THEN 'SELF PAY'
				   ELSE 'ALL OTHER'
				   END,
				   
		CASE WHEN Admit.DischargeStatus = '01' THEN 'Home'
			       WHEN Admit.DischargeStatus IN ('03' , '83') THEN 'SNF'
				   WHEN Admit.DischargeStatus = '04' THEN 'NH'
				   WHEN Admit.DischargeStatus = '63' THEN 'LTACH'
				   ELSE 'Other'
				   END,

Admit.Facility,
T_ICD10DX_CODES.Description,
Readmit.PatientAccount,
		Readmit.ICD10DxCode,
		T_ICD10DX_CODES_2.Description,
		Readmit.AdmissionDate,
		Readmit.Facility

HAVING Admit.DischargeDate = MAX(IndexAdmit.DischargeDate)
