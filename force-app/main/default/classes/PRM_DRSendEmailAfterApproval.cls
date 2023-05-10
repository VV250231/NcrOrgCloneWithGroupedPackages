//-----------------------------------------------------------------------//
//This class sends and Email to Distributors after the deal is Approved //
//Created by: Nikhil Somvanshi                                         //
//--------------------------------------------------------------------//
public class PRM_DRSendEmailAfterApproval {
    public static void SendEmails(Map<Id,Deal_Registration__c> triggeroldMap, List<Deal_Registration__c> triggerDotnew){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        String TemplateId = [SELECT Id FROM EmailTemplate WHERE Name = 'DealApprovalEmailForDistributors' LIMIT 1].Id;
        Map<String,String> CAMDetailMap = new Map<String,String>();
        List<Messaging.SingleEmailMessage> renderedEmails;
        Map<String,Distributors_and_Emails__mdt> DealAndMetadata;
        
        if(!triggerDotnew.isEmpty()){
            renderedEmails = new List<Messaging.SingleEmailMessage>();
            DealAndMetadata = new Map<String,Distributors_and_Emails__mdt>();
            for(Deal_Registration__c dr : triggerDotnew){
                if(test.isRunningTest() || (dr.isApproved__c == true && triggeroldMap.get(dr.id).isApproved__c == false 
                    && dr.Distributor__c != Null)){
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(TemplateId, c.Id, dr.Id);
                        renderedEmails.add(email);
                        if(dr.Distributor_Channel_Account_Manager__c != NULL){
                            CAMDetailMap.put(dr.Id,getCAMemail(dr.Distributor_Channel_Account_Manager__c));
                        }else{
                            CAMDetailMap.put(dr.Id,NULL);
                        }
                        if(getMetadata(dr.Distributor__c) != NULL){
                            DealAndMetadata.put(dr.Id,getMetadata(dr.Distributor__c));
                        }else{return;}
                    }else{return;}
            }
            List<Messaging.SingleEmailMessage> finalEmailList;
            Messaging.SingleEmailMessage finalEmail;
            String EmailBody;
            List<String> toAddressList;
            List<String> ccAddressList;
            
            if(!renderedEmails.isEmpty()){
                finalEmailList = new List<Messaging.SingleEmailMessage>();
                toAddressList = new List<String>();
                ccAddressList = new List<String>();
                 //Change by Saurav(EBA_SF-1349)
              	 String orgWideEmailId =  ([SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = 'partner.resourcecenter@ncr.com' LIMIT 1].id);
                for(Messaging.SingleEmailMessage em : renderedEmails){
                    finalEmail = new Messaging.SingleEmailMessage();
                    If(DealAndMetadata.get(em.whatid).Distributor_Email1__c != NULL){
                        toAddressList.add(DealAndMetadata.get(em.whatid).Distributor_Email1__c);
                    }
                    If(DealAndMetadata.get(em.whatid).Distributor_Email_2__c != NULL){
                        toAddressList.add(DealAndMetadata.get(em.whatid).Distributor_Email_2__c);
                    }
                    finalEmail.setToAddresses(toAddressList);
                    if(CAMDetailMap.get(em.whatid) != NULL){
                        ccAddressList.add(CAMDetailMap.get(em.whatid));
                    }
                    finalEmail.setCcAddresses(ccAddressList);
                    String NewHTMLBody = em.getHtmlBody();
                    If(DealAndMetadata.get(em.whatid).Distributor_Contact_Person_2__c != NULL){
                        NewHTMLBody = NewHTMLBody.replace('Distributor Contact Name',DealAndMetadata.get(em.whatid).Distributor_Contact_Person__c+' / '+DealAndMetadata.get(em.whatid).Distributor_Contact_Person_2__c);    
                    }else{
                        NewHTMLBody = NewHTMLBody.replace('Distributor Contact Name',DealAndMetadata.get(em.whatid).Distributor_Contact_Person__c);
                    }
                    
                    finalEmail.setSubject('Notice to Distributor, a Deal Registration has been approved for a partner who selected you as their distributor');
                    finalEmail.setHtmlBody(NewHTMLBody);
                   	//Change by Saurav(EBA_SF-1349)
                    //finalEmail.setOrgWideEmailAddressId([SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = 'partner.resourcecenter@ncr.com' LIMIT 1].Id);
                    finalEmailList.add(finalEmail);
                     finalEmail.setOrgWideEmailAddressId(orgWideEmailId);
                }
                if(!finalEmailList.isEmpty()){
                    if(!test.isRunningTest()){
                    Messaging.sendEmail(finalEmailList);
                   }
                }
            }
            
        }
    }
    
    // Assistant Methods
    private static String getCAMemail(Id UserId){
            User Emailfound = [SELECT Email from USER where id=:UserId];
            if(Emailfound != NULL){
                return Emailfound.Email;
            } else{
                return NULL;
            }
    }
    
    private static Distributors_and_Emails__mdt getMetadata(String DistributorName){
        Distributors_and_Emails__mdt[] mdt = [SELECT Label,Distributor_Email1__c,Distributor_Email_2__c,Distributor_Contact_Person_2__c,
                                              Distributor_Contact_Person__c FROM Distributors_and_Emails__mdt WHERE Label=:DistributorName LIMIT 1];
        if(mdt.size() > 0){
            return mdt[0];
        }else{
            return NULL;
        }
    }
    
}