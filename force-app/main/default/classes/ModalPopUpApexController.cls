/*
##################################################################################################
# Class Name............................:ModalPopUpApexController.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public class ModalPopUpApexController {
    
Public static Engineers__c eng{get;set;} 
public static ProcessInstanceStep work;
public static Deal_Registration__c dealreg;
      
    @AuraEnabled
    public static void getAccountupdatedlist(Account newAcc){
        insert newAcc ;
    }
        
    @AuraEnabled
    public static String getPopUpAvailablity(Id recordId){
        return null;
    }
        
    @AuraEnabled
    public static String fetchUrl(Id processId){
        return null;
    }
        
    @AuraEnabled
    public static String engineerToContact(Id recordId ,String engineerId ,String portalLogin){
        return null;
    }
           
    public static Id createContact(Engineers__c engineer){
    
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        //Create contact
        Contact contactInstannce = new Contact();
        contactInstannce.recordtypeId =devRecordTypeId ;
        contactInstannce.FirstName = engineer.First_name__c;
        contactInstannce.Lastname = engineer.Last_Name__c;
        contactInstannce.Email = engineer.Email_Address__c;
        contactInstannce.AccountId = engineer.Partner_Account__c;
        contactInstannce.Title ='Engineer';
        contactInstannce.Decision_Maker__c ='Not involved';
        contactInstannce.Level__c ='Individual Contributor';
        contactInstannce.Business_Function__c ='Customer Support/Service';
        contactInstannce.Portal_User__c = true;
        contactInstannce.Profile_Status__c ='Active';
        contactInstannce.Portal_Login_Status__c ='Active';
        contactInstannce.Survey_Flag__c ='No-Customer Opt Out';
        contactInstannce.Reason__c ='Channel directive';
    
        try{
            Insert contactInstannce;
        } catch(exception e){
            System.debug('Exception Caught'+e.getMessage());
        } 
        return contactInstannce.Id;
    }
    
    @AuraEnabled
    public static String sendEmail(String selectedReason,String comment,Id recordId){ 
        return null;
    }
        
    @AuraEnabled
    public static String sendEmailDealReg(String selectedReason,Id recordId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        work = [Select id,ProcessInstance.TargetObjectId from ProcessInstanceStep WHERE Id =: recordId];
        dealReg   =[Select id, Name,Owner.name,Name_of_Account_Financial_Institution__c,Channel_Partner_Company_Name__c,Channel_Partner_Key_Contact__c,OwnerID,owner.email,End_Customer_Company_Name__c,End_Customer_Key_Contact_Name__c,
                   Estimated_Close_Date__c,Is_this_part_of_an_RFP__c,Status__c,NCR_Account_Manager__c,Partner_Company_Name__c,Partner_Contact__c,Primary_Contact_Name__c,Primary_Contact_NameText__c,Projected_Opportunity_Value__c From Deal_Registration__c Where id =: work.ProcessInstance.TargetObjectId ]    ;
    
        If(selectedReason !='' && selectedReason !=null && dealReg != null){
            dealreg.VisualTemplate__c = selectedReason;
            update dealreg;
        }
        //Query Email
        List<EmailTemplate> emailtemp =[Select id from EmailTemplate Where Name ='Deal Registration Rejection Email Template'];
    
        //Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(Dealreg.owner.email);
        mail.setToAddresses(sendTo); 
    
        //Set who the email is sent from
        
        mail.setTemplateID(emailtemp[0].Id); 
        mail.setSaveAsActivity(false);
        mail.setWhatId(dealreg.id);
        mail.setTargetObjectId(dealReg.OwnerId);
    
        // (Optional) Set list of people who should be CC'ed
        List<String> ccTo = new List<String>();
        //  Set email contents - you can use variables!
        System.debug('mail'+ mail);
        List<Messaging.SingleEmailMessage> mails=
        new List<Messaging.SingleEmailMessage>();
        mails.add(mail);
        System.debug('mails'+ mails);
        // Messaging.SendEmailResult[] results = 
        Messaging.sendEmail(mails);
        return dealReg.id;
    }

}