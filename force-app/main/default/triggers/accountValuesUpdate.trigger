/*
######################################################################################################################################################################
# Project Name..........: SpringCM 
# File............................: triggerPartnerNonRorUpdate .trigger
# Version.....................: 25.0 
# Created by................: Gayatri Sharma                                                                       
# Created Date...........: 30-07-2012
# Last Modified By..........: Darshan Singh Farswan
# Last Modified Date........: 27-08-2012                                                                              
# Description...............: Account Records needed to be updated if Partner Non Ror Object Records with matching Master Customer Number and Country code is updated.
######################################################################################################################################################################
*/
trigger accountValuesUpdate on Partner_NonROR__c (after insert, after update) {
    List <String> cmb=new List<String>();
    Map<String,Partner_NonROR__c> partnerMap = new Map <String,Partner_NonROR__c>();
    List<Account> accountsToUpdate = new List<Account>();
    for(Integer i=0; i < Trigger.new.size(); i++){
        if(Trigger.new[i].ERP_Country_Code__c != null && Trigger.new[i].ERP_Country_Code__c != '' && Trigger.new[i].Master_Customer_Number__c != null && Trigger.new[i].Master_Customer_Number__c != ''){
            if(Trigger.isUpdate){
                partnerMap.put(Trigger.New[i].Country_with_Master_customer_Number__c, Trigger.New[i]);
            }
            else{
                partnerMap.put(Trigger.New[i].Country_with_Master_customer_Number__c, Trigger.New[i]);    
            }
        }
    }
    List<Account> accounts= new List<Account>([Select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ISO_Country_Code__c , Country_with_Master_customer_Number__c, Website, Phone, Comments__c FROM Account where Country_with_Master_customer_Number__c in :partnerMap.keySet() and Master_Customer_Number__c != null and Account_Country_Code__c != null]);
    //Removed doing_business_as__c from List EBA_SF-688

    for (Account acc : accounts){
        Boolean updateflag = false;
        if(partnerMap.containsKey(acc.Country_with_Master_customer_Number__c)){
            if(acc.BillingStreet == null){
                acc.BillingStreet = (partnerMap.get(acc.Country_with_Master_customer_Number__c).Address1__c + ' ' + partnerMap.get(acc.Country_with_Master_customer_Number__c).Address2__c);
                if(acc.BillingStreet != null){
                    updateflag = true;  
                }
            }
            if(acc.BillingCity == null){
                acc.BillingCity = partnerMap.get(acc.Country_with_Master_customer_Number__c).City__c;
                if(acc.BillingCity != null){
                    updateflag = true;  
                }
            }
            if(acc.BillingState == null){
                acc.BillingState = partnerMap.get(acc.Country_with_Master_customer_Number__c).State__c;
                if(acc.BillingState != null){
                    updateflag = true;  
                }
            }
            if(acc.BillingCountry == null){
                acc.BillingCountry = partnerMap.get(acc.Country_with_Master_customer_Number__c).Country_Code__c;
                if(acc.BillingCountry != null){
                    updateflag = true;  
                }
            }
            if(acc.BillingPostalCode == null){
                acc.BillingPostalCode = partnerMap.get(acc.Country_with_Master_customer_Number__c).Zip_Code__c;
                if(acc.BillingPostalCode != null){
                    updateflag = true;  
                }
            }
            if(acc.ISO_Country_Code__c == null){
                acc.ISO_Country_Code__c = acc.BillingCountry;
                if(acc.ISO_Country_Code__c != null){
                    updateflag = true;  
                }
            }
            if(acc.Website == null){
                acc.Website = partnerMap.get(acc.Country_with_Master_customer_Number__c).Website_Address__c;
                if(acc.Website != null){
                    updateflag = true;  
                }
            }
            if(acc.Phone == null){
                acc.Phone = partnerMap.get(acc.Country_with_Master_customer_Number__c).Telephone__c; 
                if(acc.Phone != null){
                    updateflag = true;  
                }
            }
           /* if(acc.Doing_Business_As__c == null){
                acc.Doing_Business_As__c = partnerMap.get(acc.Country_with_Master_customer_Number__c).Doing_Business_As__c; 
                if(acc.Doing_Business_As__c != null){
                    updateflag = true;  
                }
            }*/
            //Commenting due to EBA_SF-688
            if(acc.Comments__c == null){
                acc.Comments__c = partnerMap.get(acc.Country_with_Master_customer_Number__c).Application_Referral__c; 
                if(acc.Comments__c != null){
                    updateflag = true;  
                }
            }
            if(updateflag == true){
                accountsToUpdate.add(acc);
            }          
        }
    }
    update accountsToUpdate;
}