public with sharing class MDFExpenseDetailExtClaim {
  
  private SFDC_MDF_Claim__c mdfClaim;
  public  String pageMode {get;set;}
  public  List<MDF_Expense_Detail__c> mdfExpenseDetailList {get;set;}
  private ApexPages.StandardController sc;
  private List<MDF_Expense_Detail__c> mdfExpenseDetailToDelList ; 
  
  public MDFExpenseDetailExtClaim (ApexPages.StandardController sc) {
   
    this.sc = sc;
    pageMode = 'view';
    mdfExpenseDetailToDelList = new List<MDF_Expense_Detail__c>();
      
    mdfExpenseDetailList = [SELECT Id,MDF_Request__c, Fund_Claim__c,  Estimated_Cost__c, NCR_Estimated_Participation__c,
                            Actual_Cost__c,NCR_Approved__c,Actvity__c FROM MDF_Expense_Detail__c
                            WHERE Fund_Claim__c =: sc.getId() LIMIT 500
                           ];
  }
  
  // Return MDF Request
  public SFDC_MDF_Claim__c  getMdfClaim() {
    if (mdfClaim == null) {
      List<SFDC_MDF_Claim__c> mdfClaimList = [SELECT Id, Actual_Total_Cost__c, Amount__c, Fund_Request__r.Total_Estimated_Cost__c, Fund_Request__r.Total_NCR_Estimated_Participation__c
                                          FROM SFDC_MDF_Claim__c WHERE id =: sc.getId() LIMIT 1
                                         ];
                                       
      if (mdfClaimList.size() > 0) {
       //get request record
        mdfClaim = mdfClaimList[0] ;
      } else {
          return null;
      }
    }
    
    return mdfClaim;
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
    try {
      upsert mdfExpenseDetailList;
      
      if (mdfExpenseDetailToDelList.size() > 0) {
        delete mdfExpenseDetailToDelList;
      } 
      pageMode = 'view';
      
      // Refetch MDF Request once again because changes in MDF expense detail changes rollup field on MDF request
      // record and to show updated values we have to refetch MDF request.
      
      mdfClaim = null ;
      
    } catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
    }
  }
  
  
  
}