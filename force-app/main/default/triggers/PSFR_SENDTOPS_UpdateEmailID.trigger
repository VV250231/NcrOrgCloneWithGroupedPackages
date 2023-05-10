/*   *   Created by   : Saagar Kinja
*    Email ID    : saagar.kinja@ncr.com 
*    QLID        : SK250817
*    Details     : This Trigger will update email'id's
*                  Further, PSFR_update trigger will move the status to new and 
*                  Raise objection status will be change and trigger notification to concern teams

*/
trigger PSFR_SENDTOPS_UpdateEmailID on Presales_Engineer__c (before insert,before update, after insert, after update) 
{
    List <ID> PFRIdList = new  List <ID>();
    Map<Id ,Presales_Funding_Request__c> PFRMap  = new Map<Id ,Presales_Funding_Request__c>();
    //List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    List<NCR_EmailMessage__c> ncrEmailList = new List<NCR_EmailMessage__c>();
    String htmlBody = '';
    String subject = '';
    String BPMEmployeeCommunity=System.Label.BPM_Employee_Community_URL;
    Boolean executeEmailLogic=false;
    Id PSFRCreateResId = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_STP_to_Create_Res'].get(0).Id;
    //Change by Saurav(EBA_SF-1349)
    EmailTemplate templateIdForDisputeAnalysts = [Select id, Body, HtmlValue,Markup, Subject from EmailTemplate where name = 'PSFR_STP_to_Create_Res1'];
    /*List<String> POA_STP = new List<string>();-################################################################################################*/
    
    For(Presales_Engineer__c pse: Trigger.New)
    {
        PFRIdList.add(pse.Presales_Funding_Request__c);
        
    }
    
    /*################################################################################################*/
    
    If(PFRIdList!= null && !PFRIdList.isEmpty())
    { 
        PFRMap  = new Map<Id, Presales_Funding_Request__c>([Select 
                                                            id ,Account_Manager__c,
                                                            Opportunity_Owner_Manager__c, 
                                                            PFR_Opportunity__r.Owner.Email,
                                                            PFR_Opportunity__r.Owner.Name,
                                                            PFR_Opportunity__r.Opportunity_Number__c,
                                                            PFR_Opportunity__r.StageName,
                                                            PFR_Opportunity__r.ForecastCategoryName,
                                                            PFR_Opportunity__r.Amount,
                                                            PFR_Opportunity__r.Software_Products_QUBY__c,
                                                            PFR_Opportunity__r.Hardware_Products_QUBY__c,
                                                            PFR_Opportunity__r.PS_Products_QUBY__c,
                                                            PFR_Opportunity__r.Cloud_Products_QUBY__c,
                                                            PFR_Opportunity__r.Services_Products_QUBY__c,
                                                            Name,
                                                            PFR_Account_Name__c,
                                                            Account__c,
                                                            Region__c,
                                                            PFR_Approval_Number__c,
                                                            PFR1_Expected_Book_Date__c,
                                                            PSFR_Authentication_Token_Text__c,
                                                            PSFR_Authentication_Trigger__c,
                                                            PFR_Expected_Date__c,
                                                            PFR_Forecast_Category__c,
                                                            Approval_Status__c,
                                                            PFR_Hardware_Products__c,
                                                            PFR_Is_this_Recoverable__c,
                                                            Raise_Objection_Comments__c,
                                                            PFR_Justification__c,
                                                            PFR_Opportunity__c,
                                                            PFR_Opportunity_Amount__c,
                                                            PFR_Opportunity_Number__c,
                                                            PFR_Opportunity_Owner__c,
                                                            PFR_Opportunity_Selling_Stage__c,
                                                            PFR_Presales_Category__c,
                                                            Resource_S__c,
                                                            PFR_Sales_Engineer__c,
                                                            PFR_Software_Products__c,
                                                            PFR_Success_Criteria__c,
                                                            Raised_Objection_Status__c,
                                                            Total_Hours_not_to_exceed__c,
                                                            Total_Travel_Cost_of_Resources__c,
                                                            Total_Value_of_Resources__c,
                                                            Number_of_Resources__c,
                                                            Owner.name,Services_Products__c,Cloud_Products__c,PS_Product__c
                                                            From    Presales_Funding_Request__c 
                                                            Where   id =: PFRIdList
                                                           ]);
    }
    
    /*################################################################################################*/
    If((Trigger.IsBefore && Trigger.IsInsert) || (Trigger.isAfter && Trigger.IsUpdate))
    {
        system.debug('enter in the loop after');
        
        for (Integer i = 0; i < Trigger.new.size(); i++)
        {
            If(Trigger.IsInsert && (PFRMap != null && !PFRMap.isEmpty() && PFRMap.containsKey(trigger.new[i].Presales_Funding_Request__c)))
            {         executeEmailLogic=true;
             trigger.new[i].Opportunity_Owner_Manager__c = PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Opportunity_Owner_Manager__c;
             trigger.new[i].Opportunity_Owner_Email_ID__c = PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity__r.Owner.Email;
             trigger.new[i].Account_Manager__c=PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Account_Manager__c;
            }   
            
            if(Trigger.IsUpdate && Trigger.new[i].Trigger_Notification_Status__c == 'Sent to PS' || Trigger.new[i].Trigger_Notification_Status__c == 'On Hold')
            { executeEmailLogic=true; }
            
            if(executeEmailLogic){
                /* Below code will trigger email notification to users################################################################################################*/
                //Change by Saurav(EBA_SF-1349)
                //EmailTemplate templateIdForDisputeAnalysts = [Select id, Body, HtmlValue,Markup, Subject from EmailTemplate where name = 'PSFR_STP_to_Create_Res1'];
                //htmlBody = htmlBody.replace('#Region', String.isNotBlank(trigger.new[i].Opportunity_Region__c) ? String.ValueOf(trigger.new[i].Opportunity_Region__c) : '');    
                subject = 'Request to create Resource for PreSales Fund Request:'+PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Name+', Account Name :'+trigger.new[i].Account_Name__c+' and Region:'+trigger.new[i].Opportunity_Region__c;
                System.debug('@@@'+PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Number__c);
                htmlBody=templateIdForDisputeAnalysts.Markup;
                htmlBody = htmlBody.replace('#PreSalesFundRequestNo', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Name) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Name) : '');
                htmlBody = htmlBody.replace('#SalesEngineer', String.isNotBlank(trigger.new[i].Sales_Engineer__c) ? String.ValueOf(trigger.new[i].Sales_Engineer__c) : '');
                htmlBody = htmlBody.replace('#PresalesCategory', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Presales_Category__c) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Presales_Category__c) : '');
                htmlBody = htmlBody.replace('#Oxpportunity', String.isNotBlank(trigger.new[i].Opportunity__c) ? String.ValueOf(trigger.new[i].Opportunity__c) : '');
                htmlBody = htmlBody.replace('#Account', String.isNotBlank(trigger.new[i].Account_Name__c) ? String.ValueOf(trigger.new[i].Account_Name__c) : '');
                htmlBody = htmlBody.replace('#ExpectedStartDate', (PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Expected_Date__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Expected_Date__c) : '');
                htmlBody = htmlBody.replace('#PreSalesFundRequestNumber', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Name) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Name) : '');
                htmlBody = htmlBody.replace('#PreSalesFundRequestOwner', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Owner.Name) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Owner.Name) : '');
                htmlBody = htmlBody.replace('#SuccessCriteria', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Success_Criteria__c) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Success_Criteria__c) : '');
                htmlBody = htmlBody.replace('#Justification', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Justification__c) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Justification__c) : '');
                htmlBody = htmlBody.replace('#IsThisRecorverable', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Is_this_Recoverable__c) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Is_this_Recoverable__c) : '');
                htmlBody = htmlBody.replace('#FundRequestStatus', String.isNotBlank(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Approval_Status__c) ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Approval_Status__c) : '');
                htmlBody = htmlBody.replace('#AdditionalComments', String.isNotBlank(trigger.new[i].Body__c) ? String.ValueOf(trigger.new[i].Body__c) : '');
                // htmlBody = htmlBody.replace('#OpportunityNumber', String.isNotBlank(trigger.new[i].Opportunity__c) ? String.ValueOf(trigger.new[i].Opportunity__c) : '');
                htmlBody = htmlBody.replace('#Rregion', String.isNotBlank(trigger.new[i].Opportunity_Region__c) ? String.ValueOf(trigger.new[i].Opportunity_Region__c) : '');
                htmlBody = htmlBody.replace('#SoftwareProducts', (PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Software_Products__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Software_Products__c) : '');
                htmlBody = htmlBody.replace('#HardwareProducts', (PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Hardware_Products__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Hardware_Products__c) : '');
                htmlBody = htmlBody.replace('#ForecastCategory', String.isNotBlank(trigger.new[i].Forecast_Category__c) ? String.ValueOf(trigger.new[i].Forecast_Category__c) : '');
                htmlBody = htmlBody.replace('#OpportunityAmount',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Amount__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Amount__c) : '');
                //  htmlBody = htmlBody.replace('#Opportunity Owner', String.isNotBlank(trigger.new[i].Opportunity_Owner__c) ? String.ValueOf(trigger.new[i].Opportunity_Owner__c) : '');
                htmlBody = htmlBody.replace('#ExpectedBookDate', (trigger.new[i].PFR1_Expected_Book_Date_c__c) !=null ? String.ValueOf(trigger.new[i].PFR1_Expected_Book_Date_c__c) : '');
                htmlBody = htmlBody.replace('#PPreSalesRequestFormid', (PFRMap.get(trigger.new[i].Presales_Funding_Request__c).id) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).id) : '');
                htmlBody = htmlBody.replace('#OpportunityNumber',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Number__c ) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Number__c ) : '');
                htmlBody = htmlBody.replace('#OpportunityOwner',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Owner__c ) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Owner__c ) : '');
                htmlBody = htmlBody.replace('#OpportunitySellingStage',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Selling_Stage__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Selling_Stage__c) : ''); 
                htmlBody = htmlBody.replace('#ForecastCategory',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Forecast_Category__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Forecast_Category__c) : '');
                htmlBody = htmlBody.replace('#OpportunityAmount',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Amount__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Opportunity_Amount__c) : '');
                htmlBody = htmlBody.replace('#Region',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Region__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Region__c) : '');
                htmlBody = htmlBody.replace('#SoftwareProducts',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Software_Products__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Software_Products__c) : '');
                htmlBody = htmlBody.replace('#HardwareProducts',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Hardware_Products__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PFR_Hardware_Products__c) : '');
                htmlBody = htmlBody.replace('#SerivcesProducts',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Services_Products__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Services_Products__c) : '');
                htmlBody = htmlBody.replace('#CloudProducts',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Cloud_Products__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).Cloud_Products__c) : '');
                htmlBody = htmlBody.replace('#PSProducts',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PS_Product__c) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).PS_Product__c) : '');
                //                    	htmlBody = htmlBody.replace('#ExpectedBookDate',('#PSProducts',(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).id) !=null ? String.ValueOf(PFRMap.get(trigger.new[i].Presales_Funding_Request__c).id) : '');
                htmlBody = htmlBody.replace('#CloudProducts','');
                htmlBody = htmlBody.replace('#CloudProducts','');
                If(Trigger.new[i].Email_ID__c != null)
                {
                    
                    NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                    ncrEmail.Email_Type__c = 'PSFR_SENDTOPS_UpdateEmailID';
                    ncrEmail.HTML_Body__c = htmlBody;
                    ncrEmail.Subject__c = subject;
                    ncrEmail.Recipient1__c = Trigger.new[i].Email_ID__c;
                    ncrEmailList.add(ncrEmail);
                    
                    /*String[] ToAddress = new String[]{Trigger.new[i].Email_ID__c};
                    Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                    mailtoOO.setTemplateId(PSFRCreateResId); // email Template Id
                    mailtoOO.setsubject(subject);
                    //htmlBody = htmlBody.replace('#EmailID', (BPMEmployeeCommunity+'/PSFR_Authentication_Stage1?id='+trigger.new[i].Presales_Funding_Request__c+'&psid='+trigger.new[i].Email_ID__c)); 
                    mailtoOO.setHtmlBody(htmlBody);*/
                    /*
                    ################################################################################################
                    */
                    /*mailtoOO.setTargetObjectId(UserInfo.getUserId());
                    mailtoOO.setToAddresses(ToAddress);
                    mailtoOO.setSaveAsActivity(false);
                    mailtoOO.setSenderDisplayName('NSC Administration');   
                    mailtoOO.setSenderDisplayName('NSC Administration');  
                    system.debug('end of email'+ mailtoOO);
                    emails.add(mailtoOO);*/
                }
                
                If(Trigger.new[i].Email_ID_1__c != null)
                {
                    
                    NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                    ncrEmail.Email_Type__c = 'PSFR_SENDTOPS_UpdateEmailID';
                    ncrEmail.HTML_Body__c = htmlBody;
                    ncrEmail.Subject__c = subject;
                    ncrEmail.Recipient1__c = Trigger.new[i].Email_ID_1__c;
                    ncrEmailList.add(ncrEmail);
                    
                    /*String[] ToAddress = new String[]{Trigger.new[i].Email_ID_1__c};
                    Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                    mailtoOO.setTemplateId(PSFRCreateResId); // email Template Id
                    mailtoOO.setsubject(subject);
                    //htmlBody = htmlBody.replace('#FirstEmailID', (BPMEmployeeCommunity+'/PSFR_Authentication_Stage1?id='+trigger.new[i].Presales_Funding_Request__c+'&psid='+trigger.new[i].Email_ID_1__c)); 
                    mailtoOO.setHtmlBody(htmlBody);*/
                    /*
                    ################################################################################################
                    */
                    /*mailtoOO.setTargetObjectId(UserInfo.getUserId());
                    mailtoOO.setToAddresses(ToAddress);
                    mailtoOO.setSaveAsActivity(false);
                    mailtoOO.setSenderDisplayName('NSC Administration');   
                    mailtoOO.setSenderDisplayName('NSC Administration');  
                    system.debug('end of email'+ mailtoOO);
                    emails.add(mailtoOO);*/
                }
                
                If(trigger.new[i].Email_ID_2__c != null)
                {
                    
                    NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                    ncrEmail.Email_Type__c = 'PSFR_SENDTOPS_UpdateEmailID';
                    ncrEmail.HTML_Body__c = htmlBody;
                    ncrEmail.Subject__c = subject;
                    ncrEmail.Recipient1__c = Trigger.new[i].Email_ID_2__c;
                    ncrEmailList.add(ncrEmail);
                    
                    /*String[] ToAddress = new String[]{Trigger.new[i].Email_ID_2__c};
                    Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                    mailtoOO.setTemplateId(PSFRCreateResId); // email Template Id
                    mailtoOO.setsubject(subject);
                    //htmlBody = htmlBody.replace('#SecondEmailID', (BPMEmployeeCommunity+'/PSFR_Authentication_Stage1?id='+trigger.new[i].Presales_Funding_Request__c+'&psid='+trigger.new[i].Email_ID_2__c)); 
                    mailtoOO.setHtmlBody(htmlBody );*/
                    /*
                    ################################################################################################
                    */
                    /*mailtoOO.setTargetObjectId(UserInfo.getUserId());
                    mailtoOO.setToAddresses(ToAddress);
                    mailtoOO.setSaveAsActivity(false);
                    mailtoOO.setSenderDisplayName('NSC Administration');   
                    mailtoOO.setSenderDisplayName('NSC Administration');  
                    system.debug('end of email'+ mailtoOO);
                    emails.add(mailtoOO);*/
                    
                }
                If(Trigger.new[i].Email_ID_3__c != null)
                {
                    
                    NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                    ncrEmail.Email_Type__c = 'PSFR_SENDTOPS_UpdateEmailID';
                    ncrEmail.HTML_Body__c = htmlBody;
                    ncrEmail.Subject__c = subject;
                    ncrEmail.Recipient1__c = Trigger.new[i].Email_ID_3__c;
                    ncrEmailList.add(ncrEmail);
                    
                    /*String[] ToAddress = new String[]{Trigger.new[i].Email_ID_3__c};
                    Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                    mailtoOO.setTemplateId(PSFRCreateResId); // email Template Id
                    mailtoOO.setsubject(subject);
                    //htmlBody = htmlBody.replace('#ThirdEmailID', (BPMEmployeeCommunity+'/PSFR_Authentication_Stage1?id='+trigger.new[i].Presales_Funding_Request__c+'&psid='+trigger.new[i].Email_ID_3__c)); 
                    mailtoOO.setHtmlBody(htmlBody );*/
                    /*
                    ################################################################################################
                    */
                    /*mailtoOO.setTargetObjectId(UserInfo.getUserId());
                    mailtoOO.setToAddresses(ToAddress);
                    mailtoOO.setSaveAsActivity(false);
                    mailtoOO.setSenderDisplayName('NSC Administration');   
                    mailtoOO.setSenderDisplayName('NSC Administration');  
                    system.debug('end of email'+ mailtoOO);
                    emails.add(mailtoOO);*/
                    
                }
                If(Trigger.new[i].Email_ID_4__c != null)
                {
                    
                    NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                    ncrEmail.Email_Type__c = 'PSFR_SENDTOPS_UpdateEmailID';
                    ncrEmail.HTML_Body__c = htmlBody;
                    ncrEmail.Subject__c = subject;
                    ncrEmail.Recipient1__c = Trigger.new[i].Email_ID_4__c;
                    ncrEmailList.add(ncrEmail);
                    
                    /*String[] ToAddress = new String[]{Trigger.new[i].Email_ID_4__c};
                    Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                    mailtoOO.setTemplateId(PSFRCreateResId); // email Template Id
                    mailtoOO.setsubject(subject);
                    // htmlBody = htmlBody.replace('#FourthEmailID', (BPMEmployeeCommunity+'/PSFR_Authentication_Stage1?id='+trigger.new[i].Presales_Funding_Request__c+'&psid='+trigger.new[i].Email_ID_4__c)); 
                    mailtoOO.setHtmlBody(htmlBody );*/
                    /*
                    ################################################################################################
                    */
                    /*mailtoOO.setTargetObjectId(UserInfo.getUserId());
                    mailtoOO.setToAddresses(ToAddress);
                    mailtoOO.setSaveAsActivity(false);
                    mailtoOO.setSenderDisplayName('NSC Administration');   
                    mailtoOO.setSenderDisplayName('NSC Administration');  
                    system.debug('end of email'+ mailtoOO);
                    emails.add(mailtoOO);*/
                    
                }
                If(Trigger.new[i].Email_ID_5__c != null)
                {
                    NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                    ncrEmail.Email_Type__c = 'PSFR_SENDTOPS_UpdateEmailID';
                    ncrEmail.HTML_Body__c = htmlBody;
                    ncrEmail.Subject__c = subject;
                    ncrEmail.Recipient1__c = Trigger.new[i].Email_ID_5__c;
                    ncrEmailList.add(ncrEmail);
                    
                    /*String[] ToAddress = new String[]{Trigger.new[i].Email_ID_5__c};
                    Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                    mailtoOO.setTemplateId(PSFRCreateResId); // email Template Id
                    mailtoOO.setsubject(subject);
                    // htmlBody = htmlBody.replace('#FifthEmailID', (BPMEmployeeCommunity+'/PSFR_Authentication_Stage1?id='+trigger.new[i].Presales_Funding_Request__c+'&psid='+trigger.new[i].Email_ID_5__c)); 
                    mailtoOO.setHtmlBody(htmlBody );*/
                    /*################################################################################################*/
                    /*mailtoOO.setTargetObjectId(UserInfo.getUserId());
                    mailtoOO.setToAddresses(ToAddress);
                    mailtoOO.setSaveAsActivity(false);
                    mailtoOO.setSenderDisplayName('NSC Administration');   
                    mailtoOO.setSenderDisplayName('NSC Administration');  
                    system.debug('end of email'+ mailtoOO);
                    emails.add(mailtoOO);*/
                    
                }
            }
        }
        //Messaging.sendEmail(emails);
        if(ncrEmailList.size() > 0)
            Insert ncrEmailList;
    }    
}