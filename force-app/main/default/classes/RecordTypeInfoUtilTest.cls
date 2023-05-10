/**
 *
 * Unit testing for the GetRecordTypeIdsByDeveloperName method of RecordTypeInfoUtil
 *
 *
 */
@isTest
private class RecordTypeInfoUtilTest {

  static testMethod void testGetRecordTypeIdsByDeveloperName() {
    List<RecordType> recTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName =: 'Partner' LIMIT 1];
    
    //This is the unit testing for fetching record type of an object
    Map<String,Id> accountTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
        
    //system.assert(recTypeList[0].Id == accountTypesMap.get('Partner'));
            
    //Unit test of the code which returns list of record types which already featched in above code.
    accountTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
      
  }
}