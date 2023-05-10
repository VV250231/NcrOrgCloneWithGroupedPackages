/*
##################################################################################################
# Project Name && Request Num..........: Ticket Request Approval
# File............................: TicketRequest.cls                                                        
# Created by................: Mohammad Ahad                                                                   
# Created Date...........: 08/09/2017                                                                              
# Last Modified by......:  Mohammad Ahad
# Last Modified Date..: 08/09/2017
# Description...............: This class is used in Raise Ticket Request Component for Ticket Request Approval Project.
##################################################################################################
*/
public class TicketRequestController {
    
   
    
    
    @AuraEnabled
    public static list<Ticket_Request_Event__c> getEventNameandDate(){
        String num = '0';
        list<Ticket_Request_Event__c> EventswithDate = [ 
            Select id,Event_Type__c, Event_Name_Date__c, Event_Date__c, Lower_Level_Tickets_Available__c,Suite_Tickets_Available__c,VVIP_Tickets_Available__c,No_Of_Tickets_Available__c  from Ticket_Request_Event__c where  Event_Date__c >= Today and  (Lower_Level_Tickets_Available__c >: num or Suite_Tickets_Available__c >: num or VVIP_Tickets_Available__c >: num) and No_Of_Tickets_Available__c >:num   order by Event_Date__c ASC 
        ]; 
        system.debug('*******'+ EventswithDate);
        return EventswithDate;
        
    }
    @AuraEnabled
    public static Integer getAvailableTickets(String eventName){
        system.debug('eventName'+ eventName);
        String AvlblTckts = [ Select No_Of_Tickets_Available__c from Ticket_Request_Event__c where Event_Name_Date__c =: eventName
                            ].No_Of_Tickets_Available__c;
        
        Integer Tckts = Integer.valueOf(AvlblTckts);
        system.debug('$$$ ' + Tckts);
        return Tckts;
    }
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = 
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Ticket_Request__c' ];
        return listviews;
    }
    @AuraEnabled
    public static list<Ticket_Request__c> getSelectedValue(String RdId) {
        
         list<Ticket_Request__c> selectedValue = [ SELECT Id, Event_Typ__c,Phone_Number__c,Other_Employee_Reps_Attending__c,Additional_Info__c, Event_Name_Date__c, No_of_Tickets_Requested__c, Approval_Status__c,Ticket_Typ__c 
            FROM Ticket_Request__c 
            WHERE Id =:RdId ]; 
        system.debug('*******'+ selectedValue);
        return selectedValue;
        
     } 
    @AuraEnabled
    public static Integer getAvailableTicketsonEdit(String EventType, String EventName){
        system.debug('&&'+ EventType + '**'+EventName );
        String AvlblTckts = [ Select id,Event_Name_Date__c, Event_Type__c, No_Of_Tickets_Available__c from Ticket_Request_Event__c where 
                             Event_Type__c =: EventType AND Event_Name_Date__c =: EventName
                            ].No_Of_Tickets_Available__c;
        
        Integer Tckts = Integer.valueOf(AvlblTckts);
        return Tckts;
    }
    
   
    @AuraEnabled  
    public static boolean getUserIdPermissionSet() {
        
        list<PermissionSetAssignment> Pset = [SELECT PermissionSetId, PermissionSet.Name  FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Ticket_Request_Admin'];
        system.debug('Permission Set ' + Pset);
        boolean user_has_permission = false;
        for ( PermissionSetAssignment psa : Pset ) {
            System.debug('##psa.PermissionSet.Name' + psa.PermissionSet.Name);
            if ( psa.PermissionSet.Name.equals('Ticket_Request_Admin') ) {
                user_has_permission = true;
            }
        }
        return user_has_permission;
    }
    
    @AuraEnabled 
    Public static Map<String,List<String>> getTicketType(String Event_Selected){
            List<String> pickListValuesList= new List<String>();
            String EventSelected=  String.valueOf(Event_Selected);
            Map<String,Integer> TicketType_and_Avilibality= new Map<String,Integer>();
            Map<String,List<String>> TicketType_and_AvilibalityMap= new Map<String,List<String>>();
        try{
            
            String num = '0';            
            Ticket_Request_Event__c Obj=[Select id,Lower_Level_Tickets_Available__c,Suite_Tickets_Available__c,VVIP_Tickets_Available__c,No_Of_Tickets_Available__c from Ticket_Request_Event__c where Event_Name_Date__c =: EventSelected and (Lower_Level_Tickets_Available__c >: num or Suite_Tickets_Available__c >: num or VVIP_Tickets_Available__c >: num) and No_Of_Tickets_Available__c >:num];
            
                if(integer.valueof(Obj.VVIP_Tickets_Available__c) > 0)
                    TicketType_and_Avilibality.put('Club',integer.valueof(Obj.VVIP_Tickets_Available__c));
                    if(integer.valueof(Obj.Suite_Tickets_Available__c) > 0)
                    TicketType_and_Avilibality.put('Suite',integer.valueof(Obj.Suite_Tickets_Available__c));
                    if(integer.valueof(Obj.Lower_Level_Tickets_Available__c) > 0)
                    TicketType_and_Avilibality.put('Lower Level',integer.valueof(Obj.Lower_Level_Tickets_Available__c));
                
                    for(String s : TicketType_and_Avilibality.keySet()){
                        if(!TicketType_and_AvilibalityMap.containsKey(s)){
                            TicketType_and_AvilibalityMap.put(s,new List<String>());
                        }
                        Integer i=1; 
                        do{ 
                            TicketType_and_AvilibalityMap.get(s).add(string.valueof(i));
                             i++;  
                         }while(i<=TicketType_and_Avilibality.get(s));
                        
                 }
            
           
            
        }
            
       catch (Exception e) {
            throw new AuraHandledException('Oops!! Something went wrong: '
            + e.getMessage()); 
       }
            
         return TicketType_and_AvilibalityMap;   
            
        }
   @AuraEnabled
    public static Decimal getParkingPasses(String Event_Selected){
       return [select id,Number_of_Parking_Passes_Available__c from Ticket_Request_Event__c where  Event_Name_Date__c =: String.valueOf(Event_Selected)].Number_of_Parking_Passes_Available__c;
      
    }
    @AuraEnabled
    public static List<Wrapper> getEditModeParkingPasses(String RecordId,String Event_Selected){
       List<Wrapper> wplist = new List<Wrapper>();
        Decimal NumberOfParkingPasses= [select id,Number_of_Parking_Passes_Available__c from Ticket_Request__c where  Id =: RecordId].Number_of_Parking_Passes_Available__c;
        Wrapper wp1 = new Wrapper();
        wp1.NumberOfParkingPasses = NumberOfParkingPasses;
        wp1.TotalNumberOfPasses = getParkingPasses(Event_Selected);
        wplist.add(wp1);
        return wplist;
    }
    public class Wrapper{
        @AuraEnabled
        public Decimal TotalNumberOfPasses{get;set;}
        @AuraEnabled
        public Decimal NumberOfParkingPasses{get;set;}
    }
    //Skip Required Field for Kedell Reed Changes
    @AuraEnabled
    public static boolean isKendleReedLogin(){
        Boolean isKendleReed = false;
        if(UserInfo.getName() == 'Johnny Zizzo'){
            isKendleReed = true;
        }
       return isKendleReed;
      
     }
    //End od Skip Required Field for Kedell Reed Changes
    
    @AuraEnabled
    Public static String  processToCreateRecord(Ticket_Request__c TcktObj){
       
            try {
               TcktObj.Related_Account__r = null;
               insert TcktObj;
               system.debug('<><><><>'+TcktObj.Id); 
            } catch (Exception e) {   
                //handle error
                system.debug('<>::::::'+e);
            }
        return TcktObj.Id;
        
    }

    /*
    @AuraEnabled
    Public Static List<Contact> GetSelectedContact(String RecordId){
       List<Contact> ContactList = new List<Contact>(); 
       List<String> SelectedConactid = new List<String>();
       List<Junction_Ticket_Contact__c> JunctionTicketObj= [Select id,Related_Contact__c,Related_Ticket_Request__c from Junction_Ticket_Contact__c where Related_Ticket_Request__c =:RecordId];
        for(Junction_Ticket_Contact__c Obj:JunctionTicketObj){
            SelectedConactid.add(Obj.Related_Contact__c);
        } 
        
       return [Select Id,Name From Contact where id IN : SelectedConactid];
    }
    
    
    @AuraEnabled
    Public Static List<Opportunity> GetSelectedOpportunity(String RecordId){
       List<Contact> ContactList = new List<Contact>(); 
       List<String> SelectedConactid = new List<String>();
       List<Junction_Ticket_Opportunity__c> JunctionTicketObj= [Select id,Related_Opprtunity_to_Request__c,Related_TicketRequest__c from Junction_Ticket_Opportunity__c where Related_TicketRequest__c =:RecordId];
        for(Junction_Ticket_Opportunity__c Obj:JunctionTicketObj){
            SelectedConactid.add(Obj.Related_Opprtunity_to_Request__c);
        } 
        
       return [Select Id,Name From Opportunity where id IN : SelectedConactid];
    }
    
    @AuraEnabled
    Public Static void UpdateTicketRequest(Ticket_Request__c TcktObj,List<Junction_Ticket_Contact__c> contactToInsert , List<Junction_Ticket_Opportunity__c> OpprtunityToInsert){
          try {
               
               List<Junction_Ticket_Contact__c>  TempContactJunction=[Select id,Related_Contact__c,Related_Ticket_Request__c from Junction_Ticket_Contact__c where Related_Ticket_Request__c =:TcktObj.Id];
               List<Junction_Ticket_Opportunity__c> TempOpportuniyJunction=[Select id,Related_Opprtunity_to_Request__c,Related_TicketRequest__c from Junction_Ticket_Opportunity__c where Related_TicketRequest__c =:TcktObj.Id];
                
                  if(TempContactJunction.size()>0){ 
                      Delete TempContactJunction;
                  }
                     
                  if(TempOpportuniyJunction.size() > 0){
                      Delete TempOpportuniyJunction;
                  }
              
                Update TcktObj;
              
                if(contactToInsert.size()>0)
                insert contactToInsert;
              
                if(OpprtunityToInsert.size()>0)
                insert OpprtunityToInsert;
          }
          catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                throw new AuraHandledException('Darn it! Something went wrong: '
                    + e.getMessage());    
          }
            
    }  */
    
    
    @AuraEnabled
    Public Static void UpdateTicketRequest(Ticket_Request__c TcktObj){
          try {           
            Update TcktObj;
          }
          catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                throw new AuraHandledException('Darn it! Something went wrong: '
                    + e.getMessage());    
          }
            
    }
     @AuraEnabled
    public static String getPhoneNumber(){
        User u = [SELECT Phone from User where Id =:UserInfo.getUserId()];
       // User u = null;
        if(u!=null){
            return u.phone;
        }
        else{
            return null;
        }
    }
}