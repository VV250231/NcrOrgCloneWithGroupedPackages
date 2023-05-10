public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    
    Public Static sObject getCreatedRecord(String RecordId ,String ObjectName ){
        
        List<sObject> sObjectsList = new List<sObject>();
        
        String sQuery =  'select id, Name from ' +ObjectName + ' where id =: RecordId';
        return Database.query(String.escapeSingleQuotes(sQuery));
    }
    
    
    @AuraEnabled
    public Static sObject checkIfContactExist(String ContactEmial,String ObjectName,String ConPhone,String BusinessFunction,String FirstName,String LastName,String InvoiceMcn){
        List<Account> InvoiceRelatedAccount = new List<Account>();
        Contact ConObjtoUpdate = new Contact();
        List<Contact> conObj = new List<Contact>();
        conObj = [Select id, Name ,Business_Function__c from Contact where Email =: ContactEmial limit 1];
        //contact found
        if(conObj.size()>0){                           
            ConObjtoUpdate.Id=conObj[0].Id;
            ConObjToUpdate.Phone=ConPhone;
            ConObjToUpdate.Business_Function__c=BusinessFunction;
            Update ConObjtoUpdate;
        }  else{
            if(String.isNotBlank(InvoiceMcn)){
                InvoiceRelatedAccount= [Select id,Name, Master_Customer_Number__c from Account where Master_Customer_Number__c  =: InvoiceMcn or Master_Customer_Number__c = 'APOC1111'];
                //system.debug('<><><><><><'+InvoiceRelatedAccount);
                try{
                    if(InvoiceRelatedAccount != null && InvoiceRelatedAccount.size()>0){
                        //String sQuery =  'select id, Name ,Business_Function__c from ' +ObjectName + ' where Email =: ContactEmial limit 1';
                        String NcrAccount ='';
                        String CustAccount = '';
                        ConObjToUpdate.FirstName=FirstName;
                        ConObjToUpdate.LastName=LastName;
                        ConObjToUpdate.Phone=ConPhone;
                        ConObjToUpdate.Business_Function__c=BusinessFunction;
                        ConObjToUpdate.Email = ContactEmial;
                        //both ncr and con account exist
                        if(InvoiceRelatedAccount != null && InvoiceRelatedAccount.size() == 2){
                            if(InvoiceRelatedAccount[0].Master_Customer_Number__c=='APOC1111'){
                                ncrAccount=InvoiceRelatedAccount[0].id;
                                CustAccount=InvoiceRelatedAccount[1].id;
                            }else{
                                ncrAccount=InvoiceRelatedAccount[1].id;
                                CustAccount=InvoiceRelatedAccount[0].id; 
                            }
                        }                             
                        else{
                            CustAccount=InvoiceRelatedAccount[0].id;  
                        }
                        //checking email to see ncraccount need to be updated or customer acc
                        if(ContactEmial.toUpperCase().contains('NCR.COM') && !String.isBlank(NcrAccount)){
                            String qlook=ContactEmial.split('@')[0];
                            if(qlook.length()==8){
                                ConObjToUpdate.Quicklook_ID__c= qlook; 
                            }
                            ConObjtoUpdate.AccountId=NcrAccount;
                        }else{
                            ConObjtoUpdate.AccountId=CustAccount; 
                        }                         
                        
                        
                        
                    }else{
                        //associate orphan contact
                        ConObjToUpdate.FirstName=FirstName;
                        ConObjToUpdate.LastName=LastName;
                        ConObjToUpdate.Phone=ConPhone;
                        ConObjToUpdate.Business_Function__c=BusinessFunction;
                        ConObjToUpdate.Email = ContactEmial;
                    }
                    
                }
                catch (Exception e) {
                    
                    throw new AuraHandledException('Invoice Account Does Not exist: ' + e.getMessage());  
                }
                
            }
            else{
                ConObjToUpdate.FirstName=FirstName;
                ConObjToUpdate.LastName=LastName;
                ConObjToUpdate.Phone=ConPhone;
                ConObjToUpdate.Business_Function__c=BusinessFunction;
                ConObjToUpdate.Email = ContactEmial; 
            }
            
            insert ConObjToUpdate;
            
            
        }
        return ConObjToUpdate;
        
    }
    
    
    
}