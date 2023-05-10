/**************************************************************************************************************************************************************
This Test Class was created for the "PartnerRevenueTrigger".

#############################################################################################################################################################
Created By                           Date                              Description
Naman Kumar(nk250337)                11th February 2020                Version 1.0 , which is used for the code coverage of PartnerRevenueTrigger and dashboardLastUpdatedDate

****************************************************************************************************************************************************************/
@isTest
public class PartnerRevenueTriggerTest {
    //This method is setting-up account and Partner Revenue records.
    @TestSetup static void testDataSetup(){
        Account accObj = PRM_TestRecordsFactory.createPartnerAccount('', NULL);
        insert accObj;
        List<Partner_Revenue__c> listOfPartnerRev = PRM_TestRecordsFactory.partnerRevenueList(accObj.Id);
        insert listOfPartnerRev;
    }
    //This method is used to update "Dashboard Last Updated Date" field value on the account record when Partner Revenue gets insert
    @isTest static void insertRevenueRecord(){
        Account accRecord = [SELECT Id, Dashboard_last_updated_on__c FROM Account LIMIT 1];
        Partner_Revenue__c revRecord = new Partner_Revenue__c(
            Direct_Revenue__c=1000, Indirect_Revenue__c=1000, Hardware__c=1000, Software__c=1000, Professional_Services__c=1000,  
            TS__c=1000, Hosted__c=1000, SaaS__c=1000,POSaaS__c=1000,Total_Services_Revenue__c=1000,Solution_from_Net_New_Customers__c=1000,
            Subscription_from_Net_New_Customers__c=1000,First_Half__c=4000,Second_Half__c=4000,Partner_Account__c=accRecord.Id, 
            Year__c = '2015'
        );
        insert revRecord;
        System.assert(revRecord != NULL);
        System.assertEquals(5, [Select Id FROM Partner_Revenue__c].size());
        DateTime lastModifiedDateTime = [SELECT Id, LastModifiedDate FROM Partner_Revenue__c 
                                     WHERE Partner_Account__c =:accRecord.Id AND Year__c = '2015'].LastModifiedDate;
        Date lastModifiedDate = PartnerRevenueTriggerTest.dateTimeToDateConvertor(lastModifiedDateTime);
        System.assertEquals(accRecord.Dashboard_last_updated_on__c, lastModifiedDate);
    }
    //This method is used to update "Dashboard Last Updated Date" field value on the account record when Partner Revenue gets update
    @isTest static void updateRevenueRecord(){
        Account accRecord = [SELECT Id, Dashboard_last_updated_on__c FROM Account LIMIT 1];
        Partner_Revenue__c revRecordToUpdate = [Select Id, LastModifiedDate FROM Partner_Revenue__c WHERE Partner_Account__c =:accRecord.Id 
                                                AND Year__c =:String.valueOf(System.today().year())];
        update revRecordToUpdate;
        DateTime lastModifiedDateTime = [SELECT Id, LastModifiedDate FROM Partner_Revenue__c WHERE Id =:revRecordToUpdate.Id].LastModifiedDate;
        Date lastModifiedDate = PartnerRevenueTriggerTest.dateTimeToDateConvertor(lastModifiedDateTime);
        System.assert(revRecordToUpdate != NULL);
        System.assertEquals(4, [Select Id FROM Partner_Revenue__c].size());
        System.assertEquals(accRecord.Dashboard_last_updated_on__c, lastModifiedDate);
    }
    //This method is used to cover the case of duplicate Partner Revenue record insertion 
    @isTest static void preventDuplicateRecords(){
        Account accObj = PRM_TestRecordsFactory.createPartnerAccount('Demo', NULL);
        accObj.Master_Customer_Number__c = '91663450';
        insert accObj;
        String accId = [SELECT Id FROM Account WHERE Master_Customer_Number__c = '91663450'].Id;
        List<Partner_Revenue__c> partnerRevenueList1 = PRM_TestRecordsFactory.partnerRevenueList(accId);
        List<Partner_Revenue__c> partnerRevenueList2 = PRM_TestRecordsFactory.partnerRevenueList(accId);
        List<Partner_Revenue__c> duplicateRecordList = new List<Partner_Revenue__c>();
        duplicateRecordList.addAll(partnerRevenueList1);
        duplicateRecordList.addAll(partnerRevenueList2);
        try{
            insert duplicateRecordList;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Record for this year already exist.') ? true : false);
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    private static Date dateTimeToDateConvertor(DateTime dt){
        Date convertedDate = Date.newInstance(dt.year(), dt.month(), dt.day());
        return convertedDate;
    }
}