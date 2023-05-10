@isTest
public class TestTableauWorkbook_Connectoller{
    static testMethod void testMethod1(){
    
 /* ########################################################################################################## */          
         TableauWorkbookURL__c testobj =new TableauWorkbookURL__c ();
          
          testobj.TableauServerAddress__c = '';
          testobj.VisualforcePageURL__c = '';
          testobj.Workbook1Name__c = '';
          testobj.Workbook2Name__c = '';
          testobj.Workbook3Name__c = '';
          testobj.Workbook4Name__c = '';
          testobj.Workbook5Name__c = '';
          
          testobj.Workbook1URL__c = '';
          testobj.Workbook2URL__c = '';
          testobj.Workbook3URL__c = '';
          testobj.Workbook4URL__c = '';
          testobj.Workbook5URL__c = '';
          
        
         insert testobj;
  /* ########################################################################################################## */ 
  
          Test.startTest();
          PageReference myVfPage = Page.Tableau_Workbooks_HomePage;
          Test.setCurrentPage(myVfPage);
          System.currentPageReference().getParameters().put('id',testobj.id);
          Tableaupagecontroller testController = new Tableaupagecontroller();
          Test.StopTest();
          System.assert(myVfPage!=null);
  /* ########################################################################################################## */          
     }
}