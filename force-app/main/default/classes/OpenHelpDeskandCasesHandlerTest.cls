@isTest
public class OpenHelpDeskandCasesHandlerTest {
    @isTest
    public static void getHelpDeskCasesTest(){
        
        Account ac=new Account();
        Account parentAcc =new Account();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        User Usr = [Select Id from User Where Name = 'Soup User'];
        
        System.runAs(Usr){
            parentAcc.Name='Test Parent Account';
            parentAcc.Account_Country_Code__c='A2';
            parentAcc.MDM_Industry_Name__c='FINANACIAL:BANKING';
            parentAcc.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            insert parentAcc;
            
            ac.Name='Test Account';
            ac.Account_Country_Code__c='A2';
            ac.MDM_Industry_Name__c='FINANACIAL:BANKING';
            ac.RecordTypeId = rtMapByName.get(Label.RT_Acc_Customer).getRecordTypeId();
            ac.parentId = parentAcc.Id;
            insert ac; 
        }
        List<Open_Help_Desk_Case__c> openHelpDeskList = new  List<Open_Help_Desk_Case__c>();
        Open_Help_Desk_Case__c ohd = new Open_Help_Desk_Case__c();
        ohd.priority_code__c = 1;
        ohd.less_then_24_hours__c = 2;
        ohd.more_then_24_hours__c = 10;
        ohd.Account_Master_Lookup__c  = ac.Id;
        openHelpDeskList.Add(ohd);
        
        Open_Help_Desk_Case__c ohd2 = new Open_Help_Desk_Case__c();
        ohd2.priority_code__c = 1;
        ohd2.less_then_24_hours__c = 2;
        ohd2.more_then_24_hours__c = 10;
        ohd2.Account_Master_Lookup__c  = ac.Id;
        openHelpDeskList.Add(ohd2);
        insert openHelpDeskList;
        OpenHelpDeskandCasesHandler.getHelpDeskCases(ac.id);
         List<Open_Help_Desk_Case__c> getHlpDsk = new List<Open_Help_Desk_Case__c>();
        getHlpDsk = [SELECT Id, Name, OwnerId, priority_code__c, more_then_24_hours__c, less_then_24_hours__c, gems_customer_name__c, customer_nbr__c, Unique_ID__c FROM Open_Help_Desk_Case__c where Account_Master_Lookup__c = :ac.id];
        system.assert(getHlpDsk.size()>0);
        OpenHelpDeskHierarchy.getHelpDeskCases(ac.id);
        OpenHelpDeskHierarchy.getHelpDeskCases(parentAcc.id);
    }

}