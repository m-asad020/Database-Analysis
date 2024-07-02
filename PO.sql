-- Duplicate MR code, visit no and patient name count
SELECT year, COUNT(*) AS Duplicate_Count
FROM (
    SELECT year, VISIT_NO, MR_CODE, PATIENT_NAME
    FROM as_registration 
    GROUP BY year, VISIT_NO, MR_CODE, PATIENT_NAME
    HAVING COUNT(*) > 1
) AS Duplicate_count
GROUP BY year;

-- Duplicate MR code, visit no and patient name sum
SELECT year, SUM(subquery.count_visit_no) AS total_count
FROM (
    SELECT year, MR_CODE, VISIT_NO, PATIENT_NAME, COUNT(*) AS count_visit_no
    FROM as_registration
    GROUP BY year, MR_CODE, VISIT_NO, PATIENT_NAME
    HAVING COUNT(*) > 1
) AS subquery
GROUP BY year;

-- Data request of patients diagnosed with poison in the year 2023
SELECT 
    a.MRNo, 
    b.VisitNo, 
    a.DOB, 
    d.CreatedOn AS Discharge_Date,  
    b.CreatedOn AS Visit_Date, 
    e.Name, 
    b.Priority, 
    b.ERs, 
    c.DiagnoseId, 
    d.DisposalType 
FROM 
    VU_Patient_Information a
JOIN 
    VU_All_Visit_Information b ON a.Id = b.PatientId
JOIN 
    Evs_View_PT_Diagnosis c ON b.Id = c.VisitId
JOIN 
    Evs_Tbl_PT_Disposal d ON b.Id = d.VisitId
JOIN 
    Evs_Tbl_PresentingComplaint e ON b.PresentingComplaints = e.Id
WHERE 
    b.CreatedOn BETWEEN '2023-01-01' AND '2024-01-01'
    AND b.ERs IN (9, 7, 6, 8, 10)
    AND c.DiagnoseId IN (162, 165, 163, 156, 157);

-- Data request of patients diagnosed with Measles (Jan 2024 - Apr 2024)
SELECT 
    a.MRNo, 
    a.PatientName, 
    b.VisitNo, 
    a.DOB,
    b.CreatedOn AS Visit_Date,
    d.CreatedOn AS Discharge_Date,
    c.Name AS Presenting_Complaint, 
    b.Priority AS Triage_Category, 
    b.Immunization AS Vaccination,
    d.DisposalType AS Disposition,  
    MAX(CASE WHEN e.DiagnoseId = 92 THEN 'Yes' ELSE 'No' END) AS DiagnoseId_92,
    MAX(CASE WHEN e.DiagnoseId = 93 THEN 'Yes' ELSE 'No' END) AS DiagnoseId_93,
    MAX(CASE WHEN e.DiagnoseId = 94 THEN 'Yes' ELSE 'No' END) AS DiagnoseId_94,
    MAX(CASE WHEN e.DiagnoseId = 1237 THEN 'Yes' ELSE 'No' END) AS DiagnoseId_1237
FROM 
    VU_Patient_Information a
INNER JOIN 
    VU_All_Visit_Information b ON a.Id = b.PatientId
INNER JOIN 
    Evs_Tbl_PresentingComplaint c ON b.PresentingComplaints = c.Id
INNER JOIN 
    Evs_Tbl_PT_Disposal d ON b.Id = d.VisitId
INNER JOIN 
    Evs_View_PT_Diagnosis e ON b.Id = e.VisitId
WHERE 
    b.ERs = 1010
    AND b.CreatedOn BETWEEN '2024-01-01' AND '2024-05-01'
GROUP BY 
    a.MRNo, a.PatientName, a.DOB, b.CreatedOn, d.CreatedOn, b.VisitNo, c.Name, b.Priority, d.DisposalType, b.Immunization
HAVING 
    MAX(CASE WHEN e.DiagnoseId IN (92, 93, 94, 1237) THEN 1 ELSE 0 END) = 1;

-- Total Measles patients with complications (pneumonia/eye/oral/gastroenteritis/meningoencephalitis) Nov 2023 - Apr 2024 
SELECT 
    a.PatientName, 
    b.Id, 
    b.Priority, 
    a.DOB, 
    b.CreatedOn AS Visit_Date, 
    c.DiagnoseId, 
    d.DisposalType 
FROM 
    VU_Patient_Information a
JOIN 
    VU_All_Visit_Information b ON a.Id = b.PatientId 
JOIN 
    Evs_Tbl_PT_Diagnosis c ON b.Id = c.VisitId
JOIN 
    Evs_Tbl_PT_Disposal d ON b.Id = d.VisitId
WHERE 
    b.ERs = 1009 
    AND b.CreatedOn BETWEEN '2023-11-01' AND '2024-05-01'
    AND c.DiagnoseId IN (92, 93, 94, 1237);

-- Data request
SELECT 
    a.MRNo,
    b.Id AS VisitId,
    b.ERs,
    a.Gender,
    a.DOB,
    b.CreatedOn AS VisitDate,
    d.Weight,
    b.Priority,
    c.CreatedOn AS DischargeDate,
    f.Name AS PresentingComplaint,
    e.DiagnoseId,
    c.DisposalType 
FROM 
    VU_Patient_Information a
JOIN 
    VU_All_Visit_Information b ON a.Id = b.PatientId
JOIN 
    Evs_Tbl_PT_Disposal c ON b.Id = c.VisitId
JOIN 
    VU_Vitals_History d ON b.Id = d.VisitId
JOIN 
    Evs_Tbl_PT_Diagnosis e ON b.Id = e.VisitId
JOIN 
    Evs_Tbl_PresentingComplaint f ON b.PresentingComplaints = f.Id
WHERE 
    d.CreatedOn = (SELECT MIN(CreatedOn) 
                   FROM VU_Vitals_History x 
                   WHERE d.VisitId = x.VisitId AND x.Weight IS NOT NULL)
    AND e.CreatedOn = (SELECT MIN(CreatedOn) 
                       FROM Evs_Tbl_PT_Diagnosis y 
                       WHERE d.VisitId = y.VisitId)
    AND b.CreatedOn BETWEEN '2024-01-01' AND '2024-04-01'
    AND e.DiagnoseId IN (1, 3);

-- Data request of medicine issuance with details (Jan 2024 - May 2024)
SELECT TOP 10 
    a.PatientName, 
    a.ERs, 
    a.MRNo, 
    b.Id, 
    b.QuantityIssued,
    b.IssuedOn, 
    c.FirstName, 
    d.itemCode 
FROM 
    VU_Patient_Information a
JOIN 
    VU_Medications b ON a.Id = b.PatientId
JOIN 
    Evs_Tbl_User c ON b.IssuedBy = c.Id
JOIN 
    Evs_Tbl_Medicine d ON d.Id = b.Medicine
WHERE 
    d.Id = 241
    AND b.IssuedOn BETWEEN '2024-01-01' AND '2024-05-04'
    AND b.ER = 9;
