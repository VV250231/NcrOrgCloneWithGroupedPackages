public class PRM_CaseController {
    
    @AuraEnabled
    public static List<Case> getCases(String selectedView)
    {
       
        List<Case> lstCase;
            
        if(selectedView == 'All Cases')
        {
            lstCase =  [Select Id, CaseNumber, Contact.Name, Category__c, Subject, Priority, Status, Description, CC__c, CreatedDate, Owner.Name
                       from Case where RecordType.Name = 'IPT Partner' order by CreatedDate ];
        }
        else if (selectedView == 'All Open Cases')
        {
            lstCase =  [Select Id, CaseNumber, Contact.Name, Category__c, Subject, Priority, Status, Description, CC__c, CreatedDate, Owner.Name
                       from Case where RecordType.Name = 'IPT Partner' and Status != 'Closed' order by CreatedDate ];
        }
        else
        {
            lstCase =  [Select Id, CaseNumber, Contact.Name, Category__c, Subject, Priority, Status, Description, CC__c, CreatedDate, Owner.Name
                       from Case where OwnerId =: UserInfo.getUserId() and RecordType.Name = 'IPT Partner' order by CreatedDate ];
        }
        return lstCase;
    }
    
     @AuraEnabled
    public static Case getCaseDetail(String recId)
    {
       
        List<Case> lstCase;
       
        lstCase =  [Select Id, CaseNumber, Contact.Name,Account.Name,Master_Customer_Number__c,ContactEmail,Category__c,RecordType.Name, Subject, Priority, Status, Description, CC__c, CreatedDate, Owner.Name,
                    CC__r.Name
                       from Case where Id=: recId ];
       
        if(!lstCase.isEmpty())
        {
            return lstCase[0];
        }
        
        return null;
    }
    
     @AuraEnabled
    public static void createComment(String caseId, String body)
    {
        CaseComment objComment = new CaseComment(ParentId = caseId, CommentBody = body, IsPublished = true);
        insert objComment;
        
        
    }
    
     @AuraEnabled
    public static List<Attachment> getAttachments(String recId)
    {
        List<Attachment> lstAttachment =  [Select Id, Name from Attachment where ParentId =: recId];
        
        return lstAttachment;
    }
    
    @AuraEnabled
    public static List<CaseComment> getCaseComments(String recId)
    {
        List<CaseComment> lstCaseComment = [Select Id, CommentBody, CreatedDate, CreatedBy.Name from CaseComment where ParentId =: recId];
        
        return lstCaseComment;
    }
     @AuraEnabled
    public static String saveCase(Case objCase, String contactId, String ccId)
    {
       
        objCase.ContactId = String.isNotBlank(contactId) ? contactId : null;
        objCase.CC__c = String.isNotBlank(ccId) ? ccId : null;
        
        Case objNewCase = new Case(ContactId =  objCase.ContactId, 
                                   CC__c = objCase.CC__c,
                                   Subject = objCase.Subject,
                                   Status = 'New', 
                                   Priority = objCase.Priority,
                                   Description = objCase.Description, 
                                   Category__c = objCase.Category__c );
        insert objNewCase;
        
        return objNewCase.Id;
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) 
    {      
        if (fileId == '') 
        {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } 
        else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) 
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) 
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =: fileId];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;
    }
    
     @AuraEnabled
    public static PicklistDetail getPicklistValues()
    {
        PicklistDetail objPicklistDetail = new PicklistDetail();
        
        //Category
        Schema.DescribeFieldResult fieldResult = Case.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            objPicklistDetail.lstCategory.add(f.getValue());
        }   
        
        //Status
        Schema.DescribeFieldResult fieldResult2 = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
            
        for(Schema.PicklistEntry f : ple2)
        {
            objPicklistDetail.lstStatus.add(f.getValue());
        }    
        
        
        return objPicklistDetail;        
    }
    
    @AuraEnabled
    public static Contact getContactDetail()
    {
        String loginPartnerContactId = [Select ContactId from User where Id = :UserInfo.getUserId()].ContactId;
        
        Contact partnerContact = [Select Id, Name from Contact where Id = :loginPartnerContactId];
        return partnerContact;
    }
    
     public class PicklistDetail
    {
        @AuraEnabled
        public Case objC;
        
        @AuraEnabled
        public List<String> lstCategory;
        
        @AuraEnabled
        public List<String> lstStatus;
        
        
        public PicklistDetail()
        {
            lstCategory = new List<String>();
            lstCategory.add('-- None --');
            
            lstStatus = new List<String>();
            lstStatus.add('-- None --');
        }
    }
    
    public class CaseRelatedDetails
    {
		@AuraEnabled
        public List<Attachment> lstAttachment;
        
        @AuraEnabled
        public List<CaseComment> lstCaseComment;
        
    }
}