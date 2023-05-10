public class WarrLaborReimbursementRequest{
    public ApexPages.standardController controller {get; set;}
    public Equipment_Declaration__c equipmentDeclaration { get; set; }
    public String mailBody {get; set;}
    public boolean mailcontent{get; set;}
    public boolean errorcontent{get; set;}
    public Date serviceDate{get; set;}
    String idate = '';
    String sdate = '';
    String CustomerName = '';
    public WarrLaborReimbursementRequest(ApexPages.StandardController stdController) {
        controller = stdController;
        equipmentDeclaration = [Select Id, Class__c, Owner.Name, Name, Service_Date__c, Partner_Account__r.Name, Partner_Account__r.Id, Partner_Account__r.Partner_Type__c, Partner_Account__r.Master_Customer_Number__c, Partner_Account__r.BillingStreet, Partner_Account__r.BillingCity, Partner_Account__r.BillingState, Partner_Account__r.BillingPostalCode, Partner_Account__r.BillingCountry, Partner_Account__r.Region__c, Partner_Account__r.Account_Region__c, Partner_Account__r.Account_Country_Code__c, Active_Unit__c, Customer_Name__c, Installation_Date_of_New_Unit__c from Equipment_Declaration__c where id = :stdController.getid() limit 1].get(0);
        if(equipmentDeclaration.Active_Unit__c == false){
            errorcontent = true;
            mailcontent = false;
        }
        else{
            mailcontent = true;
            errorcontent = false;
        }
    }
    //public void sendMail(){ 
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{'pa230005@ncr.com'};
        mail.setToAddresses(toAddress);
        mail.setSubject('Warranty Reimbursement Request');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        if(equipmentDeclaration.Installation_Date_of_New_Unit__c != null){
            idate = String.valueOf(equipmentDeclaration.Installation_Date_of_New_Unit__c);
        }
        if(equipmentDeclaration.Service_Date__c != null){
            sdate = String.valueOf(equipmentDeclaration.Service_Date__c);
        }
        if(equipmentDeclaration.Customer_Name__c!= null){
            customerName = equipmentDeclaration.Customer_Name__c;
        }
        mail.setHTMLBody('Serial Number : '+equipmentDeclaration.Name+'<br/>Product ID : '+equipmentDeclaration.Class__c+'<br/>Customer Name : '+CustomerName+'<br/>Installation Date : '+idate+'<br/>Account Name : '+equipmentDeclaration.Partner_Account__r.Name+'<br/>SalesForce ID : '+equipmentDeclaration.Id+'<br/>Service Date : '+sdate+'<br/>Service Problem and Repair Description:<table><tr><td>&nbsp;</td><td><pre style="font-family:Times New Roman;font-size:12pt">'+mailBody+'</pre></td></tr></table>Thank You,<br/>NCR SalesCentral Administration');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        PageReference pageref = new PageReference('/'+equipmentDeclaration .id);
        createWarrLabourReimbursementObj(equipmentDeclaration);
        return pageref; */
    // } commented empty block statement
    public PageReference cancel(){
        PageReference pageref = new PageReference('/'+equipmentDeclaration .id);
        return pageref;
    }
    public PageReference createWarrLabourReimbursementObj(){
        Equipment_Declaration__c ed = equipmentDeclaration ;
        Warranty_Labor_Request__c wlr = new Warranty_Labor_Request__c();
        // getting email and phone of logged in user as this is not available as UserInfo
        User u=[Select Phone, Email from User where id = :UserInfo.getUserId()];
        
        wlr.Account_Name__c=ed.Partner_Account__r.Name;
        wlr.Equipment__c = ed.Id;
        wlr.Master_Customer_Number__c= ed.Partner_Account__r.Master_Customer_Number__c;
        wlr.Street__c=ed.Partner_Account__r.BillingStreet;
        wlr.City__c=ed.Partner_Account__r.BillingCity;
        wlr.State__c=ed.Partner_Account__r.BillingState;
        wlr.Postal__c=ed.Partner_Account__r.BillingPostalCode;
        wlr.Country__c = ed.Partner_Account__r.BillingCountry;
        wlr.Theater__c= ed.Partner_Account__r.Region__c;
        wlr.Account_Region__c= ed.Partner_Account__r.Account_Region__c;
        wlr.ISO_Country_Code__c=ed.Partner_Account__r.Account_Country_Code__c;
        wlr.First_Name__c=UserInfo.getFirstName();
        wlr.Last_Name__c=UserInfo.getLastName();
        wlr.Contact_Email__c=u.Email;
        wlr.Contact_Phone__c=u.Phone;
        wlr.Serial_Number__c=ed.Name;
        wlr.Product_Class__c=ed.Class__c;
        wlr.Service_Date__c=ed.Service_Date__c;
        wlr.Service_Problem_Repair_Description__c=mailBody;
        wlr.Date_Submitted__c=System.today();
        wlr.Partner_Type__c=ed.Partner_Account__r.Partner_Type__c;
        for(PRM_Services__c prm : [Select id, Participation_Number__c from PRM_Services__c where Account_Name__c =:ed.Partner_Account__r.Id])
        {
            if( prm.Participation_Number__c != null && prm.Participation_Number__c != '')
            {
                wlr.Participation_Number__c = prm.Participation_Number__c ;
                break;
            }
         }          
        insert wlr;
        
        
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
            
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(wlr.id);
        
        // Submit the approval request for the account
        if(!Test.isRunningTest())
        Approval.ProcessResult result = Approval.process(req1);
        
        PageReference pageref = new PageReference('/'+equipmentDeclaration.id);
        return pageref;
    }
}