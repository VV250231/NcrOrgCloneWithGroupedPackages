/*************************************************************************************************
*   ClassName   : PRM_MDFSuccessStoryController
*   Description :   
*   Author      :   
# Modification History.: 
Story No         Date           DevName         Description
EBA_SF-1948     20-10-2022      KAVYA SREE      Technical Debt - Apex sharing violation part 2 -PRM 
*************************************************************************************************/
public without sharing class PRM_MDFSuccessStoryController 
{
@AuraEnabled
  public static SpotlightInfo getMDFSuccessStory(String recId)
    {
        System.debug('-------recId---------'+recId);
       Partner_Spotlight__c objPS =  [Select Id,Name,Partner_Name__r.Name, First_Name__c, Last_Name__c, Partner_Contact_s_Title_or_Position__c, Partner_Contact_s_Email_Address__c,
                                      		Country_the_Partner_is_located_in__c, Industries_partner_focuses_on__c, Type_of_Event__c, Event_Promotion__c, Successful_Event__c,
                                      		share_story_in_NCR_Partner_Communication__c, Story_on_NCR_Partner_Comm_Social_Media__c,
                                      		(Select Id, Name from Attachments)
                                     from Partner_Spotlight__c 
                                     where Id =:recId ];
        User objUser = [Select id, Profile.UserLicense.Name from user where id =: UserInfo.getUserId()];
        
        SpotlightInfo objInfo = new SpotlightInfo();
        
        objInfo.attachmentCount = objPS.Attachments.size();
        objInfo.userLicenseName = objUser.Profile.UserLicense.Name;
        objInfo.objPS = objPS;
        
        return objInfo;
        
    }
    
    @AuraEnabled
    public static String saveMDFSuccessStory(Partner_Spotlight__c objSpotlight)
    {
        objSpotlight.Partner_Spotlight_Type__c='MDF Success Story';
        insert objSpotlight;
        
        return objSpotlight.Id;
    }
    
     @AuraEnabled
    public static String updateMDFSuccessStory(Partner_Spotlight__c objSpotlight)
    {
        
        update objSpotlight;
        
        return objSpotlight.Id;
    }
    
     @AuraEnabled
    public static Id saveChunk( Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        /*  
        check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        next time (in else) we are call the appentTOFile() method
        for update the attachment with reamins chunks 
        */  
        if (fileId == '') 
        {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } 
        else 
        {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) 
    {
        System.SavePoint sp = DataBase.setSavePoint();
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        try
        { 
            oAttachment.parentId = parentId;
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            insert oAttachment;
        }
        catch(Exception ex)
        {
            Database.rollback(sp); 
        }
        
        return oAttachment.Id;
    }
    
     private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
    @AuraEnabled
    public static SpotlightInfo getAllAttachment(String parentRecId)
    {
        List<Attachment> lstAttachment = [SELECT Id, Name  FROM Attachment WHERE ParentId =: parentRecId];
        
       	SpotlightInfo objInfo = new SpotlightInfo();
        
        objInfo.attachmentCount = lstAttachment.size();
        objInfo.lstPSAttachment = lstAttachment;
        
        return objInfo;
    }
    
    public class SpotlightInfo
    {
        @AuraEnabled
        public Integer attachmentCount;
        
        @AuraEnabled
        public String userLicenseName;
        
        @AuraEnabled
        public Partner_Spotlight__c objPS;
        
        @AuraEnabled 
        public List<Attachment> lstPSAttachment ;
        
    }

}