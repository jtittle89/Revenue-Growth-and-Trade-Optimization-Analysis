# Revenue-Growth-and-Trade-Optimization-Analysis

Project Overview:

This project demonstrates an end-to-end Revenue Growth Management (RGM) and Trade Promotion Analytics workflow, similar to what is used in Consumer Packaged Goods (CPG) organizations. 
The goal of the analysis is to evaluate promotion effectiveness, quantify incremental volume and revenue, and assess trade spend ROI to support pricing and promotional decision-making.

The project intentionally mirrors a real-world analytics workflow:

    SQL for data preparation, business logic, and metric calculation
    
    Python for validation, exploration, and advanced analysis
    
    Power BI for executive-ready visualization and decision support
    
    Business Objectives:

Business Problem

    Trade promotions represent a significant investment, but not all promotions generate profitable incremental volume. 
    
    This project answers key RGM questions:
    
    Which promotions generate incremental (non-base) volume?
    
    How do discount levels impact ROI?
    
    Which retailers and promo mechanics create or destroy value?
    
    Where should promotions be scaled, optimized, or cut?

Data Sources (Mock / Simulated)

  The analysis uses realistic mock datasets modeled after common CPG data sources:
  
    POS Sales Data – weekly unit sales, base price, promo flags
    
    Trade Promotion Data – trade spend, promo type, discount percent
    
    Product Master – product and pack attributes

Tools & Technologies

    SQL (MySQL) – data aggregation, base vs promo logic, ROI calculations
    
          Separate base volume vs promotional volume
          
          Calculate incremental units during promotions
          
          Apply discount-adjusted pricing
          
          Join trade spend data
          
          Compute incremental revenue and promotion ROI
          
          The final SQL output was exported as a clean, analysis-ready dataset for downstream tools.
          
          Output:
          
          promo_analysis_sql.csv
    
    Python (Pandas) – exploratory analysis, validation, and aggregation

          Validate SQL calculations

          Aggregate results by retailer and promo type
          
          Explore ROI distribution and discount effectiveness
          
          Prepare insights for visualization
    
    Power BI – interactive dashboards and executive reporting
    
          KPI Cards: Incremental Revenue, Trade Spend, Net Promo ROI, Avg Discount
        
          ROI by Retailer
          
          ROI by Promo Type
          
          Discount vs ROI Scatter Plot
          
          Trade Spend vs Incremental Revenue Analysis

    
  
  <img width="1443" height="812" alt="image" src="https://github.com/user-attachments/assets/25d03f53-5095-4c2b-8f00-86a7702dc245" />


Insights:

      Higher discounts do not always correlate with higher ROI
      
      Certain promo mechanics consistently outperform others
      
      Some retailers generate incremental volume efficiently, while others destroy value
      
      Weighted ROI provides a more accurate performance view than simple averages
