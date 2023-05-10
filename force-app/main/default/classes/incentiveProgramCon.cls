public class incentiveProgramCon {
    public Account partAct {get;set;}
    public User cam {get;set;}
    public User currentUser {get;set;}
    public String mcn {get;set;}
    public Boolean isAgree {get;set;}
    public String prgId;
    public Date enrollExpDate {get;set;}
    public String currentUserContactId;

    
    
    public incentiveProgramCon() {
       isAgree = false;
       prgId = ApexPages.currentPage().getParameters().get('id');
       enrollExpDate = Incentive_All_Program_Config__c.getInstance('IncentiveProgram').Passed_date__c  ;

       if (UserInfo.getUserId() != null) {
           List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
           if (users.size() > 0) {
               currentUser = users [0];
               currentUserContactId = users[0].ContactId;
           }
           if (currentUser != null) {
               List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: currentUser.AccountId LIMIT 1];
               if (accounts.size() > 0) {
                   partAct = accounts[0];
                   mcn = accounts[0].Master_Customer_Number__c ;
               }

           }
       }
       
    }
    
    private List<Incentive_Program_Enrollment__c> enrolledPrograms;
    public List<Incentive_Program_Enrollment__c> getEnrolledPrograms() {
            enrolledPrograms = [SELECT Id, Name, Incentive_Program__c FROM Incentive_Program_Enrollment__c WHERE
                                Incentive_Program__c =: prgId AND Requester__c =: currentUserContactId AND Late_Enrollment__c = false
                               ];
        return enrolledPrograms;
    }
    
    public PageReference submit(){
        try {
            String prgName = ApexPages.currentPage().getParameters().get('id');
            Incentive_Program_Enrollment__c incentiveProEnorollementReq = new Incentive_Program_Enrollment__c();
            
            String incentivePrgName = prgName.contains('Quarterly')? 'Quarterly Sales Incentives' : 'Annual Quota Incentives';
            incentiveProEnorollementReq .Incentive_Program__c = ApexPages.currentPage().getParameters().get('id');
            
            // Check either request had created before the expiration date or after the expiration date. If request gets created before the expiration
            // date consider it as approved.
            if (Date.Today() > enrollExpDate ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'The enrollment period for this incentive has expired. Please check back for future incentives.'));
                // Checking if user already has done late enrollment.Then no more record should be created in database.
                List<Incentive_Program_Enrollment__c> lateEnrollments = new List<Incentive_Program_Enrollment__c>();
                lateEnrollments = [SELECT Id, Name, Incentive_Program__c FROM Incentive_Program_Enrollment__c WHERE
                                   Incentive_Program__c =: prgId AND Requester__c =: currentUserContactId AND Late_Enrollment__c = true
                                  ];
                if (lateEnrollments.size() > 0) {
                    return null;
                }
                                  
                incentiveProEnorollementReq.Late_Enrollment__c = true;
                incentiveProEnorollementReq.Status__c = 'Submitted';
            } else {
                incentiveProEnorollementReq.Status__c = 'Approved';
            }
            
            // Check user has acceptted Teams and conditions
            if (isAgree) {
                incentiveProEnorollementReq.Is_Agree__c = true;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please accept the terms and conditions'));
            }
            
            // Fill account name if user is associated with the account.
            if (partAct != null) {
                incentiveProEnorollementReq.Account__c = partAct.Id;
            }
            
            // Fill contact information
            if (currentUser != null && currentUser.contactId != null) {
                incentiveProEnorollementReq.Requester__c = currentUser.contactId;
            } else {
                incentiveProEnorollementReq.Requester__c = UserInfo.getUserId();
            }
            
            incentiveProEnorollementReq.Enrolled_Date__c = Date.Today();
            if (partAct != null)
            incentiveProEnorollementReq.CAM_email__c = partAct.Owner.Email;
            incentiveProEnorollementReq.Partner_User_Email__c = UserInfo.getUserEmail();
            
            insert incentiveProEnorollementReq;
            
            // Creating Incentive Program Enrollment(IPE) Request
            if (Date.Today() > enrollExpDate ) {
                Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
                appReq.setComments('Incentive Program Enrollment request for approvel.');
                appReq.setObjectId(incentiveProEnorollementReq.Id);
                
                // Submitting IPE request.
                Approval.ProcessResult result = Approval.process(appReq );   
            }
            
            // If late enrollment, let user stay on the same message, with error messsge.
            if (Date.Today() > enrollExpDate ) {
                return null;
            }
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()+ ex.getLineNumber()));
            return null;
        }
        
        PageReference pr = Page.incentive_program_success_message;
        pr.getParameters().put('message','You have enrolled successfully for the Incentive Program.');
        return pr;
    }
    
    
    
    public PageReference redirectBack() {
        return Page.incentivePrograms;
    }
    

}