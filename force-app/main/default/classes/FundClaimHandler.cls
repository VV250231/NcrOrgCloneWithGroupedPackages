/*
# Project Name: IDT                                                                                                                            
# Description: This is the trigger handler class fo "Fund Claim" object. It handles all the trigger functionalities.                                                            
# Created by: Anupam Agrawal                                                                     
# Created Date: 3 May 2017                                                                              
# Last Modified by: Anupam Agrawal                                                                         
# Last Modified Date: 3 May 2017                                                                        
*/

public class FundClaimHandler 
{ 
    //Method invokes at After Insert event
    public void onAfterInsert(Map<Id, SFDC_MDF_Claim__c> mapIdToFundClaim)
    {
        //Call private method to populate Claim Month and Year values on Fund Request Month and Year fields.
        populateFundRequestReleasedMonthAndYear(mapIdToFundClaim, null);
        if(!Test.isRunningTest()){
            BatchShareMDFClaim obj = new BatchShareMDFClaim(mapIdToFundClaim.keySet());
            Database.executeBatch(obj, 1); 
        }
    }
    
    //Method invokes at After Update event
    public void onAfterUpdate(Map<Id, SFDC_MDF_Claim__c> mapNewIdToFundClaim, Map<Id, SFDC_MDF_Claim__c> mapOldIdToFundClaim)
    {
        //Call private method to populate Claim Month and Year values on Fund Request Month and Year fields.
        populateFundRequestReleasedMonthAndYear(mapNewIdToFundClaim, mapOldIdToFundClaim);
    }
    
    //Local Mehtod resposible to populate Claim month and year on Associated Fund Request record.
    private void populateFundRequestReleasedMonthAndYear(Map<Id, SFDC_MDF_Claim__c> mapNewIdToFundClaim, Map<Id, SFDC_MDF_Claim__c> mapOldIdToFundClaim)
    {
        List<SFDC_MDF__c> lstUpdateFundRequest = new List<SFDC_MDF__c>();
        
        List<SFDC_MDF_Claim__c> lstNewFundClaim = new List<SFDC_MDF_Claim__c>();
        
        //Insert New Fund Claim 
        if(mapOldIdToFundClaim == null)
        {
            lstNewFundClaim.addAll(mapNewIdToFundClaim.values());
        }
        else //Update Fund Claim 
        {
            for(SFDC_MDF_Claim__c objNewFundClaim : mapNewIdToFundClaim.values())
            {
                SFDC_MDF_Claim__c objOldFundClaim = mapOldIdToFundClaim.get(objNewFundClaim.Id);
                if((objNewFundClaim.Fund_Request__c != null && 
                    ((objOldFundClaim.Released_Funds__c != objNewFundClaim.Released_Funds__c) || 
                        (objOldFundClaim.Released_Month__c != objNewFundClaim.Released_Month__c) || 
                        (objOldFundClaim.Released_Year__c != objNewFundClaim.Released_Year__c))))
                {
                    lstNewFundClaim.add(objNewFundClaim);
                }
            }
        }
        
        for(SFDC_MDF_Claim__c objNewFundClaim : lstNewFundClaim)
        {   
            if(String.isNotBlank(objNewFundClaim.Fund_Request__c))
            {
                SFDC_MDF__c objFundRequest = new SFDC_MDF__c(Id = objNewFundClaim.Fund_Request__c);
                objFundRequest.Released_Month__c = objNewFundClaim.Released_Month__c;
                objFundRequest.Released_Year__c = objNewFundClaim.Released_Year__c;
                
                if(mapOldIdToFundClaim != null)
                {
                    SFDC_MDF_Claim__c objOldFundClaim = mapOldIdToFundClaim.get(objNewFundClaim.Id);
                    if(objOldFundClaim.Released_Funds__c != objNewFundClaim.Released_Funds__c)
                        objFundRequest.Released_Amount__c = objNewFundClaim.Released_Funds__c;
                }
                else
                    objFundRequest.Released_Amount__c = objNewFundClaim.Released_Funds__c;
                lstUpdateFundRequest.add(objFundRequest);
            }
        }
        
        //Update Fund Request
        if(!lstUpdateFundRequest.isEmpty())
        {
            update lstUpdateFundRequest;
        }
    }
}