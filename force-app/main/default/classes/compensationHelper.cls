/*
##################################################################################################
# Project Name..........: ARCS 2013
# File............................: compensationHelper.cls
# Version.....................: 23.0
# Created by................: Darshan Singh Farswan
# Created Date...........: 11-12-2012
# Last Modified by......: Darshan Singh Farswan
# Last Modified Date..: 02-01-2013
# Description...............: Class that checks for record duplicacy.
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
################################################################################################
*/

public without sharing class compensationHelper{
	public static Map<Id, Boolean> errorMap = new Map<Id, Boolean>();
    public static Boolean checkDuplicate(Map<String, List<List<Date>>>datesMap, String currentOPID,  Date startDate, Date endDate){
        Boolean Flag = FALSE;
        for(String role : datesMap.KeySet()){
            if(role == currentOPID ||currentOPID == 'All' || role == 'ALL'){
                for(Integer i=0; i<datesMap.get(role).size(); i++){
                    if(!((datesMap.get(role).get(i).get(1) == null && endDate < datesMap.get(role).get(i).get(0))|| (datesMap.get(role).get(i).get(1) != null &&  endDate < datesMap.get(role).get(i).get(0)) || (datesMap.get(role).get(i).get(1) != null &&  startDate > datesMap.get(role).get(i).get(1)))){
                        Flag = TRUE;
                    }   
                }
            }
        }
        return Flag;
    }

    @future
    public static void createRecords(List<String> recordDetails){
    	List<Sales_Compensation_Notification__c> insertRecords = new List<Sales_Compensation_Notification__c>();
    	for(String record : recordDetails){
    		String[] details = record.split(':', -1);
    		String ManagerQLID = details.get(3);
    		String managerName = details.get(4);
    		String oldJobCode = details.get(5);
    		String newJobCode = details.get(6);
    		String oldJobRole = details.get(7);
    		String newJobRole = details.get(8);
    		if(ManagerQLID == null || ManagerQLID.equalsIgnoreCase('null')){
    			ManagerQLID = '';
    		}
    		if(managerName == null || managerName.equalsIgnoreCase('null')){
    			managerName = '';
    		}
    		if(oldJobCode == null || oldJobCode.equalsIgnoreCase('null')){
    			oldJobCode = '';
    		}
    		if(newJobCode == null || newJobCode.equalsIgnoreCase('null')){
    			newJobCode = '';
    		}
    		if(oldJobRole == null || oldJobRole.equalsIgnoreCase('null')){
    			oldJobRole = '';
    		}
    		if(newJobRole == null || newJobRole.equalsIgnoreCase('null')){
    			newJobRole = '';
    		}
    		Sales_Compensation_Notification__c SCM = new Sales_Compensation_Notification__c (
    			Action__c = details.get(0),
    			Sales_Person_Quicklook_ID__c = details.get(1),
    			Sales_Person__c = details.get(2),
    			Manager_QuicklookID__c = ManagerQLID,
    			Manager_Name__c = managerName,
    			Previous_Job_Code__c = oldJobCode,
    			Job_Code__c = newJobCode,
    			Previous_ARCS_Job_Family__c = oldJobRole,
    			ARCS_Job_Family__c = newJobRole,
    			Role_Change_Date__c = System.Today(),
    			Sales_Persons_Country_Code__c = details.get(9),
    			Notified__c = FALSE,
    			Notified_On__c = null,
    			QuicklookId_Action__c = details.get(1) + details.get(0));
    			
    		insertRecords.add(SCM);
    	}
    	upsert insertRecords QuicklookId_Action__c;
    	List<Sales_Compensation_Notification__c> notifications = [SELECT Id, Action__c, Sales_Person_Quicklook_ID__c, Sales_Person__c, Previous_Job_Code__c, Job_Code__c, Previous_ARCS_Job_Family__c, ARCS_Job_Family__c, Role_Change_Date__c, Notified__c, Manager_Name__c, Manager_QuicklookID__c, Sales_Persons_Country_Code__c from Sales_Compensation_Notification__c where Notified__c = FALSE];
        System.debug('darshan'+notifications);
    }
}