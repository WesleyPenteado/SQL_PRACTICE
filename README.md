# Praticando SQL - Questionários de entrevistas

## Overview
    Este repositório foi criado no intuíto de compartilhar questionários de entrevistas para o desenvolvimento das habilidades em SQL.

📚 **Base de dados**: [Microsoft - Sales Data Contoso](https://www.microsoft.com/en-us/download/details.aspx?id=46801)


    **Questionário 1 + Soluções**: [interview_questions_1.sql](interview_questions_1.sql)





## Analysis Approach

### 1. Customer Segmentation
- Identified customers lifetime value (LTV) 
- Segmented customers into high, mid and low-value groups
- Analyzed each segment's share of total customer value

🖥️ Query: [1_customer_segmentation.sql](1_customer_segmentation.sql)


📈 **Visualization:**

<img src="images\1_image.png" width="50%">


📊 **Key Findings:**
- High_value segment (25% of customers) drives 66% of revenue ($135.4M)
- Mid_value segment (50% of customers) generates 32% of revenue ($66.6M)
- Low-value segment (25% of customers) accounts for 2% of revenue ($4.3M)

💡**Business Insights**
- High-Value (66% revenue): Offer premium membership program to 12.372 VIP customers, as losing one customer significantly impacts revenue.
- Mid-value (32% revenue): Create upgrade paths through personalized promotions, with potential $66.6M -> $135.4M revenue oportunity.
- Lor-value (2% revenue): Design re-engagement campaigns and price-sensitive promotions to increase purchase frequency.

### 2. Cohort Analysis
- Tracked revenue and customer count per cohorts
- Cohorts were grouped by year of first purchase
- Analyzed customer retention at a cohort level

🖥️ Query: [2_cohort_analysis.sql](/2_cohort_analysis.sql)

📈 **Visualization:**

<img src="images\2_image.png" width="80%">

📊 **Key Findings:**
- Revenue per customer shows an alarming decreasing trend over time
- 2022-2024 cohorts are consistently performing worse than earlier cohorts
- NOTE: Although net revenue is increasing, this is likely due to a larger customer base, which is not reflective of customer value.

💡**Business Insights**
- Value extracted from customers is decreasing over time and needs further investigation
- In 2023 we saw a drop in number of customers acquired, which is concerning
- With both lowering LTV and decreasing customer acquisition, the company is facing a potential revenue decline

### 3. Customer Retention
- Identified customers at risk of churning
- Analyzed last purchase patterns
- Calculated customer-specific metrics

🖥️ Query: [3_retention_analysis.sql](/3_retention_analysis.sql)

📈 **Visualization:**

<img src="images\3_image.png" width="80%">

📊 **Key Findings:**
- Cohort churn stabilizes at ~90% after 2-3 years, indicating a predictable long-term retention pattern.
- Retention rates are consistently low (8-10%) across all cohorts, suggesting retention issues are systemic rather than specific to certain years.
- Newer cohorts (2022-2023) show similar churn trajectories , signaling that without intervention, future cohorts will follow the same pattern.

💡**Business Insights**
- Strengthen early engagement strategies to target first 1-2 years with onboarding incentives, loyalty rewards, and personalized offers to improve long-term retention.
- Re-engage high-value churned customers by focusing on targeted win-back campaigns rather  than broad retention efforts, as reactivating valuable users may yeld higher ROI.
- Predict & preempt churn risk and use customer_specific warning indicators to proactively intervene at-risk users before they lapse.




