public with sharing class OppQuickEditCtlr {


    public Opportunity oppObj{get;set;}
    public Date expBookDate{get;set;}
    public String expDeliveryDate{get;set;}
    
    public OppQuickEditCtlr(ApexPages.StandardController stdController) {
        this.oppObj = (Opportunity)stdController.getRecord();
        
        if(oppObj != null && oppObj.Id != null) {
            this.oppObj = [SELECT Id, recordtypeid, Name, AccountId,Account.Name,Contacts__c,Contacts__r.Name,Amount,Type,Industry__c,Marketing_Program__c, CloseDate,StageName, Expected_Delivery_Date__c,Forecast_Category__c FROM Opportunity WHERE Id = :oppObj.Id LIMIT 1];  
            this.expBookDate = oppObj.CloseDate;
            
			if (oppObj.Expected_Delivery_Date__c != null) {
                this.expDeliveryDate = oppObj.Expected_Delivery_Date__c.format();
            }
        }
    }
    
    public void saveOppRecord() {
        if(oppObj != null) {
            System.debug(oppObj);
            if(expBookDate != null) oppObj.CloseDate = expBookDate;
            //if(expDeliveryDate != null) oppObj.Expected_Delivery_Date__c = expDeliveryDate;
                
            try {
                update oppObj;
            }  catch(Exception e) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:' + e.getMessage())); 
            }
        }
    }
}