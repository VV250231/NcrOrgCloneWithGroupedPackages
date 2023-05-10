trigger PRM_MDFExpenseDetailTrigger on MDF_Expense_Detail__c (Before Insert, After Insert, After Update, After Delete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        // Populate Approved Reimbursement Limit(NCR_Estimated_Participation__c) as a 50% of Estimated Cost(Estimated_Cost__c)
        for (MDF_Expense_Detail__c mdfRec : Trigger.New) {
            if (mdfRec.Estimated_Cost__c != null) {
                mdfRec.NCR_Estimated_Participation__c = mdfRec.Estimated_Cost__c * .5 ;
            }          
        }
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
        /* This trigger Rollup some currency fields from MDF Expense Detail to MDF Request and Claim Record. 
     Please add new changes and chage date in comment as well.
  */
  
  Set<Id> MDFReqIdSet   = new Set<Id>();
  Set<Id> MDFClaimIdSet = new Set<Id>();
  Boolean isChanged = false;
  
  if (Trigger.isInsert || Trigger.isUpdate) {
    for (MDF_Expense_Detail__c detail : Trigger.New) {
      MDFReqIdSet.add(detail.MDF_Request__c );
      MDFClaimIdSet.add(detail.Fund_Claim__c);
    }
  }
  
  if (Trigger.isDelete) {
    for (MDF_Expense_Detail__c detail : Trigger.old) {
      MDFReqIdSet.add(detail.MDF_Request__c );
      MDFClaimIdSet.add(detail.Fund_Claim__c);
    }
  }
  
  // Fetch associated MDF requests
  Map<Id,SFDC_MDF__c> idToMdfReqMap = new Map<Id,SFDC_MDF__c>([SELECT Id, Amount__c, Total_Actual_Cost__c,Total_Anticipated_Expense__c, Total_Estimated_Cost__c, Total_NCR_Approved__c, Total_NCR_Estimated_Participation__c FROM SFDC_MDF__c WHERE Id IN : MDFReqIdSet]);
  
  //Fetch associated MDF claims
  Map<Id,SFDC_MDF_Claim__c> idToMdfClaimMap = new Map<Id,SFDC_MDF_Claim__c>([SELECT Id, Amount__c, Actual_Total_Cost__c FROM SFDC_MDF_Claim__c WHERE Id IN: MDFClaimIdSet ]);
  
  // Calculate Estimated Matrics and store the result on MDF request Records 
  AggregateResult[] groupedResults = [
      SELECT 
          MDF_Request__c, SUM(Estimated_Cost__c) TotalEstimatedCost, SUM(NCR_Estimated_Participation__c) TotalEstimatedPart,
          SUM(NCR_Approved__c) TotalNCRApproved, SUM(Actual_Cost__c) TotalActualCost 
      FROM MDF_Expense_Detail__c 
      WHERE MDF_Request__c IN : MDFReqIdSet 
      GROUP BY MDF_Request__c 
  ];
                                      
  
  List<SFDC_MDF__c> MDFReqList = new List<SFDC_MDF__c>();
  
  Map<Id,AggregateResult> MDFReqIdToAggRes = new Map<Id,AggregateResult>();
 
  
  for (AggregateResult ar : groupedResults)  {
    if (ar.get('MDF_Request__c') != null) {
      MDFReqIdToAggRes.put((Id)ar.get('MDF_Request__c'), ar);
    }
  }
  
  for (SFDC_MDF__c rec : idToMdfReqMap.values()) {
    isChanged = false;
    
    // If Aggregate result not exist for the MDF request, It means no MDF detail records.
    if (MDFReqIdToAggRes.get(rec.Id) == null) {
      if (rec.Total_Actual_Cost__c != 0 || rec.Total_Anticipated_Expense__c != 0 || rec.Total_Estimated_Cost__c != 0 || rec.Total_NCR_Approved__c != 0 || rec.Amount__c != 0 || rec.Total_NCR_Estimated_Participation__c != 0) {
        rec.Total_Actual_Cost__c                 = 0;
        rec.Total_Anticipated_Expense__c         = 0;
        rec.Total_Estimated_Cost__c              = 0;
        rec.Total_NCR_Approved__c                = 0;
        rec.Amount__c                            = 0;
        rec.Total_NCR_Estimated_Participation__c = 0;
        isChanged = true;
      }
    } else {
      AggregateResult ar = MDFReqIdToAggRes.get(rec.Id);
      if (rec.Total_Actual_Cost__c != (Decimal)ar.get('TotalActualCost')) {
        rec.Total_Actual_Cost__c                 = (Decimal)ar.get('TotalActualCost');
        isChanged = true;
      }
      
      if (rec.Total_Anticipated_Expense__c != (Decimal)ar.get('TotalEstimatedPart')) {
        rec.Total_Anticipated_Expense__c = (Decimal)ar.get('TotalEstimatedPart');
        isChanged = true;
      }
      
      if (rec.Total_Estimated_Cost__c != (Decimal)ar.get('TotalEstimatedCost')) {
        rec.Total_Estimated_Cost__c  = (Decimal)ar.get('TotalEstimatedCost');
        isChanged = true;
      }
      
      if (rec.Total_NCR_Approved__c != (Decimal)ar.get('TotalNCRApproved')) {
        rec.Total_NCR_Approved__c = (Decimal)ar.get('TotalNCRApproved');
        isChanged = true;
      }
      
      if (rec.Amount__c != (Decimal)ar.get('TotalNCRApproved')) {
        rec.Amount__c= (Decimal)ar.get('TotalNCRApproved');
        isChanged = true;
      }
      
      if (rec.Total_NCR_Estimated_Participation__c != (Decimal)ar.get('TotalEstimatedPart')) {
        rec.Total_NCR_Estimated_Participation__c = (Decimal)ar.get('TotalEstimatedPart');
        isChanged = true;
      }
    }
    if (isChanged) {
        MDFReqList.add(rec);
    }
  }
  
  
  if (MDFReqList.size() > 0) { 
    update MDFReqList;
  }
  
  
  //Calculate Actual Matrics and store the result on claim record
  groupedResults.clear();
  
  groupedResults = [SELECT Fund_Claim__c, SUM(Actual_Cost__c) ActulaTotalCost, SUM(NCR_Approved__c) TotalNCRApproved FROM MDF_Expense_Detail__c WHERE Fund_Claim__c IN : MDFClaimIdSet GROUP BY Fund_Claim__c];
  
  List<SFDC_MDF_Claim__c> claimsToUpdateList = new List<SFDC_MDF_Claim__c>();
  
  Map<Id,AggregateResult> claimIdToAggRes  = new Map<Id,AggregateResult>();
  
  for (AggregateResult ar : groupedResults)  {
    if (ar.get('Fund_Claim__c') != null) {
      claimIdToAggRes.put((Id)ar.get('Fund_Claim__c'), ar);
    }
  }
  
  for (SFDC_MDF_Claim__c rec : idToMdfClaimMap.values()) {
    isChanged = false;
    
     if (claimIdToAggRes.get(rec.Id) == null) {
       if (rec.Actual_Total_Cost__c != 0 || rec.Amount__c != 0) {
         rec.Actual_Total_Cost__c = 0;
         rec.Amount__c            = 0;
         isChanged = true;
       }
     } else {
        AggregateResult ar = claimIdToAggRes.get(rec.Id);
        
        if (rec.Actual_Total_Cost__c != ((Decimal) ar.get('ActulaTotalCost'))) {
          rec.Actual_Total_Cost__c = ((Decimal) ar.get('ActulaTotalCost')) ;
          isChanged = true;
        }
      
        if (rec.Amount__c != ((Decimal) ar.get('TotalNCRApproved'))) {
          rec.Amount__c = ((Decimal) ar.get('TotalNCRApproved')) ;
          isChanged = true;
        }
      }
      
      if (isChanged) {
        claimsToUpdateList.add(rec);
      }
  }
  
  if (claimsToUpdateList.size() > 0) {
    update claimsToUpdateList;
  }
 
    }
    
}