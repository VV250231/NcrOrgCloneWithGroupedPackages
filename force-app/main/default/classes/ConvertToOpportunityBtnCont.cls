public class ConvertToOpportunityBtnCont {
    @AuraEnabled
    public static ConvertDetail convertToPartnerOpportunity (String partnerOpportunityObjId) 
    {
       ConvertDetail objConvertDetail = new ConvertDetail();
        
        Opportunity opp = new Opportunity();
        Partner_Opportunity__c po = [SELECT Id, Name,TAM__c, Opportunity_Name__c, End_Customer__c, Status__c, Funnel_Opportunity__c,
                                     	End_Customer_Primary_Contact__c,Partner_Sales_Person__c, Amount__c, Expected_Book_Date__c, CAM__c, Partner_Account__c FROM Partner_Opportunity__c WHERE Id =: partnerOpportunityObjId LIMIT 1];
        if(	po.Status__c == 'Approved' && po.Funnel_Opportunity__c == null )
        {
            RecordType objRT =  [select Id from RecordType where Name = 'Indirect - Include in Funnel Reseller' and SobjectType = 'Opportunity'];
            opp.RecordTypeId = objRT.id;
            opp.Name = po.Opportunity_Name__c;
            opp.Partner_End_Customer__c  = po.End_Customer__c;
            opp.Amount = po.Amount__c;
            opp.CloseDate = po.Expected_Book_Date__c;
            opp.CAM__c = po.CAM__c;
            opp.TAM__c = po.TAM__c;
            opp.StageName = 'Analyzing';
            opp.AccountId = po.Partner_Account__c;
            opp.Linked_Partner_Opportunity__c = po.Id;
            
            objConvertDetail.objOppoturnity = opp;
            objConvertDetail.errorMsg = 'Success';
        }
         if(po.Status__c != 'Approved')
        {
            objConvertDetail.objOppoturnity = null;
            objConvertDetail.errorMsg = 'Only Approved Record can be converted into Opportunity.';
        }
        else if(po.Funnel_Opportunity__c != null )
        {
            objConvertDetail.objOppoturnity = null;
            objConvertDetail.errorMsg = 'Record has been already converted into Opportunity.';
        }
        
        return objConvertDetail;
        //return null;
    }
    
    public class ConvertDetail
    {
        @AuraEnabled
        public Opportunity objOppoturnity;
        
        @AuraEnabled
        public String errorMsg;
    }
}