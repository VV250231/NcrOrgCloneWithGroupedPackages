public with sharing class PRM_WarrLaborRequestCon {
    @AuraEnabled
    public static Equipment_Declaration__c getEquipmentDetail(Id equipmentId) {
    	return [ SELECT Id, Class__c, Owner.Name, Name, Service_Date__c, Partner_Account__r.Name, Partner_Account__r.Id, Partner_Account__r.Partner_Type__c, 
    	         Partner_Account__r.Master_Customer_Number__c, Partner_Account__r.BillingStreet, Partner_Account__r.BillingCity,
    	         Partner_Account__r.BillingState, Partner_Account__r.BillingPostalCode, Partner_Account__r.BillingCountry, Partner_Account__r.Region__c,
    	         Partner_Account__r.Account_Region__c, Partner_Account__r.Account_Country_Code__c, Active_Unit__c, Customer_Name__c, 
    	         Installation_Date_of_New_Unit__c 
		    	  FROM Equipment_Declaration__c where id =: equipmentId LIMIT 1
		       ];
    }
    
    @AuraEnabled
    public static void submitWarrLabReq(Equipment_Declaration__c equipment, String problemDescription) {
    	Warranty_Labor_Request__c wlr = new Warranty_Labor_Request__c();
    	
    	// getting email and phone of logged in user as this is not available as UserInfo
        User u=[Select Phone, Email from User where id = :UserInfo.getUserId()];
        wlr.Account_Name__c=equipment.Partner_Account__r.Name;
        wlr.Equipment__c = equipment.Id;
        wlr.Master_Customer_Number__c= equipment.Partner_Account__r.Master_Customer_Number__c;
        wlr.Street__c=equipment.Partner_Account__r.BillingStreet;
        wlr.City__c=equipment.Partner_Account__r.BillingCity;
        wlr.State__c=equipment.Partner_Account__r.BillingState;
        wlr.Postal__c=equipment.Partner_Account__r.BillingPostalCode;
        wlr.Country__c = equipment.Partner_Account__r.BillingCountry;
        wlr.Theater__c= equipment.Partner_Account__r.Region__c;
        wlr.Account_Region__c= equipment.Partner_Account__r.Account_Region__c;
        wlr.ISO_Country_Code__c=equipment.Partner_Account__r.Account_Country_Code__c;
        wlr.First_Name__c=UserInfo.getFirstName();
        wlr.Last_Name__c=UserInfo.getLastName();
        wlr.Contact_Email__c=u.Email;
        wlr.Contact_Phone__c=u.Phone;
        wlr.Serial_Number__c=equipment.Name;
        wlr.Product_Class__c=equipment.Class__c;
        wlr.Service_Date__c=equipment.Service_Date__c;
        wlr.Service_Problem_Repair_Description__c=problemDescription;
        wlr.Date_Submitted__c=System.today();
        wlr.Partner_Type__c=equipment.Partner_Account__r.Partner_Type__c;
        for(PRM_Services__c prm : [Select id, Participation_Number__c from PRM_Services__c where Account_Name__c =:equipment.Partner_Account__r.Id])
        {
            if( prm.Participation_Number__c != null && prm.Participation_Number__c != '')
            {
                wlr.Participation_Number__c = prm.Participation_Number__c ;
                break;
            }
         }          
        insert wlr;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();           
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(wlr.id);    
        // Submit the approval request for the account
        if(!Test.isRunningTest())
        Approval.ProcessResult result = Approval.process(req1);

    }
}