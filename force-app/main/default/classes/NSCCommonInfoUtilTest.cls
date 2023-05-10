/*
####################################################################################################################                                                        
# Created by................: Ajay Dixit                                                                      
# Created Date...........: 07-06-2017                                                                                  
# Last Modified by......: Ajay Dixit                                                                           
# Last Modified Date..: 07-06-2017                                                                                
# Description...............: Test Class
####################################################################################################################
*/

@isTest

public class NSCCommonInfoUtilTest {
    public static testMethod void testCommonUtil(){
        NSCCommonInfoUtil ncu= NSCCommonInfoUtil.getInstance();
        ncu.buildMapOfAllRecordTypes('Account');
        ncu.buildMapOfRecordTypes('Account');
        ncu.BuildSoqlString('Account', new Set<String>{'id'}, null, 'id!=null', 'id', 100);
        ncu.getMapOfAllProfiles();
        ncu.getNonRORCtrs_PicklistVals();
        Account a=TestRecordsFactory.createAccount();
        ncu.getObject('Account', a.id);
        ncu.getPicklistAsSelectOptions('Account', 'Account_Country_Code__c', true);
        ncu.getPicklistValues('Account', 'Account_Country_Code__c', true);
        Id i = ncu.getProfileId('System Administrator');
        ncu.getQueueUsers('test', 'test');
        ncu.getQueueUsers('test', null);        
        ncu.getTheaterAreaMapping();
        ncu.selectStar('Account', true);
        ncu.selectStar('Account', false);        
        ncu.sortOptionList(new List<SelectOption>{new SelectOption('Ajay',''), new SelectOption('B','Puneet')});
        ncu.getPrdCat_PicklistVals();
        ncu.CollectLocaleConversionRate();
        ncu.userHasLightningPermission(Userinfo.getUserId());
        ncu.getFiscalMonthEndDate(); 
        ncu.getRecordTypeId('Account', 'Customer');
        ncu.getSystemUsers();
        NSCCommonInfoUtil.getIdOf('Test');
        NSCCommonInfoUtil.getIdSetOf('Test');
        system.assertEquals(i, '00e70000000sR8UAAU'); 
    }
    
    public static testMethod void testCommonUtil2(){
     	  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='ICM_Access' LIMIT 1];
          User u = new User(Email='standarduser@testorg.com',FirstName='test', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,  
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12@org.com.test',Quicklook_ID__c='tst12');
         insert u;
         
         List<PermissionSetAssignment> prmAgnLst = new List<PermissionSetAssignment>();
         prmAgnLst.add(new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=u.Id));
         Database.SaveResult[] insertRslt = Database.insert(prmAgnLst, false);
         String msg = NSCCommonInfoUtil.getInstance().prsSaveRslt(insertRslt, prmAgnLst);
             
         Database.DeleteResult[] deleteRslt = Database.delete(prmAgnLst, false);
         NSCCommonInfoUtil.getInstance().prsDelRslt(deleteRslt, prmAgnLst);
         system.assert(msg != null,'There is some error while inserting the records.');  
         NSCCommonInfoUtil.getDependentPicklistValues(Lead.Industry_Code__c);
     }
}