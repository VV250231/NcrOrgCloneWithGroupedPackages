//for creating default PO and CA automatically on a new customer coming in contract using PO and CA Matrix object resp.
//Test Class name- BPM_Alert_Aging_HistoryTest
public class BPMAPOC_PORelation {
    public static Map<String,String> camatrix = new Map<String,String>();
    public static void assignPOToAccountFromTrigger(String bpmList){
        if(System.isFuture() || System.isBatch()){
            assignPOToAccount(bpmList);
        }else{                 
            assignPOToAccountFuture(bpmList);
        }
    }
    @future
    public static void assignPOToAccountFuture(String bpmList){
        assignPOToAccount(bpmList);
    }
    public static void assignPOToAccount(String bpmList){
        List<BPM_Annuity__c> newbpmList = (List<BPM_Annuity__c>)JSON.deserialize(bpmList, List<BPM_Annuity__c>.Class);
        Map<String,Account> masterAccMap = new Map<String,Account>();
        Map<String,BPM_Annuity__c> masterBpmMap = new Map<String,BPM_Annuity__c>();
        Set<Id> accountSet = new Set<Id>();
        for(BPM_Annuity__c bpmObj : newbpmList){
            if(bpmObj.Cust_Nbr_CH__c!=null){
                masterBpmMap.put(bpmObj.Cust_Nbr_CH__c,bpmObj);
            }
        }
        for(Account acc: [Select Master_Customer_Number__c from Account where Master_Customer_Number__c in :masterBpmMap.keyset()]){
            masterAccMap.put(acc.Master_Customer_Number__c,acc);   
        }
        /*for(BPM_Annuity__c bpmObj : newbpmList){
            if(!String.isBlank(bpmObj.Cust_Nbr_CH__c)){
                if(!masterAccMap.containsKey(bpmObj.Cust_Nbr_CH__c)){
                    bpmObj.addError('No Customer Account is present in System with provided Master Number '+bpmObj.Cust_Nbr_CH__c);
                }
            }
        }*/
        Map<String,String> pomatrix = new Map<String,String>();
        Map<String,ASM_Role_Hierarchy__c> roleMap = new Map<String,ASM_Role_Hierarchy__c>();
        Map<String,ASM_Role_Hierarchy__c> CAroleMap = new Map<String,ASM_Role_Hierarchy__c>();
        for(ASM_Role_Hierarchy__c role:[Select id,Role_Name__c,Master_Number__c from ASM_Role_Hierarchy__c where Master_Number__c in :masterBpmMap.keyset()]){
            roleMap.put(role.Master_Number__c,role);  
            if(role.Role_Name__c=='Customer Advocate'){
                CAroleMap.put(role.Master_Number__c,role);
            }
        }
       
        for(PO_Matrix__c pomat: [Select Country__c,Region__c,LOB__c,QuicklookId__c,Point_Of_Contact__c from PO_Matrix__c]){
            System.debug(pomat.LOB__c+pomat.Country__c+pomat.Region__c);
            if(pomat.LOB__c!=null&&pomat.Country__c!=null&&pomat.Region__c==null)
                pomatrix.put(pomat.LOB__c.tolowercase()+pomat.Country__c.tolowercase(),pomat.QuicklookId__c);
            else if(pomat.LOB__c!=null&&pomat.Region__c!=null)
                pomatrix.put(pomat.Region__c.tolowercase()+pomat.LOB__c.tolowercase(),pomat.QuicklookId__c);
            else if(pomat.Country__c!=null&&pomat.Region__c!=null)
                 pomatrix.put(pomat.Region__c.tolowercase()+pomat.Country__c.tolowercase(),pomat.QuicklookId__c);
            else
                pomatrix.put(pomat.Region__c.tolowercase(),pomat.QuicklookId__c);
                
        }
        for(CA_Matrix__c camat: [Select Country_Code__c,CA_QuicklookId__c from CA_Matrix__c]){
            if(camat.Country_Code__c!=null){
                camatrix.put(camat.Country_Code__c.tolowercase(),camat.CA_QuicklookId__c);
            }
        }
        System.debug('pomatrix'+pomatrix);
        List<ASM_Role_Hierarchy__c> roles = new List<ASM_Role_Hierarchy__c>();
        for(String master: masterAccMap.keyset()){
            if(!roleMap.containskey(master)){
                ASM_Role_Hierarchy__c role = new ASM_Role_Hierarchy__c();
                role.Master__c = master;
                role.Role_Name__c ='PO/Billing Person';
                String matchingCriteria='';
                if(masterBpmMap.containskey(master)){
                    if(masterBpmMap.get(master).Region__c!=null && masterBpmMap.get(master).Country_Code_C_BPM__c!=null ){
                        matchingCriteria = masterBpmMap.get(master).Region__c+masterBpmMap.get(master).Country_Code_C_BPM__c;
                        matchingCriteria = matchingCriteria.toLowerCase();
                    }
                    System.debug('matchingCriteria'+matchingCriteria);
                    if(pomatrix.containskey(matchingCriteria)){
                        role.QuickLook_ID__c = pomatrix.get(matchingCriteria);
                    }
                    else{
                        if(masterBpmMap.get(master).Region__c!=null && masterBpmMap.get(master).Industry_Group_Name_CH__c!=null ){
                            matchingCriteria = masterBpmMap.get(master).Region__c+masterBpmMap.get(master).Industry_Group_Name_CH__c;
                            matchingCriteria = matchingCriteria.toLowerCase();
                        }
                        
                        System.debug('matchingCriteria'+matchingCriteria);
                        if(pomatrix.containskey(matchingCriteria)){
                            role.QuickLook_ID__c = pomatrix.get(matchingCriteria);
                        }
                        else{
                            if(masterBpmMap.get(master).Industry_Group_Name_CH__c!=null && masterBpmMap.get(master).Country_Code_C_BPM__c!=null ){
                                matchingCriteria = masterBpmMap.get(master).Industry_Group_Name_CH__c+masterBpmMap.get(master).Country_Code_C_BPM__c;
                                matchingCriteria = matchingCriteria.toLowerCase();
                            }
                            
                            System.debug('matchingCriteria'+matchingCriteria);
                            if(pomatrix.containskey(matchingCriteria)){
                                role.QuickLook_ID__c = pomatrix.get(matchingCriteria);
                            }
                            else{
                                if(masterBpmMap.get(master).Region__c!=null){
                                    matchingCriteria = masterBpmMap.get(master).Region__c;
                                    matchingCriteria = matchingCriteria.toLowerCase();
                                }
                                System.debug('matchingCriteria'+matchingCriteria);
                                if(pomatrix.containskey(matchingCriteria)){
                                    role.QuickLook_ID__c = pomatrix.get(matchingCriteria);
                                }
                                else{
                                    role.QuickLook_ID__c = BPM_Configuration__c.getValues('BPMDefaultPOQLID').values__c;
                                    //role = new ASM_Role_Hierarchy__c();
                                    // masterBpmMap.get(master).addError('PO can not be found using PO matrix'); 
                                }
                            }
                        }
                    }
                    if(masterBpmMap.get(master).Country_Code_C_BPM__c!=null){
                        string ccode = masterBpmMap.get(master).Country_Code_C_BPM__c.toLowerCase();
                        roles.add(assignCA(ccode,master));
                    }
                }
                roles.add(role);
            }
            else if(caroleMap.get(master)==null){
                string ccode = masterBpmMap.get(master).Country_Code_C_BPM__c.toLowerCase();
                roles.add(assignCA(ccode,master));
            }
        }
        if(!roles.isEmpty()){
            database.insert(roles,false); 
        }
        
    }
    public static ASM_Role_Hierarchy__c assignCA(String ccode,String master){
        ASM_Role_Hierarchy__c role1 = new ASM_Role_Hierarchy__c();
        if(camatrix.get(ccode)!=null){
            role1.Master__c = master;
            role1.Role_Name__c ='Customer Advocate';
            role1.QuickLook_ID__c = camatrix.get(ccode);
        }
        return role1;
    }
}