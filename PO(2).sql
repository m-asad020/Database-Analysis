-- Patient Visit and Medication Details

SELECT 
    a.MRNo, 
    a.Gender,
    a.DOB, 
    b.Priority, 
    e.Name AS Diagnose, 
    c.Name AS Presenting_Complaints,
    b.CreatedOn AS Visit_Date, 
    f.CreatedOn AS Discharge_Date,
    i.PhysicianOrder,
    j.GIR,
    g.Name
FROM 
    VU_Patient_Information a, 
    VU_All_Visit_Information b, 
    Evs_Tbl_PresentingComplaint c,
    Evs_Tbl_PT_Diagnosis d, 
    Evs_Tbl_Diagnose e, 
    Evs_Tbl_PT_Disposal f, 
    Evs_Tbl_Medicine g,
    VU_Medication_Consumptions h,
    Evs_Tbl_PT_PhysicianOrder i,
    VU_Vitals_History j
WHERE 
    a.id = b.PatientId
    AND b.PresentingComplaints = c.Id
    AND b.Id = d.VisitId
    AND b.Id = f.VisitId
    AND d.DiagnoseId = e.Id
    AND b.Id = h.VisitId
    AND h.MedicineId = g.Id
    AND b.Id = i.VisitId
    AND b.Id = j.VisitId
    AND g.Name IN ('10% DEXTROSE WATER 1000ML', '10% DEXTROSE WATER 500ML')
    AND b.CreatedOn BETWEEN '1-nov-2023' AND '1-may-2024'
    AND b.ERs = 1007;


-- Hypoglycemia Patient Visit and Medication Details with Maintenance Fluids Check

SELECT 
    a.MRNo, 
    a.Gender,
    a.DOB, 
    b.Priority, 
    e.Name AS Diagnose, 
    c.Name AS Presenting_Complaints,
    b.CreatedOn AS Visit_Date, 
    f.CreatedOn AS Discharge_Date,
    i.PhysicianOrder,
    j.GIR,
    g.Name,
    CASE 
        WHEN i.PhysicianOrder LIKE '%maintenance fluids%' THEN 'Yes'
        ELSE 'No'
    END AS 'With_Maintenance_Fluids ?'
FROM 
    VU_Patient_Information a
    INNER JOIN VU_All_Visit_Information b ON a.id = b.PatientId
    INNER JOIN Evs_Tbl_PresentingComplaint c ON b.PresentingComplaints = c.Id
    INNER JOIN Evs_Tbl_PT_Diagnosis d ON b.Id = d.VisitId
    INNER JOIN Evs_Tbl_Diagnose e ON d.DiagnoseId = e.Id
    INNER JOIN Evs_Tbl_PT_Disposal f ON b.Id = f.VisitId
    INNER JOIN VU_Medication_Consumptions h ON b.Id = h.VisitId
    INNER JOIN Evs_Tbl_Medicine g ON h.MedicineId = g.Id
    INNER JOIN Evs_Tbl_PT_PhysicianOrder i ON b.Id = i.VisitId
    INNER JOIN VU_Vitals_History j ON b.Id = j.VisitId
WHERE 
    g.Name IN ('10% DEXTROSE WATER 1000ML', '10% DEXTROSE WATER 500ML')
    AND e.Name LIKE '%hypoglycemia%'
    AND b.CreatedOn BETWEEN '1-nov-2023' AND '1-may-2024'
    AND b.ERs = 1007;



-- Acute Asthma and Status Asthmaticus Patient Visit Details with PRAM Score and Maintenance Fluids Check


SELECT 
    a.MRNo, 
    a.DOB, 
    b.CreatedOn AS Visit_Date, 
    b.Id AS Visit_ID,
    b.Priority, 
    e.Name AS Diagnose, 
    c.Name AS Presenting_Complaints,
    f.CreatedOn AS Discharge_Date,
    f.DisposalType AS Disposition,
    CASE 
        WHEN h.Name IN ('MAGNESIUM SULPHATE', 'Magnesium Sulphate 5000mg') THEN 'Yes'
        ELSE 'No'
    END AS 'With_Maintenance_Fluids ?',
    h.Name AS Medicine,
    i.Id, 
    CASE 
        WHEN i.Id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS 'Pram_Score_Done?'
FROM 
    VU_Patient_Information a
    INNER JOIN VU_All_Visit_Information b ON a.id = b.PatientId
    INNER JOIN Evs_Tbl_PT_Diagnosis d ON b.Id = d.VisitId
    INNER JOIN Evs_Tbl_Diagnose e ON d.DiagnoseId = e.Id
    INNER JOIN Evs_Tbl_PT_Disposal f ON b.Id = f.VisitId
    INNER JOIN Evs_Tbl_PresentingComplaint c ON b.PresentingComplaints = c.Id
    INNER JOIN VU_Medication_Consumptions g ON b.Id = g.VisitId
    INNER JOIN Evs_Tbl_Medicine h ON g.MedicineId = h.Id
    LEFT JOIN Evs_Tbl_PT_PRAM i ON b.Id = i.VisitId
WHERE 
    b.ERs = 1009
    AND b.CreatedOn BETWEEN '1-jun-2023' AND '1-jun-2024'
    AND e.Name IN ('Acute Asthma', 'Status Asthmaticus');



-- Dog Bite and Vaccination Cases with Detailed Diagnoses and Medication

SELECT 
    a.MRNo, 
    a.DOB, 
    b.CreatedOn AS Visit_Date, 
    b.Id AS Visit_Id, 
    c.DisposalType AS Disposition,
    g.Name AS Medicine,
    STRING_AGG(e.Name, ', ') AS Diagnoses,
    MAX(CASE 
        WHEN e.Name = 'Dog Bite' THEN 'Yes'
        ELSE 'No'
    END) AS Dog_Bite_Diagnosis,
    MAX(CASE 
        WHEN e.Name = 'Repeated vaccination dosage dog bite case' THEN 'Yes'
        ELSE 'No'
    END) AS Repeated_Vaccination_Diagnosis
FROM 
    VU_Patient_Information a
    INNER JOIN VU_All_Visit_Information b ON a.Id = b.PatientId
    INNER JOIN Evs_Tbl_PT_Disposal c ON b.Id = c.VisitId
    INNER JOIN Evs_Tbl_PT_Diagnosis d ON b.Id = d.VisitId
    INNER JOIN Evs_Tbl_Diagnose e ON d.DiagnoseId = e.Id
    INNER JOIN VU_Medication_Consumptions f ON b.Id = f.VisitId
    INNER JOIN Evs_Tbl_Medicine g ON f.MedicineId = g.Id
WHERE 
    b.CreatedOn BETWEEN '2023-01-01' AND '2024-06-01'
    AND b.ERs = 8
    AND e.Name IN ('Dog Bite', 'Repeated vaccination dosage dog bite case')
    AND g.Name IN ('ANTI RABIES VAC', 'RABIES IMMUNOGLOBULIN')
GROUP BY 
    a.MRNo, 
    a.DOB, 
    b.CreatedOn, 
    b.Id, 
    c.DisposalType,
    g.Name;