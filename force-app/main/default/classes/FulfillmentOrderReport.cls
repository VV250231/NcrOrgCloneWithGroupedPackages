global class FulfillmentOrderReport implements Schedulable{
    public Id partnerId{get;set;}
    public String getInstanceURL(){
        return System.URL.getSalesforceBaseURL().toExternalForm();
    }
    private DateTime getOrderStartDateUpperLimit(){
        DateTime dt1 = DateTime.now();
		DateTime dt2= DateTime.newInstance(dt1.year(), dt1.month()+1, 1, dt1.hour(),dt1.minute(),dt1.second());
        return dt2;
    }
    public String getAlohaBusinessEmail(){
        return NCR_CPQBLG_Email__c.getValues('Order Management').Email__c;
    } 
    
    public List<qtc_FulfillmentOrder__c> getFulfillmentOrders() {
        List<qtc_FulfillmentOrder__c> fulfillmentOrders;
		String qry='SELECT Id, Name,qtc_Quote__r.Name, qtc_Quote__r.SBQQ__Partner__r.Name, qtc_Quote__r.SBQQ__Account__r.Name, qtc_Quote__r.Deliver_To_Site__r.Name,qtc_OrderStartDate__c FROM qtc_FulfillmentOrder__c WHERE qtc_Quote__r.SBQQ__Partner__c= :partnerId AND qtc_Quote__r.SBQQ__Ordered__c = false AND qtc_OrderStartDate__c <= ' +getOrderStartDateUpperLimit().format('yyyy-MM-dd');
        fulfillmentOrders = Database.query(qry);        
        return fulfillmentOrders;
    }
    
    global void execute(SchedulableContext sc){
        List<Messaging.SingleEmailMessage> lstMessages = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce.donotreply@ncr.com'];
        
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Fulfillment_Order_Reports_For_Channel'];
		List<qtc_FulfillmentOrder__c> fOrders;
        String qry2 ='SELECT qtc_Quote__r.SBQQ__Partner__r.Primary_Contact__c, qtc_Quote__r.SBQQ__Partner__r.Primary_Contact__r.Email FROM qtc_FulfillmentOrder__c Where qtc_Quote__r.qtc_Channel_Local_Office_Record_Type__c = \'PARTNER\' AND qtc_Quote__r.SBQQ__Ordered__c = false AND qtc_OrderStartDate__c <= '+ getOrderStartDateUpperLimit().format('yyyy-MM-dd')+ ' ORDER BY qtc_Quote__r.SBQQ__Partner__c';
        fOrders = Database.query(qry2);        
        Id prevPartnerId = null;
        String prevEmail = null;
        Id currentPartnerId = null;
        String currentEmail = null;
        Set<Account> partners = new Set<Account>();
        for(qtc_FulfillmentOrder__c fo : fOrders){
            Id oid = fo.qtc_Quote__r.SBQQ__Partner__r.Primary_Contact__c;
            if(oid == null){
                System.debug('Error > No primary contact of partner account');
                continue;
            }
            partners.add(fo.qtc_Quote__r.SBQQ__Partner__r);
            }
        sendEmail(owea, et, partners);
        
    }
    
    @TestVisible private void sendEmail(OrgWideEmailAddress[] owea, EmailTemplate et, Set<Account> partners){
        try{
            List<Messaging.SingleEmailMessage> lstMessages = new List<Messaging.SingleEmailMessage>();
            for(Account partner : partners){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSaveAsActivity(false);
            if ( owea.size() > 0 ) {
                    Message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            message.setTemplateId(et.Id);
            message.setTargetObjectId(partner.Primary_Contact__c);
            message.setTreatTargetObjectAsRecipient(false);
            message.setWhatId(partner.Id);
            
            message.toAddresses = new List<String> {partner.Primary_Contact__r.Email};
                lstMessages.add(message);
            }
            List<Messaging.SendEmailResult> lstResults = Messaging.sendEmail(lstMessages);
        } catch (Exception ex) {
            system.debug('***'+ex.getLineNumber());
            system.debug('***'+ex.getMessage());
            system.debug('***'+ex.getCause());
            system.debug('***'+ex.getStackTraceString());
        }
    }
}