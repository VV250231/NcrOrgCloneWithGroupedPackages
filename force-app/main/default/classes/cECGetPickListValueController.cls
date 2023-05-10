/*##################################################################################################
# Description...........: This class is for CEC functionality.This class is controller class 
of LWC - cEC_MeetingIntakeForm
# Created by......: Sushant, Saurav, Yogesh, Monika 
# Created Date....: Nov 2021.  
# Story Number ......: EBA_SF-1607 , EBA_SF-1606 , EBA_SF-1605 , EBA_SF-1554
##################################################################################################*/
public with sharing class cECGetPickListValueController {
    
    //fetch picklist values from custom object in lwc
    @AuraEnabled(cacheable=true)
    public static List < customValueWrapper > pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        for (Schema.PicklistEntry myCustPick: custPickValues) {
            customValueWrapper selectOptionValueWrapper = new customValueWrapper();
            selectOptionValueWrapper.custFldlabel = myCustPick.getLabel();
            selectOptionValueWrapper.custFldvalue = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }
        
        return customObjWrapper;
        
    }
    // wrapper class 
    public with sharing class customValueWrapper {
        @auraEnabled public string custFldlabel {get;set;}
        @auraEnabled public string custFldvalue {get;set;}
    }

    @AuraEnabled
    public static cec__c start(cec__c cecRecordData, List<String> ContactIds,List<String> UserIds,List<CEC_Attendees__c> UserNotInSF,List<String> OppIds, List<CEC_Attendees__c> ExtUserList, String OApiName, String rId) {
        List<opportunity> OppList= new List<opportunity>();
         Id campId = NSCCommonInfoUtil.getIdOf('CEC_Campaign_id');
        //Create CEC Meeting Record
        if(cecRecordData !=null){
            if(OApiName=='Opportunity'){
                
                List<Opportunity> opport = [Select id,name, AccountId from Opportunity where id =:rId];
                for(Opportunity op:opport ){ 
                    cecRecordData.Account_Name__c=op.AccountId;
                    cecRecordData.Opportunity__c=rId; 
                }
            }
            if(OApiName=='Account'){
                cecRecordData.Account_Name__c=rId;
                if(OppList !=null && OppList.size() > 0){
                    Update OppList;
                }
            }
            // Changes for email template
                Set<id> OppIdLst1 = new Set<Id>();
                for(String opp: OppIds){
                    if(string.isNotBlank(opp)){
                        OppIdLst1.add(opp);
                    }
                }
                for(opportunity opp: [Select id, CampaignId,Opportunity_Number__c from opportunity where id In:OppIdLst1]){
                    if(opp.CampaignId != campId){
                      cecRecordData.Opportunity__c = opp.id;  
                    }
                }
                  
            insert cecRecordData;                                      
            system.debug('cec created from apex: '+cecRecordData.id);   
        }
        CEC__c cecObj =[Select Meeting_Purpose__c,Meeting_Purpose_Other__c,RFP_Affiliation__c,RFP_Name__c,/*Visited_NCR_CEC_Location__c,*/When_last_visit__c from CEC__c where id=:cecRecordData.id];
        if(cecObj.Meeting_Purpose__c!='Other'){
            cecObj.Meeting_Purpose_Other__c=null;
        }
        if(cecObj.RFP_Affiliation__c!='Yes'){
            cecObj.RFP_Name__c=null;
        }
        /*if(cecObj.Visited_NCR_CEC_Location__c!='Yes'){
            cecObj.When_last_visit__c=null;
        }*/
        update cecObj;
        //Id campId = NSCCommonInfoUtil.getIdOf('CEC_Campaign_id');
        Map<String, Object> cecRecord = new Map<String, Object>();
        cecRecord.put('CecRecordId', cecRecordData.id);
        List<String> conList = new List<String>();
        List<String> usrList = new List<String>();                                 
        List<CEC_Attendees__c> externalUserList = new List<CEC_Attendees__c>();  
        List<CEC_Attendees__c> AttendeesList= new List<CEC_Attendees__c>();
        List<CampaignMember> cmList= new List<CampaignMember>();
        List<String> contactsInCecVisit=new List<String>();
        List<String> contactsNotInCecVisit=new List<String>();
        List<CEC_Attendees__c> intList = new List<CEC_Attendees__c>(); // EBA_SF -1792
        
        for(CEC_Attendees__c strExt:ExtUserList ){
            if(strExt !=null && string.isNotBlank(strExt.Email__c) && string.isNotBlank(strExt.Role__c) && 
               string.isNotBlank(strExt.Attendee_Name_External__c))
            {
                externalUserList.add(strExt);
            }            
        }
        for(CEC_Attendees__c stusr:UserNotInSF ){
            if(stusr !=null && string.isNotBlank(stusr.Email__c) && string.isNotBlank(stusr.Role__c) && 
               string.isNotBlank(stusr.Non_Sf_NCR__c))
            {
                intList.add(stusr);
            }            
        }
        //Get CampaignMember List 
        for(CampaignMember cmb:[Select id,ContactId from CampaignMember where CampaignId =:campId and ContactId IN :conList])
        {
            contactsInCecVisit.add(cmb.ContactId);  
        }
        for(String cnt:ContactIds){
            if(string.isNotBlank(cnt)){                                        
                CEC_Attendees__c Attnd= new CEC_Attendees__c();
                Attnd.Attendee_Name_Contact__c=cnt;
                Attnd.CEC_Meeting__c= cecRecordData.id;
                Attnd.RecordTypeId= Schema.SObjectType.CEC_Attendees__c.getRecordTypeInfosByName().get('Contacts in Salesforce').getRecordTypeId();
                AttendeesList.add(Attnd);
                system.debug('Attnd'+Attnd);
                // Add contacts not aligned to CEC VISIT Campaign as of now.
                If(!contactsInCecVisit.contains(cnt)){
                    contactsNotInCecVisit.add(cnt);
                }                                                                                      
            }
        }
        Set<String> conIdLst = new Set<String>();
        System.debug('@@@@contactsNotInCecVisit'+contactsNotInCecVisit);
        if(!contactsNotInCecVisit.isEmpty()){
            for(CampaignMember str:[Select ContactId, CampaignId from CampaignMember where ContactId In:contactsNotInCecVisit]){
                if(str.CampaignId ==campId){
                    conIdLst.add(str.ContactId);
                }
            }
        }
        for(String cm :contactsNotInCecVisit){
            if(!conIdLst.contains(cm)){
                CampaignMember c= New CampaignMember();                                       
                c.CampaignId= campId;
                c.CEC_Meeting__c=cecRecordData.id;
                c.ContactId=cm;
                c.Status='Sent';
                cmList.add(c);
            }
        }
        System.debug('@@@@conIdLst'+conIdLst);        
        //Create Attendees as Internal Users
        for(String uid:UserIds){
            if(string.isNotBlank(uid)){
                CEC_Attendees__c Attnd= new CEC_Attendees__c();
                Attnd.Attendee_Name_Internal__c=uid;
                Attnd.CEC_Meeting__c= cecRecordData.id;
                Attnd.RecordTypeId= Schema.SObjectType.CEC_Attendees__c.getRecordTypeInfosByName().get('NCR Employee in Salesforce').getRecordTypeId();
                AttendeesList.add(Attnd);
            }
        }     
        //Create Attendees as External Users
        for(CEC_Attendees__c extUsr: externalUserList){
            CEC_Attendees__c Attnd= new CEC_Attendees__c();
            Attnd.Attendee_Name_External__c=extUsr.Attendee_Name_External__c;
            Attnd.Email__c=extUsr.Email__c;
            Attnd.Role__c=extUsr.Role__c;
            Attnd.CEC_Meeting__c= cecRecordData.id;
            Attnd.RecordTypeId= Schema.SObjectType.CEC_Attendees__c.getRecordTypeInfosByName().get('Contacts not in Salesforce').getRecordTypeId();
            AttendeesList.add(Attnd);
        }
        //EBA-SF-1792 Create Attendees as for users not in SF                                  
        for(CEC_Attendees__c intStr: intList){
            CEC_Attendees__c Attnd= new CEC_Attendees__c();
            Attnd.Is_Non_Sf_NCR__c = True;
            Attnd.Non_Sf_NCR__c=intStr.Non_Sf_NCR__c;                                       
            Attnd.Email__c=intStr.Email__c;
            Attnd.Role__c=intStr.Role__c;
            Attnd.CEC_Meeting__c= cecRecordData.id;
            Attnd.RecordTypeId= Schema.SObjectType.CEC_Attendees__c.getRecordTypeInfosByName().get('NCR Employee in Salesforce').getRecordTypeId();
            
            AttendeesList.add(Attnd);
        }
        //Create Attendees and CampaignMembers
        if(AttendeesList !=null && AttendeesList.size() > 0){
            insert AttendeesList;
        }
        if(cmList !=null && cmList.size() > 0){
            // insert cmList;
        }
        //Associate Opportunities To be Influenced with CEC Meeting
        List<OpportunityAndCECObject__c> cecOppJLst = new List<OpportunityAndCECObject__c>();
        List<opportunity> unlikedCamOppLst = new List<opportunity>();
        Set<id> OppIdLst = new Set<Id>();
        for(String opp: OppIds){
            if(string.isNotBlank(opp)){
                OppIdLst.add(opp);
            }
        }
        for(opportunity opp: [Select id, CampaignId,Opportunity_Number__c from opportunity where id In:OppIdLst]){
            OpportunityAndCECObject__c oppCecObj = new OpportunityAndCECObject__c();
            opportunity op= new opportunity();
            op.id=opp.id;
            op.bypass_validation__c=true;  
            // op.cec_bypass_validation__c=true;   
            //op.CEC_Meeting__c= cecRecordData.id;
            oppCecObj.CEC_Meeting__c = cecRecordData.id;
            oppCecObj.Opportunity__c = opp.id;
            oppCecObj.Name = opp.Opportunity_Number__c;
            if(opp.CampaignId == null){
                op.CampaignId= campId; 
            }
            else if(opp.CampaignId != campId){
                unlikedCamOppLst.add(opp);
                cecRecordData.Opportunity__c = opp.id;
            }
            OppList.add(op);
            cecOppJLst.add(oppCecObj);
            System.debug('@@@@1');
            
        }    
        System.debug('@@@OppList'+OppList);
        if(OppList !=null && OppList.size() > 0){
            Update OppList;
        }
        if(!cecOppJLst.isEmpty()){
            insert cecOppJLst;
        }
        
        if(!unlikedCamOppLst.isEmpty()){
            
            String body = '';
            String subject= '';
            Contact c = [select id, Email from Contact where id =:BPM_Configuration__c.getValues('BPMContactIdForNotifyActionOwner').values__c];
            List<opportunity> oppLst = [Select id, Account.Name,Name,AccountId from opportunity where id In: unlikedCamOppLst];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            EmailTemplate emailTemplate = [Select Id,Markup,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'CEC Opp Campaign Temp'];
            //body=emailTemplate.Markup;
            //subject ='Primary CEC Campaign Source Unable to Link to '+oppLst[0].Account.Name; 
            String temBody='';
            //Set<Id> uIdSet = new Set<Id>();
            String[] toAddresses = new String[]{};
                for (GroupMember uId: [Select UserOrGroupId,Group.Name FROM GroupMember WHERE Group.Name ='CEC Notification Group']){
                    //  uIdSet.add(uId.UserOrGroupId);
                    toAddresses.add(uId.UserOrGroupId);
                }
            System.debug('@@@@'+toAddresses);
            message.setToAddresses(toAddresses);
            /*temBody+= '<br/> <br/>Account - ';
            temBody+= '<a href="'+Label.inactiveLeadAndContactLabel+'lightning/r/Account/'+oppLst[0].Accountid+'/view">' +oppLst[0].Account.Name+'</a><br/><br/>';
            temBody+= 'Opportunity - ';
            for(opportunity oppId : oppLst ){
                temBody+= '<a href="'+Label.inactiveLeadAndContactLabel+'lightning/r/Opportunity/'+oppId.id+'/view">' +oppId.Name+'</a><br/>';
            }
            body =body.replace('#tempBody', temBody);*/
            // message.htmlbody =body;
            //message.setHtmlBody(body);
            //message.setSubject(subject);
            message.setTargetObjectId(c.id); 
            message.setSenderDisplayName('CEC Notification');
            message.setReplyTo('cec.team@ncr.com');
            message.setUseSignature(false); 
            message.setBccSender(false);
            message.setTreatTargetObjectAsRecipient(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(cecRecordData.Id);
            // mail.add(message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
        }
        return [select id , account_name__r.Name from cec__c where id =: cecRecordData.id];
    }
}