@isTest
private class ConvertToOpportunityBtnContTest{
    
    static testmethod  void PartnerOpportunityTest() {
        
        
        Contact con = new Contact();
        con.lastName = 'Test';
        insert con;
        
        Account act = new Account();
        act.Name = 'Partner Demo Account';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }    
        
        Partner_Opportunity__c obj = new Partner_Opportunity__c();
        obj.Amount__c = 100;
        obj.CAM__c = userinfo.getUserId();
        obj.End_Customer__c = 'End Customer';
        obj.Expected_Book_Date__c = system.today();
        obj.Opportunity_Name__c = 'Test Opportunity';
        obj.Partner_Account__c = act.Id;
        obj.TAM__c = null;  
        obj.Status__c = 'Approved';
        obj.Funnel_Opportunity__c = null;
        insert obj;
        ConvertToOpportunityBtnCont.convertToPartnerOpportunity(obj.id);
        
        obj.Status__c = 'Rejected';
        update obj;
        ConvertToOpportunityBtnCont.ConvertDetail cdObj = ConvertToOpportunityBtnCont.convertToPartnerOpportunity(obj.id);
        System.assert(cdObj.errorMsg=='Only Approved Record can be converted into Opportunity.');
        
    } 
}