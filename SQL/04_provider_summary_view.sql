/*VIEW*/
create view provider_summary as
with patient_claims as(
select 
    BeneID,Provider,count(ClaimID) as claim_count,
    sum(InscClaimAmtReimbursed) as claim_reimb,
    avg(datediff(
    str_to_date(DischargeDt,'%d-%m-%Y'),
    str_to_date(AdmissionDt,'%d-%m-%Y')
    )) as avg_los
    from stg_ip group by Provider,BeneID),
patient_disease as(
select BeneID,
    (
CASE WHEN ChronicCond_Alzheimer=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_Heartfailure=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_KidneyDisease=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_Cancer=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_ObstrPulmonary=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_Depression=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_Diabetes=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_IschemicHeart=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_Osteoporasis=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_rheumatoidarthritis=1 THEN 1 ELSE 0 END+
CASE WHEN ChronicCond_stroke=1 THEN 1 ELSE 0 END
)
AS chronic_disease
FROM stg_beneficiary
)

select 
      pc.provider,p.PotentialFraud,
      sum(pc.claim_count) as total_claims,
     count(*) as total_patients,
     round(sum(pc.claim_count)/count(*),2) as claims_per_patient,
     sum(pc.claim_reimb) as total_reimb,
     round(sum(pc.claim_reimb)/count(*),2) as avg_reimb_per_patient,
     round(avg(avg_los),2) as avg_length_ostay,
     sum(case when pc.claim_count>1 then 1 else 0 end) as readmitted,
     round(sum(case when pc.claim_count>1 then 1 else 0 end)*100/count(*),2) as readm_rate,
     round(avg(pd.chronic_disease),2) as avg_chronic_disease
from patient_claims pc join patient_disease pd on pc.BeneID=pd.BeneID
join stg_provider p on pc.Provider = p.Provider
group by pc.Provider,p.PotentialFraud
having count(*)>=30
order by readm_rate desc;
     
select *from provider_summary;

drop view provider_summary;




