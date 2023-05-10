/**************************************************************************************************************************************************************
   Class was created as a Edit controller for DealRegistration Edit Page. 
   
   #############################################################################################################################################################
   Created By                           Date                  Description
   Rahul Gaira(rg250274)                18th August 2016       Version 1 , which consist of the PopulatePartnerField  for deal Registration
   Monika                               19-12-2022            EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  

****************************************************************************************************************************************************************/

public with sharing class DealRegistrationEditController {
    
  public Deal_Registration__c dealreg{get;set;}
  public String channelPartnerKeyContactText{get;set;} 
  public String channelPartnerAccount{get;set;} 
  //public RecordType rt{get;set;}
    
    
  //Get the schema from the Sobject
 // Map<ID,Schema.RecordTypeInfo> rt_Map = Deal_Registration__c.sObjectType.getDescribe().getRecordTypeInfosById();

  /*
   @constructor Name: populatePartnerField
   @purpose: Constructor was used for the auto population of the partner fields 
   @author : Rahul Gaira(rg250274)                  

  */
  public DealRegistrationEditController(ApexPages.StandardController controller) {
     
    //get the recordType Name
    //Id recordTypeID = Id.valueOf(getRecordTypeId());
   
    //rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Deal_Registration__c' AND Id =:recordTypeID LIMIT 1];
    //get the userDetail for populating the necessaary fields
    List<User> userlist= getuserDetail();
    this.dealreg = (Deal_Registration__c)controller.getRecord();
    
     IF(userList != null && !UserList.isEmpty() ){
      channelPartnerKeyContactText  = UserList[0].Contact.Name;//UserList[0].Contact.name;
      channelPartnerAccount = UserList[0].Contact.Account.Name;    
        IF(userList[0].ContactId != null)
          dealreg.partner_Contact__c = userList[0].ContactId;
        IF(userList[0].Contact.AccountId != null)
          dealreg.partner_Company_Name__c = userList[0].Contact.AccountId;
        
    }
  }

   /*
   @constructor Name: getRecordTypeId
   @purpose: method was used for getting the recordType name 
   @author : Rahul Gaira(rg250274)                  

  
  public String getRecordTypeId(){
    return ApexPages.currentPage().getParameters().get('RecordType');
  }  */ 

   /*
   @constructor Name: getuserDetail
   @purpose: method was used for getting the user detail. 
   @author : Rahul Gaira(rg250274)                  

  */
  public List<User> getuserDetail(){
    return [SELECT Id , Name , ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name FROM User WHERE id =: UserInfo.getUserId()];
  }
  
  public PageReference submitForApproval(){
      return null;
  }
  

}