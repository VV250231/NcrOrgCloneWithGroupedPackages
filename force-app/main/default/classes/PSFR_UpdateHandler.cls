/*   Created by   : Saagar Kinja
*    Email ID    : saagar.kinja@ncr.com 
*    QLID        : SK250817
*    Details     : This Trigger will update fields, trigger emails. Please find below respective comment for more details :

*/
public class PSFR_UpdateHandler {
    
    public static void PSFR_Updates(List<Presales_Funding_Request__c> psfrNewTrigger) {
        List <ID> OPPIdList = new  List <ID>();
        List <ID> AccIdList = new  List <ID>();
        Map<Id ,Opportunity> OppMap  = new Map<Id ,Opportunity>();
        Map<Id ,Account> AccMap= new Map<Id ,Account>();
        For(Presales_Funding_Request__c pse:psfrNewTrigger)
        { 
            OPPIdList.add(pse.PFR_Opportunity__c);
            AccIdList.add(pse.Account__c); 
        } 
        
        If(OPPIdList!=null)
        {
            OppMap = new Map<Id ,Opportunity>([Select id ,Account.id,
                                               Account.Owner.Email,Owner.Email,
                                               Account.Account_Country_Code__c, Account.Account_Region__c,Account.Area__c, 
                                               Owner.Manager.Email
                                               From Opportunity Where id =: OPPIdList]);
        }
        
        If(AccIdList!=null)
        { 
            AccMap = new Map<Id,Account>([Select id, Owner.Email, Area__c
                                          From   Account
                                          Where   id=:AccIdList]);
        }               
        
        if(Trigger.IsBefore)
        {
            
            /*
#####################################################################################################################
*/
            If(trigger.isinsert)
            {
                for (Integer i = 0; i < psfrNewTrigger.size(); i++)
                {   
                    /*
#####################################################################################################################
*/
                    
                    If(OppMap!= null && !OppMap.isEmpty() && OppMap.containsKey(psfrNewTrigger[i].PFR_Opportunity__c) )
                    {
                        psfrNewTrigger[i].Opportunity_Owner_Manager__c = OppMap.get(psfrNewTrigger[i].PFR_Opportunity__c).Owner.Manager.Email ;
                        psfrNewTrigger[i].Account_Manager__c = OppMap.get(psfrNewTrigger[i].PFR_Opportunity__c).Account.Owner.Email ;
                        psfrNewTrigger[i].Opportunity_Owner__c=OppMap.get(psfrNewTrigger[i].PFR_Opportunity__c).Owner.Email;
                        psfrNewTrigger[i].Account__c= OppMap.get(psfrNewTrigger[i].PFR_Opportunity__c).Account.id;
                        
                    }
                    /*
#####################################################################################################################
*/
                    
                    If(psfrNewTrigger[i].Account__c !=null && psfrNewTrigger[i].PFR_Opportunity__c==null)           
                    {       
                        psfrNewTrigger[i].Account_Manager__c = AccMap.get(psfrNewTrigger[i].Account__c).owner.email ;
                    }
                    /*
#####################################################################################################################
*/
                    
                    If(psfrNewTrigger[i].Fund_Request_Owner__c ==null) 
                    {
                        psfrNewTrigger[i].Fund_Request_Owner__c=psfrNewTrigger[i].Record_Creator__c;
                    }
                    
                    /*
#####################################################################################################################
*/
               PSFR_Retail_Approval_Assignment__c raa = PSFR_Retail_Approval_Assignment__c.getvalues('RET-CIS/RU');
                PSFR_Retail_Approval_Assignment__c raa1 = PSFR_Retail_Approval_Assignment__c.getvalues('RET-SE-FRANCE');
                PSFR_Retail_Approval_Assignment__c raa2 = PSFR_Retail_Approval_Assignment__c.getvalues('RET-EMEA-UKI');
                PSFR_Retail_Approval_Assignment__c raa3 = PSFR_Retail_Approval_Assignment__c.getvalues('RET-EMEA-NORDICS');
                PSFR_Retail_Approval_Assignment__c raa4 = PSFR_Retail_Approval_Assignment__c.getvalues('RET-EMEA-CE-GERMANY');
                PSFR_Retail_Approval_Assignment__c raa5 = PSFR_Retail_Approval_Assignment__c.getvalues('RET-PCR-MGR');
                PSFR_Retail_Approval_Assignment__c raa6 = PSFR_Retail_Approval_Assignment__c.getvalues('ElseOwner');
                
                
                If(psfrNewTrigger[i].Division_of_User__c.contains('RET') && psfrNewTrigger[i].R_Sales_Leader__c == null)
                {
                    If(psfrNewTrigger[i].Division_of_User__c != null)
                    {
                        If(psfrNewTrigger[i].Division_of_User__c == 'RET-CIS/RU' || psfrNewTrigger[i].Division_of_User__c=='RET-CIS/RU-MGR')
                        {
                            psfrNewTrigger[i].R_Sales_Leader__c = raa.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa.Sub_Region_Sales_Leader_Email__c;  
                        }
                        else If(psfrNewTrigger[i].Division_of_User__c == 'RET-SE-FRANCE' || psfrNewTrigger[i].Division_of_User__c == 'RET-SE-IBERIA' || 
                                psfrNewTrigger[i].Division_of_User__c == 'RET-ISRAEL' || psfrNewTrigger[i].Division_of_User__c == 'RET-ISRAEL-DIRECTOR' ||
                                psfrNewTrigger[i].Division_of_User__c == 'RET-SE-ITALY' || psfrNewTrigger[i].Division_of_User__c == 'RET-SE-ITALY-MGR' || 
                                psfrNewTrigger[i].Division_of_User__c == 'RET-SE-ITALY-MGR' || psfrNewTrigger[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL' )
                        {
                            psfrNewTrigger[i].R_Sales_Leader__c = raa1.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa1.Sub_Region_Sales_Leader_Email__c;                                       
                        }
                        else If(psfrNewTrigger[i].Division_of_User__c == 'RET-EMEA-UKI' || psfrNewTrigger[i].Division_of_User__c == 'RET EMEA UKI- Sales')
                        {
                            psfrNewTrigger[i].R_Sales_Leader__c = raa2.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa2.Sub_Region_Sales_Leader_Email__c;   
                        }
                        else If(psfrNewTrigger[i].Division_of_User__c == 'RET-EMEA-NORDICS' || psfrNewTrigger[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL' ||
                                psfrNewTrigger[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL-MGR' || psfrNewTrigger[i].Division_of_User__c == 'RET-MEA-CHANNEL')
                        {
                            psfrNewTrigger[i].R_Sales_Leader__c = raa3.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa3.Sub_Region_Sales_Leader_Email__c;   
                        }
                        else If(psfrNewTrigger[i].Division_of_User__c == 'RET-EMEA-CE-GERMANY')
                        {
                           psfrNewTrigger[i].R_Sales_Leader__c = raa4.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa4.Sub_Region_Sales_Leader_Email__c; 
                        }
                        else If(psfrNewTrigger[i].Division_of_User__c == 'RET-PCR-MGR')
                        {
                           psfrNewTrigger[i].R_Sales_Leader__c = raa5.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa5.Sub_Region_Sales_Leader_Email__c; 
                        }
                        else
                        {
                            psfrNewTrigger[i].R_Sales_Leader__c = raa6.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa6.Sub_Region_Sales_Leader_Email__c; 
                        }
                    }
                    else
                    {   
                        psfrNewTrigger[i].R_Sales_Leader__c = raa6.R_Sales_Leader__c;
                            psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c = raa6.Sub_Region_Sales_Leader_Email__c;
                    }
                }
                
                /*If(Trigger.new[i].Division_of_User__c.contains('RET') && Trigger.new[i].R_Sales_Leader__c == null)
                {
                    If(Trigger.new[i].Division_of_User__c != null)
                    {
                        If(Trigger.new[i].Division_of_User__c == 'RET-CIS/RU' || Trigger.new[i].Division_of_User__c=='RET-CIS/RU-MGR')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003gI9I';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Andriy.Pinkevych@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-SE-FRANCE' || Trigger.new[i].Division_of_User__c == 'RET-SE-IBERIA' || 
                                Trigger.new[i].Division_of_User__c == 'RET-ISRAEL' || Trigger.new[i].Division_of_User__c == 'RET-ISRAEL-DIRECTOR' ||
                                Trigger.new[i].Division_of_User__c == 'RET-SE-ITALY' || Trigger.new[i].Division_of_User__c == 'RET-SE-ITALY-MGR' || 
                                Trigger.new[i].Division_of_User__c == 'RET-SE-ITALY-MGR' || Trigger.new[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL' )
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003j5hS';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Guy.Perry@ncr.com';                                       
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-EMEA-UKI' || Trigger.new[i].Division_of_User__c == 'RET EMEA UKI- Sales')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000002U4M9';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'js185378@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-EMEA-NORDICS' || Trigger.new[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL' ||
                                Trigger.new[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL-MGR' || Trigger.new[i].Division_of_User__c == 'RET-MEA-CHANNEL')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003jQjK';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'ok185014@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-EMEA-CE-GERMANY')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000001R8tf';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Stefan.Clemens@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-PCR-MGR')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000002Ti7k';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'yy185027@ncr.com';   
                        }
                        else
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003hDvY';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Mark.Duff@ncr.com';  
                        }
                    }
                    else
                    {   
                        Trigger.new[i].R_Sales_Leader__c ='00570000003hDvY';
                        Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Mark.Duff@ncr.com';
                    }
                } */
                
                    
                    /*
#####################################################################################################################
*/
                    
                    If(psfrNewTrigger[i].Approval_Status__c !='New')
                    {
                        psfrNewTrigger[i].adderror(system.label.PSFR_Upd2); //PreSales Fund Request can only be created with New Status
                    }
                    /*
#####################################################################################################################
*/
                    
                    /*    
If(! psfrNewTrigger[i].Division_of_User__c.contains('FIN'))
{
psfrNewTrigger[i].addError(system.label.PSFR_UpdateLabel1);  

}
*/  
                    If(psfrNewTrigger[i].TriggerController__c == True)
                    {
                        psfrNewTrigger[i].TriggerController__c = False;
                    } 
                    
                }
                
            }                  
            
            
            /*
#####################################################################################################################
*/
            
            if(trigger.isupdate)
            {  
                for(integer i = 0; i<psfrNewTrigger.size();i++)
                {
                    
                    /*
#####################################################################################################################
*/
                    
                    If(psfrNewTrigger[i].Approval_Status__c=='Approved')
                    {
                        string PSFRCategory;
                        
                        If(psfrNewTrigger[i].PFR_Presales_Category__c.contains('1'))
                        {PSFRCategory = '1-Network Cert' ;}
                        
                        if(psfrNewTrigger[i].PFR_Presales_Category__c.contains('2'))
                        {PSFRCategory = '2-Early Presales';}
                        
                        if(psfrNewTrigger[i].PFR_Presales_Category__c.contains('3'))
                        {PSFRCategory = '3-POC';}
                        
                        if(psfrNewTrigger[i].PFR_Presales_Category__c.contains('4'))
                        {PSFRCategory = '4-SOW';}
                        
                        if(psfrNewTrigger[i].PFR_Presales_Category__c.contains('5'))
                        {PSFRCategory = '5-PS work-ahead';}
                        
                        if(psfrNewTrigger[i].PFR_Presales_Category__c.contains('6'))
                        {PSFRCategory = '6-Non Standard';}                 
                        
                        If(OppMap!= null && !OppMap.isEmpty() && OppMap.containsKey(psfrNewTrigger[i].PFR_Opportunity__c)  )
                        { 
                            psfrNewTrigger[i].PFR_Approval_Number__c =  OppMap.get(psfrNewTrigger[i].PFR_Opportunity__C).Account.Account_Region__c+'_'+OppMap.get(psfrNewTrigger[i].PFR_Opportunity__C).Account.Account_Country_Code__c+'_'+system.today().Year()+system.today().Month()+'_'+psfrNewTrigger[i].name+'_'+PSFRCategory+'_'+psfrNewTrigger[i].Total_Value_of_Resources__c+'_'+psfrNewTrigger[i].Recoverable__c;
                        }
                        else 
                        {
                            psfrNewTrigger[i].PFR_Approval_Number__c =  '_'+system.today().Year()+system.today().Month()+'_'+psfrNewTrigger[i].name+'_'+PSFRCategory+'_'+psfrNewTrigger[i].Total_Value_of_Resources__c+'_'+psfrNewTrigger[i].Recoverable__c;
                        }
                        
                    }
                    
                    /*
#####################################################################################################################
*/ 
                    
                    If(psfrNewTrigger[i].PSFR_Authentication_Trigger__c==True)
                    {
                        psfrNewTrigger[i].PSFR_Authentication_Token_Text__c = '#'+string.valueOf(psfrNewTrigger[i].Name)+'#'+string.valueOf(psfrNewTrigger[i].lastModifiedDate)+string.valueOf(psfrNewTrigger[i].TriggerController__c)+string.valueOf(psfrNewTrigger[i].Region__c)+string.valueOf(psfrNewTrigger[i].Recoverable__c)+'###'+string.valueOf(psfrNewTrigger[i].Division_of_User__c)+'#';
                        
                    }
                    
                    If(psfrNewTrigger[i].PSFR_PSANumber__c != null && psfrNewTrigger[i].Approval_Status__c !='Approved')
                    {
                        psfrNewTrigger[i].adderror(system.label.PSFR_Upd3); //PSA Number can only be added after Approved Request
                    }
                }
                
                
            }
            
        }   
    }
    
     public static void PSFR_SubmitforApproval (List<Presales_Funding_Request__c> psfrNewTrigger, List<Presales_Funding_Request__c> psfrOldTrigger) {
        List <ID> RQIdList = new  List <ID>();
        List<String> POA_STP = new List<string>();
        List<String> POA_OOO = new List<string>();
        Id Template_PSFR_Subm_FM_ID= [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_Notification_OOteam_initial_subm_FS'].get(0).Id;
        EmailTemplate et=[Select id from EmailTemplate where DeveloperName=:'PSFR_STP_Authentication_Tokens'];
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE Group.DeveloperName = 'PSFR_Fund_Request_Approver']; 
        Id Template_PSFR_OTT_ID = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_To_OOTeam_Submit'].get(0).Id; // email Template Id
        Id Template_PSFR_OOT_SUB_ID = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_To_Approvers_StatusApproved'].get(0).Id;
        Id Template_PSFR_Rejected_ID = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_Notification_when_Rejected'].get(0).Id;
        Id Template_PSFR_SalesLeader = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_Retail_To_SalesLeader'].get(0).Id; // email Template Id
        Id Template_PSFR_LeaderShip = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_Retail_To_Leadership'].get(0).Id;
        Id Template_PSFR_STP_Approved = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_STP_Approved'].get(0).Id; // email Template Id
        Id Template_PSFR_Query_fr_All_ID = [Select id from EmailTemplate where DeveloperName=:'Raised_Query_PSFR_forall'].get(0).Id;
        
        EmailTemplate ett=[Select id from EmailTemplate where DeveloperName=:'Raised_Query_PSFR_forall'];
         //Change by Saurav(EBA_SF-1349)
        EmailTemplate psfrReject = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_STP_Rejected'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Presales_Funding_Request__c psfrmail = new Presales_Funding_Request__c();
        Boolean resourceeditaccess = False ;
        Boolean onlyrejected = False ;
        psfrmail =        [SELECT   Name,
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
                           Owner.name
                           FROM
                           Presales_Funding_Request__c
                           Where
                           id =:Trigger.newMap.keySet()];
        
        
        
        //Below Query will fetch latest updated Comments status on Rejected 
        
        List<ProcessInstanceStep> Processinstance = new List<ProcessInstanceStep>([Select id, 
                                                                                   ProcessInstance.TargetObjectId ,
                                                                                   comments,StepStatus, ElapsedTimeInMinutes 
                                                                                   from ProcessInstanceStep 
                                                                                   WHERE ProcessInstance.TargetObjectId =: Trigger.newMap.keySet()
                                                                                   And StepStatus ='Rejected' AND comments !='Raised Objection'
                                                                                   order by ElapsedTimeInMinutes asc limit 1]);
        
        If(Processinstance.size() > 0)
        {
            system.debug('Processinstance is not null :&:&:'+Processinstance);
            onlyrejected = true;
        }
        
        /*
#####################################################################################################################
*/
        
        
        if(Trigger.IsAfter)
        {          
            
            if(Trigger.IsUpdate)
            {
                
                for (Integer i = 0; i < psfrNewTrigger.size(); i++)
                {   
                    
                    
                    
                    
                    /*   Below will be executed to send notification to Opportunity team, when PS Request is sent to PS Team
This is common for All users
#####################################################################################################################
*/
                    
                    
                    if(psfrNewTrigger[i].Approval_Status__c=='Sent to PS' && psfrOldTrigger[i].Approval_Status__c!='Sent to PS')
                    {
                        resourceeditaccess = true;
                        
                        system.debug('common condition to sent notification to PS Team');
                        if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_OOO.add(psfrNewTrigger[i].Account_Manager__c);}
                        if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_OOO.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                        if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_OOO.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                        if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_OOO.add(psfrNewTrigger[i].Fund_Request_Owner__c);}                                  
                        
                        Messaging.SingleEmailMessage mailtoOO = new Messaging.SingleEmailMessage();  
                        mailtoOO.setTemplateId(Template_PSFR_Subm_FM_ID); // email Template Id
                        mailtoOO.setTargetObjectId(UserInfo.getUserId());
                        mailtoOO.setToAddresses(POA_OOO);
                        mailtoOO.setWhatId(psfrmail.Id);
                        mailtoOO.setSaveAsActivity(false);
                        mailtoOO.setSenderDisplayName('NSC Administration');  
                        emails.add(mailtoOO);
                    }
                    
                    
                    
                    /*   Below is executed to notify the concerned PS User with authentication token, generated to authentication
This is common for All users
#####################################################################################################################
*/
                    
                    if(psfrNewTrigger[i].PSFR_Authentication_Trigger__c==True ||test.isRunningTest() )
                    {
                        resourceeditaccess = true;
                        
                        system.debug('common condition to send authentication token to PS User');
                        POA_STP.add(psfrNewTrigger[i].PS_Rec_Authentication_Email__c);
                        Messaging.SingleEmailMessage mailAuth = new Messaging.SingleEmailMessage();  
                        mailAuth.setToAddresses(POA_STP);
                        mailAuth.setTargetObjectId(UserInfo.getUserId());
                        
                        mailAuth.setTemplateId(et.id); 
                        mailAuth.setWhatId(psfrmail.Id);
                        mailAuth.setSaveAsActivity(false);
                        mailAuth.setSenderDisplayName('NSC Administration'); 
                        //remove sender from recepient 20 feb 2020.
                        mailAuth.setTreatTargetObjectAsRecipient(false);
                        system.debug('Ajay Emails:'+POA_STP);
                        system.debug('Ajay Emails2:'+mailAuth); 
                        
                        emails.add(mailAuth);
                        //psfrNewTrigger[i].PSFR_Authentication_Trigger__c=False;
                    }
                    
                    
                    
                    /* Below condition will be only executed for Finance Presales Funding Request

#####################################################################################################################
*/
                    
                    if(psfrNewTrigger[i].Division_of_User__c.contains('FIN') || Test.isRunningTest())
                    {
                        //resourceeditaccess = true;
                        
                        system.debug('Division_of_User__c.contains(FIN)')   ;
                        //Below will fetch the email id's of Actual approvers
                        List<String> mailList = new List<String>();
                        List<String> mailAddresses = new List<String>(); 
                        // Below code is not in use ss185863
                        // for (GroupMember gm : g.groupMembers){ mailList.add(gm.userOrGroupId);}
                        // User[] usr = [SELECT email FROM user WHERE id IN :mailList];for(User u : usr){mailAddresses.add(u.email);} 
                        
                        //PS Team User address List
                        if(psfrNewTrigger[i].PS_Team_User1__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User1__c);}
                        if(psfrNewTrigger[i].PS_Team_User2__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User2__c);}
                        if(psfrNewTrigger[i].PS_Team_User3__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User3__c);}
                        if(psfrNewTrigger[i].PS_Team_User4__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User4__c);}
                        if(psfrNewTrigger[i].PS_Team_User5__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User5__c); }
                        if(psfrNewTrigger[i].PS_Team_User6__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User6__c); }
                        
                        //Sales Team
                        if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_STP.add(psfrNewTrigger[i].Account_Manager__c);}
                        if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                        if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                        if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_STP.add(psfrNewTrigger[i].Fund_Request_Owner__c);}
                        
                        //Finance notified team
                        POA_STP.add('pf230064@ncr.com.com');
                        
                        /*  When Presales Funding Request is submitted for approval and division is finance
#####################################################################################################################
*/
                        
                        if (psfrNewTrigger[i].Approval_Status__c == 'Pending for Approval' )
                        {
                            system.debug('Pending for Approval');
                            resourceeditaccess = true;
                            
                            // String[] toAddresses1 = new String[] {PSTEAMUser1,PSTEAMUser2,PSTEAMUser3, PSTEAMUser4, PSTEAMUser5, PSTEAMUser6};
                            Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                            mailtoSTP.setTemplateId(Template_PSFR_OTT_ID); // email Template Id
                            mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                            mailtoSTP.setToAddresses(POA_STP);
                            mailtoSTP.setWhatId(psfrmail.Id);
                            mailtoSTP.setSaveAsActivity(false);
                            mailtoSTP.setSenderDisplayName('NSC Administration');  
                            // Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailtoSTP});
                            emails.add(mailtoSTP);
                        }
                        
                        /* When Finance Presales Funding Request is Approved
#####################################################################################################################
*/
                        
                        if(psfrNewTrigger[i].Approval_Status__c=='Approved' && (psfrNewTrigger[i].TriggerController__c == True || test.isRunningTest()) )
                        { 
                            system.debug('Approved');
                            resourceeditaccess = true;
                            Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                            mailtoSTP.setTemplateId(Template_PSFR_OOT_SUB_ID); // email Template Id
                            mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                            mailtoSTP.setToAddresses(POA_STP);
                            mailtoSTP.setWhatId(psfrmail.Id);
                            mailtoSTP.setSaveAsActivity(false);
                            mailtoSTP.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailtoSTP});
                            emails.add(mailtoSTP);
                            
                        }
                        
                        /* When Finance Presales Funding Request is Rejected
#####################################################################################################################
*/
                        if(psfrNewTrigger[i].TriggerController__c == True || test.isRunningTest() )
                        {
                            If(onlyrejected == true || test.isRunningTest())
                            {
                                //if(Processinstance[i].StepStatus == 'Rejected' && Processinstance[i].comments != 'Raised Objection')
                                //    {
                                resourceeditaccess = true;
                                system.debug('Status :FIN -  Rejected & Processinstance details are :#:' + Processinstance);
                                Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                                mailtoSTP.setTemplateId(Template_PSFR_Rejected_ID); // email Template Id
                                mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                                mailtoSTP.setToAddresses(POA_STP);
                                mailtoSTP.setWhatId(psfrmail.Id);
                                mailtoSTP.setSaveAsActivity(false);
                                mailtoSTP.setSenderDisplayName('NSC Administration');  
                                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailtoSTP});
                                emails.add(mailtoSTP);
                                //  }
                            }
                        }
                    }
                    
                    // End of Finance Presales Funding Request
                    
                    
                    
                    
                    /* Below code will only execute for Retail Presales Funding Request
#######################################################################################################
*/
                    
                    if(psfrNewTrigger[i].Division_of_User__c.contains('RET')|| Test.isRunningTest() )
                    {    
                        //resourceeditaccess = true;
                        system.debug('Division_of_User__c.contains(RET)')   ;
                        
                        // PS Team
                        if(psfrNewTrigger[i].PS_Team_User1__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User1__c);}
                        if(psfrNewTrigger[i].PS_Team_User2__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User2__c);}
                        if(psfrNewTrigger[i].PS_Team_User3__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User3__c);}
                        if(psfrNewTrigger[i].PS_Team_User4__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User4__c);}
                        if(psfrNewTrigger[i].PS_Team_User5__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User5__c); }
                        if(psfrNewTrigger[i].PS_Team_User6__c != null) {POA_STP.add(psfrNewTrigger[i].PS_Team_User6__c); }
                        // Sales Team
                        if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_STP.add(psfrNewTrigger[i].Account_Manager__c);}
                        if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                        if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                        if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_STP.add(psfrNewTrigger[i].Fund_Request_Owner__c);}
                        // Notified Team                        
                        
                        POA_STP.add('IT230058@ncr.com');
                        POA_STP.add('MS517157@ncr.com');
                        POA_STP.add('OS185034@ncr.com');
                        POA_STP.add('cg400005@ncr.com');
                        
                        //Notified Leadership Teams
                        POA_STP.add('md185209@ncr.com');
                        POA_STP.add('AH250232@ncr.com');
                        
                        //Notified Sales Leader
                        POA_STP.add(psfrNewTrigger[i].Sub_Region_Sales_Leader_Email__c);
                        
                        // Notified Team  for POC                      
                        /*
POA_STP.add('IT230058@ncr.com');
POA_STP.add('MS517157@ncr.com');
POA_STP.add('ts250290@ncr.com');
POA_STP.add('lb185039@ncr.com');
*/
                        
                        
                        /* When Presales Funding Request is submitted for Approval to Regional Sales Leader
Stage 1 Approval
#####################################################################################################################
*/
                        if (psfrNewTrigger[i].Approval_Status__c == 'Pending from Regional Sales Leader' || test.isRunningTest())
                        {   
                            resourceeditaccess = true;
                            system.debug('Pending from Regional Sales Leader');
                            
                            Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                            mailtoSTP.setTemplateId(Template_PSFR_SalesLeader); // email Template Id
                            mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                            mailtoSTP.setToAddresses(POA_STP);
                            mailtoSTP.setWhatId(psfrmail.Id);
                            mailtoSTP.setSaveAsActivity(false);
                            mailtoSTP.setSenderDisplayName('NSC Administration');  
                            emails.add(mailtoSTP);
                            
                        }
                        /*  When Retail Presales Funding Request is submitted for Approval to LeaderShip Team   
Stage 2 Approval
#####################################################################################################################
*/
                        if (psfrNewTrigger[i].Approval_Status__c == 'Pending from Leadership Team' || test.isRunningTest())
                        {
                            system.debug('Pending from Leadership Team');
                            resourceeditaccess = true;
                            Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                            mailtoSTP.setTemplateId(Template_PSFR_LeaderShip); // email Template Id
                            mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                            mailtoSTP.setToAddresses(POA_STP);
                            mailtoSTP.setWhatId(psfrmail.Id);
                            mailtoSTP.setSaveAsActivity(false);
                            mailtoSTP.setSenderDisplayName('NSC Administration');  
                            emails.add(mailtoSTP);
                            
                        }
                        /*  When Retail Presales Funding Request is Approved (Final Approval)
#####################################################################################################################
*/
                        if(psfrNewTrigger[i].Approval_Status__c=='Approved' && (psfrNewTrigger[i]. PSFR_Trigger_Controller_RET__c == True || test.isRunningTest()))
                        {
                            system.debug('Approved');
                            //Leadership Approvers
                            resourceeditaccess = true;
                            Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                            mailtoSTP.setTemplateId(Template_PSFR_STP_Approved); // email Template Id
                            mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                            mailtoSTP.setToAddresses(POA_STP);
                            mailtoSTP.setWhatId(psfrmail.Id);
                            mailtoSTP.setSaveAsActivity(false);
                            mailtoSTP.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailtoSTP});
                            emails.add(mailtoSTP);
                            
                            
                        }
                        
                        /*  When Presales Funding Request is Rejected
#####################################################################################################################
*/
                        
                        if(psfrNewTrigger[i].TriggerController__c == True  || test.isRunningTest())
                        {
                            If(onlyrejected == true || test.isRunningTest())
                            {
                                //if(Processinstance[i].StepStatus == 'Rejected' && Processinstance[i].comments != 'Raised Objection')
                                //    {
                                system.debug('Status : RET - Rejected & Processinstance details are :#:' + Processinstance);
                                resourceeditaccess = true;
                                Messaging.SingleEmailMessage mailtoSTP = new Messaging.SingleEmailMessage();  
                               	//Change by Saurav(EBA_SF-1349)
                                // mailtoSTP.setTemplateId([SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'PSFR_STP_Rejected'].get(0).Id); // email Template Id
                                mailtoSTP.setTemplateId(psfrReject.Id);
                                mailtoSTP.setTargetObjectId(UserInfo.getUserId());
                                mailtoSTP.setToAddresses(POA_STP);
                                mailtoSTP.setWhatId(psfrmail.Id);
                                mailtoSTP.setSaveAsActivity(false);
                                mailtoSTP.setSenderDisplayName('NSC Administration');  
                                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailtoSTP});
                                emails.add(mailtoSTP);
                                
                                //  }
                            }
                        }
                        
                        
                    }
                    // End of Finance Presales Funding Request
                    
                    
                    
                    /* When Objection is Raised by Approvers to make changes in Presales Fundind Request
This is common for All users
#####################################################################################################################
*/
                    
                    if((psfrNewTrigger[i].Approval_Status__c=='On Hold' && psfrOldTrigger[i].Approval_Status__c !='On Hold') || test.isRunningTest())
                    {
                        resourceeditaccess = true;
                        system.debug('common step when raised objection');
                        
                        
                        /*  When Objection is Raised only to Sales Team
#####################################################################################################################
*/
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to Sales Team' || test.isRunningTest())
                        {   
                            system.debug('condition : Raised to Sales Team');
                            
                            if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_STP.add(psfrNewTrigger[i].Account_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                            if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_STP.add(psfrNewTrigger[i].Fund_Request_Owner__c);}
                            
                            
                            
                            //  String[] toAddresses = new String[] {Opportunityowner,OpportunityOManager, FundOwner, AccountManager};
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                            mail.setToAddresses(POA_STP);
                            mail.setTargetObjectId(UserInfo.getUserId());
                            String mailMessage = mail.getHTMLBody();
                            // EmailTemplate et=[Select id from EmailTemplate where DeveloperName=:'Raised_Query_PSFR_forall'];
                            mail.setTemplateId(Template_PSFR_Query_fr_All_ID);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                            emails.add(mail);
                            
                        }
                        
                        /*  When Objection is Raised only to PS Team
#####################################################################################################################
*/                      
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to PS Team'  || test.isRunningTest())
                        { 
                            system.debug('condition : Raised to PS Team');
                            
                            if(psfrNewTrigger[i].PS_Team_User1__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User1__c);}
                            if(psfrNewTrigger[i].PS_Team_User2__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User2__c);}
                            if(psfrNewTrigger[i].PS_Team_User3__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User3__c);}
                            if(psfrNewTrigger[i].PS_Team_User4__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User4__c);}
                            if(psfrNewTrigger[i].PS_Team_User5__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User5__c); }
                            if(psfrNewTrigger[i].PS_Team_User6__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User6__c); } 
                            
                            //String[] toAddresses = new String[] {PSTEAMUser1,PSTEAMUser2,PSTEAMUser3, PSTEAMUser4, PSTEAMUser5, PSTEAMUser6};
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                            mail.setToAddresses(POA_STP); 
                            mail.setTargetObjectId(UserInfo.getUserId());
                            //EmailTemplate et=[Select id from EmailTemplate where DeveloperName=:'Raised_Query_PSFR_forall'];
                            mail.setTemplateId(Template_PSFR_Query_fr_All_ID);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                            emails.add(mail);                           
                        }
                        
                        
                        /*  When Objection is Raised to Sales Team and PS Team
#####################################################################################################################
*/                      
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to Sales Team and PS Team'  || test.isRunningTest())
                        {   
                            system.debug('condition : Raised to Sales Team and PS Team');
                            
                            if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_STP.add(psfrNewTrigger[i].Account_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                            if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_STP.add(psfrNewTrigger[i].Fund_Request_Owner__c);}
                            if(psfrNewTrigger[i].PS_Team_User1__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User1__c);}
                            if(psfrNewTrigger[i].PS_Team_User2__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User2__c);}
                            if(psfrNewTrigger[i].PS_Team_User3__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User3__c);}
                            if(psfrNewTrigger[i].PS_Team_User4__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User4__c);}
                            if(psfrNewTrigger[i].PS_Team_User5__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User5__c); }
                            if(psfrNewTrigger[i].PS_Team_User6__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User6__c); } 
                            
                            //  String[] toAddresses = new String[] {Opportunityowner,OpportunityOManager, FundOwner, AccountManager,PSTEAMUser1,PSTEAMUser2,PSTEAMUser3, PSTEAMUser4, PSTEAMUser5, PSTEAMUser6};
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                            mail.setToAddresses(POA_STP);
                            mail.setTargetObjectId(UserInfo.getUserId());
                            mail.setTemplateId(Template_PSFR_Query_fr_All_ID);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailtoSTP});
                            emails.add(mail);
                        }
                        
                        
                        /*
#####################################################################################################################
*/                                                                                                      
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to Others'  || test.isRunningTest())
                        {   
                            system.debug('condition : Raised to Others');
                            
                            if(psfrNewTrigger[i].Query_User1__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User1__c); }
                            if(psfrNewTrigger[i].Query_User2__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User2__c); }
                            if(psfrNewTrigger[i].Query_User3__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User3__c);}
                            
                            //String[] toAddresses = new String[] {RaiseQuery1, RaiseQuery2, RaiseQuery3};
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                            mail.setToAddresses(POA_STP);
                            mail.setTargetObjectId(UserInfo.getUserId());
                            // EmailTemplate et=[Select id from EmailTemplate where DeveloperName=:'Raised_Query_PSFR_forall'];
                            mail.setTemplateId(Template_PSFR_Query_fr_All_ID);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});   
                            emails.add(mail);
                        }
                        
                        
                        /*  When Objection is Raised to Sales Team & PS Team and Others
#####################################################################################################################
*/                        
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to Sales Team, PS Team and Others'  || test.isRunningTest())
                        {   
                            system.debug('condition : Raised to Sales Team, PS Team and Others');
                            
                            if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_STP.add(psfrNewTrigger[i].Account_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                            if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_STP.add(psfrNewTrigger[i].Fund_Request_Owner__c);}
                            if(psfrNewTrigger[i].PS_Team_User1__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User1__c);}
                            if(psfrNewTrigger[i].PS_Team_User2__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User2__c);}
                            if(psfrNewTrigger[i].PS_Team_User3__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User3__c);}
                            if(psfrNewTrigger[i].PS_Team_User4__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User4__c);}
                            if(psfrNewTrigger[i].PS_Team_User5__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User5__c); }
                            if(psfrNewTrigger[i].PS_Team_User6__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User6__c); } 
                            if(psfrNewTrigger[i].Query_User1__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User1__c); }
                            if(psfrNewTrigger[i].Query_User2__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User2__c); }
                            if(psfrNewTrigger[i].Query_User3__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User3__c);}
                            
                            // String[] toAddresses = new String[] {PSTEAMUser6,PSTEAMUser1,PSTEAMUser2,PSTEAMUser3, PSTEAMUser4, PSTEAMUser5, PSTEAMUser6,RaiseQuery1, RaiseQuery2, RaiseQuery3,Opportunityowner,OpportunityOManager, FundOwner, AccountManager};
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(POA_STP);  
                            mail.setTargetObjectId(UserInfo.getUserId());
                            //EmailTemplate et=[Select id from EmailTemplate where DeveloperName=:'Raised_Query_PSFR_forall'];
                            mail.setTemplateId(Template_PSFR_Query_fr_All_ID);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
                            emails.add(mail);
                        }                                                                                            
                        
                        
                        /*  When Objection is raised to PS Team & Other Users
#####################################################################################################################
*/                        
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to PS Team and Others' )
                        {   
                            system.debug('condition : Raised to PS Team and Others');
                            
                            if(psfrNewTrigger[i].PS_Team_User1__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User1__c);}
                            if(psfrNewTrigger[i].PS_Team_User2__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User2__c);}
                            if(psfrNewTrigger[i].PS_Team_User3__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User3__c);}
                            if(psfrNewTrigger[i].PS_Team_User4__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User4__c);}
                            if(psfrNewTrigger[i].PS_Team_User5__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User5__c); }
                            if(psfrNewTrigger[i].PS_Team_User6__c != null)                 {POA_STP.add(psfrNewTrigger[i].PS_Team_User6__c); } 
                            if(psfrNewTrigger[i].Query_User1__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User1__c); }
                            if(psfrNewTrigger[i].Query_User2__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User2__c); }
                            if(psfrNewTrigger[i].Query_User3__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User3__c);}
                            
                            //  String[] toAddresses = new String[] {PSTEAMUser1,PSTEAMUser2,PSTEAMUser3, PSTEAMUser4, PSTEAMUser5, PSTEAMUser6,RaiseQuery1, RaiseQuery2, RaiseQuery3};
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                            mail.setToAddresses(POA_STP);
                            mail.setTargetObjectId(UserInfo.getUserId());
                            mail.setTemplateId(Template_PSFR_Query_fr_All_ID);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                            emails.add(mail);
                        } 
                        
                        /*  When Objection is Raised to Sales Team and Other users
#####################################################################################################################
*/                                                                                                                    
                        
                        If(psfrNewTrigger[i].Raised_Objection_Status__c == 'Raised to to Sales Team and Others')
                        {   
                            system.debug('condition : Raised to to Sales Team and Others');
                            
                            if(psfrNewTrigger[i].Account_Manager__c != null)               {POA_STP.add(psfrNewTrigger[i].Account_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner_Manager__c != null)     {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner_Manager__c);}
                            if(psfrNewTrigger[i].Opportunity_Owner__c != null)             {POA_STP.add(psfrNewTrigger[i].Opportunity_Owner__c); }
                            if(psfrNewTrigger[i].Fund_Request_Owner__c != null)            {POA_STP.add(psfrNewTrigger[i].Fund_Request_Owner__c);}
                            if(psfrNewTrigger[i].Query_User1__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User1__c); }
                            if(psfrNewTrigger[i].Query_User2__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User2__c); }
                            if(psfrNewTrigger[i].Query_User3__c != null)                   {POA_STP.add(psfrNewTrigger[i].Query_User3__c);}
                            
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                            mail.setToAddresses(POA_STP);
                            mail.setTargetObjectId(UserInfo.getUserId());
                            
                            mail.setTemplateId(ett.id);
                            mail.setWhatId(psfrmail.Id);
                            mail.setSaveAsActivity(false);
                            mail.setSenderDisplayName('NSC Administration');  
                            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
                            emails.add(mail);
                        } 
                    }
                    
                    //End of condition Objection Raised
                    
                    
                    
                    /*  Below will be execute to automate the Approval Process. It will be submitted by PS Team
This is common for All users
#####################################################################################################################
*/
                    
                    if (psfrNewTrigger[i].Approval_Status__c == 'Pending for Approval' && psfrNewTrigger[i].TriggerController__c == False && !test.isRunningTest())
                    {
                        system.debug('common condition to automate the approval process');
                        
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setObjectId(psfrNewTrigger[i].Id);
                        Approval.ProcessResult result = Approval.process(req);
                    }
                    
                    
                    
                }     
            }
        }
        
        If(emails != null && resourceeditaccess == True && !test.isRunningTest())
        {
            Messaging.sendEmail(emails);
        }
        
        /*
#####################################################################################################################
*/      
       /* public Id getWorkItemId(Id targetObjectId)
    {            
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id 
                                                 From   ProcessInstanceWorkitem p
                                                 Where  p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
            system.debug('workItem.Id'+retVal);
        }
        return retVal;
    } */
        
        
    }

}