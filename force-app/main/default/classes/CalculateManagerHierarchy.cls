/*
####################################################################################################################
# Project Name..........: NSC CRM 2017                                                                                                                        
# File............................:CalculateManagerHierarchy.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 02-03-2017                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 28-01-2018                                                                                 
# Description...............: This class calculates Manager Hierarchy of all users.
####################################################################################################################
*/

global class CalculateManagerHierarchy implements Database.Batchable < sObject > , Database.Stateful {

    Map < String, String > EmpMap = new Map < String, String > ();
    Map < String, String > empgblIdNameMap = new Map < String, string >();
    String email;
    List <String> errLst = new List<string>();
    integer sccssCnt =0, errCnt = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        List < NCR_Employee_Detail__c > EmpList = [Select Id, User_Name__c, Quicklook_ID__c, Global_ID__c, Manager_Global_ID__c from NCR_Employee_Detail__c where inactive__c = false];

        for (NCR_Employee_Detail__c emp: EmpList) {
            empgblIdNameMap.put(emp.global_id__c, emp.User_Name__c);

            if (emp.global_id__c != emp.manager_global_id__c) {
                EmpMap.put(emp.global_id__c, emp.manager_global_id__c);
            }
        }

        if (Test.isRunningTest()) {
            return Database.getQueryLocator([SELECT Id, Name, Quicklook_ID__c, global_id__c, manager_global_id__c from User WHERE UserType = 'standard'
                AND isActive = True AND profileId = '00e70000000sR8W'
            ]);
        } else {
            return Database.getQueryLocator([SELECT Id, Name, Quicklook_ID__c, global_id__c, manager_global_id__c from User WHERE Quicklook_ID__c != null AND IsActive= true And (ProfileId != '00e70000000k6DaAAI' AND ProfileId != '00e70000000k6DGAAY' AND ProfileId != '00e70000000xVKPAA2')
            ]);
        }
    }

    global void execute(Database.BatchableContext BC, List < User > usrList) {

        List < User > updateUsrList = new List < User > ();
        
        try {
            for (User usrObj: usrList) {
                String H1;
                List < String > hierarchy = new List < String > ();
                H1 = usrObj.global_id__c;
                hierarchy.add(H1);
    
                while (EmpMap.get(H1) != null && String.isNotEmpty(EmpMap.get(H1))) {
                    hierarchy.add(EmpMap.get(H1));
                    H1 = EmpMap.get(H1);
                }
    
                user u = usrObj;
    
                if (hierarchy != null && hierarchy.size() > 0) {
                    if (hierarchy.size() == 10) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(6));
                        u.Region_VP__c = empgblIdNameMap.get(hierarchy.get(5));
                        u.Area_VP__c = empgblIdNameMap.get(hierarchy.get(4));
    
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Manager_Level_04__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Manager_Level_05__c = empgblIdNameMap.get(hierarchy.get(5));
                        u.Manager_Level_06__c = empgblIdNameMap.get(hierarchy.get(6));
                        
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                        u.Manager_Level_04_ID__c = hierarchy.get(4);
                        u.Manager_Level_05_ID__c = hierarchy.get(5);
                        u.Manager_Level_06_ID__c = hierarchy.get(6);
                    } else if (hierarchy.size() == 9) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(5));
                        u.Region_VP__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Area_VP__c = empgblIdNameMap.get(hierarchy.get(3));
    
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Manager_Level_04__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Manager_Level_05__c = empgblIdNameMap.get(hierarchy.get(5));
                        u.Manager_Level_06__c = empgblIdNameMap.get(hierarchy.get(6));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                        u.Manager_Level_04_ID__c = hierarchy.get(4);
                        u.Manager_Level_05_ID__c = hierarchy.get(5);
                        u.Manager_Level_06_ID__c = hierarchy.get(6);
                    } else if (hierarchy.size() == 8) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Region_VP__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Area_VP__c = empgblIdNameMap.get(hierarchy.get(2));
    
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Manager_Level_04__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Manager_Level_05__c = empgblIdNameMap.get(hierarchy.get(5));
                        u.Manager_Level_06__c = empgblIdNameMap.get(hierarchy.get(6));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                        u.Manager_Level_04_ID__c = hierarchy.get(4);
                        u.Manager_Level_05_ID__c = hierarchy.get(5);
                        u.Manager_Level_06_ID__c = hierarchy.get(6);
                    } else if (hierarchy.size() == 7) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Region_VP__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Area_VP__c = empgblIdNameMap.get(hierarchy.get(1));
    
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Manager_Level_04__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Manager_Level_05__c = empgblIdNameMap.get(hierarchy.get(5));
                        u.Manager_Level_06__c = empgblIdNameMap.get(hierarchy.get(6));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                        u.Manager_Level_04_ID__c = hierarchy.get(4);
                        u.Manager_Level_05_ID__c = hierarchy.get(5);
                        u.Manager_Level_06_ID__c = hierarchy.get(6);
                    } else if (hierarchy.size() == 6) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Region_VP__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Area_VP__c = empgblIdNameMap.get(hierarchy.get(0));
    
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Manager_Level_04__c = empgblIdNameMap.get(hierarchy.get(4));
                        u.Manager_Level_05__c = empgblIdNameMap.get(hierarchy.get(5));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                        u.Manager_Level_04_ID__c = hierarchy.get(4);
                        u.Manager_Level_05_ID__c = hierarchy.get(5);
                    } else if (hierarchy.size() == 5) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Region_VP__c = empgblIdNameMap.get(hierarchy.get(0));
                        u.Area_VP__c = u.Name;
    
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
                        u.Manager_Level_04__c = empgblIdNameMap.get(hierarchy.get(4));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                        u.Manager_Level_04_ID__c = hierarchy.get(4);
                    } else if (hierarchy.size() == 4) {
                        u.Division_VP__c = empgblIdNameMap.get(hierarchy.get(0));
                        u.Region_VP__c = u.Name;
                        u.Area_VP__c = u.Name;
                        
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
                        u.Manager_Level_03__c = empgblIdNameMap.get(hierarchy.get(3));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                        u.Manager_Level_03_ID__c = hierarchy.get(3);
                    } else if (hierarchy.size() == 3) {
    
                        u.Division_VP__c = u.Name;
                        u.Region_VP__c = u.Name;
                        u.Area_VP__c = u.Name;
                        
                        u.Manager_Level_01__c = empgblIdNameMap.get(hierarchy.get(1));
                        u.Manager_Level_02__c = empgblIdNameMap.get(hierarchy.get(2));
    
                        u.Manager_Level_01_ID__c = hierarchy.get(1);
                        u.Manager_Level_02_ID__c = hierarchy.get(2);
                    } else {
                        u.Division_VP__c = u.Name;
                        u.Region_VP__c = u.Name;
                        u.Area_VP__c = u.Name;
                    }
                }
    
                updateUsrList.add(u);
            }
    
            Database.SaveResult[] results = Database.update(updateUsrList,false);        
            
            if(results != null) {
                integer j = 0;
                for (Database.SaveResult sr : results) {                
                    if (!sr.isSuccess()) {
                        String errMsg = 'QuicklookId:' + updateUsrList[j].Quicklook_ID__c + ', Error :[';
                        
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += err.getStatusCode() + ':' + err.getMessage() + ','; 
                        }
                        errMsg = errMsg.removeEnd(',') + ']';  
                        errCnt++; errLst.add(errMsg);  
                    } else {
                    	sccssCnt++;		    
                    } 
					j++;
                }
        	}
        } catch(Exception e) {
            errCnt = errCnt + usrList.size(); 
            for(User u : usrList) {
            	 errLst.add('QuicklookId:' + u.Quicklook_ID__c + ', Error :[' + e.getMessage() + ']');    
            }   
        }
        
    }

    global void finish(Database.BatchableContext BC) {        
        String[] toAddresses = new String[] {
            'NI230017@ncr.com', 'pb185126@ncr.com'
        };
     
        String mailBdy = '<b>Total Users:</b>' + (sccssCnt + errCnt) + ', <b>Successfully updated users:</b>'  + sccssCnt + ',<b>Failed users:</b>' + errCnt + '<br/><br/>';
        String mailSub = '', mailHeader = '';
        
        if (errLst.size() > 0) {
            mailHeader = 'Manager Hierarchy Batch Process Failed';
            mailSub = 'Manager Hierarchy Batch Process Failed for ' +  errLst.size() + ' users';
        	for (String err : errLst) {
                mailBdy += err + '<br/>';    
            } 
            
        } else {
            mailHeader = 'Manager Hierarchy Batch Process completed Successfully';
        	mailSub = 'Manager Hierarchy Batch Process completed Successfully with ' + sccssCnt + ' update users';     
        }
      
        EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
        String EmailBody=template.HtmlValue;            
        CommonUtility.sendEmail(mailSub,mailHeader,mailSub,mailBdy,EmailBody,toAddresses); 
    }
}