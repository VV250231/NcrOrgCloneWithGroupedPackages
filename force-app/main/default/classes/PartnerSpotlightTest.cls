@isTest
public class PartnerSpotlightTest 
{
	 public static testMethod void testPartnerFeatureFridayController()
     {
         String spId = PRM_PartnerFeatureFridayController.savePartnerFeatureFriday(new Partner_Spotlight__c(First_Name__c = 'Test Class'));
         system.assert(spId!=null);
         Partner_Spotlight__c objSP = [Select Id from Partner_Spotlight__c where ID =: spId];         
         PRM_PartnerFeatureFridayController.updatePartnerFeatureFriday(objSP);
         
         PRM_PartnerFeatureFridayController.getPartnerFeatureFriday(spId);
         
       	 PRM_PartnerFeatureFridayController.saveChunk( spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
         Attachment oAttachment = new Attachment();
         Blob b = Blob.valueOf('Test Data');
         oAttachment.parentId = spId;
         oAttachment.Name = 'Test Attachment for Parent';
         oAttachment.Body = b;
         insert oAttachment;
         PRM_PartnerFeatureFridayController.saveChunk(spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
         
         PRM_PartnerFeatureFridayController.getAllAttachment(spId);
	}
    
    public static testMethod void testMDFSuccessStoryController()
    {
         String spId = PRM_MDFSuccessStoryController.saveMDFSuccessStory(new Partner_Spotlight__c(First_Name__c = 'Test Class'));
         system.assert(spId!=null);
         Partner_Spotlight__c objSP = [Select Id from Partner_Spotlight__c where ID =: spId];    
         
         PRM_MDFSuccessStoryController.updateMDFSuccessStory(objSP);
         
         PRM_MDFSuccessStoryController.getMDFSuccessStory(spId);
         
       	 PRM_MDFSuccessStoryController.saveChunk( spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
         Attachment oAttachment = new Attachment();
         Blob b = Blob.valueOf('Test Data');
         oAttachment.parentId = spId;
         oAttachment.Name = 'Test Attachment for Parent';
         oAttachment.Body = b;
         insert oAttachment;
         PRM_MDFSuccessStoryController.saveChunk(spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
         
         PRM_MDFSuccessStoryController.getAllAttachment(spId);
	}
    
    public static testMethod void testPartnerAmbassadorEventController()
    {
         String spId = PRM_PartnerAmbassadorEventController.savePartnerAmbassadorEvent(new Partner_Spotlight__c(First_Name__c = 'Test Class'));
         
         Partner_Spotlight__c objSP = [Select Id from Partner_Spotlight__c where ID =: spId];    
         
         PRM_PartnerAmbassadorEventController.updatePartnerAmbassadorEvent(objSP);
         
         PRM_PartnerAmbassadorEventController.getPartnerAmbassadorEvent(spId);
         
       	 PRM_PartnerAmbassadorEventController.saveChunk( spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
         Attachment oAttachment = new Attachment();
         Blob b = Blob.valueOf('Test Data');
         oAttachment.parentId = spId;
         oAttachment.Name = 'Test Attachment for Parent';
         oAttachment.Body = b;
         insert oAttachment;
        system.assert(oAttachment.id!=null);
         PRM_PartnerAmbassadorEventController.saveChunk(spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
         
         PRM_PartnerAmbassadorEventController.getAllAttachment(spId);
	}
    
    public static testMethod void testSignificantCustomerWinController()
    {
         String spId = PRM_SignificantCustomerWinController.saveSignificantCustomerWin(new Partner_Spotlight__c(First_Name__c = 'Test Class'));
         system.assert(spId!=null);
         Partner_Spotlight__c objSP = [Select Id from Partner_Spotlight__c where ID =: spId];    
         
         PRM_SignificantCustomerWinController.updateSignificantCustomerWin(objSP);
         
         PRM_SignificantCustomerWinController.getSignificantCustomerWin(spId);
         
       	 PRM_SignificantCustomerWinController.saveChunk( spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
         Attachment oAttachment = new Attachment();
         Blob b = Blob.valueOf('Test Data');
         oAttachment.parentId = spId;
         oAttachment.Name = 'Test Attachment for Parent';
         oAttachment.Body = b;
         insert oAttachment;
        system.assert(oAttachment.id!=null);
         PRM_SignificantCustomerWinController.saveChunk(spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
         
         PRM_SignificantCustomerWinController.getAllAttachment(spId);
	}
    
    public static testMethod void testMiscellaneousBusinessController()
    {
         String spId = PRM_MiscellaneousBusinessController.saveMiscellaneousBusinessRelatedTopic(new Partner_Spotlight__c(First_Name__c = 'Test Class'));
         
         Partner_Spotlight__c objSP = [Select Id from Partner_Spotlight__c where ID =: spId];    
         
         PRM_MiscellaneousBusinessController.updateMiscellaneousBusinessRelatedTopic(objSP);
         
         PRM_MiscellaneousBusinessController.getMiscellaneousBusinessRelated(spId);
         
       	 PRM_MiscellaneousBusinessController.saveChunk( spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
         Attachment oAttachment = new Attachment();
         Blob b = Blob.valueOf('Test Data');
         oAttachment.parentId = spId;
         oAttachment.Name = 'Test Attachment for Parent';
         oAttachment.Body = b;
         insert oAttachment;
        system.assert(oAttachment.id!=null);
         PRM_MiscellaneousBusinessController.saveChunk(spId, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
         
         PRM_MiscellaneousBusinessController.getAllAttachment(spId);
	}
    
    public static testMethod void testPartnerSpotlight()
    {
        
        Partner_Spotlight__c objSP = new Partner_Spotlight__c(First_Name__c = 'Test Class');
        insert objSP;
        system.assertEquals('Test Class',objSP.First_Name__c);
        PartnerSpotlight.getSpotlight(objSP.Id); 
    }
        
    public static testMethod void testPartnerSpotlightListviewController()
    {
		Partner_Spotlight__c objSP = new Partner_Spotlight__c(First_Name__c = 'Test Class', Partner_Spotlight_Type__c = 'MDF Success Story');
        insert objSP;
      
        system.assertEquals('MDF Success Story',objSP.Partner_Spotlight_Type__c);
        PRM_PartnerSpotlightListviewController.getPartnerSpotlight('MDF Success Story');
    }
    
}