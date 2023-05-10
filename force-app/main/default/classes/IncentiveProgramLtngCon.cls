public class IncentiveProgramLtngCon {
    
    
    @AuraEnabled public static List<Incentive_Program__c> getAvailableIncentivePrograms() {
        String partnerAccountId='';
        String partnerAccountName='';
        String partnerIndustry='';
        List<String> partnerIndustries= new List<String>();
        String partnerRegion='';
        String partnerProgramLevel='';
        Set<Id> availableIncentiveProgramIds = new Set<Id>();
        
        User currentUser;
        Account act;
        
        List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
        if (users.size() > 0) {
            currentUser = users [0];
        }
        List<Account> accounts = [SELECT Id, Name,OwnerId,Partner_Industry__c,Account_Region__c,Partner_Program_Level__c, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: currentUser.AccountId LIMIT 1];
        if (accounts.size() > 0) {
            partnerAccountId = accounts[0].Id;
            partnerAccountName = accounts[0].Name;
            //partnerIndustry = accounts[0].Partner_Industry__c;
            if (accounts[0].Partner_Industry__c != null) {
                for (string s : accounts[0].Partner_Industry__c.split(';')) {
                    partnerIndustries.add('\''+s+'\'');
                }
            }
            partnerIndustry = String.valueOf(partnerIndustries);
            system.debug('&&'+partnerIndustries);
            system.debug('##'+partnerIndustry);
            partnerRegion = accounts[0].Account_Region__c;
            partnerProgramLevel = accounts[0].Partner_Program_Level__c;
            system.debug('--partnerAccountId'+partnerAccountId);
            system.debug('--partnerAccountName'+partnerAccountName);
            system.debug('--partnerIndustry'+partnerIndustry);
            system.debug('--partnerRegion'+partnerRegion);
            system.debug('--partnerProgramLevel'+partnerProgramLevel);
            
        }
        
        // Finding availabele active incentive program for the parter. Either partner accouts should match with the incentive program
        // attributes else it should be the part of exception list for the incentive program.
        
        if (partnerIndustry == null)
            partnerIndustry = '';
        if (partnerRegion == null)
            partnerRegion = '';
        if (partnerProgramLevel == null)
            partnerProgramLevel = '';
        
        String strQuery = 'SELECT Id, Name FROM Incentive_Program__c WHERE Partner_Industry__c includes  '+ partnerIndustry+' AND '+
                            'Region__c includes (\''+ partnerRegion+'\') AND Partner_Levels__c includes (\''+ partnerProgramLevel+'\') AND Active__c = true';
                                                                
        system.debug('***'+strQuery);
        List<Incentive_Program__c> availableIncentivePrograms = (List<Incentive_Program__c>)Database.query(strQuery);
        
        if (availableIncentivePrograms.size() > 0) {
            for (Incentive_Program__c ip : availableIncentivePrograms) {
                availableIncentiveProgramIds.add(ip.Id);
            }          
        }
        
        List<Incentive_Program_Exception_Account__c> incentivePrgExcepAccouts = [SELECT Id, Incentive_Program__r.Id, 
                                                                                 Incentive_Program__r.Name FROM Incentive_Program_Exception_Account__c
                                                                                 WHERE Account__c =: partnerAccountId AND Incentive_Program__r.Active__c = true
                                                                                ];
        if (incentivePrgExcepAccouts.size() > 0) {
            for (Incentive_Program_Exception_Account__c ipea: incentivePrgExcepAccouts) {
                availableIncentiveProgramIds.add(ipea.Incentive_Program__r.Id);
            }
        }        
        
        
        List<Incentive_Program__c> incentivePrgs = [SELECT Id, Name FROM Incentive_Program__c WHERE Id IN: availableIncentiveProgramIds];
        system.debug('***'+incentivePrgs);
        return incentivePrgs;
    }
    
    
    @AuraEnabled public static IncentiveProgramDetail getIncentiveProgramDetail(String prgId) {
        User currentUser;
        Account act;
        Incentive_Program__c ip;
        
        List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
        if (users.size() > 0) {
            currentUser = users [0];
        }
        List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: currentUser.AccountId LIMIT 1];
        if (accounts.size() > 0) {
            act = accounts[0];
        }
        
        List<Incentive_Program__c> incentivePrgs = [SELECT Id, Passed_Date__c, Incentive_Summary__c, Terms_Conditions__c FROM Incentive_Program__c
                                                    WHERE Id =: prgId LIMIT 1
                                                   ];
        
        if (incentivePrgs.size() > 0)
            ip = incentivePrgs[0];
        
        IncentiveProgramDetail ipDetail = new IncentiveProgramDetail(act,ip);
        return ipDetail;
    }
    
    public class IncentiveProgramDetail {
        @AuraEnabled public Account act {get;set;}
        @AuraEnabled public Date currentDate {get;set;}
        @AuraEnabled public Incentive_Program__c incentiveProgram {get;set;}
        
        public IncentiveProgramDetail(Account act, Incentive_Program__c ip) {
            this.act = act;
            this.incentiveProgram = ip;
            this.currentDate = System.today();
        }
    }
    
    /* Submit incentive program enrollment Request*/
    
    @AuraEnabled public static Result submitEnrollmentReq(String incentivePrg, Boolean isAgree) {
        Result res;
        Boolean isAlreadyDoneLateEnrollement;
        Incentive_Program_Enrollment__c incentiveProEnorollementReq = new Incentive_Program_Enrollment__c();
        Incentive_Program__c ip = new Incentive_Program__c();
        
        // check either user already had enrolled for the programe or not.
        List<Incentive_Program__c> ipList = [SELECT Id, Name, Passed_Date__c FROM Incentive_Program__c WHERE Id =: incentivePrg];
        if (ipList.size()>0) {
            ip = ipList[0];
        }
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        List<Incentive_Program_Enrollment__c> enrollments = new List<Incentive_Program_Enrollment__c>();
        if (Users[0].ContactId != null) {
            enrollments = [SELECT Id, Late_Enrollment__c FROM Incentive_Program_Enrollment__c WHERE 
                           Incentive_Program_Name__c =: ip.Id AND Requester__c =: users[0].ContactId 
                          ];
        }
        if (enrollments.size()>0 && enrollments[0].Late_Enrollment__c != true){
            throw new AuraHandledException('You already enrolled for this incentive program');
            
        } else if (enrollments.size()>0 && enrollments[0].Late_Enrollment__c == true) {
            throw new AuraHandledException('The enrollment period for this incentive has expired. Please check back for future incentives.');
        } else {
            // Check user has acceptted Teams and conditions
            
            if (isAgree) {
                incentiveProEnorollementReq.Is_Agree__c = true;
            } else {
                throw new AuraHandledException('You must acknowledge and accept the terms and conditions before you submit.');
            }
            
            //populate field in request
            incentiveProEnorollementReq.Incentive_Program_Name__c = incentivePrg;
            if (Date.Today() > ip.Passed_Date__c) {
                incentiveProEnorollementReq.Late_Enrollment__c = true;
                incentiveProEnorollementReq.Status__c = 'Submitted';
            } else {
                incentiveProEnorollementReq.Status__c = 'Approved';
            }
            
            if (users[0].ContactId != null) {
                List<Contact> contacts = [SELECT Id, Name, Email, Account.Name, AccountId, Account.Owner.Email FROM Contact 
                                          WHERE Id =: users[0].ContactId
                                         ];
                incentiveProEnorollementReq.Requester__c = contacts[0].Id;
                incentiveProEnorollementReq.Account__c = contacts[0].AccountId;
                incentiveProEnorollementReq.CAM_email__c = contacts[0].Account.Owner.Email;
            }
            
            incentiveProEnorollementReq.Enrolled_Date__c = Date.Today();
            insert incentiveProEnorollementReq;
            
            // If Late enrollement than submit the requst for approval.
            if (Date.Today() > ip.Passed_Date__c ) {
                Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
                appReq.setComments('Incentive Program Enrollment request for approvel.');
                appReq.setObjectId(incentiveProEnorollementReq.Id);
                
                // Submitting IPE request.
                Approval.ProcessResult result = Approval.process(appReq );
                res = new Result('ERROR','The enrollment period for this incentive has expired. Please check back for future incentives.') ;
                return res;
            }
        }
        
        res = new Result('SUCCESS','You have enrolled successfully for the Incentive Program.');
        return res;
    }
    
    public class Result {
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String message {get;set;}
        
        public result(String state, String message) {
            this.state = state;
            this.message = message;
        }
    }
}