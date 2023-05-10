public without sharing class PRM_CoBrandedCollateralController 
{
	@AuraEnabled
    public static List<Co_Branded_Collateral__c> getCoBrandedCollateral(String selectedView)
    {
       
        List<Co_Branded_Collateral__c> lstCoBranded;
            
        if(selectedView == 'All')
        {
            lstCoBranded =  [Select Id, Name, Status__c, Campaign_Name__c, Final_dimensions_you_need__c, Partner_Account__c, Partner_Account__r.Name, Partner_Contact__r.Name, Partner_Email_Address__c,
                       What_is_your_deadline__c, What_kind_of_document_are_you_requesting__c, CreatedDate
                       from Co_Branded_Collateral__c order by CreatedDate ];
        }
        else
        {
            lstCoBranded =  [Select Id, Name, Status__c, Campaign_Name__c, Final_dimensions_you_need__c, Partner_Account__c, Partner_Account__r.Name, Partner_Contact__r.Name, Partner_Email_Address__c,
                       What_is_your_deadline__c, What_kind_of_document_are_you_requesting__c, CreatedDate                          
                       from Co_Branded_Collateral__c where Status__c =: selectedView order by CreatedDate ];
        }
        return lstCoBranded;
    }
    
    @AuraEnabled
    public static Co_Branded_Collateral__c getCoBrandedCollateralDetail(String recId)
    {
       
        List<Co_Branded_Collateral__c> lstCoBranded;
       
        lstCoBranded =  [Select Id, Name, Status__c, Campaign_Name__c, Final_dimensions_you_need__c, Partner_Account__c, Partner_Account__r.Name, Partner_Contact__r.Name, Partner_Email_Address__c,
                       		What_is_your_deadline__c, What_kind_of_document_are_you_requesting__c, CreatedDate
                       	from Co_Branded_Collateral__c where Id=: recId ];
       
        if(!lstCoBranded.isEmpty())
        {
            return lstCoBranded[0];
        }
        
        return null;
    }
    
    @AuraEnabled
    public static PicklistDetail getEditCoBrandedCollateralDetail(String recId)
    {
       
        List<Co_Branded_Collateral__c> lstCoBranded;
       
        lstCoBranded =  [Select Id, Name, Status__c, Campaign_Name__c, Final_dimensions_you_need__c, Partner_Account__c, Partner_Account__r.Name, Partner_Contact__r.Name, Partner_Email_Address__c,
                       		What_is_your_deadline__c, What_kind_of_document_are_you_requesting__c, CreatedDate
                       	from Co_Branded_Collateral__c where Id=: recId ];
        PicklistDetail objDetail = getPicklistValues();
        objDetail.objCB = !lstCoBranded.isEmpty() ? lstCoBranded[0] : null ;
        
        return objDetail;
    }
    
    @AuraEnabled
    public static PicklistDetail getPicklistValues()
    {
        PicklistDetail objPicklistDetail = new PicklistDetail();
        
        //Campaign Name
        Schema.DescribeFieldResult fieldResult = Co_Branded_Collateral__c.Campaign_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            objPicklistDetail.lstCampaignName.add(f.getValue());
        }   
        
        //Requesting Documents
        Schema.DescribeFieldResult fieldResult2 = Co_Branded_Collateral__c.What_kind_of_document_are_you_requesting__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
            
        for(Schema.PicklistEntry f : ple2)
        {
            objPicklistDetail.lstRequestingDocument.add(f.getValue());
        }    
        
        return objPicklistDetail;        
    }
    
    @AuraEnabled
    public static List<Attachment> getCBCAttachments(String recId)
    {
        return [Select Id, Name from Attachment where ParentId =: recId];
    }
    
    @AuraEnabled
    public static String saveCoBranded(Co_Branded_Collateral__c objCBC)
    {
        objCBC.Campaign_Name__c = objCBC.Campaign_Name__c == '-- None --' ? null : objCBC.Campaign_Name__c;
        objCBC.What_kind_of_document_are_you_requesting__c = objCBC.What_kind_of_document_are_you_requesting__c == '-- None --' ? null : objCBC.What_kind_of_document_are_you_requesting__c;
        
        insert objCBC;
        
        return objCBC.Id;
    }
    
    @AuraEnabled
    public static String saveEditedCoBranded(Co_Branded_Collateral__c objCBC)
    {
        objCBC.Campaign_Name__c = objCBC.Campaign_Name__c == '-- None --' ? null : objCBC.Campaign_Name__c;
        objCBC.What_kind_of_document_are_you_requesting__c = objCBC.What_kind_of_document_are_you_requesting__c == '-- None --' ? null : objCBC.What_kind_of_document_are_you_requesting__c;
        
        update objCBC;
        
        return objCBC.Id;
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
    public static ProcessResult submitApprovalRequest(String recordId, String comment) 
    {
        List<Attachment> lstAttachment = [Select Id from Attachment where ParentId =: recordId];
        ProcessResult result ;
        if(!lstAttachment.isEmpty())
        {
        
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest ();
            req.setComments(comment);
            req.setObjectId(Id.valueOf(recordId));
            
            try 
            {
                Approval.ProcessResult approvalResult = Approval.process(req);
                if(approvalResult.isSuccess()) 
                {
                    result = new ProcessResult('success','Record successfully submitted for Approval');
                } 
                else 
                {
                    result = new ProcessResult('error', String.valueOf(approvalResult.getErrors()));
                }
            }
            catch(Exception e) 
            {
                result =  new ProcessResult('error','Record cannot be submitted because of glitch in System. Contact IT support');
            }
        }
        else
        {
            result = new ProcessResult('info','Please upload the attachment before submit for Approval.');
        }
       	return result;
    }
    
     public class ProcessResult {
        @AuraEnabled public String status = '';
        @AuraEnabled public String message = '';
        
        /*public processResult(){} commented empty block */
        
        public processResult(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
    public class PicklistDetail
    {
        @AuraEnabled
        public Co_Branded_Collateral__c objCB;
        
        @AuraEnabled
        public List<String> lstCampaignName;
        
        @AuraEnabled
        public List<String> lstRequestingDocument;
        
       
        
        public PicklistDetail()
        {
            lstCampaignName = new List<String>();
            lstCampaignName.add('-- None --');
            
            lstRequestingDocument = new List<String>();
            lstRequestingDocument.add('-- None --');
        }
    }
    
}