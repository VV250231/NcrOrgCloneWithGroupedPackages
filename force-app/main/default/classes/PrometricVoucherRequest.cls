public class PrometricVoucherRequest{
    public ApexPages.standardController controller {get; set;}
    public Engineers__c engineers{ get; set; }
    public boolean mailcontent{get; set;}
    public boolean errorcontent{get; set;}
    public String mailBody {get; set;}
    public PrometricVoucherRequest(ApexPages.StandardController stdController) {
        controller = stdController;
        engineers = [Select Id, Owner.Name, Partner_Account__r.Name, First_Name__c, Last_Name__c, Active_Engineer__c from Engineers__c where id = :stdController.getid() limit 1].get(0);
        //Partner_Account__r.Service_Partner__c -Removed From select query due to EBA_SF-688
        if(engineers.Active_Engineer__c == false){
            errorcontent = true;
            mailcontent = false;
        }
        else{
            mailcontent = true;
            errorcontent = false;
        }
    }
    public PageReference sendMail(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{'pa230005@ncr.com'};
        mail.setToAddresses(toAddress);
        mail.setSubject('Prometric Voucher Request');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHTMLBody('Engineer Name : '+engineers.First_Name__c+' '+engineers.Last_Name__c+'<br/> Account Name : '+ engineers.Partner_Account__r.Name +'<br/>SalesForce ID : '+engineers.id+'<br/>Additional Information:<table><tr><td>&nbsp;</td><td><pre style="font-family:Times New Roman;font-size:12pt">'+mailBody+'</pre></td></tr></table>Thank You,<br/>NCR SalesCentral Administration');
        //Service Partner ID : '+engineers.Partner_Account__r.Service_Partner__c+'<br/> removed due to EBA_SF-688
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        PageReference pageref = new PageReference('/'+engineers.id);
        return pageref;
    }
    public PageReference cancel(){
        PageReference pageref = new PageReference('/'+engineers.id);
        return pageref;
    }
}