/*This test class is used to prepare test data and other test utilities */
@isTest 
public class PrepareMDFTestDataUtil{
    
    /* Prepare and create the MDF Requst record*/
    public static  SFDC_MDF__c prepareMDFRecord(){
        
        SFDC_MDF__c mdfReq= new SFDC_MDF__c();
        mdfReq.Name= 'Test Activity';
        mdfReq.Activity_Date__c= Date.today().addDays(35);
        mdfReq.End_Date__c= Date.today().addDays(40);
        mdfReq.Activity_Type__c= 'Event - Roadshow';
        mdfReq.Other_Vendors_Represented__c='Micros';
        mdfReq.Activity_Description__c='TestDescription';
        mdfReq.Number_of_Leads__c= 1000;       
        mdfReq.Status__c='Request Created'; 
        insert mdfReq;
        return mdfReq;
    }
   
   /* Prepare and create the MDF Expense Details record*/
   public static  MDF_Expense_Detail__c prepareMDFExpenseRecord(Id mdfReqId ){
        MDF_Expense_Detail__c mdfExpenseDetails = new MDF_Expense_Detail__c();
        mdfExpenseDetails.Actvity__c='Print';
        mdfExpenseDetails.Estimated_Cost__c=1000;
        mdfExpenseDetails.NCR_Estimated_Participation__c=1000;
        mdfExpenseDetails.MDF_Request__c=mdfReqId;
        insert mdfExpenseDetails;
        
        return mdfExpenseDetails;
    }
    
    /* Prepare and create the MDF Claim record*/
    public static  SFDC_MDF_Claim__c prepareMDFClaimRecord(Id mdfReqId ){
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
        mdfClaim.Status__c='Created';
        mdfClaim.Numbers_of_Leads__c=1000;
        mdfClaim.Fund_Request__c=mdfReqId;
        insert mdfClaim;
        
        return mdfClaim;
    }
        /**
     * Create a User with Contact And Account 
     */
   public  static User userWithContactAndAccount(String quicklookId){ 
            //Create portal account owner
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1]; 
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User portalAccountOwner1 = new User( 
                    Username = System.now().millisecond() + 'test2#!@test.com',
                    Alias = 'ajtest', Email=System.now().millisecond()+'aj.test@wayneenterprises.com', EmailEncodingKey='UTF-8',
                    Firstname='aj', Lastname='Test'+System.now().millisecond(), LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago',
                    Quicklook_ID__c=quicklookId+'nc1234',
                    UserRoleId = portalRole.Id,
                    ProfileId = profile1.Id
            );
            Database.insert(portalAccountOwner1);
            
            //Create Account and Contact 
            Contact contact1;
            System.runAs(new User(Id = Userinfo.getUserId())) { 
                //Create account
                Account portalAccount1 = new Account( Name = 'TestAccount'+System.now().millisecond(), OwnerId = portalAccountOwner1.Id, CurrencyIsoCode = 'USD');
                Database.insert(portalAccount1);
                 
                //Create contact
                contact1 = new Contact( Email = System.now().millisecond() + 'test@test.com', 
                    FirstName = 'Test', Lastname = 'ajtestlst'+System.now().millisecond(), 
                    AccountId = portalAccount1.Id
                );
                Database.insert(contact1); 
            }
                
            //Create user with Contact and Account 
            Profile portalProfile = [select id,name from profile Where usertype='PowerPartner' limit 1];
             
            //Create User
             User userWithContactAndAccount = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                //ManagerId=managerUser.id,
                Alias = 'test123',
                Email = System.now().millisecond()+'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'ajtestlst'+System.now().millisecond(),
                CommunityNickname = 'test12345'+System.now().millisecond(),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                Quicklook_ID__c=quicklookId+'nc4567'
            );  
                
            Database.insert(userWithContactAndAccount);
            System.debug('userWithContactAndAccount#'+userWithContactAndAccount);
        return userWithContactAndAccount;   
     }
     
   }