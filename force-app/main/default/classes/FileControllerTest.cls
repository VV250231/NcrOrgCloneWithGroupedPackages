@isTest(seeAlldata =true)
public class FileControllerTest {
     
    static testmethod void submitAttachmentPage()
    {
        
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
          
            VFpage.getParameters().put('pid', mdfReq.id);
            VFpage.getParameters().put('fieldapi','Fund_Request__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
        	fruc.fildDescription = 'Test';
            fruc.processAttachment();
     }   
    
         static testmethod void submitAttachmentPage2()
    {
        
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
         System.assertEquals(mdfCliam!=Null, True);
            VFpage.getParameters().put('pid', mdfCliam.id);
            VFpage.getParameters().put('fieldapi','Fund_Claim__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
       		fruc.fildDescription = 'Test';
            fruc.processAttachment();
             Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
            
            File__c file = new File__c();
            file.Name = 'test' ;
             file.put('Fund_Request__c',mdfReq.Id); 
            file.Claim__c = true;
            file.put('Attachment_ID__c',attachment.Id);
             Database.insert(file);
        
            //FileController.parentId =mdfCliam.id;
            fruc.updatePreAppFileList();
           
            

    }   
    static testmethod void filecontrollerExt(){
         
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
         System.assertEquals(mdfCliam!=Null, True);
            VFpage.getParameters().put('pid', mdfCliam.id);
            VFpage.getParameters().put('fieldapi','Fund_Claim__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
       		fruc.fildDescription = 'Test';
            fruc.processAttachment();
             Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
            
            File__c file = new File__c();
            file.Name = 'test' ;
             file.put('Fund_Request__c',mdfReq.Id); 
            file.Claim__c = true;
        file.Pre_Approval__c = false;
            file.put('Attachment_ID__c',attachment.Id);
             Database.insert(file);
        
            //FileController.parentId =mdfCliam.id;
            fruc.updatePreAppFileList();
        
      //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
            
        fileExt.updateFileProcess();
        fileExt.updateAttachment();
        
		
    }
    
    
     static testmethod void filecontrollerExt2(){
         
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
          
            VFpage.getParameters().put('pid', mdfReq.id);
            VFpage.getParameters().put('fieldapi','Fund_Request__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
        	fruc.fildDescription = 'Test';
            fruc.processAttachment();
      //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
       filecontrollerExt fileExt = new filecontrollerExt(fruc);
            
        fileExt.updateFileProcess();
         fileExt.updateAttachment();
        
        
    }
    
    /*
    static testmethod void filecontrollerExtError(){
         
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        System.assertEquals(mdfReq!=Null, True);     
        Attachment__c obj = new Attachment__c();
         Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
        FileController  fruc = new FileController();
            PageReference VFpage = Page.ncrUpdateFile;
            File__c file = new File__c();
            file.Name = 'test' ;
             file.put('Fund_Request__c',mdfReq.Id); 
            file.Claim__c = true;
            file.put('Attachment_ID__c',attachment.Id);
             Database.insert(file);
         VFpage.getParameters().put('pid', mdfReq.id);
        VFpage.getParameters().put('fileId', file.id);
       
     //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
       fileExt.updateFileProcess();    
    }
    */
    
    static testmethod void FileControllerExtTest1()
    {
        
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
          
            VFpage.getParameters().put('pid', mdfReq.id);
            VFpage.getParameters().put('fieldapi','Fund_Request__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.processAttachment();
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
       fileExt.updateFileProcess();
       fileExt.updateAttachment();
     }
    
    
    static testmethod void FileControllerExtTest2()
    {
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
         System.assertEquals(mdfCliam!=Null, True);
            VFpage.getParameters().put('pid', mdfCliam.id);
            VFpage.getParameters().put('fieldapi','Fund_Claim__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
       		fruc.fildDescription = 'Test';
            fruc.processAttachment();
             Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
            
            File__c file1 = new File__c();
            file1.Name = 'test' ;
             file1.put('Fund_Request__c',mdfReq.Id); 
            file1.Claim__c = false;
        file1.Pre_Approval__c = true;
            file1.put('Attachment_ID__c',attachment.Id);
             Database.insert(file1);
        
            //FileController.parentId =mdfCliam.id;
            //fruc.updatePreAppFileList();
        
      //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
        fileExt.attDoc=attachment;
        fileExt.file=file1;
        fileExt.filename='test';
            
        fileExt.updateFileProcess();
        fileExt.updateAttachment();
    }
    
    static testmethod void FileControllerExtTest3()
    {
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
         System.assertEquals(mdfCliam!=Null, True);
            VFpage.getParameters().put('pid', mdfCliam.id);
            VFpage.getParameters().put('fieldapi','Fund_Claim__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
       		fruc.fildDescription = 'Test';
            fruc.processAttachment();
             Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
            
            File__c file = new File__c();
            file.Name = 'test' ;
             file.put('Fund_Request__c',mdfReq.Id); 
            file.Claim__c = true;
        file.Pre_Approval__c = true;
            file.put('Attachment_ID__c',attachment.Id);
             Database.insert(file);
        
            //FileController.parentId =mdfCliam.id;
            fruc.updatePreAppFileList();
        
      //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
            
        fileExt.updateFileProcess();
        fileExt.updateAttachment();
    }
    
    static testmethod void FileControllerExtTest4()
    {
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
         System.assertEquals(mdfCliam!=Null, True);
            VFpage.getParameters().put('pid', mdfCliam.id);
            VFpage.getParameters().put('fieldapi','Fund_Claim__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
       		fruc.fildDescription = 'Test';
            fruc.processAttachment();
             Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
            
            File__c file = new File__c();
            file.Name = 'test' ;
             file.put('Fund_Request__c',mdfReq.Id); 
            file.Claim__c = false;
        file.Pre_Approval__c = false;
            file.put('Attachment_ID__c',attachment.Id);
             Database.insert(file);
        
            //FileController.parentId =mdfCliam.id;
            fruc.updatePreAppFileList();
        
      //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
            
        fileExt.updateFileProcess();
        fileExt.updateAttachment();
    }
    
    static testmethod void FileControllerExtTest5()
    {
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        Attachment__c obj = new Attachment__c();
         PageReference VFpage = Page.ncr_pre_approval_doc;
         System.assertEquals(mdfCliam!=Null, True);
            VFpage.getParameters().put('pid', mdfCliam.id);
            VFpage.getParameters().put('fieldapi','Fund_Claim__c');
    
            Test.setCurrentPageReference(VFpage);
            FileController fruc = new FileController();
            fruc.fileBody =  Blob.valueOf(' ');
            fruc.fileName ='test.txt';
       		fruc.fildDescription = 'Test';
            fruc.processAttachment();
             Attachment attachment = new Attachment();
             attachment.body       = Blob.valueOf(' ');
             attachment.name       ='test.txt';
             attachment.parentId   = mdfReq.Id;
            insert attachment;
            
            File__c file1 = new File__c();
            file1.Name = 'test' ;
             file1.put('Fund_Request__c',mdfReq.Id); 
            file1.Claim__c = false;
        file1.Pre_Approval__c = true;
            file1.put('Attachment_ID__c',attachment.Id);
             Database.insert(file1);
        
            //FileController.parentId =mdfCliam.id;
            //fruc.updatePreAppFileList();
        
      //  ApexPages.StandardController sc = new ApexPages.StandardController(fruc);
        filecontrollerExt fileExt = new filecontrollerExt(fruc);
        fileExt.file=file1;
        fileExt.filename='test';
            
        fileExt.updateFileProcess();
        fileExt.updateAttachment();
    }
        
   
}