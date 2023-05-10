public with sharing class MDFExpenseDetailExt {
    
    private SFDC_MDF__c mdfRequest;
    public  String pageMode {get;set;}
    public  List<MDF_Expense_Detail__c> mdfExpenseDetailList {get;set;}
    private ApexPages.StandardController sc;
    private List<MDF_Expense_Detail__c> mdfExpenseDetailToDelList ; 
    
    public Boolean isEditable {get;set;}
    
    public MDFExpenseDetailExt (ApexPages.StandardController sc) {
    	isEditable = false;
        this.sc = sc;
        pageMode = 'view';
        mdfExpenseDetailToDelList = new List<MDF_Expense_Detail__c>();
        
        mdfExpenseDetailList = [SELECT Id,MDF_Request__c, Fund_Claim__c,  Estimated_Cost__c, NCR_Estimated_Participation__c,
                                Actual_Cost__c,NCR_Approved__c,Actvity__c FROM MDF_Expense_Detail__c
                                WHERE MDF_Request__c =: sc.getId() LIMIT 500
                               ];
                               
       List<SFDC_MDF_Claim__c> lstFundClaim = [Select Id from SFDC_MDF_Claim__c where Fund_Request__c =: sc.getId() and Status__c Not IN ('Created', 'Rejected')];
       isEditable = !lstFundClaim.isEmpty();
       
        Profile objProfile = [Select Id, Name from Profile where Id=: UserInfo.getProfileId()];
        
        CAM_and_TAM_Profile_Name__c objCS = CAM_and_TAM_Profile_Name__c.getInstance(objProfile.Name);
        
        Boolean isNotEditAccess = objCS != null;
       	isEditable = !isNotEditAccess && isEditable;
    }
    
    // Return MDF Request
    public SFDC_MDF__c  getMdfRequest() {
        if (mdfRequest == null) {
            List<SFDC_MDF__c> mdfRequestList = [SELECT Id, Total_Estimated_Cost__c, Total_NCR_Estimated_Participation__c, 
                                                Status__c, Total_Actual_Cost__c, Total_NCR_Approved__c, CAM__c, RCL__c 
                                                FROM SFDC_MDF__c WHERE id =: sc.getId() LIMIT 1
                                               ];
            
            if (mdfRequestList.size() > 0) {
                //get request record
                mdfRequest = mdfRequestList[0] ;
            } else {
                return null;
            }
        }
        
        return mdfRequest;
    }
    
    
    // Opens Page in edit mode
    public void editMode() {
        pageMode = 'edit';
    }
    
    // Cancel editing and open page in view mode
    public void cancelEditing() {
        pageMode = 'view';
    }
    
    // Delete Expense Detail
    public void deleteExpenseDetail() {
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        MDF_Expense_Detail__c del = mdfExpenseDetailList.remove(rowIndex);
        
        if (del.Id != null) {
            mdfExpenseDetailToDelList.add(del);
        }
    }
    
    // Save Expense Detail. If new record is added, insert the record in DB else update existing one.
    public void saveExpenseDetail() {
        //try {
        	for(MDF_Expense_Detail__c objED : mdfExpenseDetailList)
        	{
        		if(objED.Estimated_Cost__c < objED.NCR_Approved__c)
        		{
        			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'NCR Approved amount can not be greater than Estimated Cost'));
        			return;
        		}
        		if(objED.Estimated_Cost__c < objED.NCR_Estimated_Participation__c)
        		{
        			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Approved Reimbursement Limit should not be greater than Estimated Cost.'));
        			return;
        		}
        	}
            upsert mdfExpenseDetailList;
            
            if (mdfExpenseDetailToDelList.size() > 0) {
                delete mdfExpenseDetailToDelList;
            } 
            pageMode = 'view';
            
            // Refetch MDF Request once again because changes in MDF expense detail changes rollup field on MDF request
            // record and to show updated values we have to refetch MDF request.
            
            mdfRequest = null ;
            
        /*} catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }*/
    }
    
    public boolean isOpsTeamMember {
        get {
            isOpsTeamMember = false;
            List<Group> qIdList = [select id from Group where type='Queue' AND Name='Channel Operation Team' Limit 1];
            if (qIdList.size() > 0) {
                // find out all the member of group, which can be userId or other groupId as well.
                List <GroupMember> grpMemberList = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = : qIdList[0].Id];
                
                // Check either loged in user is a member of operation team or not.(Directly or indirectly)
                Set<Id> gmIdSet = new Set<Id>();
                for (GroupMember gm : grpMemberList) {
                    gmIdSet.add(gm.UserOrGroupId);
                }
                // Directly
                if (gmIdSet.contains(UserInfo.getUserId())) {
                    return true;
                }
                //Indirectly
                List <GroupMember> userGroupList = [SELECT Group.name, Group.Id FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId() AND Group.Type = 'Queue'];      
                // If he is not member of any group than it means he is not member of queue as well, return false;
                if (! (grpMemberList.size() > 0)) {
                    return false ;
                } else {
                    for (GroupMember gm : userGroupList) {
                        if (gmIdSet.contains(gm.GroupId)) {
                            return true;
                        }
                    } 
                }
                
            } else {
                return false;
            }
            return isOpsTeamMember;
        } set;
    }
}