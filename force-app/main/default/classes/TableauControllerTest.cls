@isTest
public class TableauControllerTest {
    @testSetup static void setup() {
        TableauPortalAdmin_config__c tc=new TableauPortalAdmin_config__c( Answer__c='test', Carousal_Description__c='test',RecordTypeId=Schema.SObjectType.TableauPortalAdmin_config__c.getRecordTypeInfosByName().get('GSA Team Member').getRecordTypeId(), Carousal__c=1.0, Corousal_Header__c='test', Dashboard_Type__c='Compensation', Description__c='test', Email__c='test@test.com', Frequency__c='Weekly', GSA_Team_Member_Name__c='test', GSA_Team_Role__c='test', Question__c='test', Report_Name__c='test', Report_Owner__c='test', Report_URL__c='test', Sort_Order__c=1,image_Name__c='test');
       // TableauPortalAdmin_config__c tc1=new TableauPortalAdmin_config__c( Answer__c='test', Carousal_Description__c='test',RecordTypeId=Schema.SObjectType.TableauPortalAdmin_config__c.getRecordTypeInfosByName().get('faq').getRecordTypeId(), Carousal__c=2.0, Corousal_Header__c='test', Dashboard_Type__c='Compensation', Description__c='test', Email__c='test@test.com', Frequency__c='Weekly', GSA_Team_Member_Name__c='test', GSA_Team_Role__c='test', Question__c='test', Report_Name__c='test', Report_Owner__c='test', Report_URL__c='test', Sort_Order__c=2,image_Name__c='test');
        TableauPortalAdmin_config__c tc2=new TableauPortalAdmin_config__c( Answer__c='test', Carousal_Description__c='test',RecordTypeId=Schema.SObjectType.TableauPortalAdmin_config__c.getRecordTypeInfosByName().get('Carousal').getRecordTypeId(), Carousal__c=3.0, Corousal_Header__c='test', Dashboard_Type__c='Compensation', Description__c='test', Email__c='test@test.com', Frequency__c='Weekly', GSA_Team_Member_Name__c='test', GSA_Team_Role__c='test', Question__c='test', Report_Name__c='test', Report_Owner__c='test', Report_URL__c='test', Sort_Order__c=3,image_Name__c='test');
        List<TableauPortalAdmin_config__c> tcl=new List<TableauPortalAdmin_config__c>();
        tcl.add(tc);
       // tcl.add(tc1);
        tcl.add(tc2);
        insert tcl;
    }
    
    
    @isTest static void testgetReports(){
        
        String dashBoardType='Compensation';
        List<TableauPortalAdmin_config__c> reports =new List<TableauPortalAdmin_config__c>();     
        reports=[Select id, Report_Name__c, Report_Owner__c, Frequency__c, Description__c, Report_URL__c from TableauPortalAdmin_config__c where Dashboard_Type__c=:DashboardType];
        
        system.debug(reports);
        List<TableauPortalAdmin_config__c> Returnreport =new List<TableauPortalAdmin_config__c>(); 
        Returnreport= TableauPortalController.getReports(dashBoardType) ; 
        system.debug('@@@@@'+Returnreport);
    }
    @isTest static void testgetCarousalInfo(){
        
        List<TableauPortalAdmin_config__c> c =new List<TableauPortalAdmin_config__c>(); 
        c= TableauPortalController.getCarousalInfo();
        
        
    }
    @isTest static void testgetfaqs(){
        
        List<TableauPortalAdmin_config__c> faqs =new List<TableauPortalAdmin_config__c>();  
        
        faqs = TableauPortalController.getfaqs();
        
        
    }
    @isTest static void testgetteam(){
        List<TableauPortalAdmin_config__c> teams =new List<TableauPortalAdmin_config__c>(); 
        teams= TableauPortalController.getteam();
        system.debug(teams);
        
    }
    @isTest static void testsubmitMessage(){
        
        String name='testName';
        String email='testEmail@abc.com';
        String message='testMessage';
        Tableau_Portal_Feedback__c tf=new Tableau_Portal_Feedback__c(name__c=name, email__c=email, message__c=message);
        TableauPortalController.submitMessage(name, email, message) ;
        
    }
    @isTest static void testloggedInAs(){
        user userList=new user();
        userList =TableauPortalController.loggedInAs();
        system.debug('@@@@'+userList);
        
    }
    
}