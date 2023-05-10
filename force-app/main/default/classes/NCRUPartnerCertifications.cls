public with sharing class NCRUPartnerCertifications 
{
    public List<Certification__c> lstCertification {get;set;}
    
    public NCRUPartnerCertifications(ApexPages.StandardController stdController)
    {
        lstCertification = [Select Valid_For__c, User_Status__c, User_Manager_Name__c, User_Login__c, User_Last_Name__c, User_ID__c, User_First_Name__c, User_Country__c, 
                                    Transcript_Status__c, Transcript_Registration_Date__c, Transcript_Completion_Date__c, Training_Type__c,
                                    Name, Master_Customer_Number__c, Inside_Curriculum__c, Division_Planning_Org__c, Days_Valid__c, Curriculum_Number__c, 
                                    Area_Supported_ID__c, Account__c, Contact__c, Contact__r.Name 
                            From Certification__c 
                            where Account__c =: stdController.getId()];
                            
        List<Account> lstAccount = [Select Id, Primary_Portal_Contact__c from Account 
                                        where Id =: stdController.getId() and Primary_Portal_Contact__r.Partner_User__c =: UserInfo.getUserId()];
                                        
        
         
        if(lstAccount.isEmpty())
        {
            lstCertification = [Select Valid_For__c, User_Status__c, User_Manager_Name__c, User_Login__c, User_Last_Name__c, User_ID__c, User_First_Name__c, User_Country__c, 
                                    Transcript_Status__c, Transcript_Registration_Date__c, Transcript_Completion_Date__c, Training_Type__c,
                                    Name, Master_Customer_Number__c, Inside_Curriculum__c, Division_Planning_Org__c, Days_Valid__c, Curriculum_Number__c, 
                                    Area_Supported_ID__c, Account__c, Contact__c, Contact__r.Name 
                            From Certification__c 
                            where Account__c =: stdController.getId() and Contact__r.Partner_User__c =: UserInfo.getUserId()];
        }                  
    }
    
    /*public NCRUPartnerCertifications()
    {
        //Do Nothing
    } commented empty block statement */
    
    @AuraEnabled
    public static  List<Certification__c> getNCRUPartnerCertifications(String accId)
    {
        List<Certification__c> lstCertification;
        lstCertification = [Select Valid_For__c, User_Status__c, User_Manager_Name__c, User_Login__c, User_Last_Name__c, User_ID__c, User_First_Name__c, User_Country__c, 
                                    Transcript_Status__c, Transcript_Registration_Date__c, Transcript_Completion_Date__c, Training_Type__c,
                                    Name, Master_Customer_Number__c, Inside_Curriculum__c, Division_Planning_Org__c, Days_Valid__c, Curriculum_Number__c, 
                                    Area_Supported_ID__c, Account__c, Contact__c, Contact__r.Name 
                            From Certification__c 
                            where Account__c =: accId];
                            
        List<Account> lstAccount = [Select Id, Primary_Portal_Contact__c from Account 
                                        where Id =: accId and Primary_Portal_Contact__r.Partner_User__c =: UserInfo.getUserId()];
                                        
        
         
        if(lstAccount.isEmpty())
        {
            lstCertification = [Select Valid_For__c, User_Status__c, User_Manager_Name__c, User_Login__c, User_Last_Name__c, User_ID__c, User_First_Name__c, User_Country__c, 
                                    Transcript_Status__c, Transcript_Registration_Date__c, Transcript_Completion_Date__c, Training_Type__c,
                                    Name, Master_Customer_Number__c, Inside_Curriculum__c, Division_Planning_Org__c, Days_Valid__c, Curriculum_Number__c, 
                                    Area_Supported_ID__c, Account__c, Contact__c, Contact__r.Name 
                            From Certification__c 
                            where Account__c =: accId and Contact__r.Partner_User__c =: UserInfo.getUserId()];
        }   
        
        return lstCertification;               
    }
    
    
}