public class ResellerTriggerHandler {
    
    public static void populateNCRLeadOwner (List<Reseller__c > resellerTriggerNew,Map<id, Reseller__c> oldResellerMap) {  
        List <String> userId=new List<String>();
        Map <String,String> userQlkidMap=new Map<String, String> ();
        for(Reseller__c r:resellerTriggerNew){ 
            // Reseller Load automation
            if(r.CountryCode__c=='US'){
                if(r.ZipCode_File__c!=null){
                    if(r.ZipCode_File__c.length()==4){ r.ZIPCode__c='0'+r.ZipCode_File__c;}
                    if(r.ZipCode_File__c.length()==3){ r.ZIPCode__c='00'+r.ZipCode_File__c;}
                    if(r.ZipCode_File__c.length()==2){ r.ZIPCode__c='000'+r.ZipCode_File__c; }
                    if(r.ZipCode_File__c.length()==1){ r.ZIPCode__c='0000'+r.ZipCode_File__c;}
                    r.Reseller_Unique__c='US'+r.ZipCode_File__c;
                }else{
                    r.addError(system.label.popLeadOwn1); //You cannot load US Country reseller without Zip Code in ZipCode_file field
                }
            }else{
                if(r.CountryCode__c!=null){
                    r.Reseller_Unique__c=r.CountryCode__c;
                }else{
                    r.addError(system.label.popLeadOwn2); //You cannot load reseller without Country Code 
                }            
            }
            if(r.CCEmail__c!=null && r.CCEmail__c.contains(',')){ String s=r.CCEmail__c; r.CCEmail__c=s.trim().replaceAll(',', ';');
            }
            // resller Load utomation finshes
            if(r.NCR_Lead_Owner_Quicklook__c==null){ r.addError(system.label.popLeadOwn3); //Please specify NCR lead owner when lead will be assigned to Reseller.
            }
           else if(Trigger.isInsert || (r.NCR_Lead_Owner_Quicklook__c!=oldResellerMap.get(r.id).NCR_Lead_Owner_Quicklook__c)){
                userId.add(r.NCR_Lead_Owner_Quicklook__c.toLowerCase());
            }
        }
        if(userId.size()>0){
            List <user> usrList=[Select id, Quicklook_id__c from user where Quicklook_id__c in :userId];
            // create Map
            for(User u:usrList){
                userQlkidMap.put(u.Quicklook_id__c.tolowercase(), u.id);
            }
            for(Reseller__c r:resellerTriggerNew){
                if(Trigger.isInsert || (r.NCR_Lead_Owner_Quicklook__c!=null && r.NCR_Lead_Owner_Quicklook__c!=oldResellerMap.get(r.id).NCR_Lead_Owner_Quicklook__c)){
                    if(userQlkidMap.get(r.NCR_Lead_Owner_Quicklook__c.toLowerCase())!=null){
                        r.NCR_Lead_Owner__c= userQlkidMap.get(r.NCR_Lead_Owner_Quicklook__c.toLowerCase());
                    }else{
                        r.addError(system.label.popLeadOwn4) ; //Use is not a Salesforce user, Please create user and reload OR assign correct user
                    }
                    
                }
            }
        }   
    }
    
    
/****************************************************************************************************************************************************
*   ComponentName :   updateResellerDataOnLead on Reseller__c (before update)
*   Description :   As Salesforce, if Reseller record data is updated and that Reseller is already assigned to a lead, 
I need to update the Reseller data on the lead to match the Reseller record data and I need to store the changes in the
Lead History data so that a lead always has the up to date Reseller data assigned and so that a Salesforce user can always
reference the Reseller data history of a lead if it's been updated.
*   Author      :   Sushant
*   Version     :   Initial
# Modification History.: 
Story No#         Date             DevName                Description
NC_AGILE-2310     05 May 2019      Sushant                Salesforce - Reseller Data Updates on Lead Record / Lead History - 64   
*****************************************************************************************************************************************************/

    public static void updateResellerDataOnLead (List<Reseller__c> resellerTriggerNew,List<Reseller__c > resellerTriggerOld) {
        Map<String, Reseller__c> resellersWithupdateddetails = new Map<String, Reseller__c>(); 
        
        //Find the list of resellers whom data is updates
        
        for (Integer i = 0; i < resellerTriggerNew.size(); i++) {
            if (   (resellerTriggerOld[i].ToEmail__c != resellerTriggerNew[i].ToEmail__c) || (resellerTriggerOld[i].Reseller__c != resellerTriggerNew[i].Reseller__c) || (resellerTriggerOld[i].CCEmail__c != resellerTriggerNew[i].CCEmail__c) || (resellerTriggerOld[i].ResellerContactPhone__c != resellerTriggerNew[i].ResellerContactPhone__c) || (resellerTriggerOld[i].ResellerContactFirstName__c != resellerTriggerNew[i].ResellerContactFirstName__c) || (resellerTriggerOld[i].ResellerContactLastName__c != resellerTriggerNew[i].ResellerContactLastName__c))
                
            {
                resellersWithupdateddetails.put(resellerTriggerOld[i].ZIPCode__c,resellerTriggerNew[i]);
            }
        }
        
        
        // Find all the list of leads assocaited with a reseller whom data is updated 
        
        List<Lead> LeadsToBeUpdateWithNewResellerData = new List<Lead>();
        
        if(resellersWithupdateddetails.size() >0)
        {
            for (Lead l : [SELECT id,PostalCode, Reseller_email_1__c, Reseller_office__c,Reseller_email_2__c, Reseller_Contact_Phone__c, Reseller_Contact__c
                           FROM Lead WHERE PostalCode in :resellersWithupdateddetails.keySet() AND isconverted=False AND Status='Partner Managed'])
            {   
                System.debug('**************Values in Lead conatining reresellersWithupdateddetails**********************'+ l);    
                
                if(l != null)
                {
                    Reseller__c associatedResellerPostalCode = resellersWithupdateddetails.get(l.PostalCode); 
                    
                    System.debug('**************Values in  associatedResellerPostalCode**********************'+ associatedResellerPostalCode);
                    
                    //Update the Reseller details on Leads associated with them
                    
                    
                    if (associatedResellerPostalCode.ToEmail__c != null) 
                    {    
                        l.Reseller_email_1__c = associatedResellerPostalCode.ToEmail__c;
                    } 
                    else 
                    {
                        if (associatedResellerPostalCode.CCEmail__c != null) 
                        {
                            l.Reseller_email_1__c = (associatedResellerPostalCode.CCEmail__c.split(';', 3)).get(0);
                        }
                    }
                    l.Reseller_office__c = associatedResellerPostalCode.Reseller__c;
                    l.Reseller_email_2__c = associatedResellerPostalCode.CCEmail__c;
                    l.Reseller_Contact_Phone__c = associatedResellerPostalCode.ResellerContactPhone__c;
                    l.Reseller_Contact__c = (associatedResellerPostalCode.ResellerContactFirstName__c == null ? ' ' : associatedResellerPostalCode.ResellerContactFirstName__c) + '   ' + (associatedResellerPostalCode.ResellerContactLastName__c == null ? ' ' : associatedResellerPostalCode.ResellerContactLastName__c);
                    
                    LeadsToBeUpdateWithNewResellerData.add(l);
                }      
            }
        }
        
        System.debug('**************size of  LeadsToBeUpdateWithNewResellerData**********************'+ LeadsToBeUpdateWithNewResellerData.size());
        System.debug('**************Values in  LeadsToBeUpdateWithNewResellerData**********************'+ LeadsToBeUpdateWithNewResellerData);
        
        
        if(LeadsToBeUpdateWithNewResellerData.size() > 0)
        {
            update LeadsToBeUpdateWithNewResellerData;  
        }  
    }
}