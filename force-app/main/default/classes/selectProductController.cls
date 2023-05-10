public without sharing class selectProductController{

  /* @AuraEnabled
  public static String getProfileName() {
    string  usrId = userinfo.getProfileId();
    system.debug('====usrId '+usrId );
    string profileName;
    list<profile>pList = [select id,name from profile where id=:usrId];
    for(profile p : pList){
      profileName = p.name;
    }
     return profileName;
     
  }
 
 @AuraEnabled 
  public static list<string> getQuotelist(){
   List<String> options = new List<String>();
   list<zqu__Quote__c> qList = [select id,zqu__SubscriptionType__c,Track_Approval_Steps__c from zqu__Quote__c where id =:'a2b4F0000008ZqSQAU'];
   for (zqu__Quote__c f: qList) {
         options.add(f.Track_Approval_Steps__c );
    }       
   return options;
  }
  */
  
 @AuraEnabled 
 public static wrapperClasstolight   methodToReturnWrapper(String Quoteid){
  wrapperClasstolight  WC = new wrapperClasstolight();
  string  usrId = userinfo.getProfileId();
  
  string profileName;
  Profile pList = [select id,name from profile where id=:usrId][0];
  
  zqu__Quote__c qList = [select id,zqu__SubscriptionType__c,zqu__Status__c,Track_Approval_Steps__c from zqu__Quote__c where id =:Quoteid];
  WC.QuoteObj = qList;
  WC.profilename = pList.name; 
  system.debug('>>????'+wc); 
  return wc;

 }
 
 public class wrapperClasstolight{
   @AuraEnabled  
   public string profilename;
   @AuraEnabled 
   public zqu__Quote__c QuoteObj;
 }


}