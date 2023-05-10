public class DemingEmailServiceClass {
    Public Static Messaging.SingleEmailMessage CreateEmailObject(Set<String> toAddresses,Set<String> ccAddresses,String RecordId ,String TemplateId){
        System.debug('Base');
        Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage(); 
/*try{ 
LIST<String> toAddressListTemp = new LIST<String>(); 
LIST<String> ccAddressListTemp = new LIST<String>();  
Set<String> bccAddressListTemp = new Set<String>();
List<String> bccAddress = new List<String>();
/*if(toAddresses != null && toAddresses.size()>0){ 
//toAddressListTemp.addAll(toAddresses); 
//mailObj.setToAddresses(toAddressListTemp);
//bccAddressListTemp.add('Salesforce.Deming@ncr.com');  
//bccAddressListTemp.add('ss185638@ncr.com'); 
//bccAddressListTemp.add('mk111221@ncr.com');  
}	
if( ccAddresses != null && ccAddresses.Size()>0){
//ccAddressListTemp.addAll(ccAddresses);
//mailObj.setCcAddresses(ccAddressListTemp);
}
if(String.isNotBlank(TemplateId)){
//mailObj.setTemplateId(TemplateId);     
}

try{
//mailObj.setTargetObjectId(CADDDoNotReply__c.getValues('Do Not Reply User For CADD').UserID__c); 
}
catch(Exception e){
//System.debug('Exception Caught'+e.getMessage());


}*/  
        //if(bccAddressListTemp.size()>0){
        //bccAddress.addAll(bccAddressListTemp);
        //mailObj.setBccAddresses(bccAddress);
        //}
        /*mailObj.setReplyTo('NCROrderArrivalDate@ncr.com');
mailObj.setSenderDisplayName('Do Not Reply, Salesforce'); 
mailObj.setUseSignature(false); 
mailObj.setBccSender(false); 
mailObj.setSaveAsActivity(false); 
//This method would make sure email will not be sent to user
mailObj.setTreatTargetObjectAsRecipient(false);
mailObj.setWhatId(RecordId);*/
        /*   return mailObj;
}
catch(Exception e){


}*/
        return mailObj;
    }
    //Share Record with UserOrGroup
    Public static Deming__Share  CreateShareRecord(ID UserOrGroupId, String AccessLevel , ID RecordId){
        Deming__Share DemShare = new Deming__Share();
        
        if(String.isNotBlank(RecordId)){ 
            DemShare.ParentId=RecordId;  
            DemShare.AccessLevel=AccessLevel;
            if(String.IsNotBlank(UserOrGroupId)){ 
                DemShare.UserOrGroupId=UserOrGroupId;
            }
            DemShare.RowCause = Schema.Deming__Share.RowCause.Manual;
        }
        return DemShare;
    }
}