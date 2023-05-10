@isTest
private class convertSBRtoOpportunityConTest{
    
    static testmethod  void PartnerOpportunityTest() {
        
        
        Contact con = new Contact();
        con.lastName = 'Test';
        insert con;
        Account act = TestRecordsFactory.createAccount('Test Account',Null);
        
        Deal_Registration__c sbr = new  Deal_Registration__c();
        sbr.Deal_Name__c = 'test';
        sbr.End_Customer_Company_Name__c = 'End Customer';
        sbr.Projected_Opportunity_Value__c = 1000;
        sbr.Estimated_Close_Date__c = system.today();
        sbr.NCR_Account_Manager__c = userinfo.getUserId();
        sbr.NCR_Account_Senior_Manager__c = userinfo.getUserId();
        sbr.Partner_Company_Name__c = act.Id;
        sbr.Status__c = 'Approved';
        insert sbr;
        
        convertSBRtoOpportunityCon.ConvertDetail objConvertDetail = new convertSBRtoOpportunityCon.ConvertDetail();
        objConvertDetail = convertSBRtoOpportunityCon.convertToOpportunity(sbr.id);
        system.debug(objConvertDetail);
        
        system.assert(objConvertDetail.errorMsg =='Success','Fail to convert opportunity');
        
        sbr.Status__c = 'Rejected';
        update sbr;
        objConvertDetail = convertSBRtoOpportunityCon.convertToOpportunity(sbr.id);
        system.assert(objConvertDetail.errorMsg =='Only Approved Record can be converted into Opportunity.');
        convertSBRtoOpportunityCon.getRecordTypeList();
        
        Opportunity opp = TestRecordsFactory.createOpportunity(act.id,'Test MarketProductOpp','Analyzing',true);
        
        Deal_Registration__c sbr2 = new  Deal_Registration__c();
        sbr2.Deal_Name__c = 'test';
        sbr2.End_Customer_Company_Name__c = 'End Customer';
        sbr2.Projected_Opportunity_Value__c = 1000;
        sbr2.Estimated_Close_Date__c = system.today();
        sbr2.NCR_Account_Manager__c = userinfo.getUserId();
        sbr2.NCR_Account_Senior_Manager__c = userinfo.getUserId();
        sbr2.Partner_Company_Name__c = act.Id;
        sbr2.Status__c = 'Approved';
        sbr2.Funnel_Opportunity__c = opp.id;
        insert sbr2;    
        objConvertDetail = convertSBRtoOpportunityCon.convertToOpportunity(sbr2.id);
        system.assert(objConvertDetail.errorMsg =='Record has been already converted into Opportunity.');
    } 
}