public class TableauPortalController {
    @AuraEnabled
    public static List<TableauPortalAdmin_config__c> getReports(String DashboardType) {
        
         List<TableauPortalAdmin_config__c> reports =new List<TableauPortalAdmin_config__c>();        
        reports=[Select id, Report_Name__c, Report_Owner__c, Frequency__c, Description__c, Report_URL__c from TableauPortalAdmin_config__c where Dashboard_Type__c=:DashboardType];
       
        return reports;
        
    } 
    @AuraEnabled 
    public static List<TableauPortalAdmin_config__c> getCarousalInfo() {
        
         List<TableauPortalAdmin_config__c> c =new List<TableauPortalAdmin_config__c>();        
        c=[Select id, Carousal_Description__c, Corousal_Header__c, image_Name__c from TableauPortalAdmin_config__c where RecordType.Name='Carousal' order by Carousal__c limit 5];
       
        return c;
        
    } 
    @AuraEnabled
    public static List<TableauPortalAdmin_config__c> getfaqs() {
        
        List<TableauPortalAdmin_config__c> faqs =new List<TableauPortalAdmin_config__c>();        
        faqs=[Select id, Question__c, Answer__c from TableauPortalAdmin_config__c where RecordType.Name='faq'];
        return faqs;
        
    } 
     @AuraEnabled
    public static List<TableauPortalAdmin_config__c> getteam() {
        
        List<TableauPortalAdmin_config__c> teams =new List<TableauPortalAdmin_config__c>();        
        teams=[Select id, GSA_Team_Member_Name__c, GSA_Team_Role__c, Email__c from TableauPortalAdmin_config__c where RecordType.Name='GSA Team Member' order by Sort_Order__c];
        return teams;
        
    }
     @AuraEnabled
    public static void submitMessage(String name, String email, String message) {
        
        Tableau_Portal_Feedback__c tf=new Tableau_Portal_Feedback__c(name__c=name, email__c=email, message__c=message);
        insert tf;
        
    }
     @AuraEnabled
    public static User loggedInAs() {
        return [Select email, Name, usertype from User where id=:UserInfo.getUserId()];
        
    }
    
    
}