public class TcktReqHandlr {
    /*NumberOfTcktsAvailable Trigger method starts*/
	
    public static list<Ticket_Request_Event__c> getTcktReqEvnt(){
        return [Select id, name,Number_of_Parking_Passes_Available__c, Event_Name_Date__c, Event_Type__c, No_Of_Tickets_Available__c,
                                                   Lower_Level_Tickets_Available__c, Suite_Tickets_Available__c, VVIP_Tickets_Available__c
                                                   from Ticket_Request_Event__c];
    }
    public static void updtTcktReq(List<Ticket_Request_Event__c> tcktReqLst){
        if (tcktReqLst != null && tcktReqLst.size() > 0) {
            update tcktReqLst;
        }
    }
    //Logic for Update
    public static void manageNbrOfTcktsOnUpdt(List<Ticket_Request__c> trList, Map<Id,Ticket_Request__c> trOldMap){
		String SuiteTickets,VVIPtickets,LowerLevel,AllAvlblTickets;
	 	map<String,Integer> mpEventNameDate = new map<String,Integer>();
        list<Ticket_Request_Event__c> tcktReqLst=new list<Ticket_Request_Event__c>();
        list<Ticket_Request_Event__c> tcktReqEvntBU=getTcktReqEvnt();
        for(Ticket_Request__c tr : trList) {
                Ticket_Request__c oldTR = trOldMap.get(tr.Id);
                if((tr.Approval_Status__c == 'Submitted' && oldTR.Approval_Status__c != 'Submitted') ) {
                    for(Ticket_Request_Event__c tre : tcktReqEvntBU) {
                        if(tr.Event_Name_Date__c == tre.Event_Name_Date__c ) {
                            //Start Changes By Nagendra
                            if(tr.Number_of_Parking_Passes_Available__c != null &&  tre.Number_of_Parking_Passes_Available__c == null) {
                                tr.addError(system.label.NoOfTckAvlb1);//There are no parking pass availble for this Event.
                            }
                            if( tr.Number_of_Parking_Passes_Available__c != null &&  tre.Number_of_Parking_Passes_Available__c != null) {
                                if(tre.Number_of_Parking_Passes_Available__c<tr.Number_of_Parking_Passes_Available__c){
                                    tr.addError(system.label.NoOfTckAvlb2); //There are less parking pass availble for this Event.
                                }else{
                                    tre.Number_of_Parking_Passes_Available__c =tre.Number_of_Parking_Passes_Available__c - tr.Number_of_Parking_Passes_Available__c;
                                    
                                    mpEventNameDate.put(tr.Event_Name_Date__c ,Integer.valueOf(tr.Number_of_Parking_Passes_Available__c));
                                }
                            }
                            //End Changes By Nagendra
                            
                            if(tr.Ticket_Typ__c == 'Suite'){
                                tre.Suite_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Suite_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                
                                if(Integer.valueOf(tre.Suite_Tickets_Available__c)<0){
                                    tr.addError(system.label.NoOfTckAvlb3); //There are less tickets available than requested for Suite Tickets. Please change the number of requested tickets.
                                }
                            }
                            else if(tr.Ticket_Typ__c == 'Club'){
                                tre.VVIP_Tickets_Available__c = String.valueOf(Integer.valueof(tre.VVIP_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                
                                if(Integer.valueOf(tre.VVIP_Tickets_Available__c)<0){
                                    tr.addError(system.label.NoOfTckAvlb5);//There are less tickets available than requested for Other Tickets. Please change the number of requested tickets.
                                }
                            }
                            else if(tr.Ticket_Typ__c == 'Lower Level'){
                                tre.Lower_Level_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Lower_Level_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                
                                if(Integer.valueOf(tre.Lower_Level_Tickets_Available__c)<0){
                                    tr.addError(system.label.NoOfTckAvlb5);//There are less tickets available than requested for Other Tickets. Please change the number of requested tickets.
                                }
                            }
                            else{
                                if(tre.No_Of_Tickets_Available__c != null && tre.No_Of_Tickets_Available__c != '' && tr.No_of_Tickets_Requested__c != null && tr.No_of_Tickets_Requested__c!= '' ) {
                                    tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                }
                            }
                            tcktReqLst.add(tre);
                        }
                    }  
                }
                
                // Added by Divya for 2176
                if((tr.Approval_Status__c == 'Rejected' && oldTR.Approval_Status__c != 'Rejected') ) {
                    for(Ticket_Request_Event__c tre : tcktReqEvntBU) {
                        if(tr.Event_Name_Date__c == tre.Event_Name_Date__c ) {
                            //Start Changes By Nagendra
                            if(tr.Event_Name_Date__c == tre.Event_Name_Date__c){
                                if(tre.Number_of_Parking_Passes_Available__c !=null && tr.Number_of_Parking_Passes_Available__c != null){
                                    tre.Number_of_Parking_Passes_Available__c =tre.Number_of_Parking_Passes_Available__c + tr.Number_of_Parking_Passes_Available__c;
                                }
                                
                            }
                            //End Changes By Nagendra
                            
                            if(tr.Ticket_Typ__c == 'Suite'){
                                tre.Suite_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Suite_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c));
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                
                            }
                            else if(tr.Ticket_Typ__c == 'Club'){
                                tre.VVIP_Tickets_Available__c = String.valueOf(Integer.valueof(tre.VVIP_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c));
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                            }
                            else if(tr.Ticket_Typ__c == 'Lower Level'){
                                tre.Lower_Level_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Lower_Level_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c));
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                            }
                            else{
                                tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                            }
                            tcktReqLst.add(tre);
                        }
                    }  
                }
                
                // END Change , Divya 2176
    		}
    	updtTcktReq(tcktReqLst);
    }  
    //Logic for Insert
    public static void manageNbrOfTcktsOnInsrt(List<Ticket_Request__c> trList){
        String SuiteTickets,VVIPtickets,LowerLevel,AllAvlblTickets;
	 	map<String,Integer> mpEventNameDate = new map<String,Integer>();
        list<Ticket_Request_Event__c> tcktReqLst=new list<Ticket_Request_Event__c>();
        list<Ticket_Request_Event__c> tcktReqEvntBU=getTcktReqEvnt();
        for(Ticket_Request__c tr : trList) {
                if(tr.Ticket_Type__c == 'Admin Assigned') {
                    for(Ticket_Request_Event__c tre : tcktReqEvntBU) {
                        if(tr.Event_Name_Date__c == tre.Event_Name_Date__c) {
                            //Start Chnages By Nagendra
                            if(tr.Event_Name_Date__c == tre.Event_Name_Date__c){
                                if(tre.Number_of_Parking_Passes_Available__c<tr.Number_of_Parking_Passes_Available__c){
                                    tr.addError(system.label.NoOfTckAvlb2); //There are less parking pass availble for this Event.
                                }else{
                                    if(Integer.valueOf(tre.Number_of_Parking_Passes_Available__c) >= Integer.valueOf(tr.Number_of_Parking_Passes_Available__c) && Integer.valueOf(tr.Number_of_Parking_Passes_Available__c)>0 && tr.Number_of_Parking_Passes_Available__c != null)
                                        tre.Number_of_Parking_Passes_Available__c =tre.Number_of_Parking_Passes_Available__c - Integer.valueOf(tr.Number_of_Parking_Passes_Available__c);
                                    
                                }
                                
                            }
                            //End Changes By Nagendra
                            if(tr.Ticket_Typ__c == 'Suite'){
                                SuiteTickets = String.valueOf(Integer.valueof(tre.Suite_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                
                                if(Integer.valueOf(SuiteTickets)<0){
                                    tr.addError(system.label.NoOfTckAvlb3); //There are less tickets available than requested for Suite Tickets. Please change the number of requested tickets.
                                }else{
                                    tre.Suite_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Suite_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                    tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                }
                            }
                            else if(tr.Ticket_Typ__c == 'Club'){
                                VVIPtickets = String.valueOf(Integer.valueof(tre.VVIP_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                
                                if(Integer.valueOf(VVIPtickets)<0){
                                    tr.addError(system.label.NoOfTckAvlb4);//There are less tickets available than requested for Club Tickets. Please change the number of requested tickets
                                }   else{
                                    tre.VVIP_Tickets_Available__c = String.valueOf(Integer.valueof(tre.VVIP_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                    tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                }
                            }
                            else if(tr.Ticket_Typ__c == 'Lower Level'){
                                LowerLevel = String.valueOf(Integer.valueof(tre.Lower_Level_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                
                                if(Integer.valueOf(LowerLevel)<0){
                                    tr.addError(system.label.NoOfTckAvlb5);//There are less tickets available than requested for Other Tickets. Please change the number of requested tickets.
                                }else{
                                    tre.Lower_Level_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Lower_Level_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c));
                                    tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) - Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                }
                            }
                            else if(tr.Ticket_Typ__c == '' || tr.Ticket_Typ__c == null){
                                tr.addError(system.label.NoOfTckAvlb6); //look for custom label NoOfTckAvlb6
                            }
                            tcktReqLst.add(tre);
                        }
                    }
            }
        }
         updtTcktReq(tcktReqLst);
    }
    //Logic for Delete
    public static void manageNbrOfTcktsOnDlt(List<Ticket_Request__c> trList){
        String SuiteTickets,VVIPtickets,LowerLevel,AllAvlblTickets;
	 	map<String,Integer> mpEventNameDate = new map<String,Integer>();
        list<Ticket_Request_Event__c> tcktReqLst=new list<Ticket_Request_Event__c>();
        list<Ticket_Request_Event__c> tcktReqEvntBU=getTcktReqEvnt();
        for(Ticket_Request__c tr : trList) {
                if(tr.Approval_Status__c == 'Submitted'  ||tr.Approval_Status__c == 'Approved' || 
                   tr.Approval_Status__c == 'Got First Approval' ) {
                       for(Ticket_Request_Event__c tre : tcktReqEvntBU) {
                           if(tr.Event_Name_Date__c == tre.Event_Name_Date__c ) {
                               //Start Chnages By Nagendra
                               if(tr.Event_Name_Date__c == tre.Event_Name_Date__c){
                                   
                                   if(tre.Number_of_Parking_Passes_Available__c !=null && tr.Number_of_Parking_Passes_Available__c != null){
                                       tre.Number_of_Parking_Passes_Available__c =tre.Number_of_Parking_Passes_Available__c + tr.Number_of_Parking_Passes_Available__c;
                                   }
                                   
                               }
                               //End Changes By Nagendra
                               
                               if(tr.Ticket_Typ__c == 'Suite'){
                                   tre.Suite_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Suite_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c));
                                   tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                                   
                               }
                               else if(tr.Ticket_Typ__c == 'Club'){
                                   tre.VVIP_Tickets_Available__c = String.valueOf(Integer.valueof(tre.VVIP_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c));
                                   tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                               }
                               else if(tr.Ticket_Typ__c == 'Lower Level'){
                                   tre.Lower_Level_Tickets_Available__c = String.valueOf(Integer.valueof(tre.Lower_Level_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c));
                                   tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                               }
                               else{
                                   tre.No_Of_Tickets_Available__c =String.valueOf(Integer.valueof(tre.No_Of_Tickets_Available__c) + Integer.valueof(tr.No_of_Tickets_Requested__c)) ;
                               }
                               tcktReqLst.add(tre);
                           }
                       }  
                   }
            }
        updtTcktReq(tcktReqLst);
    }
    /*NumberOfTcktsAvailable Trigger method ends*/
    
    //OpportunityCampaignCodeTrigger logic written in this method starts here*/
    public static void setCampaingIdforOpp(List<Ticket_Request__c> trList,Map<Id,Ticket_Request__c> trOldMap){
        List<Id> lstId = new List<Id>();
        List<String> lstRltdOpp = new List<String>();
        List<Related_Campaign_Code__mdt> rcmdts=[SELECT MasterLabel, DeveloperName , Campaign_code__c FROM Related_Campaign_Code__mdt];
        String campaignCode;
        String eventType;
        for (Ticket_Request__c tr: trList) {
            Ticket_Request__c oldStatus = trOldMap.get(tr.Id);
            eventType=tr.Event_Type__c;
            if(null == eventType){
                eventType = tr.Event_Typ__c;
            }
            if('Approved' == tr.Approval_Status__c && 'Approved' != oldStatus.Approval_Status__c )
            {
                lstId.add(tr.id);
                
            }
        }  
        if(String.isNotBlank(eventType)){
            for(Related_Campaign_Code__mdt rmd:rcmdts){
                if(eventType==rmd.MasterLabel){
                    campaignCode=rmd.Campaign_code__c;
                }             
            }
        }
        if(lstId.size()>0){
            List<Junction_Ticket_Opportunity__c> a=[Select Related_Opprtunity_to_Request__r.Id,Related_Opprtunity_to_Request__r.Name from Junction_Ticket_Opportunity__c where Related_TicketRequest__c   IN : lstId];
            for(Junction_Ticket_Opportunity__c a1:a){
                lstRltdOpp.add(a1.Related_Opprtunity_to_Request__c);
                
            }
            if(lstRltdOpp.size()>0){
                List<Opportunity>  opps;
                List<Opportunity> lstOpp2Upadte=new List<Opportunity>();
                Campaign camp;
                try{
                    opps =  [select CampaignId, Name,Secondary_Campaign__c from Opportunity where id IN : lstRltdOpp ];
                }
                catch(Exception ex){
                    System.debug('Related Opportunity not found');  
                }
                try{
                    camp=[select id from Campaign where Name =:campaignCode ]; 
                }
                catch(Exception ex){
                    System.debug('Campaign code not found');
                }
                if(null!=camp){
                    for(Opportunity opp:opps){
                        if(null==opp.CampaignId ){
                            opp.CampaignId=camp.Id;
                            lstOpp2Upadte.add(opp);
                        }
                        else{
                            opp.Secondary_Campaign__c=camp.Id;
                            lstOpp2Upadte.add(opp);                    
                        }
                    }
                }
                Try{
                    update lstOpp2Upadte;   
                }
                catch(Exception ex)
                {
                    System.debug('Issue in Updating Opportunity'+ex);
                }
            }
        }
    }
    //OpportunityCampaignCodeTrigger logic written in this method ends here*/
}