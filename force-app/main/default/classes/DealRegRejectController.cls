/*************************************************************************************************
*   ClassName :   DealRegRejectController
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
EBA_SF-2491     19-12-2022      Monika      JDK Locale impact - Upgrade API Part 5  
*************************************************************************************************/
public without sharing class DealRegRejectController {

    
    public Id dealId{get;set;}
    public String OppName{get;set;}
    public Deal_Registration__c dealReg{get;set;}
    public List<String> getListOfReason()
    {
        List<String> listofReason;
        dealReg= [SELECT Name, Id, Owner.name,Name_of_Account_Financial_Institution__c,VisualTemplate__c, End_Customer_Company_Name__c FROM Deal_Registration__c WHERE id=: dealId];
        If(dealReg.VisualTemplate__c  != null && dealReg.VisualTemplate__c != ''){
            listofReason = dealReg.VisualTemplate__c.split(',');
        }
        IF(dealReg.End_Customer_Company_Name__c != '' && dealReg.End_Customer_Company_Name__c != null){
            OppName = dealReg.End_Customer_Company_Name__c;
        }Else{
            OppName = dealReg.Name_of_Account_Financial_Institution__c;
        }
        return listofReason;
    }
}