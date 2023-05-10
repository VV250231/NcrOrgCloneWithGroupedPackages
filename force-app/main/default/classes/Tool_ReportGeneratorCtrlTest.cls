@istest(SeeAlldata = true)
public class Tool_ReportGeneratorCtrlTest {
    
    
    static testmethod void testtheTool(){
        User u = [Select id , name,contactId from user Where isActive = true And contactID != null Limit 1];
        String test = u.contactid ;
        Blob myBlob = Blob.valueof(test);
        Tool_ReportGeneratorController c = new Tool_ReportGeneratorController();
        c.contentFile = myBlob;
        PageReference ref = c.fetchdetails();
        System.assert(ref!=null);
        c.getwrapperConAndUser();
    } 
}