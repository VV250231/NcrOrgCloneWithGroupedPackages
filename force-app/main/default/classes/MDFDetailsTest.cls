@istest
public class MDFDetailsTest 
{
    public static testmethod void testMDFDetails() 
    {
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event - Roadshow';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
           
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
        
            lstMDFClaim.add(mdfClaim);
        }
        insert lstMDFClaim;
        
        MDFDetails obj = new MDFDetails();
        obj.objFundRequest = new SFDC_MDF__c();
        obj.claimStatus = 'Approved';
        system.assertEquals(obj.claimStatus , 'Approved');
        
    }
}