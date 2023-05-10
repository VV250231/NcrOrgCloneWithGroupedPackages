/*************************************************************************************************
*   ClassName :   PramataContractEDWController
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
*************************************************************************************************/
public with sharing class PramataContractEDWController {
    @auraenabled    
    public static List<Pramata_Contracts_EDW__c> pramataGetData(id RecID)
    {
        List<Pramata_Contracts_EDW__c> data = [SELECT Pramata_Nbr__c,Pramata_Contract_Status__c,Pramata_Agg_Term_Type__c,Pramata_Agg_Start_Date__c,
                                           Pramata_Agg_End_Date__c,Pramata_Term_Effective_Date__c,
                                           Pramata_Last_Update_Date_Time__c FROM Pramata_Contracts_EDW__c WHERE Account_Master_Lookup__c= :RecID
                                           AND Pramata_Contract_Status__c in ('Current','Status cannot be determined') ORDER BY Pramata_Nbr__c DESC NULLS LAST ];
       // System.debug('@@@'+data);
        return data;        
    }
}