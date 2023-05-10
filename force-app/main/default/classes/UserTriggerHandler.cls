/*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   User  :   
* Return        :   
* Description   :   Combined Multipile Trigger in One User Trigger
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1788     01 Feb 2022     Kapil Bhati          Removed hardcoded profile Id from deleteteammembers and SAMLAutoProvisioning method
*************************************************************************************************/
/************************************************************************************************* 
* Update By     :   Pankaj Kashyap For Story : EBA_SF-1628 // 9 Dec 2021
* Param         :   User  :   
* Return        :   
* Description   :   Add a check for on line 683 
*************************************************************************************************/

public class UserTriggerHandler {
    /*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   User  :   User
* Return        :   
* Description   :   Email to List of Inactive User' Contact and Lead to Sam
*************************************************************************************************/
    public static Boolean isfirst = true;

    @future
    public static void ListOfInactiveUserinFtr(Set<Id> userList) {
        ListOfInactiveUser(userList);
    }

    public static void ListOfInactiveUser(Set<Id> userList) {
        List<Id> userIdLst = new List<Id>();
        List<Lead> lList = new List<Lead>();
        List<Contact> cList = New List<Contact>();
        for (User userObj : [Select IsActive, id from User where id In :userList]) {
            if (userObj.IsActive == false)
                userIdLst.add(userObj.Id);
        }
        lList = [SELECT id, Name, OwnerId, Owner.Name, isConverted From Lead Where OwnerId IN :userIdLst and isConverted = False];
        cList = [SELECT id, Name, OwnerId, Owner.Name From Contact Where OwnerId IN :userIdLst];
        if (!userIdLst.isEmpty() && (!lList.isEmpty() || !cList.isEmpty())) {
            List<User__c> mcs = User__c.getall().values();
            NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'Inactive Users Leads And Contacts Notification', Recipient1__c = mcs[0].Email_Address__c, UserIDs__c = String.join(userIdLst, ','));
            //NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'Inactive Users Leads And Contacts Notification', Recipient1__c = Label.InactiveLeadAndContactEmail, UserIDs__c=String.join(userIdLst, ','));
            insert ncrEmail;

        }

    }
    /*Set<Id> userIdSets = new Set<Id>();
    for(User userObj : userList){
        if(userObj.IsActive==false)
            userIdSets.add(userObj.Id);
        System.debug('1');
    }
    system.debug('@@'+userIdSets);
    if(userIdSets!=null){
        if(System.isFuture() || System.isBatch()){
            mainMethod(userIdSets);
        }else{
            mainMethodWithFuture(userIdSets);
        }
    }
}
public static void mainMethod(Set<Id>userIdSets){
    List<Contact> conList = new List<Contact>();
    List<Lead> leadList = new List<Lead>();
    Map<String,List<Contact>> conMap = new Map<String, List<Contact>>();
    Map<String,List<Lead>> leadMap = new Map<String, List<Lead>>();
    System.debug('@@@'+[SELECT id,Name,OwnerId,Owner.Name From Lead Where OwnerId IN:userIdSets]);
    for(Lead leadObj : [SELECT id,Name,OwnerId,Owner.Name From Lead Where OwnerId IN:userIdSets]){
        if(leadMap.containsKey(leadObj.OwnerId +'-'+leadObj.Owner.Name)){
            leadMap.get(leadObj.OwnerId +'-'+leadObj.Owner.Name).add(leadObj);
        }else{
            leadMap.put(leadObj.OwnerId +'-'+leadObj.Owner.Name,new List<Lead>{leadObj});
        }

    }
    for(Contact conObj : [SELECT id,Name,OwnerId,Owner.Name From Contact Where OwnerId IN:userIdSets]){
        if(conMap.containsKey(conObj.OwnerId +'-'+conObj.Owner.Name)){
            conMap.get(conObj.OwnerId +'-'+conObj.Owner.Name).add(conObj);
        }else{
            conMap.put(conObj.OwnerId +'-'+conObj.Owner.Name,new List<Contact>{conObj});
        }
    }
    if(conMap.size()>0 || leadMap.size()>0){
        List<User__c> customSettingList = new List<User__c>();
        List<User__c> mcs = User__c.getall().values();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{mcs[0].Email_Address__c};
            message.setToAddresses(sendingTo);
        //  message.setInReplyTo('NI230017@ncr.com');
        message.setSenderDisplayName('NSC Admin');
        message.optOutPolicy = 'FILTER';
        message.subject = 'Inactive Users Leads And Contacts';
        String body;
        body = 'Hi Samantha, <br/><br/>';
        body += 'The below Salesforce User has been deactivated from our Production Org in Salesforce.  Please refer to the below list of Contact(s) and Lead(s) where this user is still the owner.<br/><br/>';

        if(conMap.size()>0){
            //     body += 'Below the list Of contact of all deactivated users names and its contacts list<br/>';
            for(String mapId : conMap.keySet()){
                body += '<b>Salesforce User Name :</b> '+ mapId.split('-')[1]+'<br/>';
                body += '<b>List Of Contact </b><br/>';
                for(Contact con : conMap.get(mapId))
                {
                    System.debug('@@@@'+con);
                    body += '<a href="'+Label.inactiveLeadAndContactLabel+'lightning/r/Contact/'+con.id+'/view">' +con.Name+'</a><br/>';
                }
                body+='<br/>';
            }
        }
        body +=' <br/><br/>';
        if(leadMap.size()>0){
            //        body += 'Below the list Of Lead of all deactivated users name and its lead list-<br/>';
            for(String mapLeadId : leadMap.keySet()){
                body += '<b>Salesforce User Name : </b>'+ mapLeadId.split('-')[1]+'<br/>';
                body += '<b>List Of Lead </b><br/>';

                for(Lead leadObj : leadMap.get(mapLeadId))
                {
                    System.debug('@@@@'+leadObj);
                    body += '<a href="'+Label.inactiveLeadAndContactLabel+'lightning/r/Contact/'+leadObj.id+'/view">' +leadObj.Name+'</a><br/>';
                }
                body+='<br/>';
            }
        }
        body += '<br/>Please take necessary action on these Contact(s) and Lead(s).<br/><br> Thanks,<br/>NCR Corporation';
        System.debug('Messgae '+message);
        message.htmlbody = body;

        Messaging.SingleEmailMessage[] messages =
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }
}
@future
public static void mainMethodWithFuture(Set<Id>userIdSets){
    mainMethod(userIdSets);
}
*/
    /*************************************************************************************************
* Author        :   Sagar Kinja   
* Param         :   User  :   User
* Return        :   
* Description   :   
*************************************************************************************************/
    /*  ##################################################################################################
# Project Name............: NSC Sales Central                                                                        
# File....................: UserCreationAutomation                                                       
# Version.................:  
# Created by..............: Shephalika Belapurkar                                                                    
# Created Date............: 01-06-2012                                                                                
# Last Modified by........: 
# Last Modified Date......: 
# Description.............: NAR - R-0136
Streamline new user creation by the following: 
a. The Alias field should contain the QLID (lower case) 
b. Community nickname should be Last, First 
c. The Allow Forecasting checkbox should default to Yes/True 
e) Autocomplete Company (NCR Corporation)
################################################################################################*/
    public void UserCreationAutomation(List<User> triggernew) {
        List<User> users = new List<User>();
        for (User usr : triggernew) {
            if (
                    (!HSRUtil.isUserProvisioningCustomerProfile(usr.User_Profile__c)) &&
                            (!usr.User_Profile__c.contains('Chatter')) &&
                            (!usr.User_Profile__c.contains('Community')) &&
                            (!usr.User_Profile__c.contains('Banking'))
            ) { // &&(!usr.User_Profile__c.contains('Banking'))
                usr.Alias = usr.Quicklook_ID__c.toLowerCase();
                usr.CommunityNickname = usr.LastName + ',' + usr.FirstName;
                //  usr.ForecastEnabled = TRUE;
                if (usr.CompanyName == NULL) {
                    usr.CompanyName = 'NCR Corporation';
                    System.debug('3');
                }
            }

            else if (usr.User_Profile__c != null && usr.User_Profile__c.equalsIgnoreCase('90 Chatter Free')) {
                if (usr.Quicklook_ID__c != null) {
                    usr.CommunityNickname = usr.Quicklook_ID__c;
                } else if (usr.FederationIdentifier != null) {
                    usr.CommunityNickname = usr.FederationIdentifier ;
                }

            }
        }
    }
    /*************************************************************************************************
* Author        :   Dev Admin   
* Param         :   User  :   SelectDoNotDeactivatebyDefault 
* Return        :   
* Description   :   
*************************************************************************************************/
    public void SelectDoNotDeactivatebyDefault(List<User> triggernew) {
        List<User> uList = new List<User>();
        for (User u : triggernew) {
            if (u.User_Profile__c == '61 DI Community Members') {
                u.Do_Not_Deactivate__c = true ;
            }
        }
    }
    /*************************************************************************************************
* Author        :   Mudasir Rashid   
* Param         :   User  :   AddUserToPramataGroup  
* Return        :   
* Description   :   
*************************************************************************************************/
    /*public void AddUserToPramataGroup(List<User> triggernew){
        Id PramataGroupId = '00G70000003MhmFEAS';
        List < GroupMember > AddGroupMemberList = new List < GroupMember > ();
        List < GroupMember > DelGroupMemberList = new List < GroupMember > ();
        List < GroupMember > ExistingGroupMemberList = new List < GroupMember > ();
        Set < Id > ExistingGroupMemberSet = new Set < Id > ();
        ExistingGroupMemberList = [Select UserOrGroupId FROM GroupMember WHERE GroupId =: PramataGroupId];
        for (GroupMember u: ExistingGroupMemberList) {
            ExistingGroupMemberSet.add(u.UserOrGroupId);
        }
        Set < Id > userIdSet = new Set < Id > ();
        for (User u: triggernew) {
            //system.debug('::::PROFILEID:::::' + u.profileid);
            if (PramataProfiles__c.getValues(u.profileid) != null) {
                //system.debug('::::IM HERE::::');
                if (!ExistingGroupMemberSet.contains(u.Id)) {
                    GroupMember gm = new GroupMember();
                    gm.GroupId = PramataGroupId;
                    gm.UserOrGroupId = u.Id;
                    AddGroupMemberList.add(gm);
                    System.debug('5');
                }
            } else {
                userIdSet.add(u.Id);
            }
        }
        //system.debug('::::usersToAddToGroup:::' + AddGroupMemberList);
        //system.debug('::::NoOfusersToAddToGroup:::' + AddGroupMemberList.size());
        
        DelGroupMemberList = [Select Id from GroupMember where GroupId =: PramataGroupId and UserOrGroupId IN: userIdSet];
        
        //system.debug('::::usersToDeleteFromGroup::::' + DelGroupMemberList);
        
        if (AddGroupMemberList != null && AddGroupMemberList.size() > 0)
            System.debug('Insert');
        insert AddGroupMemberList;
        
        if (DelGroupMemberList != null && DelGroupMemberList.size() > 0)
            System.debug('Delete');
        delete DelGroupMemberList;
    }*/  /*
####################################################################################################################
# Project Name..........: NSC CRM 2017, Sales Order Reporting                                                                                                                           
# File............................:CalculateIsManagerFlag.trigger                                                           
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 17-07-2017                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 18-01-2017                                                                                 
# Description...............: This trigger checks the Is_Manager check box to true if the user is a manager or Area_VP 
#                             or Region_VP or Division_VP. IsManager_In_Workday field is also gets checked if the user
#                             ia a manager in workday.
####################################################################################################################*/
    public void CalculateIsManagerFlag(List<User> triggernew) {
        List < User > usr = new List < User > ();
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        Set < String > GblId = new Set < String > ();
        Set < String > mgrGblId = new Set < String > ();
        for (User u : triggernew) {
            if (String.isNotBlank(u.Global_ID__c))
                GblId.add(u.Global_ID__c);
        }
        system.debug('User Global Ids : ' + GblId);
        if (!GblId.isEmpty())
            ncrEmp = [Select Manager_Global_ID__c from NCR_Employee_Detail__c where Manager_Global_ID__c IN :GblId AND InActive__c = false];
        system.debug('User ncrEmp Ids : ' + ncrEmp);
        if (ncrEmp != null && ncrEmp.size() > 0) {
            for (NCR_Employee_Detail__c emp : ncrEmp) {
                if (emp.Manager_Global_ID__c != null) {
                    mgrGblId.add(emp.Manager_Global_ID__c);
                    System.debug('6' + mgrGblId);
                }
            }
        }
        system.debug('#####' + mgrGblId);
        Set < String > AreaVP = new Set < String > ();
        Set < String > RegionVP = new Set < String > ();
        Set < String > DivisionVP = new Set < String > ();
        if (!mgrGblId.isEmpty()) {
            for (User u : [
                    SELECT Id, Name, Area_VP_QuickLook__c, Region_VP_QuickLook__c, Division_VP_QuickLook__c
                    from User
                    WHERE UserType = 'standard'
                    AND isActive = True
            ]) {
                if (u.Area_VP_QuickLook__c != null) {
                    AreaVP.add(u.Area_VP_QuickLook__c.toUpperCase());
                }
                if (u.Region_VP_QuickLook__c != null) {
                    RegionVP.add(u.Region_VP_QuickLook__c.toUpperCase());
                }
                if (u.Division_VP_QuickLook__c != null) {
                    DivisionVP.add(u.Division_VP_QuickLook__c.toUpperCase());
                }
            }
        }
        for (User u : triggernew) {
            if ((u.Global_ID__c != null) && mgrGblId.contains(u.Global_ID__c)) {
                u.Is_Manager__c = true;
                u.IsManager_In_Workday__c = true;
                system.debug('User is a simple Manager');
            } else if (u.Quicklook_ID__c != null && (AreaVP.contains(u.Quicklook_ID__c.toUpperCase()) || RegionVP.contains(u.Quicklook_ID__c.toUpperCase()) || DivisionVP.contains(u.Quicklook_ID__c.toUpperCase()))) {
                u.Is_Manager__c = true;
                u.IsManager_In_Workday__c = false;
                system.debug('User Is VP');
            } else {
                u.Is_Manager__c = false;
                u.IsManager_In_Workday__c = false;
                system.debug('User Is not Manager');
            }
        }
    }
    /*
####################################################################################################################
# Project Name..........: Sales Order Reporting                                                                                                                       
# File............................:CalculateRegionHierarchy                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 15-01-2018                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 18-01-2017                                                                                 
# Description...............: This triggercalculates Region Hierarchy of all users.
####################################################################################################################
*/
    public void CalculateRegionHierarchy(List<User> triggernew) {
        System.debug('@@@@@@@@@@' + triggernew);
        Set < String > SalesOrg = new Set < String > ();
        for (User u : triggernew) {
            if (u.Sales_Org_Code__c != null) {
                SalesOrg.add(u.Sales_Org_Code__c);
            }
        }

        List < Sales_Org__c > so = new List < Sales_Org__c > ();
        so = [select sales_org_code__c, Hierarchy_2__c, Hierarchy_4__c, Hierarchy_6__c from sales_org__c where sales_org_code__c IN :SalesOrg];
        System.debug('@@@@@@@@@@so' + so);
        Map < string, string > H2 = new Map < string, string > ();
        Map < string, string > H4 = new Map < string, string > ();
        Map < string, string > H6 = new Map < string, string > ();

        if (!so.isEmpty() && so.size() > 0) {
            for (Sales_org__c rec : so) {
                H2.put(rec.sales_org_code__c, rec.Hierarchy_2__c);
                H4.put(rec.sales_org_code__c, rec.Hierarchy_4__c);
                H6.put(rec.sales_org_code__c, rec.Hierarchy_6__c);
                System.debug('7CalculateRegionHierarchy2121');
            }
        }
        if (!so.isEmpty() && so.size() > 0) {
            for (User u : triggernew) {
                u.L2_Industry__c = H2.get(u.Sales_Org_Code__c);
                u.L4_Sub_Region__c = H4.get(u.Sales_Org_Code__c);
                u.Region_OCR_Team__c = H6.get(u.Sales_Org_Code__c);
                System.debug('7CalculateRegionHierarchy');
            }
        }
    }
    /*************************************************************************************************
* Author        :   Admin NSC   
* Param         :   User  :   User
* Return        :   
* Description   :   Combined Multipile Trigger in One User Trigger
*************************************************************************************************/

    public void updateUser(List<User> userList) {
        //   List<User> users = new List<User>();
        // If(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        for (User usr : userList) {
            if (!usr.User_Profile__c.contains('Chatter External')) {
                if (usr.Quicklook_ID__c != null) {
                    if (usr.contactId == null) {
                        usr.Quicklook_ID__c = usr.Quicklook_ID__c.toLowerCase();
                        usr.FederationIdentifier = usr.Quicklook_ID__c.toLowerCase();
                        System.debug('@@updateuser');
                    } else {
                        usr.Quicklook_ID__c = usr.Quicklook_ID__c; usr.FederationIdentifier = usr.Quicklook_ID__c;
                    }

                } else if (usr.Quicklook_ID__c == null && usr.FederationIdentifier != null) {
                    usr.License_Entitlement__c = 'Chatter Free';
                    usr.Theater__c = 'GLOBAL';
                    if (usr.ContactId == null) {
                        usr.FederationIdentifier = usr.FederationIdentifier.toLowerCase();
                        usr.Quicklook_ID__c = usr.FederationIdentifier.toLowerCase();
                    } else {
                        usr.FederationIdentifier = usr.FederationIdentifier; usr.Quicklook_ID__c = usr.FederationIdentifier;
                    }
                } else if (usr.Quicklook_ID__c == null && usr.FederationIdentifier == null && usr.isactive == true) {
                    usr.adderror(system.label.updUsr1); //Please enter Quicklook ID or FederationIdentifier. These fields cannot be left blank
                    System.debug('@@updateuser');
                }
            }
            // START Change , by Divya for 2241
            if (usr.User_Profile__c != null && usr.User_Profile__c.equalsIgnoreCase('90 Chatter Free')) {
                if (usr.Quicklook_ID__c != null) {
                    usr.CommunityNickname = usr.Quicklook_ID__c;
                } else if (usr.FederationIdentifier != null) {
                    usr.CommunityNickname = usr.FederationIdentifier ;
                }

            }
            // END Change , 2241
        }
        //}
    }
    /****************************************************************************************************************
* Author        :   Ajay Dixit   
* Param         :   User  :   SAMLAutoProvisioning 
* Return        :   
* Description   :   
****************************************************************************************************************/
    public void SAMLAutoProvisioning(List<User> uList, Map<Id, User> uOldMap) {
        // EBA_SF-1788 Removed hardcoded profile Id - Modified by Kapil Bhati
        Id profId = NSCCommonInfoUtil.getIdOf('UserTriggerHandler_ProfileId');
        /* if (uOldMap.get(u.id).ProfileId != '00e70000000xC4uAAE' && u.ProfileId == '00e70000000xC4uAAE') {
                 u.ProfileId = uOldMap.get(u.id).ProfileId;
             }*/
        for (User u : (List<User>) trigger.new) {
            if (uOldMap.get(u.id).ProfileId != profId && u.ProfileId == profId) {
                u.ProfileId = uOldMap.get(u.id).ProfileId;
            }
        }
        //End Yogesh Changes
    }
    public void UserTriggerAiAuAfterInsert(List<User> uList) {
        Map<Id, Id> newUserProfIdMap = new Map<Id, Id>();
        Map<Id, Id> oldUserProfIdMap = new Map<Id, Id>();
        /* This trigger update 'Partner User' field on contact object */
        List<Id> userIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        for (User u : uList) {
            if (u.IsPortalEnabled && (!u.IsBPMUser__c)) {
                userIds.add(u.Id);
            }
            newUserProfIdMap.put(u.Id, u.profileId);
        }

        if (System.isFuture() || System.isBatch()) { // Check User HSG Group membership
            UserTriigerHandler.updateHSGGroupUsers(newUserProfIdMap, oldUserProfIdMap);
        } else {
            UserTriigerHandler.updateHSGGroupUserswithFuture(newUserProfIdMap, oldUserProfIdMap);
        }
        if (userIds.size() > 0)
            UserTriigerHandler.updateContact(userIds, Trigger.isInsert, Trigger.isUpdate);
    }
    public void UserTriggerAiAuAfterUpdate(List<User> uList, Map<Id, User> userOldMap) {
        Map<Id, Id> newUserProfIdMap = new Map<Id, Id>();
        Map<Id, Id> oldUserProfIdMap = new Map<Id, Id>();
        /* This trigger update 'Partner User' field on contact object */
        List<Id> userIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        for (User u : uList) {
            if ((userOldMap.get(u.Id).IsPortalEnabled) && (!u.IsPortalEnabled)) {
                userIds.add(u.Id);
            }
            User oldUser = userOldMap.get(u.Id);
            if (u.profileId != oldUser.profileId) {
                newUserProfIdMap.put(u.Id, u.profileId);
                oldUserProfIdMap.put(oldUser.Id, oldUser.profileId);
            }
        }
        if (!newUserProfIdMap.isEmpty()) {
            if (System.isFuture()) { // Check User HSG Group membership
                UserTriigerHandler.updateHSGGroupUsers(newUserProfIdMap, oldUserProfIdMap);
            } else {
                UserTriigerHandler.updateHSGGroupUserswithFuture(newUserProfIdMap, oldUserProfIdMap);
            }
        }
        if (userIds.size() > 0)
            UserTriigerHandler.updateContact(userIds, Trigger.isInsert, Trigger.isUpdate);
    }
    public void deleteteammembers(List<User> uList, Map<Id, User>uOldMap) {
        List<Id> user = new List<Id>();
        List<AccountTeamMember> accountteam = new List<AccountTeamMember>();
        List<OpportunityTeamMember> opportunityteam = new List<OpportunityTeamMember>();
        // EBA_SF-1788 Removed hardcoded profile Id - Modified by Kapil Bhati
        // Id ProfileID = '00e70000000x3egAAA';
        Id profileID = NSCCommonInfoUtil.getIdOf('PS_SCH_AdmnPrfId');
        //End Changes
        //Previous Condition
        //if(UserInfo.getProfileID() != profileID){
        //New Condition with lightning clone profile
        if (UserInfo.getProfileID() != profileID) {
            for (User u : uList) {
                if (u.IsActive == false && uOldMap.get(u.Id).IsActive == true) {
                    user.add(u.Id);
                }
            }
        }
        if (user.size() > 0) {
            List<AsyncApexJob> batchAccTeamDelete = [SELECT Id, Status, JobType, ApexClassID FROM AsyncApexJob WHERE JobType = 'BatchApex' and ApexClassID = '01p700000002oMM' and Status IN ('Queued', 'Preparing', 'Processing')];
            if (!batchAccTeamDelete.isEmpty()) {

                System.abortJob(batchAccTeamDelete.get(0).Id);
            }
            List<AsyncApexJob> batchOppTeamDelete = [SELECT Id, Status, JobType, ApexClassID FROM AsyncApexJob WHERE JobType = 'BatchApex' and ApexClassID = '01p700000002oMN' and Status IN ('Queued', 'Preparing', 'Processing')];

            if (!batchOppTeamDelete.isEmpty()) {

                System.abortJob(batchOppTeamDelete.get(0).Id);
            }
            Database.executeBatch(new batchAccTeamDelete());
            Database.executeBatch(new batchOppTeamDelete());
        }

    }
    public void updateStartDateAndManager(List<user> uList) {
        List<String> ManagerIds = new List<String>();
        Boolean managerFlag = FALSE;
        Map <String, Id> ManagerMap = new Map <String, Id>();
        /*  if(Trigger.Isupdate){
for(Integer i=0; i< Trigger.new.size(); i++){
if(Trigger.New.get(i).Manager_Global_ID__c != NULL){
ManagerIds.add(Trigger.New.get(i).Manager_Global_ID__c);
}
}
}
if(ManagerIds != NULL && ManagerIds.size() > 0){
List<User> managerUsers = [SELECT Id, Global_ID__c from User where Global_ID__c in :ManagerIds];
for(User usr : managerUsers){
ManagerMap.put(usr.Global_ID__c, usr.Id);
}
}*/
        List<Job_Role_Mapping__c> JobCodes = [SELECT Name, ARCS_Job_Family__c from Job_Role_Mapping__c];
        Map <String, String> JobCodeRoleMap = new Map <String, String>();
        for (Job_Role_Mapping__c jobCode : JobCodes) {
            JobCodeRoleMap.put(jobCode.Name, jobCode.ARCS_Job_Family__c);
        }
        //  JobCodeRoleMap.put(NULL,NULL);
        for (User u : uList) {
            //Code starts for Manager Sync
            /* if(Trigger.Isupdate){
if(ManagerMap.ContainsKey(Trigger.New.get(i).Manager_Global_ID__c) && Trigger.New.get(i).Manager_Global_ID__c != Trigger.New.get(i).Global_ID__c){
Trigger.New.get(i).ManagerId = ManagerMap.get(Trigger.New.get(i).Manager_Global_ID__c);
}
else {
Trigger.New.get(i).ManagerId = null;    
}
}*/
            //Code ends for Manager Sync
            //Code starts for Role Start Date change
            if (u.Job_Role_Start_Date__c == NULL && u.Joining_Date__c != NULL) {
                u.Job_Role_Start_Date__c = u.Joining_Date__c;
            }
            /*  else if(Trigger.IsUpdate && Trigger.New.get(i).Job_Code__c != Trigger.Old.get(i).Job_Code__c && JobCodeRoleMap.get(Trigger.New.get(i).Job_Code__c) != JobCodeRoleMap.get(Trigger.Old.get(i).Job_Code__c)){
Trigger.New.get(i).Job_Role_Start_Date__c = System.Today();
}*/
            //Code end for Role Start Date change
        }
    }
    public void updateStartDateAndManagerOnUpdate(List<user> uList, Map<Id, User> uOldMap) {
        List<String> ManagerIds = new List<String>();
        Boolean managerFlag = FALSE;
        Map <String, Id> ManagerMap = new Map <String, Id>();
        List<String> jCode = new List<String>();
        // if(Trigger.Isupdate){
        for (User u : uList) {
            if (String.isNotBlank(u.Job_Code__c))
                jCode.add(u.Job_Code__c);
            if (u.Manager_Global_ID__c != NULL) {
                ManagerIds.add(u.Manager_Global_ID__c);
            }
        }
        //  }
        if (ManagerIds != NULL && ManagerIds.size() > 0) {
            List<User> managerUsers = [SELECT Id, Global_ID__c from User where Global_ID__c in :ManagerIds];
            for (User usr : managerUsers) {
                ManagerMap.put(usr.Global_ID__c, usr.Id);
            }
        }

        //   List<Job_Role_Mapping__c> JobCodes = [SELECT Name, ARCS_Job_Family__c from Job_Role_Mapping__c];
        Map <String, String> JobCodeRoleMap = new Map <String, String>();
        if (!jCode.isEmpty()) {
            for (Job_Role_Mapping__c jobCode : [SELECT Name, ARCS_Job_Family__c from Job_Role_Mapping__c]) {
                JobCodeRoleMap.put(jobCode.Name, jobCode.ARCS_Job_Family__c);
            }
        }
        //  JobCodeRoleMap.put(NULL,NULL);
        for (User u : uList) {
            //Code starts for Manager Sync
            //if(Trigger.Isupdate){
            if (ManagerMap.ContainsKey(u.Manager_Global_ID__c) && u.Manager_Global_ID__c != u.Global_ID__c) {
                u.ManagerId = ManagerMap.get(u.Manager_Global_ID__c);
            } else {
                u.ManagerId = null;
            }
            //  }
            //Code ends for Manager Sync
            //Code starts for Role Start Date change
            if (u.Job_Role_Start_Date__c == NULL && u.Joining_Date__c != NULL) {
                u.Job_Role_Start_Date__c = u.Joining_Date__c;
            } else if (u.Job_Code__c != uOldMap.get(u.id).Job_Code__c && JobCodeRoleMap.get(u.Job_Code__c) != JobCodeRoleMap.get(uOldMap.get(u.id).Job_Code__c)) {
                u.Job_Role_Start_Date__c = System.Today();
            }
            //Code end for Role Start Date change
        }
    }
    public void updateCompensationRecords(List<user> uList, Map<Id, User>uOldMap) {
        List<ID> InactivatedMembers = new List<ID>();
        List<String> temporaryObjectMap = new List<String>();
        //    List<Job_Role_Mapping__c> JobCodes = [SELECT Name, ARCS_Job_Family__c from Job_Role_Mapping__c];
        Map <String, String> JobCodeRoleMap = new Map <String, String>();
        List<String> jCode = new List<String>();
        for (User u : uList) {
            if (String.isNotBlank(u.Job_Code__c))
                jCode.add(u.Job_Code__c);
        }
        if (!jCode.isEmpty()) {
            for (Job_Role_Mapping__c jobCode : [SELECT Name, ARCS_Job_Family__c from Job_Role_Mapping__c]) {
                JobCodeRoleMap.put(jobCode.Name, jobCode.ARCS_Job_Family__c);
            }
        }
        List<Id> managerIds = new List<Id>();
        for (User u : uList) {
            managerIds.add(u.ManagerId);
        }
        Map<Id, User> Managers = new Map<Id, User>([SELECT id, Name, Quicklook_ID__c from User where id in :managerIds]);

        for (User u : uList) {
            String details = '';
            if (u.Incentive_Plan__c == 'SCP') {
                if (uOldMap.get(u.Id).Incentive_Plan__c != 'SCP') {
                    details = details + 'New SCP Associate' + ':';
                } else {
                    if (u.IsActive == FALSE && u.IsActive != uOldMap.get(u.Id).IsActive) {
                        details = details + 'Terminated' + ':';
                        InactivatedMembers.add(u.id);
                    }
                    if (uOldMap.get(u.Id).Job_Role_Start_Date__c != NULL && u.Job_Role_Start_Date__c != uOldMap.get(u.Id).Job_Role_Start_Date__c) {
                        details = details + 'Role Changed' + ':';
                        InactivatedMembers.add(u.id);
                    }
                }
            } else {
                if (uOldMap.get(u.Id).Incentive_Plan__c == 'SCP') {
                    details = details + 'Role Changed' + ':';
                    InactivatedMembers.add(u.id);
                }
            }
            if (details != '') {
                details = details + u.Quicklook_ID__c + ':';
                details = details + u.FirstName + ' ' + u.LastName + ':';
                if (!String.isBlank(u.ManagerId) && Managers.ContainsKey(u.ManagerId)) {
                    details = details + Managers.get(u.ManagerId).Quicklook_ID__c + ':';
                    details = details + Managers.get(u.ManagerId).Name + ':';
                } else {
                    details = details + '::';
                }
                if (!String.isBlank(uOldMap.get(u.Id).Job_Code__c)) {
                    details = details + uOldMap.get(u.Id).Job_Code__c + ':';
                } else {
                    details = details + ':';
                }
                if (!String.isBlank(u.Job_Code__c)) {
                    details = details + u.Job_Code__c + ':';
                } else {
                    details = details + ':';
                }
                if (!String.isBlank(uOldMap.get(u.Id).Job_Code__c) && JobCodeRoleMap.containsKey(uOldMap.get(u.Id).Job_Code__c)) {
                    details = details + JobCodeRoleMap.get(uOldMap.get(u.Id).Job_Code__c) + ':';
                } else {
                    details = details + ':';
                }
                if (!String.isBlank(u.Job_Code__c) && JobCodeRoleMap.containsKey(u.Job_Code__c)) {
                    details = details + JobCodeRoleMap.get(u.Job_Code__c) + ':';
                } else {
                    details = details + ':';
                }
                if (!String.isBlank(u.Country_Code__c)) {
                    details = details + u.Country_Code__c + ':';
                } else {
                    details = details + ':';
                }
            }
            if (details != '') {
                temporaryObjectMap.add(details);
            }
        }
        if (!UserNotifyBeforeThenDeactivationBatch.CheckForInactiveUser && temporaryObjectMap.size() > 0 && temporaryObjectMap != NULL) {
            compensationHelper.createRecords(temporaryObjectMap);
        }
    }

    public void portalRoleBasedAccess(List<User> uList) {
        Set<Id> setUserId = new Set<Id>();
        Group objGroup = [select Id from Group Where DeveloperName = 'MDF_Access_For_Approval'];
        List<GroupMember> lstGroupMember = new List<GroupMember>();
        for (User objNewUser : uList) {
            setUserId.add(objNewUser.Id);
            GroupMember GM = new GroupMember();
            GM.GroupId = objGroup.Id;
            GM.UserOrGroupId = objNewUser.Id;
            lstGroupMember.add(GM);
        }
        if (!setUserId.isEmpty()) {
            Database.insert(lstGroupMember, false);
            BatchShareMDFWithPartnerUser obj = new BatchShareMDFWithPartnerUser(setUserId);
            Database.executeBatch(obj, 1);
        }
        List<PermissionSet> PermissionSets = [SELECT Id FROM PermissionSet WHERE Label = 'Access to Engineer and Equipment' LIMIT 1];
        if (PermissionSets.size() > 0) {
            Set<Id> userIds = new Set<Id>();
            userIds = Trigger.newMap.keySet();

            List<User> users = [
                    SELECT Id, Name, IsActive, UserRole.PortalType, UserRole.PortalRole,
                            IsPortalEnabled
                    FROM User
                    WHERE Id IN :userIds
            ];

            Set<Id> qualifiedUserIds = new Set<Id>();
            Set<Id> disQualifiedUserIds = new Set<Id>();
            for (User u : users) {
                system.debug('&&&' + u.UserRole.PortalRole);
                if (u.IsActive && u.UserRole.PortalType == 'Partner' && u.IsPortalEnabled) {
                    if (u.UserRole.PortalRole == 'Executive' || u.UserRole.PortalRole == 'Manager') {
                        qualifiedUserIds.add(u.Id);
                    } else if (u.UserRole.PortalRole == 'Worker') {
                        disQualifiedUserIds.add(u.Id);
                    }
                }
            }
            system.debug('***' + qualifiedUserIds + '---' + disQualifiedUserIds);
            Map<Id, PermissionSetAssignment> userIdToPSA = new Map<Id, PermissionSetAssignment>();
            List<PermissionSetAssignment> psaList = [
                    SELECT AssigneeId, PermissionSetId
                    FROM PermissionSetAssignment
                    WHERE (AssigneeId IN :qualifiedUserIds
                    OR
                    AssigneeId IN :disQualifiedUserIds)
                    AND PermissionSetId = :PermissionSets[0].Id
            ];
            for (PermissionSetAssignment psa : psaList) {
                userIdToPSA.put(psa.AssigneeId, psa);
            }

            List<PermissionSetAssignment> newPSA = new List<PermissionSetAssignment>();
            List<PermissionSetAssignment> deletePSA = new List<PermissionSetAssignment>();
            for (Id userId : qualifiedUserIds) {
                if (userIdToPSA.get(userId) == null) {
                    newPSA.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = PermissionSets[0].Id));
                }
            }

            for (Id userId : disQualifiedUserIds) {
                if (userIdToPSA.get(userId) != null) {
                    deletePSA.add(userIdToPSA.get(userId));
                }
            }

            if (newPSA.size() > 0) {
                insert newPSA;
            }

            if (deletePSA.size() > 0) {
                delete deletePSA;
            }
        }
    }


    public static void insertUsersInAccountTeam(List<User> partnerUserList, Boolean isDelete) {
        Set < Id > accountIds = new Set < Id > ();
        Set < String > prtnrOwndMcn = new Set < String > ();
        Set < Id > ecIds = new Set < Id > ();
        Set < Id > validUsrs = new Set < Id > ();
        List<User> cpqUsrs = new List<User>();
        validUsrs = validateUser(partnerUserList);
        if (validUsrs.size() > 0) {
            cpqUsrs = [SELECT id, AccountId, Partner_Owned_Accounts__c, UserType, ContactId, Username FROM User WHERE Id IN :validUsrs];
            Map <id, Set<id>> prtnr_ECSiteMap = new Map <id, Set<id>>();
            if (!isDelete) {
                for (user usr : cpqUsrs) {
                    accountIds.add(usr.AccountId);
                    if (usr.Partner_Owned_Accounts__c != null)
                        prtnrOwndMcn.addAll((usr.Partner_Owned_Accounts__c.replaceAll('\\s+', '')).split(','));
                }
                // Add Partner Owned Account to Set accountIds        

                for (cdm_Account_Relationship__c c : [
                        SELECT Id, Account__c, Name, Related_Account__c
                        From cdm_Account_Relationship__c
                        where name = 'End Customer' and Related_Account_AccountType__c = :Label.AccRel_AccTyp_EC and (Account__c in :accountIds OR Account__r.Master_Customer_Number__c in :prtnrOwndMcn)
                ]) {
                    ecIds.add(c.Related_Account__c);//endcusts-ec1,ec2,ec3
                    Set<id> relatedEC = prtnr_ECSiteMap.get(c.Account__c);
                    if (relatedEC != null) {
                        relatedEC.add(c.Related_Account__c);
                    } else {
                        prtnr_ECSiteMap.put(c.Account__c, new Set<id>{
                                c.Related_Account__c
                        });//FM,EC1-EC2|I3-EC1
                    }
                }
                if (prtnr_ECSiteMap.size() > 0) {
                    database.executeBatch(new Partner_Acc_Share_main(prtnr_ECSiteMap, cpqUsrs, ecIds, prtnrOwndMcn, isDelete)); // Calling batch class.
                }
            } else {
                database.executeBatch(new Partner_Acc_Share_main(prtnr_ECSiteMap, cpqUsrs, ecIds, prtnrOwndMcn, isDelete)); // Calling batch class.
            }

        }

    }
    public static Set<Id> validateUser(List<User> partnerUserList) {
        Set < Id > validUsrs = new Set < Id > ();
        Map<id, Set<String>> usrIdMCNsMap = new Map<id, Set<String>>();
        Map<string, Id> mcnAccIdMap = new Map<string, Id>();
        Set<String> allmcns = new Set<string>();
        for (User u : partnerUserList) {
            Set<String> s = new Set<string>();
            if (u.Partner_Owned_Accounts__c != null)
                s.addAll((u.Partner_Owned_Accounts__c.replaceAll('\\s+', '')).split(','));
            allmcns.addAll(s);
            usrIdMCNsMap.put(u.id, s);
        }
        List <Account> mcnAccounts = [Select id, Master_Customer_Number__c from Account where Master_Customer_Number__c in :allmcns];
        for (Account a : mcnAccounts) {
            mcnAccIdMap.put(a.Master_Customer_Number__c, a.id);
        }
        //validate user for sharing
        for (User u : partnerUserList) {
            String invalidMCN = '';
            boolean hasParentMCN = false;
            for (String s : usrIdMCNsMap.get(u.id)) {
                if (u.AccountId == mcnAccIdMap.get(s)) {
                    hasParentMCN = true;
                    break;
                }
                if (mcnAccIdMap.get(s) == null) {
                    invalidMCN = s;
                    break;
                }
            }
            if (hasParentMCN) {
                u.addError('Partner Owned Account field contains MCN which is same as Users Parent Account.');
            } else if (!String.isEmpty(invalidMCN)) {
                u.addError('Partner Owned Account field contains Invalid MCN: ' + invalidMCN);
            } else {
                validUsrs.add(u.id);
            }

        }
        return validUsrs;
    }

    @future
    public static void asgnICMPrmSetinFtr(Set<Id> asgnPrmUsrIds, Set<Id> rmvPrmUsrIds) {
        asgnICMPrmSet(asgnPrmUsrIds, rmvPrmUsrIds);
    }

    public static void asgnICMPrmSet(Set<Id> asgnPrmUsrIds, Set<Id> rmvPrmUsrIds) {
        List<PermissionSetAssignment> prmSetAsgns = new List<PermissionSetAssignment>();
        final String ICM_PRMSET = Label.ICM_Permission_Set;
        String insrtErr = '', delErr = '', errMsg = '';

        if (!asgnPrmUsrIds.isEmpty()) {
            for (PermissionSetAssignment prm : [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :asgnPrmUsrIds AND PermissionSet.Name = :ICM_PRMSET]) {
                asgnPrmUsrIds.remove(prm.AssigneeId);
            }

            if (!asgnPrmUsrIds.isEmpty()) {
                PermissionSet icmPrmSet = [SELECT Id FROM PermissionSet WHERE Name = :ICM_PRMSET LIMIT 1];

                for (Id uId : asgnPrmUsrIds) {
                    prmSetAsgns.add(new PermissionSetAssignment(AssigneeId = uId, PermissionSetId = icmPrmSet.Id));
                }
                Database.SaveResult[] insertRslt = Database.insert(prmSetAsgns, false);
                insrtErr = NSCCommonInfoUtil.getInstance().prsSaveRslt(insertRslt, prmSetAsgns);
            }
        }


        if (rmvPrmUsrIds != NULL && !rmvPrmUsrIds.isEmpty()) {
            List<PermissionSetAssignment> prmAsmnt = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN :rmvPrmUsrIds AND PermissionSet.Name = :ICM_PRMSET];

            if (!prmAsmnt.isEmpty()) {
                Database.DeleteResult[] deleteRslt = Database.delete(prmAsmnt, false);
                delErr = NSCCommonInfoUtil.getInstance().prsDelRslt(deleteRslt, prmAsmnt);
            }
        }


        if (String.isNotBlank(insrtErr)) errMsg = String.format(Label.ICM_PrmSetAsgnErr, new List<String>{
                ICM_PRMSET, insrtErr
        });
        if (String.isNotBlank(delErr)) errMsg += String.format(Label.ICM_PrmSetRemErr, new List<String>{
                ICM_PRMSET, delErr
        });

        if (String.isNotBlank(errMsg)) {
            String mailHdr = '', mailSubHdr = '', mailSub;
            mailHdr = ICM_PRMSET + ' Permission Set Assignment/Removal Process Failed';
            mailSubHdr = mailHdr + ' for below users';
            mailSub = mailHdr;
            List<String> rcpnts = NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(',');
            rcpnts.add(UserInfo.getUserEmail());
            System.enqueueJob(new AsyncNotifier(mailHdr, mailSubHdr, mailSub, errMsg, rcpnts));
        }

    }


}