@isTest
public class PRM_FileCardOfPricingConTest {
	@isTest
    public static void testPRM_FileCardOfPricingCon() {
        // Create partner account
        // Create Partner Account
        Account partnerAct = PRM_TestRecordsFactory.createPartnerAccount('1',null);
        partnerAct.Partner_Type__c = 'Distributor';
        partnerAct.ISO_Country_Code__c = 'TR';
        partnerAct.Partner_Industry__c = 'Retail;Financial';
        system.runAs(TestRecordsFactory.getUser() )
        {
             insert partnerAct;
        }
       
        // Create partner Contact
        Contact partnerCon = PRM_TestRecordsFactory.createPartnerContact(partnerAct.Id,'1',null);
        insert partnerCon;
        // Create partner user
        Profile p = [select Name from Profile WHERE name ='IPT Partner Community Login User'];
        
        User user = new User(alias = 'test23', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                             ContactId = partnerCon.Id,FederationIdentifier = 'sm123993',Quicklook_ID__c = 'sm123993',
                             timezonesidkey='America/Los_Angeles', username='test123@noemail.com.t');
        
        insert user;
        // Create Turkey standard discount framework record.
        Channel_Price_Book_Turkey__c cpbt = new Channel_Price_Book_Turkey__c ();
        cpbt.Name = 'TEST Product';
        cpbt.Product_Group__c = 'productGroup';
        cpbt.PID__c = '123';
        cpbt.Old_Discount__c = 50;
        cpbt.New_Discount__c = 40;
        insert cpbt;
        // Create Price book entery for other region
        ChannelProgram cp = new ChannelProgram();
        cp.Category = 'Distributor';
        cp.IsActive = True;
        cp.Name = '20-20';
        insert cp;
        
        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = 'Advanced';
        cpl.ProgramId = cp.Id;
        cpl.Rank = 1;
        insert cpl;
        
        Channel_Price_Book__c cpb = new Channel_Price_Book__c();
        cpb.Industry__c = 'Retail';
        cpb.Channel_Program_Level__c = cpl.Id;
        cpb.Old_Value__c = 50;
        cpb.New_Value__c = 40;
        cpb.Region__c = 'MEA GSL';
        insert cpb;
        System.assertNotEquals(cpb, null,'Channel_Price_Book__c should not be null');

        // Update partner type as distributor
        // Update Region
        // Update industry
        PRM_FileCardOfPricingCon.fetchPriceList();
        PRM_FileCardOfPricingCon.getPriceList(partnerAct.Id);
        
        partnerAct.ISO_Country_Code__c = 'DZ';
        update partnerAct;
        PRM_FileCardOfPricingCon.fetchPriceList();
        PRM_FileCardOfPricingCon.getPriceList(partnerAct.Id);
    }
}