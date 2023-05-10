@isTest
     
     Public Class NCR_FI_User_ManagementControllerTest{
    
        Public static testMethod void managmentMethod(){
         
             NCR_FI_User_ManagementController obj = new NCR_FI_User_ManagementController();
            
             NCR_FI_User_ManagementController.wrapper wrpobj = new  NCR_FI_User_ManagementController.wrapper();
             wrpobj.str = 'Test';
             List<NCR_FI_User_ManagementController.wrapper> wrpobjlst = new  List<NCR_FI_User_ManagementController.wrapper>();
             wrpobjlst.add(wrpobj);
              Blob blb = Blob.valueOf('Test,Jan,2001,3,l\nTest1,Feb,2001,4,k');
              System.Debug('<<<<blb>>>>>'+blb);
                obj.contentFile = blb;
                NCR_FI_User_ManagementController.parseCSV('"test1""', False);
                NCR_FI_User_ManagementController.parseCSV('test1"', False);
                obj.nameFile ='test';
                obj.Results();
                obj.lstwrp = wrpobjlst;
                obj.saveUserDetails();
                PageReference prObj = obj.CreatePDF();
               System.assert(prObj!=null);
         
    
         }  
        
      }