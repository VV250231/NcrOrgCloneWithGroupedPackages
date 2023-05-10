public class CreateSalesSurveyContactsApexController {
    @AuraEnabled
    public static void saveContacts(String AccId, String SalesSurveyid,List<Contact> FinalContactList){
        List<Contact> NewContactOnAcctInsert = New List<Contact>();
        List<Contact> ListToInsertInSS = New List<Contact>();
        if(FinalContactList.size()>0){
            for(Contact obj1 : FinalContactList){
                if(AccId != null && string.isblank(obj1.Id)){
                    system.debug('---------'+obj1);
                    Contact Con = new Contact();
                    Con.AccountId = AccId;
                    Con.FirstName = obj1.FirstName;
                    con.Sales_Survey_Id__c	= SalesSurveyid;
                    Con.LastName = obj1.LastName;
                    Con.Phone = obj1.Phone;
                    NewContactOnAcctInsert.add(Con);
                   
                }
                if(string.isNotblank(obj1.Id)){
                   ListToInsertInSS.add(obj1) ;
                }
               
            }
            
            
            if(NewContactOnAcctInsert.size() > 0){
              system.debug('---------'+NewContactOnAcctInsert);

              insert NewContactOnAcctInsert;
              ListToInsertInSS.addAll(NewContactOnAcctInsert);
             
            }
              saveSalesSurvey(ListToInsertInSS,SalesSurveyid);
        }
        
       
    }
    @auraEnabled
    Public static void saveSalesSurvey (List<Contact> ContactIdsNeedtoSaveInSS,String SSid){
          system.debug('---------'+ContactIdsNeedtoSaveInSS);
        List<Sales_Survey_Contact__c> SSContactListInsert = New List <Sales_Survey_Contact__c>();
    	if(ContactIdsNeedtoSaveInSS.size()>0){
          for(Contact obj1 : ContactIdsNeedtoSaveInSS){ 
            if(SSid != null){
                Sales_Survey_Contact__c ssc = new Sales_Survey_Contact__c();
                ssc.Sales_Survey__c  = SSid;
                ssc.First_Name__c = obj1.FirstName;
                ssc.Last_Name__c = obj1.LastName;
                ssc.Contact__c = obj1.id;
                SSContactListInsert.add(ssc);
             }
          }
        }
        if(SSContactListInsert.size() > 0){
            insert SSContactListInsert;
        }
        
    }
    @auraEnabled
    public static List<contact> getAllContact(String AccId){
        return [select Id,FirstName,LastName,Phone,Name from contact where AccountId =:AccId ORDER BY LastName];
    }
    @auraEnabled
    public static List<Sales_Survey_Contact__c> getAllSalesSurveyContact(String SalesSurveyid){
        return [select Id,First_Name__c,Last_Name__c from Sales_Survey_Contact__c where Sales_Survey__c =:SalesSurveyid];
    }
}