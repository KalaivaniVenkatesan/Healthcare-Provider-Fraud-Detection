/*PROVIDERS*/
/*Total Providers
Business Question
How many healthcare providers are in our network?*/
select count(*) total_providers from stg_provider;

/*Fraud Distribution*/
select PotentialFraud,count(*) as providers,round(count(*)*100/(select count(*) from stg_provider)) as percentage
from stg_provider group by PotentialFraud;




/*INPATIENTS*/

/*Number of Beneficiaries*/
select count(*) total_beneficiary from stg_beneficiary;

/*Total Inpatient Claims*/
select count(*) total_inpatiet_claims from stg_ip;

/*Total Outpatient Claims*/
select count(*) total_Outpatiet_claims from stg_op;

/*Average Claims per Provider*/
select provider,count(*) total_claims from
(select provider from stg_ip
union all
select provider from stg_op) as claims
group by provider 
order by total_claims desc;

/*Do Potential Fraud providers receive higher reimbursement amounts than Non-Fraud providers?*/
select p.PotentialFraud,count(i.ClaimID) as total_claim,round(avg(i.InscClaimAmtReimbursed),2) as avg_reimb,
round(sum(i.InscClaimAmtReimbursed),2) as total_reimb
from stg_ip i
join
stg_provider p on i.Provider = p.Provider
group by p.PotentialFraud;

select p.PotentialFraud,count(o.ClaimID) as total_claims,round(avg(o.InscClaimAmtReimbursed),2) as avg_reimb,
round(sum(o.InscClaimAmtReimbursed),2) as total_reimb
from stg_op o
join stg_provider p on o.Provider=p.Provider
group by p.PotentialFraud;

/*length of stay*/
SELECT AdmissionDt,
       DischargeDt
FROM stg_ip
LIMIT 10;

select p.PotentialFraud,count(i.ClaimID) as total_claims,round(avg(datediff(STR_TO_DATE(i.AdmissionDt,'%d-%m-%y'),STR_TO_DATE(i.DischargeDt,'%d-%m-%y'))),2) as legnth_of_stay
from stg_ip i join stg_provider p on i.Provider=p.Provider group by p.PotentialFraud;

SELECT
AdmissionDt,
DischargeDt,
DATEDIFF(
STR_TO_DATE(DischargeDt,'%d-%m-%Y'),
STR_TO_DATE(AdmissionDt,'%d-%m-%Y')
) AS Length_of_Stay
FROM stg_ip
LIMIT 10;

SELECT
    DATEDIFF(
        STR_TO_DATE(DischargeDt,'%d-%m-%Y'),
        STR_TO_DATE(AdmissionDt,'%d-%m-%Y')
    ) AS Length_of_Stay,
    COUNT(*) AS Total_Claims
FROM stg_ip
GROUP BY Length_of_Stay
ORDER BY Length_of_Stay;
 
/*Do Potential Fraud providers receive higher reimbursement per patient?*/
select p.PotentialFraud,count(*) as total_patients,round(avg(total_reimb),2) avg_reimb_per_patient 
from
       (select BeneID,Provider,sum(InscClaimAmtReimbursed) as total_reimb from stg_ip  group by BeneID,Provider) t
join stg_provider p on t.Provider=p.Provider group by p.PotentialFraud;

/*Do Potential Fraud providers submit more claims per provider than Non-Fraud providers?*/
select p.PotentialFraud,count(*) providers,round(avg(t.total_claims),2) avg_claims_per_provider,max(t.total_claims) as highest_claim from
(select Provider,count(ClaimID) as total_claims from stg_ip group by Provider) t
join stg_provider p on t.Provider=p.Provider group by p.PotentialFraud;

/*Do Potential Fraud providers treat patients with more chronic diseases than Non-Fraud providers?*/
WITH beneficiary_disease AS (
SELECT
    BeneID,

    (
    CASE WHEN ChronicCond_Alzheimer=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Heartfailure=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_KidneyDisease=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Cancer=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_ObstrPulmonary=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Depression=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Diabetes=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_IschemicHeart=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Osteoporasis=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_rheumatoidarthritis=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_stroke=1 THEN 1 ELSE 0 END
    ) AS Total_Chronic_Diseases

FROM stg_beneficiary
)

SELECT
    p.PotentialFraud,
    COUNT(DISTINCT i.BeneID) AS Total_Patients,
    ROUND(AVG(b.Total_Chronic_Diseases),2) AS Avg_Chronic_Diseases
FROM stg_ip i
JOIN stg_provider p
    ON i.Provider = p.Provider
JOIN beneficiary_disease b
    ON i.BeneID = b.BeneID
GROUP BY p.PotentialFraud;

/*PROVIDER SUMMARY*/

select i.Provider,
        p.PotentialFraud,
        count(distinct i.BeneID) as total_patients,
        count(i.ClaimID) as total_claims,
        sum(i.InscClaimAmtReimbursed) as total_reimb,
		round(avg(i.InscClaimAmtReimbursed),2) as avg_reimb,
		round(
          avg(
          datediff(str_to_date(i.DischargeDt,'%d-%m-%Y'),
          str_to_date(i.AdmissionDt,'%d-%m-%Y'))),2) as avg_length_ofstay,
	   dense_rank() over( order by sum(i.InscClaimAmtReimbursed) desc) as reimb_rank
from stg_ip i 
join 
stg_provider p on i.Provider=p.Provider 
group by i.Provider,p.PotentialFraud
order by total_reimb desc limit 5;

/*METRICS*/
select i.Provider,
        p.PotentialFraud,
        count(distinct i.BeneID) as total_patients,
        count(i.ClaimID) as total_claims,
        sum(i.InscClaimAmtReimbursed) as total_reimb,
        round(count(i.ClaimID)/count(distinct i.BeneID),2) as claim_per_patiet,
        round(sum(InscClaimAmtReimbursed)/count(distinct i.BeneID),2) as reimb_per_patiet,
		round(avg(i.InscClaimAmtReimbursed),2) as avg_reimb,
		round(
          avg(
          datediff(str_to_date(i.DischargeDt,'%d-%m-%Y'),
          str_to_date(i.AdmissionDt,'%d-%m-%Y'))),2) as avg_length_ofstay,
	   dense_rank() over( order by sum(i.InscClaimAmtReimbursed) desc) as reimb_rank
from stg_ip i 
join 
stg_provider p on i.Provider=p.Provider 
group by i.Provider,p.PotentialFraud
order by total_reimb desc limit 5;

/*AVERAGE AGE OF PATIENTS TREATED BY FRAUD VS NON FRAUD PROVIDERS*/
select 
       p.PotentialFraud,
      round(avg(timestampdiff(YEAR,str_to_date(b.DOB,'%d-%m-%Y'),str_to_date(i.AdmissionDt,'%d-%m-%Y'))),2)as avg_patient_age
from stg_ip i join stg_beneficiary b on i.BeneID = b.BeneID 
join stg_provider p on i.Provider = p.Provider group by p.PotentialFraud order by p.PotentialFraud;

/*Do Potential Fraud providers have higher patient readmission rates than Non-Fraud providers, 
and which providers should be prioritized for investigation based on a reliable patient population*/
with patient_claims as (
select 
     BeneID,Provider,
     count(ClaimID) as claim_count
from stg_ip group by BeneID,Provider)
select 
   pc.Provider,count(*) as total_patient,p.PotentialFraud,
   sum(case when claim_count>1 then 1 else 0 end ) as readmitted_patients,
   round((sum(case when claim_count>1 then 1 else 0 end) /count(*))*100,2) as readm_rate
from patient_claims pc join stg_provider p on pc.Provider=p.Provider 
group by pc.Provider,p.PotentialFraud 
HAVING COUNT(*) >= 30
order by readm_rate desc;

/*Are providers with higher readmission rates treating patients with more chronic diseases, 
or do some providers have unusually high readmission rates despite treating less medically complex patients?*/
with patient_claims as (
select 
     BeneID,Provider,
     count(ClaimID) as claim_count
from stg_ip group by BeneID,Provider),
patient_disease AS (
SELECT
    BeneID,

    (
    CASE WHEN ChronicCond_Alzheimer=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Heartfailure=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_KidneyDisease=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Cancer=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_ObstrPulmonary=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Depression=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Diabetes=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_IschemicHeart=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_Osteoporasis=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_rheumatoidarthritis=1 THEN 1 ELSE 0 END +
    CASE WHEN ChronicCond_stroke=1 THEN 1 ELSE 0 END
    ) AS total_Chronic_Diseases

FROM stg_beneficiary
)
select 
   pc.Provider,count(*) as total_patient,p.PotentialFraud,
   sum(case when claim_count>1 then 1 else 0 end ) as readmitted_patients,
   round((sum(case when claim_count>1 then 1 else 0 end) /count(*))*100,2) as readm_rate,
   round(avg(pd.total_Chronic_Diseases),2) as avg_chronic_disease
from patient_claims pc  join patient_disease pd on pc.BeneID=pd.BeneID
join stg_provider p on pc.Provider=p.Provider
group by pc.Provider,p.PotentialFraud 
HAVING COUNT(*) >= 30
order by readm_rate desc;





/*OUTPATIENT CLAIMS*/

/*How many outpatient claims are present in the insurance network?*/
select count(*) as total_op from stg_op;

/*Do Potential Fraud providers receive higher outpatient reimbursements than Non-Fraud providers?*/
select p.PotentialFraud,sum(InscClaimAmtReimbursed) as reimb_amnt,
   round(avg(InscClaimAmtReimbursed),2) as av_reimb
   from stg_op op join stg_provider p on op.Provider=p.Provider
group by p.PotentialFraud
order by reimb_amnt desc;

/*Do Potential Fraud providers have more outpatient claims per patient?*/
with op_claims as(
     select BeneID,Provider,count(ClaimID) as claim_count
  from stg_op group by Provider,BeneID
)
select p.PotentialFraud,count(*) as total_patients,
sum(claim_count) as total_claims,
round(sum(claim_count)/count(*),2) as claims_per_patient
 from op_claims oc join stg_provider p on oc.Provider=p.Provider
 group by p.PotentialFraud;
 
 /*Which providers have the highest outpatient reimbursement?*/
 select op.Provider,p.PotentialFraud,sum(op.InscClaimAmtReimbursed) as tot_reimb,
 round(avg(op.InscClaimAmtReimbursed),2) as avg_reimb,
 dense_rank() over(order by sum(op.InscClaimAmtReimbursed) desc ) as reim_rank
  from stg_op op join stg_provider p on op.Provider=p.Provider group by op.Provider,p.PotentialFraud limit 10;
  
/*Which providers have the highest outpatient visits per patient?*/
with op as(
select BeneID,Provider,count(*) as total_patients,count(ClaimID) as claim_count 
      from stg_op group by Provider,BeneID
)
select o.Provider,p.PotentialFraud,sum(claim_count) as total_visits,
round(sum(o.claim_count)/count(*),2) as visits_per_patient,
dense_rank() over(order by sum(claim_count)/count(*) desc) as visit_rank 
from op o join stg_provider p on o.Provider=p.Provider group by o.Provider,p.PotentialFraud limit 10;
     
/*Which providers should be investigated based on outpatient behavior?*/
with op_summary as (
select Provider,
count(distinct BeneID) as tot_patients,
count(ClaimID) as tot_claims,
sum(InscClaimAmtReimbursed) tot_reimb,
round(avg(InscClaimAmtReimbursed),2) as avg_reimb,
round(count(ClaimID)/count(distinct BeneID),2) as visit_per_patient
from stg_op group by Provider
)
select os.Provider,
 p.PotentialFraud,
 os.tot_patients,
 os.tot_claims,
 os.tot_reimb,
 os.avg_reimb,
 os.visit_per_patient,
 dense_rank() over(order by os.tot_reimb desc,os.visit_per_patient desc) as risk_rank
 from op_summary os join stg_provider p on os.Provider=p.Provider limit 10;
 
show databases;

select * from provider_summary

