trigger DemingRecordSharing_and_Notification on Deming_Log__c (After Insert,Before Insert) {
      
    if(DemingValidateExecution.ValidateNotificationSwitch()){
            
        if(Trigger.IsAfter && Trigger.isInsert){
          
         String TemplateId= EmialTemplateCadd__c.getValues('TemplateId').CADDEmailTemplateId__c;
         String PDLTemplateId=EmailTemplatePrepondedPD__c.getValues('TemplateId').Template_ID__c;
         List<Deming_Log__c> DemingLogEmailStatus = new List<Deming_log__c>(); 
         for(Deming_Log__c Demlog : Trigger.New){
              
              Set<String> toAddressSet = new Set<String>();  
              Set<String> CcAddressSet = new Set<String>(); 
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
              Deming_log__c DemlogObj = new Deming_log__c();
              
             
              
              if(Demlog.Reason_Code__c=='Pd Less Then Rdd'){
                  if(Demlog.TO_Email_ID__c != null && String.isNotBlank(Demlog.TO_Email_ID__c)){
                      for(String toEmial: Demlog.TO_Email_ID__c.split(',')){
                          toAddressSet.add(toEmial);
                      }  
                  }
                  
                  if(Demlog.ccAddress__c != null && String.isNotBlank(Demlog.ccAddress__c)){
                      for(String CcEmial : Demlog.ccAddress__c.split(',')){
                          CcAddressSet.add(CcEmial);
                      }
                  }
                  mail=DemingEmailServiceClass.CreateEmailObject(toAddressSet,CcAddressSet,Demlog.Id,PDLTemplateId);  
              }
                
              else if(Demlog.Reason_Code__c=='Customer Request'){
              
                  if(Demlog.TO_Email_ID__c != null && String.isNotBlank(Demlog.TO_Email_ID__c)){
                      for(String toEmial: Demlog.TO_Email_ID__c.split(',')){
                          toAddressSet.add(toEmial);
                      }  
                  }
                  
                  if(Demlog.ccAddress__c != null && String.isNotBlank(Demlog.ccAddress__c)){
                      for(String CcEmial : Demlog.ccAddress__c.split(',')){
                          CcAddressSet.add(CcEmial);
                      }
                  }
                  mail=DemingEmailServiceClass.CreateEmailObject(toAddressSet,CcAddressSet,Demlog.Id,TemplateId);
              }
              
              else{
              
                  if(Demlog.TO_Email_ID__c != null && String.isNotBlank(Demlog.TO_Email_ID__c)){
                      for(String toEmial: Demlog.TO_Email_ID__c.split(',')){
                          toAddressSet.add(toEmial); 
                      }  
                  } 
                  
                  if(Demlog.ccAddress__c != null && String.isNotBlank(Demlog.ccAddress__c)){
                      for(String CcEmial : Demlog.ccAddress__c.split(',')){
                          CcAddressSet.add(CcEmial);
                      }
                  }
                  mail = DemingEmailServiceClass.CreateEmailObject(toAddressSet,CcAddressSet,Demlog.Id,TemplateId);
              }
              
              
              try{
                  Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                  
                  if(resultMail[0].isSuccess()){
                          DemlogObj.id=Demlog.id; 
                          DemlogObj.Emial_Status__c='Email Sent Successfully.';
                           DemingLogEmailStatus.add(DemlogObj);
                  }
                  else{
                       DemlogObj.id=Demlog.id; 
                       DemlogObj.Emial_Status__c=resultMail[0].getErrors().get(0).getMessage();
                       DemingLogEmailStatus.add(DemlogObj);
                   }
              }
              catch(System.EmailException ex){
                       DemlogObj.id=Demlog.id; 
                       DemlogObj.Emial_Status__c=ex.getMessage();
                       DemingLogEmailStatus.add(DemlogObj);
                       
              }
             
         }        
               
              if(DemingLogEmailStatus != null && DemingLogEmailStatus.size()>0){
                  update DemingLogEmailStatus;
              }     
    } 
    
    if(Trigger.IsBefore && Trigger.IsInsert){
        GenerateListViewUrl listViewObj = new GenerateListViewUrl();
        String CustomerRequestedView = listViewObj.ListViewURL('Deming__c','Customer Requested Arrival Date Changes');
        String NonCustomerRequestedView =listViewObj.ListViewURL('Deming__c','Arrival Date Changes');
        String PdLessThenRddView= listViewObj.ListViewURL('Deming__c','Arrival Date Changes Set Prior to RDD');
        String BaseUrl= Url.getsalesforcebaseurl().toExternalform();
        
        for(Deming_Log__c DemLogObj : Trigger.New){
            if(DemLogObj.Reason_Code__c == 'Customer Request'){
                DemLogObj.formUrl__c = BaseUrl+CustomerRequestedView;
                
            }
            
            else if(DemLogObj.Reason_Code__c=='Non Customer Requested'){
                DemLogObj.formUrl__c=BaseUrl+NonCustomerRequestedView;
            }
            
            else{
                DemLogObj.formUrl__c=BaseUrl+PdLessThenRddView;
            }
        }
    }
        
    }  
}