public class PRM_EquipmentController 
{
	 @AuraEnabled
    public static Equipment_Declaration__c getEngineerDetail(String recId)
    {	
        List<Equipment_Declaration__c> lstEq =  [Select Id, Name, Partner_Account__r.Name, Account__r.Name,Customer_Name__c, FDIC__c, NCUA__c, SWIFT_CODE__c, Active_Unit__c,
                                               Class__c, Class_Type__c, Features__c, Installation_Address1__c, Installation_Address2__c, Installation_City__c, Installation_State_Province__c,
                                               Installation_Postal_Code__c, Country_Code__c, Installation_Date_of_New_Unit__c, Service_Assumption_Date__c, Previous_Service_Provider__c, 
                                               Previous_Service_Provider_If_Other__c, Owner.Name, Service_Date__c,
                                               Partner_Account__r.Id, Partner_Account__r.Partner_Type__c, 
                                               Partner_Account__r.Master_Customer_Number__c, Partner_Account__r.BillingStreet, Partner_Account__r.BillingCity,
                                               Partner_Account__r.BillingState, Partner_Account__r.BillingPostalCode, Partner_Account__r.BillingCountry, Partner_Account__r.Region__c,
                                               Partner_Account__r.Account_Region__c, Partner_Account__r.Account_Country_Code__c 
                                		  from Equipment_Declaration__c where Id =: recId ];
   		
        if(!lstEq.isEmpty())
        	return lstEq[0];
        return null;
    }
    
    @AuraEnabled
    public static List<Warranty_Labor_Request__c> getWarrantyRequests(Id recId)
    {
        List<Warranty_Labor_Request__c> lstWR = [Select Id, Name, Account_Name__c, Service_Date__c, End_Customer_Name__c, Status__c
                                                 from Warranty_Labor_Request__c where Equipment__c =: recId ];
        
        return lstWR;
    }
    
    @AuraEnabled
    public static String saveEquipment(Equipment_Declaration__c objEq)
    {
        objEq.Partner_Account__c = [Select Id, AccountId from User where Id =: UserInfo.getUserId()].AccountId ;
        
        String partnerId = objEq.Partner_Account__c;
        partnerId = partnerId.length() > 15 ? partnerId.substring(0, 15) : partnerId ;
        
        String keyWhere = objEq.Name + partnerId;
        List<Equipment_Declaration__c> lstED = [Select Id From Equipment_Declaration__c Where NameAndAccount__c =: keyWhere];
        
        if(!lstED.isEmpty())
        {
            return 'Duplicate Serial Number';
        }
        objEq.Class__c = objEq.Class__c == '-- None --' ? null : objEq.Class__c;
        objEq.Class_Type__c = objEq.Class_Type__c == '-- None --' ? null : objEq.Class_Type__c;
        objEq.Features__c = objEq.Features__c == '-- None --' ? null : objEq.Features__c;
        
        objEq.Country_Code__c = objEq.Country_Code__c == '-- None --' ? null : objEq.Country_Code__c;
        objEq.Previous_Service_Provider__c = objEq.Previous_Service_Provider__c == '-- None --' ? null : objEq.Previous_Service_Provider__c;
        System.debug('--------------objEq.Id---------------'+objEq.Id);
        System.debug('--------------objEq---------------'+objEq);
        insert objEq;
        
        return objEq.Id;
    }	
    
    @AuraEnabled
    public static String editEquipment(Equipment_Declaration__c objEq)
    {
        String partnerId = objEq.Partner_Account__c;
        partnerId = partnerId.length() > 15 ? partnerId.substring(0, 15) : partnerId ;
        
        String keyWhere = objEq.Name + partnerId;
        List<Equipment_Declaration__c> lstED = [Select Id From Equipment_Declaration__c Where NameAndAccount__c =: keyWhere and Id !=: objEq.Id];
        
        if(!lstED.isEmpty())
        {
            return 'Duplicate Serial Number';
        }
        objEq.Class__c = objEq.Class__c == '-- None --' ? null : objEq.Class__c;
        objEq.Class_Type__c = objEq.Class_Type__c == '-- None --' ? null : objEq.Class_Type__c;
        objEq.Features__c = objEq.Features__c == '-- None --' ? null : objEq.Features__c;
        
        objEq.Country_Code__c = objEq.Country_Code__c == '-- None --' ? null : objEq.Country_Code__c;
        objEq.Previous_Service_Provider__c = objEq.Previous_Service_Provider__c == '-- None --' ? null : objEq.Previous_Service_Provider__c;
        update objEq;
        return objEq.Id;
    }
    @AuraEnabled
    public static String submitWarrantyLaborRequest(Equipment_Declaration__c equipment, String problemDescription) 
    {
        try
        {
            Warranty_Labor_Request__c wlr = new Warranty_Labor_Request__c();
            
            // getting email and phone of logged in user as this is not available as UserInfo
            User u=[Select Phone, Email from User where id = :UserInfo.getUserId()];
            wlr.Account_Name__c = equipment.Partner_Account__r.Name;
            wlr.Equipment__c = equipment.Id;
            wlr.Master_Customer_Number__c = equipment.Partner_Account__r.Master_Customer_Number__c;
            wlr.Street__c = equipment.Partner_Account__r.BillingStreet;
            wlr.City__c = equipment.Partner_Account__r.BillingCity;
            wlr.State__c = equipment.Partner_Account__r.BillingState;
            wlr.Postal__c =equipment.Partner_Account__r.BillingPostalCode;
            wlr.Country__c = equipment.Partner_Account__r.BillingCountry;
            wlr.Theater__c= equipment.Partner_Account__r.Region__c;
            wlr.Account_Region__c = equipment.Partner_Account__r.Account_Region__c;
            wlr.ISO_Country_Code__c=equipment.Partner_Account__r.Account_Country_Code__c;
            wlr.First_Name__c = UserInfo.getFirstName();
            wlr.Last_Name__c = UserInfo.getLastName();
            wlr.Contact_Email__c = u.Email;
            wlr.Contact_Phone__c = u.Phone;
            wlr.Serial_Number__c = equipment.Name;
            wlr.Product_Class__c = equipment.Class__c;
            wlr.Service_Date__c = equipment.Service_Date__c;
            wlr.Service_Problem_Repair_Description__c = problemDescription;
            wlr.Date_Submitted__c = System.today();
            wlr.Partner_Type__c = equipment.Partner_Account__r.Partner_Type__c;
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
        catch(Exception e)
        {
            return 'Failure';
        }
        return 'Success';
    }
    
    @AuraEnabled 
    public static Warranty_Labor_Request__c getWarrantyLaborRequest(String recId)
    {
        List<Warranty_Labor_Request__c> lstWLR = [Select Id, Name, End_Customer_Name__c, Class__c, Corporate_Address__c, Product_Class__c, Serial_Number__c, 
                                                 	Service_Problem_Repair_Description__c, Date_Submitted__c, Installation_Date__c, Service_Date__c, Status__c, Approval_Rejection_Date__c, City__c,Contact_Email__c, Contact_Phone__c, Country__c,First_Name__c, Last_Name__c,
													Participation_number__c, Partner_Type__c, Postal__c, Reimbursement_Amount__c, State__c, Street__c,
                                                 	Approval_Rejection_Comments__c, Account_Name__c, Master_Customer_Number__c, Theater__c, Account_Region__c, 
                                                 	ISO_Country_Code__c
                                                 From Warranty_Labor_Request__c where Id=:recId ];
        if(!lstWLR.isEmpty())
            return lstWLR[0];
       
        return null;
    }
    
    @AuraEnabled 
    public static DependentPicklistCollectionWrapper getEquipmentDetailForEdit(String recId)
    {
        List<Equipment_Declaration__c> lstEq =  [Select Id, Name, Partner_Account__r.Name, Customer_Name__c, FDIC__c, NCUA__c, SWIFT_CODE__c, Active_Unit__c,
                                               Class__c, Class_Type__c, Features__c, Installation_Address1__c, Installation_Address2__c, Installation_City__c, Installation_State_Province__c,
                                               Installation_Postal_Code__c, Country_Code__c, Installation_Date_of_New_Unit__c, Service_Assumption_Date__c, Previous_Service_Provider__c, 
                                               Previous_Service_Provider_If_Other__c, Owner.Name, Service_Date__c,
                                               Partner_Account__r.Id, Partner_Account__r.Partner_Type__c, 
                                               Partner_Account__r.Master_Customer_Number__c, Partner_Account__r.BillingStreet, Partner_Account__r.BillingCity,
                                               Partner_Account__r.BillingState, Partner_Account__r.BillingPostalCode, Partner_Account__r.BillingCountry, Partner_Account__r.Region__c,
                                               Partner_Account__r.Account_Region__c, Partner_Account__r.Account_Country_Code__c 
                                		  from Equipment_Declaration__c where Id =: recId ];
   	
        DependentPicklistCollectionWrapper objWrapper = PRM_EquipmentController.getDependentMap('Class__c', 'Class_Type__c', 'Features__c');
        objWrapper.objEq = lstEq.isEmpty() ? null : lstEq[0];
        
    	return objWrapper;  
    }
    
     @AuraEnabled 
    public static DependentPicklistCollectionWrapper getEquipmentDetailForClone(String recId)
    {
        List<Equipment_Declaration__c> lstEq =  [Select Id, Name, Partner_Account__r.Name, Customer_Name__c, FDIC__c, NCUA__c, SWIFT_CODE__c, Active_Unit__c,
                                               Class__c, Class_Type__c, Features__c, Installation_Address1__c, Installation_Address2__c, Installation_City__c, Installation_State_Province__c,
                                               Installation_Postal_Code__c, Country_Code__c, Installation_Date_of_New_Unit__c, Service_Assumption_Date__c, Previous_Service_Provider__c, 
                                               Previous_Service_Provider_If_Other__c, Owner.Name, Service_Date__c,
                                               Partner_Account__r.Id, Partner_Account__r.Partner_Type__c, 
                                               Partner_Account__r.Master_Customer_Number__c, Partner_Account__r.BillingStreet, Partner_Account__r.BillingCity,
                                               Partner_Account__r.BillingState, Partner_Account__r.BillingPostalCode, Partner_Account__r.BillingCountry, Partner_Account__r.Region__c,
                                               Partner_Account__r.Account_Region__c, Partner_Account__r.Account_Country_Code__c 
                                		  from Equipment_Declaration__c where Id =: recId ];
   	
        DependentPicklistCollectionWrapper objWrapper = PRM_EquipmentController.getDependentMap('Class__c', 'Class_Type__c', 'Features__c');
        objWrapper.objEq = lstEq.isEmpty() ? null : lstEq[0].clone(false, true);
        
    	return objWrapper;  
    }

    
    @AuraEnabled 
    public static DependentPicklistCollectionWrapper getDependentMap(String contrfieldApiName, String depfieldApiName1, String depfieldApiName2 ) 
    {
        
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField1 = depfieldApiName1.toLowerCase();        
        String dependentField2 = depfieldApiName2.toLowerCase();
        
        DependentPicklistCollectionWrapper  objWrapper = new DependentPicklistCollectionWrapper();       
        objWrapper.mapClassTolstClassType = new Map<String,List<String>>();
        objWrapper.mapClassTolstFeature = new Map<String,List<String>>();
        objWrapper.lstPreviousServiceProvider =  new List<String>();    
        objWrapper.lstCountryCode = new List<String>();    
        
        Schema.sObjectType objType = Equipment_Declaration__c.getSObjectType();      
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        Schema.SObjectField depField1 = objFieldMap.get(dependentField1);
        Schema.SObjectField depField2 = objFieldMap.get(dependentField2);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> classes = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> classTypes = wrapPicklistEntries(depField1.getDescribe().getPicklistValues());
        
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : classes) 
        {
            String label = ple.getLabel();
            objWrapper.mapClassTolstClassType.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : classTypes) 
        {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                     objWrapper.mapClassTolstClassType.get(controllingValues.get(i)).add(label);
                }
            }
        }
        
        List<PicklistEntryWrapper> features = wrapPicklistEntries(depField2.getDescribe().getPicklistValues());
        
        List<String> controllingValues2 = new List<String>();
        
        for (Schema.PicklistEntry ple : classes) 
        {
            String label = ple.getLabel();
            objWrapper.mapClassTolstFeature.put(label, new List<String>());
            controllingValues2.add(label);
        }
        
        for (PicklistEntryWrapper plew : features) 
        {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                     objWrapper.mapClassTolstFeature.get(controllingValues2.get(i)).add(label);
                }
            }
        }
        
        //Extension_Period__c,
        Schema.DescribeFieldResult fieldResultCC = Equipment_Declaration__c.Country_Code__c.getDescribe();
        List<Schema.PicklistEntry> pleEP = fieldResultCC.getPicklistValues();
            
        for(Schema.PicklistEntry f : pleEP)
        {
            objWrapper.lstCountryCode.add(f.getValue());
        }  
        
        //Extension_Period__c,
        Schema.DescribeFieldResult fieldResultPSP = Equipment_Declaration__c.Previous_Service_Provider__c.getDescribe();
        List<Schema.PicklistEntry> plePSP = fieldResultPSP.getPicklistValues();
            
        for(Schema.PicklistEntry f : plePSP)
        {
            objWrapper.lstPreviousServiceProvider.add(f.getValue());
        }  
        
        return objWrapper;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) 
    {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) 
        {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper
    {
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
    }
    
    public class DependentPicklistCollectionWrapper
    {
        @AuraEnabled 
    	public Map<String, List<String>> mapClassTolstClassType;
        
        @AuraEnabled 
    	public Map<String, List<String>> mapClassTolstFeature;
        
        @AuraEnabled 
    	public List<String> lstCountryCode;
        
        @AuraEnabled 
    	public List<String> lstPreviousServiceProvider	;
        
        @AuraEnabled 
        public Equipment_Declaration__c objEq;
    }
}