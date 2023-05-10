public class convertSBRtoOpportunityCon {
    @AuraEnabled
    public static ConvertDetail convertToOpportunity (String specialBidRegID) 
    {
        ConvertDetail objConvertDetail = new ConvertDetail();
        
        Opportunity opp = new Opportunity();
        Deal_Registration__c sbr = [SELECT Id, Name, Deal_Name__c, TAM__c,NCR_Account_Manager__c, End_Customer_Company_Name__c, Status__c,Estimated_Close_Date__c, 
                                    NCR_Account_Senior_Manager__c, Funnel_Opportunity__c, Primary_Contact_NameText__c, Projected_Opportunity_Value__c, 
                                    CAM__c, Partner_Company_Name__c, Special_Bid_Registration_Type__c,Probability_Score__c	 FROM Deal_Registration__c WHERE Id =: specialBidRegID LIMIT 1];

        if( sbr.Status__c == 'Approved' && sbr.Funnel_Opportunity__c == null )
        {
            RecordType objRT =  [select Id from RecordType where Name = 'Indirect - Include in Funnel Reseller' and SobjectType = 'Opportunity'];
            opp.RecordTypeId = objRT.id;
            opp.Name = sbr.Deal_Name__c;
            opp.Partner_End_Customer__c  = sbr.End_Customer_Company_Name__c;
            opp.Amount = sbr.Projected_Opportunity_Value__c;
            opp.CloseDate = sbr.Estimated_Close_Date__c;
            opp.CAM__c = sbr.NCR_Account_Manager__c;
            opp.TAM__c = sbr.NCR_Account_Senior_Manager__c;
            opp.StageName = 'Analyzing';
            opp.AccountId = sbr.Partner_Company_Name__c;
            opp.Linked_Special_Bid_Registration__c = sbr.Id;
           	//opp.Net_New_Customer__c = (sbr.Special_Bid_Registration_Type__c == 'Net New Customer') ? True : False;
            opp.Probability = sbr.Probability_Score__c;
           // system.debug('---------------------opp.Net_New_Customer__c ' +opp.Net_New_Customer__c);
            objConvertDetail.objOppoturnity = opp;
            objConvertDetail.errorMsg = 'Success';
        }
        if(sbr.Status__c != 'Approved')
        {
            objConvertDetail.objOppoturnity = null;
            objConvertDetail.errorMsg = 'Only Approved Record can be converted into Opportunity.';
        }
        else if(sbr.Funnel_Opportunity__c != null )
        {
            objConvertDetail.objOppoturnity = null;
            objConvertDetail.errorMsg = 'Record has been already converted into Opportunity.';
        }
        
        return objConvertDetail;
       // system.debug('-----------------------' +objConvertDetail);
    }
    
    @AuraEnabled (cacheable=true)
    public static List<RecordType> getRecordTypeList(){
        Set<String> recordTypeDevName = new Set<String>();
        recordTypeDevName.add('Indirect_Exclude_from_Funnel');
        recordTypeDevName.add('Indirect_Include_in_Funnel');
        List<RecordType> oppRecTypeList = new List<RecordType>();
        oppRecTypeList = [SELECT Id, Name, DeveloperName, Description FROM RecordType 
        WHERE IsActive = true AND SobjectType = 'Opportunity' AND DeveloperName IN : recordTypeDevName ORDER BY Name ASC];
        return oppRecTypeList;
    }
    
    public class ConvertDetail
    {
        @AuraEnabled
        public Opportunity objOppoturnity;
        
        @AuraEnabled
        public String errorMsg;
    }
}