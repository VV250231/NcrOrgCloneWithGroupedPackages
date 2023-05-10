public class Tool_ReportGeneratorController {
    
    public List<User> userList{get;set;}
    Public List<Contact> contactList{get;set;}
    public Blob contentFile { get; set; }  
    /*Public Tool_ReportGeneratorController(){
     
     // userList = [Select id , Name, Email , contactId, Contact.AccountId  ,contact.web_Portal_login__c , contact.Account.Master_customer_number__c,Profile.name  From User Where Profile.name IN ('Gold Partner User - Engineer','Gold Partner User - Engineer & Equipment','Gold Partner User - Equipment','Gold Partner User – Intl Engineer','Gold Partner User – Intl Engineer & Equipment','Gold Partner User – Intl Equipment' )];
        
     } commented empty statement block*/
     
     public Pagereference fetchdetails(){
      If(contentFile != null){
      String fileString = contentFile.toString();  
      List<String> indiviualRecordList = fileString.split('\n');
      List<String> indiviualRecord = new List<String>();
      for(String s : indiviualRecordList ){
      indiviualRecord.add(s.trim());
      }
      System.debug('fileString ' + indiviualRecord )  ;
      map<id,contact> contactmap = new map<id,contact>();
      IF(indiviualRecordList[0].startsWith('003')){
       contactmap = new map<id,contact>([Select id , FirstName,LastName,Email,web_Portal_login__c,Account.Master_customer_number__c,Active_Partner_Contact__c from Contact where Id in:indiviualRecord ]);
     }
     else{
     contactmap  = new map<id,contact>([Select id , FirstName,LastName,Email,web_Portal_login__c,Account.Master_customer_number__c,Active_Partner_Contact__c from Contact where Web_portal_Login__c in:indiviualRecord ]);
     }
      List<User> userList = new list<User>( [Select id ,contactId, isActive,FederationIdentifier from User Where ContactId  in:indiviualRecord  ]);
      Map<id , User> conUsermap =  new Map<id , User>();
      for(user u : userList){
          conUsermap.put(u.contactId ,u);
      }
      for(Contact con :contactmap.values() ){
          wrapperConAndUser wr = new wrapperConAndUser();
          wr.Con = con;
          If(conUsermap.containsKey(con.id)){
              wr.u = conUsermap.get(con.id);
          }
          lst.add(wr);
      }
      
            }
            
            System.debug('lst'+ lst);
            PageReference ref = Page.Tool_ReportGenerator;
            ref.setRedirect(false);
     return ref;
     
     }
     public class wrapperConAndUser{
         public Contact con{get;set;}
         public User u{get;set;}
     }
     
     
     List<wrapperConAndUser> lst = new List<wrapperConAndUser>();
     public List<wrapperConAndUser> getwrapperConAndUser(){
         return lst;
     
     }
    
}