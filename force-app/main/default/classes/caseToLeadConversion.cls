public class caseToLeadConversion {    
    /*@AuraEnabled
    public static List<sObject> searchExistingLead(String leademail){        
         List<sObject> returnlist= new List<sObject>();
        String Query='Select id,email,Name from Lead where email = :leademail LIMIT 1';
        String QueryContact='Select id,Email,Name from Contact where Email = :leademail LIMIT 1';
        List<sObject> Leadlist=Database.Query(Query);
        List<sObject> Contactlist=Database.Query(QueryContact);
        System.debug('@@@'+Leadlist);
        if(Leadlist.size() > 0)
        	{ returnlist = Leadlist; }   
        else if (Contactlist.size() > 0)
        	{ returnlist = Contactlist; }
     
        return returnlist;
    }*/
    @AuraEnabled
    public static List<sObject> searchExistingLead(String leademail){
        List<sObject> returnlist= new List<sObject>();
        String Query='Select id,email,Name from Lead where email = :leademail LIMIT 1';
       	List<sObject> Leadlist=Database.Query(Query);       
        System.debug('@@@@'+Leadlist);
        if(Leadlist.size() > 0)
        	{ returnlist = Leadlist; }           
        return returnlist;
    }
    @AuraEnabled
    public static List<sObject> searchExistingContact(String contactemail){
        List<sObject> returnlist= new List<sObject>();
       // String Query='Select id,email,Name from Lead where email = :leademail LIMIT 1';
        String QueryContact='Select id,Email,Name from Contact where Email = :contactemail LIMIT 1';
       // List<sObject> Leadlist=Database.Query(Query);
        List<sObject> Contactlist=Database.Query(QueryContact);  
        System.debug('@@@@@@'+Contactlist);
        if (Contactlist.size() > 0)
        	{ returnlist = Contactlist; }     
        return returnlist;
    }
}