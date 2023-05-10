public with sharing class cpq_AutoPayUtil {
    
    private static EmailTemplate ncrStandardTemplate { 
        get {
            if (ncrStandardTemplate == null) {
                ncrStandardTemplate = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'NCR Standard' LIMIT 1];
            }
            return ncrStandardTemplate;
        } 
        set;
    } 

    @future
    public static void handleOppOwnerNotification (List<Id> siteIds, List<Id> quoteIds) {
        try {
            Map<Id,Account> siteIdToSite = new Map<Id,Account>([SELECT Id, Name, ParentId, Site_Number__c, Parent.Master_Customer_Number__c FROM Account WHERE Id IN : siteIds]);
            if (siteIdToSite.keySet().size() > 0) {
                emailAlertToOppOwner(siteIdToSite, quoteIds);
            }
        } catch (exception ex) {
            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex, 'cpq_AutoPayUtil');
        }
        
    }

    public static void emailAlertToOppOwner (Map<Id,Account> siteIdToSite, List<Id> quoteIds){
        Map<Id, Set<Id>> billToSiteIdToOppOwnerIds = new Map<Id, Set<Id>>();
        
        List<SBQQ__Quote__c> quoteRecords = getOpenOpportunityQuotesByIds(quoteIds);
        
        if (quoteRecords.size() > 0) {
            for(SBQQ__Quote__c obj : quoteRecords) {
                if (billToSiteIdToOppOwnerIds.containsKey(obj.qtc_Bill_To_Site__c)) {
                    billToSiteIdToOppOwnerIds.get(obj.qtc_Bill_To_Site__c).add(obj.SBQQ__Opportunity2__r.ownerId);
                } else {
                    billToSiteIdToOppOwnerIds.put(obj.qtc_Bill_To_Site__c, new Set<Id>{obj.SBQQ__Opportunity2__r.ownerId});
                }
            }
        }

        Messaging.SingleEmailMessage[] messages = new List <Messaging.SingleEmailMessage>();
              
        for (Account billToSite : siteIdToSite.values()) {
            if (billToSiteIdToOppOwnerIds.containsKey(billToSite.Id)) {
                String emailBody = '';          
                String templateBody = ncrStandardTemplate.HtmlValue;
                String emailBodytoReplaced = 'Hello,<br><br>AutoPay has been successfully activated for this site.<b><br>Site Name: '+billToSite.Name+ '<br>Site Number: '+billToSite.Site_Number__c+'<br>Master Cusomer number: '+billToSite.Parent.Master_Customer_Number__c+'<b><br><br>';      
                
                emailBody = templateBody.replace('#Body', emailBodytoReplaced);
                emailBody = emailBody.replace('#Header', 'AutoPay Setup Succeeded');
                emailBody = emailBody.replace('#HeadLine', 'AutoPay Setup Succeeded for '+ billToSite.Name);
                for (Id oppOwnerId : billToSiteIdToOppOwnerIds.get(billToSite.Id)) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(oppOwnerId);
                    message.subject = 'AutoPay Setup Succeeded for '+billToSite.Name;
                    message.setHtmlBody(emailBody); 
                    message.setSaveAsActivity(false);
                    messages.add(message);
                }
            }
        }

        if (messages.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }       
    }

    public static List<SBQQ__Quote__c> getOpenOpportunityQuotesBySiteIds(List<Id> billToSiteIds) {
        List<SBQQ__Quote__c> quotes = [
                SELECT 
                    Id,qtc_Bill_To_Site__c,SBQQ__Opportunity2__r.ownerId 
                FROM 
                    SBQQ__Quote__c 
                WHERE 
                    qtc_Bill_To_Site__c IN : billToSiteIds 
                    AND SBQQ__Opportunity2__r.CPQ__c = true 
                    AND SBQQ__Opportunity2__r.IsClosed = false
        ];
        return quotes;                
    }

    public static List<SBQQ__Quote__c> getOpenOpportunityQuotesByIds(List<Id> quoteIds) {
        List<SBQQ__Quote__c> quotes = [
                SELECT 
                    Id,qtc_Bill_To_Site__c,SBQQ__Opportunity2__r.ownerId 
                FROM 
                    SBQQ__Quote__c 
                WHERE 
                    Id IN : quoteIds
        ];
        return quotes;                
    }
   
}