/*
####################################################################################################################
# Project Name..........: Sales Order Reporting                                                                                                                       
# File............................:CreateSLSUser.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 22-01-2018                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 27-02-2018                                                                                 
# Description...............: This class Creates the SCP users which are in Workday/X500 but not in NSC.
####################################################################################################################
*/

global class CreateSLSUser implements Database.Batchable < sObject > , Database.Stateful {

    Set < String > UsrQLID = new Set < String > ();
    Set < String > usrName = new Set < String > ();
    List < User > UsrList = new List < User > ();
    String email;
    
    List<String> createUserErrs = new List<String>();
    List<String> updateUserErrs = new List<String>();
    integer createcount = 0;
    integer updatecount = 0;

    global Database.QueryLocator start(Database.BatchableContext BC) {

        //List < User > UsrList = [SELECT Id, Quicklook_ID__c,UserName,Incentive_Plan__c from User Where Quicklook_ID__c != null];
        UsrList = [SELECT Id, Quicklook_ID__c, UserName, Incentive_Plan__c, IsActive_In_Workday__c from User Where Quicklook_ID__c != null];

        if (!UsrList.isEmpty() && UsrList.size() > 0) {
            for (User usr: UsrList) {
                UsrQLID.add((usr.Quicklook_ID__c).toUpperCase());
                if (usr.UserName != null) {
                    usrName.add((usr.UserName).toUpperCase());
                }
            }
        }

        return Database.getQueryLocator([Select Id, User_Name__c, Quicklook_ID__c, Global_ID__c, Manager_global_id__c, Job_Family__c, job_family_code__c, Joining_Date__c, Sales_org_code__c, Incentive_Plan__c,inactive__c  from NCR_Employee_Detail__c where Incentive_Plan__c = 'SCP']);

    }

    global void execute(Database.BatchableContext BC, List < NCR_Employee_Detail__c > EmpList) {

        Set <String> MissingQLID = new Set < String > ();
        Set <String> ScpQLID = new Set < String > ();
        Set < String > inActvScpQlID = new Set < String > ();
        Map < String, String > EmpMap = new Map < String, String > ();

        //system.debug('UsrQLIDsize>>>' + UsrQLID.size());
        //system.debug('UserQlid>>>'+UsrQLID);

        for (NCR_Employee_Detail__c empObj: EmpList) {
            if (!(UsrQLID.contains(empObj.Quicklook_ID__c.toUpperCase())) && empObj.inactive__c != TRUE) {
                MissingQLID.add(empObj.Quicklook_ID__c);
            } else if(UsrQLID.contains(empObj.Quicklook_ID__c.toUpperCase()) && empObj.inactive__c == TRUE) {
                inActvScpQlID.add(empObj.Quicklook_ID__c);
            } else{
                ScpQLID.add(empObj.Quicklook_ID__c.toUpperCase());
            }
        }

        system.debug('MissingQLIDSize: ' + MissingQLID.size());
        system.debug('MissingQLID' + MissingQLID);
        List < User > createUsrList = new List < User > ();

        for (NCR_Employee_Detail__c empObj: EmpList) {
            if (MissingQLID != null && MissingQLID.size() > 0) {
                if (MissingQLID.contains(empObj.Quicklook_ID__c)) {
                     Id profId = NSCCommonInfoUtil.getIdOf('CreateSLSUser_ProfileId');
                    User newUsr = new User(alias = empObj.Quicklook_ID__c, email = empObj.Quicklook_ID__c + '@ncr.com',
                        emailencodingkey = 'UTF-8', lastname = empObj.User_Name__c, Quicklook_Id__c = empObj.Quicklook_ID__c, FederationIdentifier = empObj.Quicklook_ID__c, languagelocalekey = 'en_US',
                        localesidkey = 'en_US', profileid = profId, timezonesidkey = 'America/Los_Angeles',
                        username = empObj.Quicklook_ID__c + '@ncr.com', global_id__c = empObj.Global_ID__c, Manager_global_id__c = empObj.manager_global_id__c,
                        Sales_org_code__c = empObj.Sales_org_code__c, IsActive_In_Workday__c = TRUE,
                        job_family__c = empObj.job_family__c, job_family_code__c = empObj.job_family_code__c, Joining_Date__c = empObj.Joining_Date__c, Incentive_Plan__c = empObj.Incentive_Plan__c);

                    String uName = (newUsr.username).toUpperCase();
                    
                    if (usrName != null && usrName.size() > 0) {
                        if (!usrName.contains(uName)) {
                            createUsrList.add(newUsr);
                        }
                    } 

                }
            }

        }

        system.debug('createUsrList Size >>> ' + createUsrList.size());
        system.debug('createUsrList>>> ' + createUsrList);
        system.debug('SCPQuicklook ID size >>> ' + ScpQLID.size());
        
        Database.SaveResult[] crList, urList;
        List<String> errorList = new List<String>();
        
        if (!createUsrList.isEmpty()) {
            crList = Database.insert(createUsrList, false);
            errorList = checkDMLErrors(crList, createUsrList);
            createUserErrs.addAll(errorList);
            createcount += createUsrList.size() - errorList.size();
        }

        
        List < User > ActvWrkDyUsrList = new List < User > ();
        if (UsrList != null && UsrList.size() > 0) {
            for (User usr: UsrList) {
                if (ScpQLID != null && ScpQLID.contains(usr.Quicklook_ID__c.toUpperCase()) && usr.IsActive_In_Workday__c == FALSE) {
                    usr.IsActive_In_Workday__c = TRUE;
                    ActvWrkDyUsrList.add(usr);
                }else if (inActvScpQlID != null && inActvScpQlID.contains(usr.Quicklook_ID__c.toUpperCase()) && usr.IsActive_In_Workday__c == TRUE){
                    usr.IsActive_In_Workday__c = FALSE;
                    ActvWrkDyUsrList.add(usr);
                }
            }
        }

        system.debug('ActvWrkDyUsrList size>>> ' + ActvWrkDyUsrList.size());
        system.debug('ActvWrkDyUsrList>>> ' + ActvWrkDyUsrList);
        if (ActvWrkDyUsrList != null && ActvWrkDyUsrList.size() > 0) {
            urList = Database.update(ActvWrkDyUsrList, false);
            errorList = checkDMLErrors(urList, ActvWrkDyUsrList);
            updateUserErrs.addAll(errorList);
            updatecount += ActvWrkDyUsrList.size() - errorList.size();
        }
        
        System.debug('createUserErrs >>' + createUserErrs.size());
        System.debug('updateUserErrs >>' + updateUserErrs.size());
    }

    global void finish(Database.BatchableContext BC) {
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(',')); 
        integer errorCount = 0;
        String emailBody = '';
        
        if ((!createUserErrs.isEmpty())) {
            errorCount += createUserErrs.size();    
            emailBody += 'Unable to create below chatter users in NSC due to error mentioned against them : <br/><br/>';
            
            for (String err : createUserErrs) 
              emailBody +=  '&nbsp;' + err + '<br/>'; 
        }
        
        if ((!updateUserErrs.isEmpty())) {
            errorCount += updateUserErrs.size();    
            emailBody += '<br/><br/>Unable to update below users in NSC due to error mentioned against them : <br/><br/>';
            
            for (String err : updateUserErrs) 
              emailBody +=  '&nbsp;' + err; 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setToAddresses(toAddresses);
        //Changes done by Yogesh - related to Story EBA_SF-1918
        Id orgWdeId = NSCCommonInfoUtil.getIdOf('CreateSLSUser_OrgWideId');// Used query instead of metadata
        // End by Yogesh
        mail.setOrgWideEmailAddressId(orgWdeId);
        mail.setSubject('Create SLS Users Apex Batch completed with ' +  createcount + ' create users, ' + updatecount + ' update users and ' + errorCount + ' errors');
        mail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
    }
    
    List<String> checkDMLErrors(Database.SaveResult[] srList, List<User> usrList) {
        List<String> errorList = new List<String>(); 
            
        if(srList != null && srList.size() > 0 && usrList != null && usrList.size() > 0) {
            integer index = 0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    errorList.add(usrList[index].Quicklook_Id__c + ': ' + sr.getErrors()[0].getMessage());   
                }
                index++;
            }      
        } 
        return errorList;
    }
    
}