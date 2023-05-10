/*************************************************************************************************
*   ClassName   : PRM_MdfClaimHandler
*   Description :   
*   Author      :   
# Modification History.: 
Story No         Date           DevName         Description
EBA_SF-1948     20-10-2022      KAVYA SREE      Technical Debt - Apex sharing violation part 2 -PRM 
*************************************************************************************************/
public without sharing class PRM_MdfClaimHandler {
    
    
    /* Update information on MDF request that How many claim is submitted for the request. */ 
    public void totalClaimCount(List<SFDC_MDF_Claim__c> claimList) {
        Set<Id> SFDCMDFIdSet = new Set<Id>();
        for (SFDC_MDF_Claim__c claim : claimList) {
            SFDCMDFIdSet.add(claim.Fund_Request__c);   
        }
        
        Map<Id,SFDC_MDF__c> idToMdfReqMap = new Map<Id,SFDC_MDF__c>([SELECT Id, No_of_Submitted_Claims__c FROM SFDC_MDF__c WHERE Id IN : SFDCMDFIdSet ]);
        
        AggregateResult[] agResultList =  [SELECT  COUNT(ID) submittedClaims,Fund_Request__c from SFDC_MDF_Claim__c WHERE Fund_Request__c IN : SFDCMDFIdSet AND (Status__c = 'Submitted' OR Status__c =  'Approved' OR Status__c = 'Rejected' OR Status__c = 'Paid')  GROUP BY Fund_Request__c ];
        
        Map<Id,AggregateResult> mdfReqIdToAggRes = new Map<Id,AggregateResult>();
        
        for(AggregateResult agResult : agResultList) {
            mdfReqIdToAggRes.put((Id)agResult.get('Fund_Request__c'),agResult);
        } 
        
        List<SFDC_MDF__c> MDFReqList = new List<SFDC_MDF__c>();
        
        for (SFDC_MDF__c fundReq : idToMdfReqMap.values()) {
            if (mdfReqIdToAggRes.get(fundReq.Id) != null) {
                if (fundReq.No_of_Submitted_Claims__c != (Decimal)(mdfReqIdToAggRes.get(fundReq.Id)).get('submittedClaims')) {
                    fundReq.No_of_Submitted_Claims__c = (Decimal)(mdfReqIdToAggRes.get(fundReq.Id)).get('submittedClaims');
                    MDFReqList.add(fundReq);
                } 
            } else if(fundReq.No_of_Submitted_Claims__c != 0) {
                fundReq.No_of_Submitted_Claims__c = 0;
                MDFReqList.add(fundReq);
            }
        }
        
        if (MDFReqList.size() > 0) { 
            update MDFReqList;
        }
    }
    
    public void creatClaimId(List<SFDC_MDF_Claim__c> newList) {
        /* Update information on MFF request that How many claim is submitted for the request. */  
        
        /* This Trigger creates claim Id based on MDF Request Id */
        Set<Id> FundReqIds = new Set<Id>();
        
        
        for(SFDC_MDF_Claim__c claim : newList) {
            
            FundReqIds.add(claim.Fund_Request__c);
        }
        
        Map<Id,SFDC_MDF__c> idToMDFReq = new Map<Id,SFDC_MDF__c>([SELECT id, Request_ID__c FROM SFDC_MDF__c WHERE Id IN: FundReqIds]);
        
        for(SFDC_MDF_Claim__c claim : newList) {
            if (idToMDFReq.get(claim.Fund_Request__c) != null && idToMDFReq.get(claim.Fund_Request__c).Request_ID__c != null) {
                String str = idToMDFReq.get(claim.Fund_Request__c).Request_ID__c;
                claim.Claim_Id_Txt__c = 'FC'+str.remove('FR');
            }
        }
    }
    
    
    
    public void updateClaimInfoOnMDF(List<SFDC_MDF_Claim__c> newList) {
        List<SFDC_MDF__c> fundRequesList = new List<SFDC_MDF__c>();
        // Map<Id, SFDC_MDF__c> FundCklaiMap =new Map<Id, SFDC_MDF__c>();
        
        for(SFDC_MDF_Claim__c  claim : newList) {
            SFDC_MDF__c  sfdcRequest = new SFDC_MDF__c();
            sfdcRequest.Id  = claim.Fund_Request__c;
            If(claim.Claim_Paid_Month__c != null || claim.Claim_Paid_Year__c != null){
                sfdcRequest.Claim_Paid_Month__c = Claim.Claim_Paid_Month__c;
                sfdcRequest.Claim_Paid_year__c = Claim.Claim_Paid_year__c;
                fundRequesList.add(sfdcRequest);
            }
            
        }
        If (fundRequesList != null && !fundRequesList .isEmpty()) {
            database.update(fundRequesList,false);
        }
    }
    
    public void updateTrasactionRefOnMDFReq (List<SFDC_MDF_Claim__c> newList) {
        Set<Id> mdfReqIds = new Set<Id>();
        Set<Id> claimIds  = new Set<Id>();
        
        Map<Id,SFDC_MDF_Claim__c> mdfReqIdToClaimRec = new Map<Id,SFDC_MDF_Claim__c>();
        
        List<SFDC_MDF__c> mdfReqs = new List<SFDC_MDF__c>();
        
        for (SFDC_MDF_Claim__c claim : newList) {
            //claimIds.add(claim.Id);
            mdfReqIdToClaimRec.put(claim.Fund_Request__c,claim);
        }
        
        for (SFDC_MDF__c mdfReq : [SELECT Id, Transaction_Reference__c FROM SFDC_MDF__c WHERE Id IN : mdfReqIdToClaimRec.keySet()]) {
            if (mdfReqIdToClaimRec.get(mdfReq.Id) != null && mdfReqIdToClaimRec.get(mdfReq.Id).Transaction_Reference__c != null && mdfReq.Transaction_Reference__c == null) {
                mdfReq.Transaction_Reference__c  = mdfReqIdToClaimRec.get(mdfReq.Id).Transaction_Reference__c;
                mdfReqs.add(mdfReq);
            }
        }
        
        if (mdfReqs.size() > 0) {
            update mdfReqs;
        }
    }
    
    public void updateAccrualBalanceAIAU(List<SFDC_MDF_Claim__c> newList) {
        // This trigger has been written to full fill below requirments
        // "Accrual Balance" on the REQUEST page should be reflective of the "Accrual Balance" on the CLAIM page.
        Set<Id> claimIds = new Set<Id>();
        Set<Id> mdfReqIds = new Set<Id>();
        
        
        for (SFDC_MDF_Claim__c claim : newList) {
            if (claim.Fund_Request__c != null) {
                claimIds.add(claim.Id);
                mdfReqIds.add(claim.Fund_Request__c);
            }
            
        }
        List<SFDC_MDF_Claim__c> claims = [SELECT Id, Name, Fund_Request__c, Accrual_Balance__c, Released_Funds__c FROM SFDC_MDF_Claim__c WHERE Id IN: claimIds];
        
        
        // Find MDF Request Ids on which we needs to update Accrual Balance
        for(SFDC_MDF_Claim__c claim : claims) {
            if (claim.Fund_Request__c != null)
                mdfReqIds.add(claim.Fund_Request__c);
        }
        
        Map<Id,SFDC_MDF__c> idToMdfMap = new Map<Id,SFDC_MDF__c>([SELECT ID, Released_Funds__c FROM SFDC_MDF__c WHERE Id IN: mdfReqIds]);
        
        List<SFDC_MDF__c> mdfReqToUpdate = new List<SFDC_MDF__c>();
        
        for(SFDC_MDF_Claim__c claim : claims) {
            if (claim.Fund_Request__c != null) {
                if (claim.Released_Funds__c != idToMdfMap.get(claim.Fund_Request__c).Released_Funds__c) {
                    idToMdfMap.get(claim.Fund_Request__c).Released_Funds__c = claim.Released_Funds__c; 
                    mdfReqToUpdate.add(idToMdfMap.get(claim.Fund_Request__c));
                }
            }
        }
        
        if (mdfReqToUpdate.size() > 0) {
            update mdfReqToUpdate;
        }
    }
    
    public void updateFundClaimChannelManager(List<SFDC_MDF_Claim__c> newList){
        /**
*   Update the Partner Owner field when the record is owned by a partner
*
*/
        
        Set<Id> ownerIds = new Set<Id>();
        
        
        //Loop through each fund claim and create a Set of all the UserIds for the fund claim owners 
        for (SFDC_MDF_Claim__c fundClaim : newList) {
            //Figure out the owner ids of the fund claims 
            ownerIds.add(fundClaim.OwnerId);
        }
        
        //Create a map of the owernids to their partner accounts
        Map<Id,User> partnerAccts = new Map<Id,User>([Select Id, Contact.Account.OwnerId from User where id in :ownerIds]);
        
        //Now loop through each fund claim to set the Partner Account Id on the claim
        for (SFDC_MDF_Claim__c fundClaim : newList) {
            //Update the partner account manager 
            if ((partnerAccts.get(fundClaim.OwnerId).Contact.Account.OwnerId != NULL) && (fundClaim.Partner_Owner__c == NULL)) {
                fundClaim.Partner_Owner__c = partnerAccts.get(fundClaim.OwnerId).Contact.Account.OwnerId;
            }
        }
    }
    
    //Local Mehtod resposible to populate Claim month and year on Associated Fund Request record.
    public void populateFundRequestReleasedMonthAndYear(Map<Id, SFDC_MDF_Claim__c> mapNewIdToFundClaim, Map<Id, SFDC_MDF_Claim__c> mapOldIdToFundClaim)
    {
        List<SFDC_MDF__c> lstUpdateFundRequest = new List<SFDC_MDF__c>();
        
        List<SFDC_MDF_Claim__c> lstNewFundClaim = new List<SFDC_MDF_Claim__c>();
        
        //Insert New Fund Claim 
        if(mapOldIdToFundClaim == null)
        {
            lstNewFundClaim.addAll(mapNewIdToFundClaim.values());
        }
        else //Update Fund Claim 
        {
            for(SFDC_MDF_Claim__c objNewFundClaim : mapNewIdToFundClaim.values())
            {
                SFDC_MDF_Claim__c objOldFundClaim = mapOldIdToFundClaim.get(objNewFundClaim.Id);
                if((objNewFundClaim.Fund_Request__c != null && 
                    ((objOldFundClaim.Released_Funds__c != objNewFundClaim.Released_Funds__c) || 
                     (objOldFundClaim.Released_Month__c != objNewFundClaim.Released_Month__c) || 
                     (objOldFundClaim.Released_Year__c != objNewFundClaim.Released_Year__c))))
                {
                    lstNewFundClaim.add(objNewFundClaim);
                }
            }
        }
        
        for(SFDC_MDF_Claim__c objNewFundClaim : lstNewFundClaim)
        {   
            if(String.isNotBlank(objNewFundClaim.Fund_Request__c))
            {
                SFDC_MDF__c objFundRequest = new SFDC_MDF__c(Id = objNewFundClaim.Fund_Request__c);
                objFundRequest.Released_Month__c = objNewFundClaim.Released_Month__c;
                objFundRequest.Released_Year__c = objNewFundClaim.Released_Year__c;
                
                if(mapOldIdToFundClaim != null)
                {
                    SFDC_MDF_Claim__c objOldFundClaim = mapOldIdToFundClaim.get(objNewFundClaim.Id);
                    if(objOldFundClaim.Released_Funds__c != objNewFundClaim.Released_Funds__c)
                        objFundRequest.Released_Amount__c = objNewFundClaim.Released_Funds__c;
                }
                else
                    objFundRequest.Released_Amount__c = objNewFundClaim.Released_Funds__c;
                lstUpdateFundRequest.add(objFundRequest);
            }
        }
        
        //Update Fund Request
        if(!lstUpdateFundRequest.isEmpty())
        {
            update lstUpdateFundRequest;
        }
    }
}