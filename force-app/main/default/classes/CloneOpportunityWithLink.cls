Public class CloneOpportunityWithLink{

    Public Opportunity Opp = new Opportunity();
    Public Opportunity Opp_CLONED = new Opportunity();


    Public CloneOpportunityWithLink(ApexPages.StandardController stdController)
    {
    Opp = (Opportunity)stdController.getRecord();
    
    
    }
    
    Public PageReference autoRun()
    {//Fields removed from below SOQL Secondary_Competitor__c, Executive_Sponsor_Name__c,Executive_Sponsor__c,Executive_Sponsorship_for_the_Deal__c
    Opp = [SELECT AccountId,Account_LOB__c, Actual_Close_Date__c, ClonedFromOpportunity__c ,/* Advocated_Solution__c,*/Age_Actual__c,Age_Bucket__c,Amount,Annuity_Contract_Term__c,Annuity_Contract_Value_USD__c,Annuity_Contract_Value__c,Annuity_Contract__c,/*Annuity_Opp_Amount_USD__c,Annuity_Opp_Amount__c,/*Application__c,*/Book_Month_Week__c,Book_Month__c,Book_Quarter_Week__c,Book_Quarter__c,Book_Year_Week__c,briefingedge__Visit_Data__c,bypass_validation__c,/*CampaignId,Campaign_Activity_System__c,*/cat_0_score_oppscore__c,cat_0_score__c,Channel_Transaction_Type__c,CloseDate,Cloud_Products__c,/*CMS_Hardware_Platform__c,*/Commitment_Risk__c,/* Competition_Status__c, Competitor_Comments__c,*/ Contacts__c,Contract_Expiration_Date__c,Contract_Signed_Date__c,Converted_Opportunity_Amount__c,CreatedById,CreatedDate,Created_Date_Actual__c,Created_Date__c,CurrencyIsoCode,Currency_Conversion_Rate__c,Description,Discontinued_Reasons__c,EBD__c,Expected_Delivery_Date__c,ForecastCategory,ForecastCategoryName,Forecast_Category__c,Fulfilled_by_Partner__c,GAM_Owner__c,/*Global_Opportunity__c,*/ Hardware_Products__c,/*HasOpenActivity,*/HasOpportunityLineItem,/*HasOverdueTask,*/Has_Value_Prompter_Completed__c,/* HW_GP__c,*/ Id,Initial_Renewal_Value__c,Invoice_Trigger__c,/*IPS_Order_Type__c,*/ IsClonedByPackage__c,IsClone__c,IsClosed,IsDeleted,IsQuoteCreatedInOtherSystem__c,IsWon,Is_PreBuild_Order__c,Key_Criteria_Comments__c,Key_Criteria__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LeadSource,Marketing_Program__c,Master_Distributor__c,Monthly_Gross_Profit__c,Name,Need_to_Engage_Proposal_Services__c,NextStep,Notes__c,NotifyOwnerforValuePrompter__c,NotifyOwnerManagerforValuePrompter__c,OCR_TEAM__c,Opportunity_Classification__c,Opportunity_Number__c,Opportunity_Site_Count__c,Overall_Contract_Value__c,OwnerAssignedDate__c,OwnerId,Owner_Manager_Email__c,PreBuild_Order_Number__c,Previous_Forecast_Category__c,Pricebook2Id,Price_Variance__c,Primary_Competitor__c,/* Proposal_Service_Type__c , */ PS_Products__c,RecordTypeId,Reseller__c,RFP_RFI_Issued__c,Risk_Comments__c,SALESFORCE_18_DIGIT_ID__c,Salesforce_ID__c,Sales_Org_Code__c,Sales_Org__c,Services_Products__c,Service_Order_Type__c,Software_Products__c,Soln_Opp_Amount__c,Solution_Engineer__c,Solution_Opp_Amount_USD__c,/*Solution_Opp_Amount__c,Solution_Portfolio__c,-P360 Initial Change - Ahad*/StageName,SystemModstamp,S_I_Products__c,Top/*_Deal__c,Top*/_Line_Total_Price__c,Total_HW_GM_Rev__c,Total_Quote_Amount_QUBY__c,Type,User_Modified_Date__c,zqu__CurrentGenerators__c,zqu__DeliveryInstallationStatus__c,zqu__MainCompetitors__c,zqu__OrderNumber__c,zqu__TrackingNumber__c,zqu__ZuoraConfig__c FROM Opportunity Where ID = :  Opp.Id];
    Opp_CLONED = Opp.clone(false, true, false, false);
    Opp_CLONED.ForecastCategoryName = NULL; Opp_CLONED.Forecast_Category__c = NULL;
    Opp_CLONED.StageName = 'Analyzing';
    //Opp_CLONED.Advocated_Solution__c = NULL;
   Opp_CLONED.cat_0_score_oppscore__c = 0;
    Opp_CLONED.Actual_Close_Date__c = NULL; Opp_CLONED.Created_Date__c = NULL; Opp_CLONED.Expected_Delivery_Date__c = NULL;
    Opp_CLONED.IsClonedByPackage__c = 'Yes';if(Opp_CLONED.ClonedFromOpportunity__c == NULL){Opp_CLONED.ClonedFromOpportunity__c = Opp.Id;}
    Database.insert(Opp_CLONED);
    PageReference PageRef = new PageReference('/'+Opp_CLONED.id);  PageRef.setRedirect(true); return PageRef;
    }
    
}