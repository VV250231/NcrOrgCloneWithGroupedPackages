/*
##################################################################################################
# Class Name............................:PSFR_RelatedList.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public class PSFR_RelatedList{
 Public Presales_Funding_Request__c MasterRecord {get;set;}
 public String MasterRecordId {get; set;}
 Public id accRecId;
 public List<Resource__c> ChildRecords{get;set;}

 public PSFR_RelatedList(ApexPages.StandardController controller) {    

   if(ApexPages.currentPage().getParameters().get('id') != null) {
     MasterRecordId=ApexPages.currentPage().getParameters().get('id');
     MasterRecord = [SELECT Name, PFR_Account_Name__c, Number_of_Resources__c, Total_Hours_not_to_exceed__c,Total_Hourly_Rate__c, Total_Travel_Cost_of_Resources__c, Total_Value_of_Resources__c
                     FROM Presales_Funding_Request__c WHERE Id = :MasterRecordId ];
     ChildRecords = [SELECT Name,
                            PFR_Num_of_days_not_to_exceed__c, 
                            PFR_BU__c,PFR_Daily_Rate_USD__c, 
                            PFR_Resource_Name__c,
                            PFR_Task__c, 
                            PFR_Total__c,
                            PFR_Travel_Cost__c,
                            PSFundingRequest__c
                     FROM Resource__c
                     WHERE PSFundingRequest__r.id = :MasterRecordId ];
         
   }
 }

}