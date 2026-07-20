import streamlit as st
import joblib
import numpy as np
import pandas as pd

model=joblib.load("fraud_model.pkl")
scaler=joblib.load("scaler.pkl")

st.title("Healthare Provider Fraud Detection")
st.write("Enter provider information below")

total_claims=st.number_input("Total claims")
total_patients=st.number_input("Total Patients")
claims_per_patient=st.number_input("Claims per patient")
total_reimb=st.number_input("Total Reimbursement")
avg_reimb_per_patient=st.number_input("Average Reimbursement per patient")
avg_length_ostay=st.number_input("Average length of stay")
readmitted=st.number_input("Readmitted Patients")
readm_rate=st.number_input("Readmission Rate")
avg_chronic_disease = st.number_input("Average Chronic Disease")

st.sidebar.title("About Project")

st.sidebar.info("""
Healthcare Provider Fraud Detection

Algorithm:
• Logistic Regression

Accuracy:
75%

AUC:
0.802

Developer:
Kalaivani
""") 
if st.button("Predict Fraud"):

    features = np.array([[
        total_claims,
        total_patients,
        claims_per_patient,
        total_reimb,
        avg_reimb_per_patient,
        avg_length_ostay,
        readmitted,
        readm_rate,
        avg_chronic_disease
    ]])

    features_scaled = scaler.transform(features)

    prediction = model.predict(features_scaled)

    probability = model.predict_proba(features_scaled)

    if prediction[0] == 1:
        st.error("⚠ Potential Fraud Provider")
    else:
        st.success("✅ Non-Fraud Provider")

fraud_prob = probability[0][1] * 100

st.metric(
    label="Fraud Probability",
    value=f"{fraud_prob:.2f}%"
)
st.progress(int(fraud_prob))
input_df = pd.DataFrame({
    "Feature":[
        "Total Claims",
        "Total Patients",
        "Claims per Patient",
        "Total Reimbursement",
        "Average Reimbursement",
        "Average Length of Stay",
        "Readmitted Patients",
        "Readmission Rate",
        "Average Chronic Disease"
    ],
    "Value":[
        total_claims,
        total_patients,
        claims_per_patient,
        total_reimb,
        avg_reimb_per_patient,
        avg_length_ostay,
        readmitted,
        readm_rate,
        avg_chronic_disease
    ]
})

st.subheader("Entered Values")
st.dataframe(input_df)

st.subheader("Top Fraud Indicators")

st.write("""
• High Total Reimbursement

• High Average Reimbursement per Patient

• Large Number of Claims

• High Readmitted Patients
""")

st.markdown("---")

st.caption(
    "Healthcare Provider Fraud Detection using Machine Learning | Developed by Kalaivani"
)