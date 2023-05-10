public class PRM_EULASubmissionController {
    
    @AuraEnabled
    public static List<EULA_submission__c> getEULASubmission(String selectedView)
    {
       
        List<EULA_submission__c> lstEULA;
            
        if(selectedView == 'All')
        {
            lstEULA =  [Select Id, Name, Status__c, Account__r.Name,Address__c,CAM__r.Name,Contact__r.Name,Country__c,Customer_Name__c,Customer_Number_MCN__c,Date_of_Agreement__c,End_Date_of_Agreement__c,
                        Solution_Name_or_Identifying_PID__c,CreatedDate
                       from EULA_submission__c order by CreatedDate ];
        }
        else
        {
            lstEULA =  [Select Id, Name, Status__c, Account__r.Name,Address__c,CAM__r.Name,Contact__r.Name,Country__c,Customer_Name__c,Customer_Number_MCN__c,Date_of_Agreement__c,End_Date_of_Agreement__c,
                        Solution_Name_or_Identifying_PID__c, CreatedDate                          
                       from EULA_submission__c where Status__c =: selectedView order by CreatedDate ];
        }
        return lstEULA;
    }
    
    @AuraEnabled
    public static EULA_submission__c getEULASubmissionDetail(String recId)
    {
       
        List<EULA_submission__c> lstEULA;
       
        lstEULA =  [Select Id, Name, Status__c,  Account__r.Name,Address__c,CAM__r.Name,Contact__r.Name,Country__c,Customer_Name__c,Customer_Number_MCN__c,Date_of_Agreement__c,End_Date_of_Agreement__c,
                        Solution_Name_or_Identifying_PID__c, CreatedDate
                       	from EULA_submission__c where Id=: recId ];
       
        if(!lstEULA.isEmpty())
        {
            return lstEULA[0];
        }
        
        return null;
    }
    
      @AuraEnabled
  		public static PicklistDetail getEditEULASubmissionDetail(String recId)
    {
       
        List<EULA_submission__c> lstEULA;
       
        lstEULA =  [Select Id, Name, Status__c, Account__r.Name,Address__c,CAM__r.Name,Contact__r.Name,Country__c,Customer_Name__c,Customer_Number_MCN__c,Date_of_Agreement__c,End_Date_of_Agreement__c,
                        Solution_Name_or_Identifying_PID__c, CreatedDate
                       	from EULA_submission__c where Id=: recId ];
        PicklistDetail objDetail = getPicklistValues();
        objDetail.objE = !lstEULA.isEmpty() ? lstEULA[0] : null ;
        
        return objDetail;
    } 
    
     @AuraEnabled
    public static PicklistDetail getPicklistValues()
    {
        PicklistDetail objPicklistDetail = new PicklistDetail();
        
        //Country
        Schema.DescribeFieldResult fieldResult = EULA_submission__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            objPicklistDetail.lstCountry.add(f.getValue());
        }   
        
       
        
        return objPicklistDetail;        
    }
    
     @AuraEnabled
    public static List<Attachment> getCBCAttachments(String recId)
    {
        return [Select Id, Name from Attachment where ParentId =: recId];
    }
    
    
     @AuraEnabled
    public static String saveEULA(EULA_submission__c objES)
    {
        objES.Country__c = objES.Country__c == '-- None --' ? null : objES.Country__c;
        
        
        insert objES;
        
        return objES.Id;
    }
    
     @AuraEnabled
    public static String saveEditedEULA(EULA_submission__c objES)
    {
        objES.Country__c = objES.Country__c == '-- None --' ? null : objES.Country__c;
       
        
        update objES;
        
        return objES.Id;
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
        public EULA_submission__c objE;
        
   
        
        @AuraEnabled
        public List<String> lstCountry;
        
        
        
       
        
        public PicklistDetail()
        {
            lstCountry = new List<String>();
            lstCountry.add('-- None --');
            
           
        }
    }

}