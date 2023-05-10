/*
####################################################################################################################
# Project Name..........: BPM Automation                                                                                                                      
# File............................:CalculateContingentHierarchy.cls                                                             
# Created by................: Varsha Pal                                                                      
# Created Date...........: 09-02-2021                                                                                
# Last Modified by......: Varsha Pal                                                                           
# Last Modified Date..: 09-02-2021                                                                               
# Description...............: This class calculates Contingent Manager Hierarchy of all Contingent workers and store
							  it in CA Hierarchy Object.
####################################################################################################################
*/

public class CalculateContingentHierarchy implements Database.Batchable < sObject > , Database.Stateful, schedulable {
    Map <String,String> EmpMap = new Map <String,String> (); // Map -> Key = Global_Id__c of User : Value = Contingent_Manager__c of user(global id of contingent hierachy) - Both values are coming from workday(NIAM team) on NCR_Employee_Detail__c object
    Map <String,String> empNameMap = new Map <String,string> (); // Map -> Key = Global_Id__c from NCR_Employee_Detail__c : Value = User_name__c from NCR_Employee_Detail__c
    Map<String,String> empQlMap = new Map<String,String>(); // Map -> Key = Global_Id__c from NCR_Employee_Detail__c : Value = Quicklook_ID__c from NCR_Employee_Detail__c
    String msgBody='Contingent Manager Hierarchy Batch Failed. Please check Apex Jobs.';
   
    public Database.QueryLocator start(Database.BatchableContext BC) {
        for (NCR_Employee_Detail__c emp: [Select Id, User_Name__c, Quicklook_ID__c, Global_ID__c, Contingent_Manager__c,Manager_Global_ID__c from NCR_Employee_Detail__c where inactive__c = false and Employee_type__c!=null limit 50000]) {
            empNameMap.put(emp.global_id__c, emp.User_Name__c);
            empQlMap.put(emp.Global_ID__c,emp.Quicklook_ID__c);
            if (emp.Contingent_Manager__c!=null){
                EmpMap.put(emp.global_id__c, emp.Contingent_Manager__c);
            }else if(emp.global_id__c!=emp.Manager_Global_ID__c) {
               EmpMap.put(emp.global_id__c, emp.Manager_Global_ID__c); 
            }
        }
        return Database.getQueryLocator([Select Role_User_Qlook_Id__c,User_Name__c from ASM_Role_hierarchy__c where Role_User_Name__r.isactive=true and Role_Name__c='Customer Advocate']);
    }

    public void execute(Database.BatchableContext BC, List<ASM_Role_hierarchy__c> CAList) {
        try{
            Map<String,List <String>> qlIdHrchyMap = new Map<String,List <String>>();//Map -> Key = Quicklook_ID__c from User :Value = reporting hierarchy of the user    
            Set<String> qlSet = new Set<String>();
            Map<String,String> actvUsr = new Map<String,String>();
            for(ASM_Role_hierarchy__c a: CAList){
                actvUsr.put(a.Role_User_Qlook_Id__c.toLowerCase(),a.User_Name__c);
            }
            for (NCR_Employee_Detail__c u: [Select Id, Quicklook_ID__c, Global_ID__c  from NCR_Employee_Detail__c where inactive__c = false and Quicklook_ID__c in:actvUsr.keyset()]) {
                List <String> hrchy = new List < String > ();
                String H = u.global_id__c;
                hrchy.add(H);
                while (EmpMap.get(H) != null && String.isNotEmpty(EmpMap.get(H)) && !(hrchy.size()>5)){
                    hrchy.add(EmpMap.get(H));
                    H = EmpMap.get(H);
                }
                if (hrchy != null && hrchy.size() > 0) {
                    qlIdHrchyMap.put(u.Quicklook_ID__c.toLowerCase(),hrchy);
                }
            }
            List<CA_Hierarchy__c> caLst = new List<CA_Hierarchy__c>();
            List<CA_Hierarchy__c> caLst1 = new List<CA_Hierarchy__c>();
            Set<String> qlids = new Set<String>();
            for(CA_Hierarchy__c ca : [Select id,CA_QuicklookId__c from CA_Hierarchy__c where CA_QuicklookId__c in: qlIdHrchyMap.keyset() ]){
                String ql = ca.CA_QuicklookId__c.toLowerCase(); 
                qlids.add(ql);
                if(actvUsr.get(ql)!=null){
                    if(qlIdHrchyMap.get(ql)!=null){
                        List<String> hrchy= qlIdHrchyMap.get(ql);
                        CA_Hierarchy__c c = ca;
                        caLst.add(setHierarchy(ql,c,hrchy));
                    }
                }else{
                    caLst1.add(ca);
                }
            }
            for(String ql: actvUsr.keyset()) {
                if(!qlids.contains(ql)){
                    if(qlIdHrchyMap.get(ql)!=null){
                        List<String> hrchy= qlIdHrchyMap.get(ql);
                        CA_Hierarchy__c c = new CA_Hierarchy__c();
                        c.CA_Name__c = actvUsr.get(ql);
                        c.CA_QuicklookId__c = ql;
                        caLst.add(setHierarchy(ql,c,hrchy));
                    }
                }
            }
            System.debug('caLst'+caLst);
            if(!caLst.isEmpty()){
                upsert caLst;    
            }
            if(!caLst1.isEmpty()){
                delete caLst1;
            }
            msgBody = 'SUCCESS';
        }catch(Exception ex){
            msgBody = 'Contingent Manager Hierarchy Batch Process has failed due to '+ex.getMessage()+' at Line number '+ex.getLineNumber();
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(!msgBody.contains('failed')){
            delete [Select id,CA_QuicklookId__c from CA_Hierarchy__c where lastmodifieddate !=today];
        }
       	if(msgBody.contains('failed')||Test.isRunningTest()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(BPM_Configuration__c.getValues('CAHierarchyJobReciever').values__c.split(','));
            //Changes done by Yogesh - related to Story EBA_SF-1919
            //ail.setOrgWideEmailAddressId('0D270000000XZHr');
             Id OrgId= NSCCommonInfoUtil.getIdOf('CCH_OrgId');
            //End changes by Yogesh
            mail.setOrgWideEmailAddressId(OrgId);
            mail.setPlainTextBody(msgBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
                    });
        }
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new CalculateContingentHierarchy());
    }
    public CA_Hierarchy__c setHierarchy(String qlId,CA_Hierarchy__c c, List<String> hrchy){
        Integer hsize = hrchy.size();
        if(hsize>=5){
            c.Manager1_Name__c = empNameMap.get(hrchy.get(1));
            c.Manager2_Name__c = empNameMap.get(hrchy.get(2));
            c.Manager3_Name__c = empNameMap.get(hrchy.get(3));
            c.Manager4_Name__c = empNameMap.get(hrchy.get(4));
            
            c.Manager1_Quicklookid__c = empQlMap.get(hrchy.get(1));
            c.Manager2_Quicklookid__c = empQlMap.get(hrchy.get(2));
            c.Manager3_Quicklookid__c = empQlMap.get(hrchy.get(3));
            c.Manager4_Quicklookid__c = empQlMap.get(hrchy.get(4));
        }
        if(hsize==4){
            c.Manager1_Name__c = empNameMap.get(hrchy.get(1));
            c.Manager2_Name__c = empNameMap.get(hrchy.get(2));
            c.Manager3_Name__c = empNameMap.get(hrchy.get(3));
            
            c.Manager1_Quicklookid__c = empQlMap.get(hrchy.get(1));
            c.Manager2_Quicklookid__c = empQlMap.get(hrchy.get(2));
            c.Manager3_Quicklookid__c = empQlMap.get(hrchy.get(3));
        }
        if(hsize==3){
            c.Manager1_Name__c = empNameMap.get(hrchy.get(1));
            c.Manager2_Name__c = empNameMap.get(hrchy.get(2));
            
            c.Manager1_Quicklookid__c = empQlMap.get(hrchy.get(1));
            c.Manager2_Quicklookid__c = empQlMap.get(hrchy.get(2));
        }
        if(hsize==2){
            c.Manager1_Name__c = empNameMap.get(hrchy.get(1));
            c.Manager1_Quicklookid__c = empQlMap.get(hrchy.get(1));
        }
        return c;
    }
}