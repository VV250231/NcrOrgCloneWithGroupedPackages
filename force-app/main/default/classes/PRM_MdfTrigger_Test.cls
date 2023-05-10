@isTest
public class PRM_MdfTrigger_Test {
    /**
     * Create CAM and RCL user of profile 21 Channel/Distributor Account Manager and run test as system admin.
     * MDF request should be shared with CAM & RCL
     */
    @testsetup
    static void mdftest()
    {
        Account acc = PRM_TestRecordsFactory.createPartnerAccount('1', null);
        system.runAs(TestRecordsFactory.getUser()){
        insert acc;
        }
        Contact con = PRM_TestRecordsFactory.createPartnerContact(acc.id, '1', null);
        insert con;
        
    }
    @isTest
    static void validateMdfSharing() {
        Profile p = TestRecordsFactory.getProfile('Channel DCAM');
       List<User> marketingUsers = TestRecordsFactory.createUsers(p.Id,'marketingUser', 4);
                Contact contactRecord = [SELECT Id,LastName, AccountId FROM Contact WHERE LastName = 'Mahla1' LIMIT 1]; 
                User partUser = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'1',null);
        insert partUser;
         system.assertNotEquals(partUser.Id,null);

        test.startTest();
        
        //Creating User
      //  User partUser = [Select id from user where Profile.name = 'IPT Partner Community Login User' and IsActive = True limit 1];
         system.runAs(partUser){
       
        //List<User> marketingUsers = MDFSharingTest.createUsers(p.Id,'marketingUser', 4);
        
        // Creating MDF Request.
        SFDC_MDF__c mdfRequest = new SFDC_MDF__c();
        mdfRequest.Name= 'Test Activity';
        mdfRequest.Activity_Date__c= Date.today().addDays(35);
        mdfRequest.End_Date__c= Date.today().addDays(40);
        mdfRequest.Activity_Type__c= 'Event - Roadshow';
        mdfRequest.Other_Vendors_Represented__c='Micros';
        mdfRequest.Activity_Description__c='TestDescription';
        mdfRequest.Number_of_Leads__c= 1000;       
        mdfRequest.Status__c='Request Created'; 
        mdfRequest.CAM__c = marketingUsers[0].Id;
        mdfRequest.RCL__c = marketingUsers[1].Id;
        mdfRequest.ownerId = partUser.id;
        insert mdfRequest;
             //system.assertEquals(mdfRequest.Status__c, 'Request Created');
        // Reassign MDF request to another user            
        mdfRequest.CAM__c = marketingUsers[2].Id;
        mdfRequest.RCL__c = marketingUsers[3].Id;
        
        update mdfRequest;
           system.debug([select ID, Contact.Account.Id FROM USER WHERE Id =:  mdfRequest.ownerId].Contact.Account.Id);
             
    }
        test.stopTest();
    }
    
    public static List<User> createUsers(String profileId, String userPrefix, Integer numOfUsers) {
        List<User> newUsers = new List<User>();
        for (Integer i=0;i < numOfUsers ; i++) {
            User us              =  new User();
            us.Profileid         = profileId;
            us.Username          = userPrefix+i+'@ncr.com';
            us.Email             = userPrefix+i+'@ncr.com';
            us.Alias             = 'alias'+i;           
            us.FirstName         = 'Fname'+i;
            us.LastName          = 'lname'+i;
            us.LocaleSidKey      = 'ar';
            us.LanguageLocaleKey = 'de';
            us.TimeZoneSidKey    = 'Africa/Cairo';
            us.EmailEncodingKey  = 'Big5';
            us.CurrencyIsoCode   = 'AUD';
            us.Quicklook_ID__c   = 'tm25066'+i;
            us.FederationIdentifier = 'tm25066'+i;
            newUsers.add(us);

        }
        
        try {
            if (newUsers.size() > 0)
            {
                insert newUsers;
            }
            else
                return null;
            // IF successfull insertion than return the user list.
            return newUsers;
        } catch(Exception ex) {
            return null;
        }       
    }
    
    //LIGHTNING PROFILE METHOD
    @isTest
    static void validateMdfSharing_LTNG() {
        Profile p = TestRecordsFactory.getProfile('Channel DCAM');
        // List<User> marketingUsers = MDFSharingTest.createUsers(p.Id,'marketingUser', 4);
       List<User> marketingUsers = TestRecordsFactory.createUsers(p.Id,'marketingUser', 4);
        
        // Creating MDF Request.
        SFDC_MDF__c mdfRequest = new SFDC_MDF__c();
        mdfRequest.Name= 'Test Activity';
        mdfRequest.Activity_Date__c= Date.today().addDays(35);
        mdfRequest.End_Date__c= Date.today().addDays(40);
        mdfRequest.Activity_Type__c= 'Event - Roadshow';
        mdfRequest.Other_Vendors_Represented__c='Micros';
        mdfRequest.Activity_Description__c='TestDescription';
        mdfRequest.Number_of_Leads__c= 1000;       
        mdfRequest.Status__c='Request Created'; 
        mdfRequest.CAM__c = marketingUsers[0].Id;
        mdfRequest.RCL__c = marketingUsers[1].Id;
        mdfRequest.ownerId = marketingUsers[0].Id;
        
        insert mdfRequest;
        // Reassign MDF request to another user            
        mdfRequest.CAM__c = marketingUsers[2].Id;
        mdfRequest.RCL__c = marketingUsers[3].Id;
        update mdfRequest;
        system.assertEquals(false, mdfRequest.IsCurrentUserCAMorRCL__c);
    }
   

   /* @isTest
    static void  reassignApproverOnChange() {
        User partUser = PrepareMDFTestDataUtil.userWithContactAndAccount('');
        SFDC_MDF__c mdfRequest = new SFDC_MDF__c();
         //mdfRequest=PrepareMDFTestDataUtil.prepareMDFRecord();
        system.runAs(partUser){
        mdfRequest=PrepareMDFTestDataUtil.prepareMDFRecord();
        mdfRequest.Is_Record_Locked__c = true;
        mdfRequest.Request_Submission_Date__c = System.now();
        mdfrequest.OwnerId = partUser.Id;
        update mdfRequest;
        system.debug('***'+mdfRequest.CAM__c+'***'+mdfRequest.RCL__c);
        Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitted for approval. Please approve.');
        req.setObjectId(mdfRequest.Id);
        Approval.ProcessResult result = Approval.process(req);
        
        }
         User u = [Select Id from User Where Name = 'Soup User'];
       // User u=[Select id from User where profile.name = 'System Administrator' AND id != :userinfo.getUserId() AND isActive = true limit 1];
        system.runas(u){
        mdfRequest.CAM__c = u.id;
        update mdfRequest;
        mdfRequest.RCL__c = u.id;
        update mdfRequest;
        }
    } 
*/


}