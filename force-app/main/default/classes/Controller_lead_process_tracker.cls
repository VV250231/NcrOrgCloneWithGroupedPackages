public class Controller_lead_process_tracker {
    @auraEnabled
    public static List<string> load_lead(string query){  
        List<string> returnvalue = new List<string>();
        List<Lead_progress_tracker_dependencies__c> dependentlist = Lead_progress_tracker_dependencies__c.getall().values();
        if(dependentlist.size()>0){
            for(Lead_progress_tracker_dependencies__c t : dependentlist){
                if(query == 'nurt' && t.status__c == 'Nurture'){
                    returnvalue.add(t.DependentField__c);
                }
                else if(query == 'disq' && t.status__c == 'Disqualified'){
                    returnvalue.add(t.DependentField__c);
                }
            }
        }
        return returnvalue;
    }
    /* ##############################################################################   */
    @auraEnabled
    public static List<string> get_dependent_fieldvalue(string query){
        List<string> returnvalue = new List<string>();
        List<string> pickVal = new List<string>();
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        Schema.DescribeFieldResult fieldResult ;
        if(query == 'nurtISR' ){fieldResult  = lead.Return_to_Nurture_Reason__c.getDescribe();
                               }
        if(query == 'nurt' ){fieldResult  = lead.Return_to_Nurture_Reason__c.getDescribe();
                            }
        else if(query == 'disq'){
            fieldResult = lead.Disqualified_Reason__c.getDescribe();
        }
        if(query == 'disqISR'){
            fieldResult = lead.Disqualified_Reason__c.getDescribe();
        }
        ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) { 
            pickVal.add(f.getLabel());
        }
        for(String str:pickVal){
            if(str.length()>40 && (query == 'nurtISR' || query == 'disqISR')){
                returnvalue.add(str); 
            }else if(str.length()<40 && (query == 'nurt' || query == 'disq')){
                returnvalue.add(str);
            }
        }
        return returnvalue;
    }
    /* ##############################################################################   */
    @auraEnabled
    public static list<trackerwrapper> get_tracker_details(id recordid){
        system.debug('recordid is : '+recordid);
        List<trackerwrapper> returnvalue = new List<trackerwrapper>();
        Set<string> stage_set = new Set<string>();
        List<string> lead_status_picklists = get_lead_status_picklist() ;
        Map<String, Lead_progress_tracker__c> lead_progress_cs =  return_progress_cs_map(); 
        Map<id,Lead_progress_tracker__c> lead_progress_mp = new Map<id,Lead_progress_tracker__c>() ;
        Map<string,string> lead_history = new Map<string,string>();
        Map<string,integer> lead_num_days = new Map<string,integer>();
        Map<string,Map<string,date>> old_status_date = new  Map<string,Map<string,date>>();
        Map<string,integer> status_days = new Map<string,integer>();
        
        lead l = [select id,status,Lead_Stage__c,CreatedDate,LastModifiedDate,CATM_Record__c,
                  (select oldvalue,newvalue,CreatedDate from Histories) from lead where id=:recordid ORDER BY LASTMODIFIEDDATE ASC][0] ;
        
        for(leadhistory h : l.Histories){
            if(string.valueOf(h.oldvalue) != string.valueOf(h.newvalue)){
                
                if(lead_status_picklists.contains(string.valueOf(h.oldvalue))){
                    lead_history.put(string.valueOf(h.oldvalue),string.valueOf(h.oldvalue));
                }
            }
        }
        
        old_status_date =  get_old_status_stage_dependecies(l);
        
        
        status_days = get_status_stage_dependecies(old_status_date, l);
        
        for(Lead_progress_tracker__c l_cs : Lead_progress_tracker__c.getall().values()){
            lead_progress_mp.put(l_cs.id,l_cs);
        }
        if(integer.valueOf(lead_progress_cs.get(l.status).Name) == 100 ){ 
            // disqualified
            returnvalue = return_greyedvalues(l,lead_status_picklists,lead_progress_cs,lead_progress_mp,lead_history,status_days);
        }
        else if(integer.valueOf(lead_progress_cs.get(l.status).Name) == 101 ){ 
            //nurture
            returnvalue = return_greyedvalues(l,lead_status_picklists,lead_progress_cs,lead_progress_mp,lead_history,status_days);
        }
        else { 
            //lead in progress
            returnvalue = return_progress_returnvalue(l,lead_status_picklists,lead_progress_cs,lead_progress_mp,lead_history, status_days);
        }
        
        return returnvalue;
    } 
    
    // ##################################################################################################################################### //
    public static List<string> get_lead_status_picklist(){
        
        List<SelectOption> options = new List<SelectOption>();
        List<string> lead_picklist = new List<string>() ;
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple) {
            lead_picklist.add(f.getValue());
        }       
        
        return lead_picklist;
    }
    
    // ##################################################################################################################################### //
    @auraEnabled
    public static string return_tooltipv(String status,Map<string,integer> status_days){
        return (status_days.containskey(status)) ? status_days.get(status)+' days' : 'NA' ;
    }
    
    // ##################################################################################################################################### //
    public static List<trackerwrapper> return_progress_returnvalue(Lead l,List<String> lead_status_picklists, Map<String, Lead_progress_tracker__c> lead_progress_cs,Map<id,Lead_progress_tracker__c> lead_progress_mp,Map<string,string> lead_history, Map<string,integer> status_days){
        List<trackerwrapper> returnvalue = new trackerwrapper[5];
        
        for(String fname : lead_status_picklists){
            system.debug('line 104 fname:'+fname);
            system.debug('line 104 lead_progress_cs:'+lead_progress_cs);
            if(lead_progress_cs.get(fname) != null && integer.valueOf(lead_progress_cs.get(fname).Name) != 100  && integer.valueOf(lead_progress_cs.get(fname).Name) != 101 ){
                if(fname == l.status ){
                    
                    //  system.debug('value of process map is (equal cond) : ' + integer.valueOf(lead_progress_cs.get(fname).Name));
                    //  system.debug('value of status is (equal cond) : ' + fname);
                    
                    trackerwrapper tw = new trackerwrapper();
                    tw.isCATMRecord = l.CATM_Record__c;
                    tw.stagename = l.status ;tw.stageid = integer.valueOf(lead_progress_cs.get(fname).Name)-1 ;
                    tw.if_nurt_disq = 'false' ;
                    tw.classname = '3' ; // 1 for  : slds-is-incomplete ### 2 for : slds-is-complete ### 3 for : slds-is-active
                    tw.tooltipv = return_tooltipv(tw.stagename,status_days);
                    returnvalue.add(integer.valueOf(lead_progress_cs.get(fname).Name)-1,tw);
                    
                }
                else if(fname != l.status 
                        && lead_progress_mp.get(lead_progress_cs.get(fname).id).Status1__c == fname 
                        && returnvalue.get(integer.valueOf(lead_progress_cs.get(fname).Name)-1) == null 
                        && (integer.valueOf(lead_progress_cs.get(fname).Name)-1) != (integer.valueOf(lead_progress_cs.get(l.Status).Name)-1)  ){
                            
                            //   system.debug('value of process map is (else cond): ' + integer.valueOf(lead_progress_cs.get(fname).Name));
                            //   system.debug('value of status is (else cond): ' + fname);
                            
                            trackerwrapper tw = new trackerwrapper();
                            tw.isCATMRecord = l.CATM_Record__c;
                            // tw.stagename = lead_progress_mp.get(lead_progress_cs.get(fname).id).Status1__c ;
                            tw.stagename = get_old_status(l,fname,lead_progress_cs,lead_progress_mp,lead_history);
                            tw.stageid = integer.valueOf(lead_progress_cs.get(fname).Name)-1 ;
                            tw.if_nurt_disq = 'false' ;
                            tw.classname = (((integer.valueOf(lead_progress_cs.get(fname).Name))-1) < ((integer.valueOf(lead_progress_cs.get(l.status).Name))-1) ) ? '2' : '1' ;
                            tw.tooltipv = return_tooltipv(tw.stagename,status_days);
                            returnvalue.add(integer.valueOf(lead_progress_cs.get(fname).Name)-1,tw);
                            
                        }
            }
            
        }
        
        return returnvalue;
        
    }
    
    // ##################################################################################################################################### //
    public static string get_old_status(Lead l,String fname, Map<String, Lead_progress_tracker__c> lead_progress_cs,Map<id,Lead_progress_tracker__c> lead_progress_mp,Map<string,string> lead_history){
        
        if(((integer.valueOf(lead_progress_cs.get(fname).Name))-1) < ((integer.valueOf(lead_progress_cs.get(l.status).Name))-1) ){
            
            if(lead_progress_mp.get(lead_progress_cs.get(fname).id).Status1__c!=null){for(string s : lead_history.keyset()){if(lead_progress_cs.get(fname).name == lead_progress_cs.get(s).name){ return s ; }}}
        }
        return lead_progress_mp.get(lead_progress_cs.get(fname).id).Status1__c ;
    }
    
    // ##################################################################################################################################### //
    public static List<trackerwrapper> return_greyedvalues(Lead l,List<String> lead_status_picklists, Map<String, Lead_progress_tracker__c> lead_progress_cs,Map<id,Lead_progress_tracker__c> lead_progress_mp,Map<string,string> lead_history, Map<string,integer> status_days){
        List<trackerwrapper> returnvalue = new trackerwrapper[5];
        
        for(String fname : lead_status_picklists){
            if(lead_progress_cs.get(fname) != null && integer.valueOf(lead_progress_cs.get(fname).Name) != 100 && integer.valueOf(lead_progress_cs.get(fname).Name) != 101 ){
                if(fname != l.status && lead_progress_mp.get(lead_progress_cs.get(fname).id).Status1__c == fname && returnvalue.get(integer.valueOf(lead_progress_cs.get(fname).Name)-1) == null && (integer.valueOf(lead_progress_cs.get(fname).Name)-1) != (integer.valueOf(lead_progress_cs.get(l.Status).Name)-1)  ){
                    
                    trackerwrapper tw = new trackerwrapper();tw.isCATMRecord = l.CATM_Record__c;tw.stagename = get_old_status(l,fname,lead_progress_cs,lead_progress_mp,lead_history) ;
                    tw.stageid = integer.valueOf(lead_progress_cs.get(fname).Name)-1 ;tw.if_nurt_disq = integer.valueOf(lead_progress_cs.get(l.status).Name) == 100 ? 'disq' : 'nurt' ;
                    tw.classname = '1' ;tw.tooltipnur =  return_tooltipv(integer.valueOf(lead_progress_cs.get(l.status).Name) == 100 ? 'Disqualified' : 'Nurture' ,status_days);
                    tw.tooltipv = return_tooltipv(tw.stagename,status_days);returnvalue.add(integer.valueOf(lead_progress_cs.get(fname).Name)-1,tw);
                    
                }
            }
            
            
        }
        return returnvalue;
        
    } 
    
    // ##################################################################################################################################### //
    public static  Map<String, Lead_progress_tracker__c> return_progress_cs_map(){
        
        Map<String, Lead_progress_tracker__c> lead_progress_cs = new Map<String, Lead_progress_tracker__c>(); 
        
        for(Lead_progress_tracker__c l_cs : Lead_progress_tracker__c.getall().values()){
            
            if(l_cs.Status1__c != null) { lead_progress_cs.put(l_cs.Status1__c,l_cs) ; } 
            if(l_cs.Status2__c != null) { lead_progress_cs.put(l_cs.Status2__c,l_cs) ; }
            if(l_cs.Status3__c != null) { lead_progress_cs.put(l_cs.Status3__c,l_cs) ; }
            if(l_cs.Status4__c != null) { lead_progress_cs.put(l_cs.Status4__c,l_cs) ; }
            if(l_cs.Status5__c != null) { lead_progress_cs.put(l_cs.Status5__c,l_cs) ; }
            if(l_cs.Status6__c != null) { lead_progress_cs.put(l_cs.Status6__c,l_cs) ; }
            if(l_cs.Status7__c != null) { lead_progress_cs.put(l_cs.Status7__c,l_cs) ; }
            if(l_cs.Status8__c != null) { lead_progress_cs.put(l_cs.Status8__c,l_cs) ; }
        }
        return lead_progress_cs ;
        
    }
    
    // ##################################################################################################################################### //
    public class trackerwrapper {
        @auraEnabled
        public string stagename { get; set; }
        @auraEnabled
        public string classname { get; set; }
        @auraEnabled
        public string if_nurt_disq { get; set; }
        @auraEnabled
        public string tooltipnur { get; set; }
        @auraEnabled
        public Decimal stageid { get ; set ; }
        @auraEnabled
        public string tooltipv { get ; set ; }
        
        @auraEnabled
        public boolean isCATMRecord {get; set;}
    }
    
    // ##################################################################################################################################### //
    public static  Map<string,Map<string,date>>  get_old_status_stage_dependecies(lead l ){
        
        List<string> lead_status_picklists = get_lead_status_picklist() ;
        Map<string,Map<string,date>> result_map = new Map<string,Map<string,date>>();
        
        for(leadhistory h : l.histories){
            //logic to get all the changed status values from lead history with the on-changed date
            if(string.valueOf(h.oldvalue) != string.valueOf(h.newvalue) && lead_status_picklists.contains(string.valueOf(h.oldvalue)) ){
                Map<string,date> sub_map = new Map<string,date>();sub_map.put('newvalue',date.valueOf(h.createddate));result_map.put(string.valueOf(h.oldvalue),sub_map);
            }
        }
        
        for(leadhistory h : l.histories){
            //logic to get all the changed status values from lead history with the on-changed date
            if(string.valueOf(h.oldvalue) != string.valueOf(h.newvalue) && lead_status_picklists.contains(string.valueOf(h.newvalue)) ){
                if(result_map.containskey(string.valueOf(h.newvalue))){
                    Map<string,date> sub_map = new Map<string,date>();sub_map.putall(result_map.get(string.valueOf(h.newvalue)));
                    sub_map.put('oldvalue',date.newinstance(h.createddate.year(),h.createddate.month(),h.CreatedDate.day()));
                    result_map.put(string.valueOf(h.newvalue),sub_map);
                }
                else if(string.valueOf(h.newvalue) == l.status){
                    Map<string,date> sub_map = new Map<string,date>();
                    sub_map.put('oldvalue',date.newinstance(h.createddate.year(),h.createddate.month(),h.CreatedDate.day()));
                    sub_map.put('newvalue',date.valueof(system.now()));result_map.put(string.valueOf(h.newvalue),sub_map);
                }
            }
        }
        
        // logic to get the first status, if status is changed and part of lead history
        for(string s : result_map.keyset()){
            if(!result_map.get(s).containskey('oldvalue') ){ Map<string,date> sub_map = new Map<string,date>();
                                                            sub_map.putall(result_map.get(s));sub_map.put('oldvalue',date.newinstance(l.createddate.year(),l.createddate.month(),l.CreatedDate.day()));result_map.put(s,sub_map); 
                                                           }
        }
        // logic if the lead history doesnot contain any status change... it means no status is changed on lead
        if(result_map.isempty()){
            Map<string,date> sub_map = new Map<string,date>();
            sub_map.put('oldvalue',date.newinstance(l.createddate.year(),l.createddate.month(),l.CreatedDate.day()));
            sub_map.put('newvalue',date.valueof(datetime.now()));
            result_map.put(l.Status,sub_map); 
        }
        return result_map ;
        
    }
    // ##################################################################################################################################### //
    // below method will find the difference between the old value and new value.
    public static map<string,integer> get_status_stage_dependecies( Map<string,Map<string,date>> old_status_date ,lead lh){
        
        map<string,integer> returnvalue = new map<string,integer>();
        List<string> lead_status_picklists = get_lead_status_picklist() ;
        
        for(String s: lead_status_picklists){
            
            if(old_status_date.containskey(s)){
                returnvalue.put(s,
                                old_status_date.get(s).get('oldvalue').daysbetween(old_status_date.get(s).get('newvalue'))
                               );
                
            }
            
        }
        return returnvalue;
    }
    @AuraEnabled
    public static Lead updateLead(Id recordId,String lStatus,String reason, String dsqRsnCmmnts){
        Lead leadRec = [SELECT Id, Status,Disqualified_Reason__c,Return_to_Nurture_Reason__c,CATM_Record__c FROM lead WHERE id=:recordId];
        String msg = '';
        try{            
            if(lStatus =='Nurture'){
                leadRec.Status ='Nurture';
                leadRec.Return_to_Nurture_Reason__c =reason;
                System.debug('@@No'+leadRec);
            }else if(lStatus == 'Disqualified'){leadRec.Status ='Disqualified';
                                                leadRec.Disqualified_Reason__c =reason;
                                                if(leadRec.CATM_Record__c) { 
                                                	leadRec.Disqualified_Reason_Comments__c = dsqRsnCmmnts;
                                                }
                                                System.debug('@@Yes'+leadRec);
                                               }
            update leadRec;
            
        }catch(DmlException e){
            //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
            //we can get from DmlException
            
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) { msg =+ e.getDmlMessage(i) +  '\n' ;
                                                        }throw new AuraHandledException(msg);
            
        }catch(Exception e){
            //throw all other exception message
            throw new AuraHandledException(e.getMessage());
        } 
        return leadRec;
    }
    
}