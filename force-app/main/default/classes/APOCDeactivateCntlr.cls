public class APOCDeactivateCntlr {
    public static Id userId {get;set;}
    public static List<List<wrap>> wrapLst {get;set;}
    public APOCDeactivateCntlr(){
        System.debug(ApexPages.currentPage().getParameters().get('Id'));
        System.debug(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id')));
        //userId = ApexPages.currentPage().getParameters().get('Id');
        userId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id'));
        List<ASM_Role_Hierarchy__c> APOCL = new List<ASM_Role_Hierarchy__c>();
        try{
            APOCL = [select Role_User_Name__r.Manager.Isactive,Role_User_Name__c,User_Name__c,Role_Name__c,Role_User_Qlook_Id__c,Account__c,id,Role_User_Name__r.ManagerId,Role_User_Name__r.Manager.Email,Account_Name__c,Master__c from ASM_Role_Hierarchy__c where Role_User_Name__c  =:userId and Role_User_Name__c!=null order by Role_User_Name__c];         
        }catch(Exception ex){
            System.debug('Exception Occured'+ex.getMessage());
        }
        if(!APOCL.isEmpty()){ 
            Map<String,String> CAQLidM = new Map<String,String>();
            List<wrap> wLst= new List<wrap>();
            for(ASM_Role_Hierarchy__c ar : APOCL){
                if(ar.Role_Name__c=='Customer Advocate'){
                    CAQLidM.put(ar.Role_User_Qlook_Id__c.toLowerCase(),null);   
                }
            }
            for(CA_Hierarchy__c ca : [SELECT CA_QuicklookId__c, Manager1_Quicklookid__c FROM CA_Hierarchy__c where CA_QuicklookId__c in:CAQLidM.keySet() ]){
                CAQLidM.put(ca.CA_QuicklookId__c.toLowerCase(),ca.Manager1_Quicklookid__c.toLowerCase());
            }
            Map<String,user> qlidusrM = new Map<String,user>();
            for(User usr : [select id,email,quicklook_id__c from User where quicklook_id__c in: CAQLidM.values() and isactive=true and quicklook_id__c!=null]){
                qlidusrM.put(usr.quicklook_id__c.toLowerCase(),usr);
            }
            Map<String,user> CAqlidusrM = new Map<String,user>();
            for(String qlid : CAQLidM.keyset()){
                CAqlidusrM.put(qlid,qlidusrM.get(CAQLidM.get(qlid)));
            }
            for(ASM_Role_Hierarchy__c ar : APOCL){
                if(CAqlidusrM.get(ar.Role_User_Qlook_Id__c.toLowerCase())!=null){
                    wLst.add(new wrap(ar.User_Name__c,ar.Role_User_Qlook_Id__c,ar,true));
                }else{
                    if(ar.Role_User_Name__r.ManagerId!=null&& !(ar.Role_User_Name__r.Manager.Isactive)){
                        wLst.add(new wrap(ar.User_Name__c,ar.Role_User_Qlook_Id__c,ar,true));
                    }else{
                        wLst.add(new wrap(ar.User_Name__c,ar.Role_User_Qlook_Id__c,ar,false)); 
                    }
                }
            }
            wrapLst = new List<List<wrap>>();
            for(Integer j = 0 ; j < (wLst.size() / 1000)+1 ; j++){
                List<wrap> wList = new List<wrap>();
                for(Integer k=(j*1000);(k<(j*1000)+1000) && k<wLst.size() ; k++){
                    wList.add(wLst[k]);
                }
                wrapLst.add(wList);
            }
        }
    }
    public class wrap{
        public String UserName{get;set;}
        public String QuicklookId{get;set;}
        public ASM_Role_Hierarchy__c accSup {get;set;}
        public String  retiredDate {get;set;}
        public Boolean isMngr{get;set;}
        public wrap(String UserName,String QuicklookId,ASM_Role_Hierarchy__c acc,Boolean isMngr){
            this.UserName = UserName;
            this.QuicklookId = QuicklookId;
            retiredDate = Datetime.now().format('MMM dd,yyyy');
            this.accSup= acc;
            this.isMngr =isMngr;
        }
    }
    
}