/*
*********************************************************
Apex Class Name    : MDFListControllerExt
Test Class Name    : MDFListControllerExtTest
Created Date       :  1/22/2016 7:45 AM
@author            : Dev Admin
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
1/20/2022 3:00 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
*********************************************************
*/
public with sharing class MDFListControllerExt {
  
  ApexPages.StandardSetController ssc ;
  private string sortExp = 'CreatedDate';
  private string sortDirection = 'DESC';
  private integer currentPageNumber = 0;
  private integer totalListSize;
  private List<SFDC_MDF__c> allRequests = new List<SFDC_MDF__c>();
  private List<List<MDFReqWrapper>> totalList = new List<List<MDFReqWrapper>>();
  private List<SFDC_MDF__c> reqList = new List<SFDC_MDF__c>();
  public String sortExpression
   {
     get
     {
        return sortExp;
     }
     set
     {
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
       currentPageNumber = 0;
     }
   }

     public String getSortDirection()
     {
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     }
     
 private integer recordSize = 20;
  public boolean newFilter{get; set;}
  public MDFListControllerExt (ApexPages.StandardController sc) {
          System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
  }
    
  public MDFListControllerExt (ApexPages.StandardSetController ssc) {
    this.ssc = ssc;
    newFilter = true;  
  }
  
  
  public List<MDFReqWrapper> getMdfRequestPagination() {
    List<MDFReqWrapper> mdfReqWrapperList = new List<MDFReqWrapper>();
    if(newFilter == true){
      reqList.clear();
        if(!test.isRunningTest()){
      while(ssc.getHasNext())
        {
            for(SFDC_MDF__c testRecord : (List<SFDC_MDF__c>) ssc.getRecords())
            {
                reqList.add(testRecord);
            }
            ssc.next();
        }
        }
        reqList.addAll((List<SFDC_MDF__c>) ssc.getRecords());
        sortExpression = 'CreatedDate';
        sortDirection = 'DESC';
        currentPageNumber = 0;
        newFilter = false;
    }
        string sortFullExp = sortExpression  + ' ' + sortDirection;
    allRequests.clear();
      string query = 'SELECT id, Name, status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c WHERE Id IN: reqList ORDER BY '+sortFullExp;
    allRequests  = Database.query(String.escapeSingleQuotes(query));
    if(!allRequests.isEmpty()){
        integer quotient = allRequests.size()/recordSize;
        integer remainder = math.mod(allRequests.size(), recordSize);
        totalList.clear();
        if(quotient > 0){
            for(integer i=0; i<quotient; i++){
                List<MDFReqWrapper> tempmdfReqWrapperList = new List<MDFReqWrapper>();
                for(integer j=(recordSize*i); j<(recordSize*(i+1)); j++){
                    SFDC_MDF__c req = allRequests[j];
                    if ((req.R00N30000002DjDcEAK__r).size() > 0) {
                        tempmdfReqWrapperList.add( new mdfReqWrapper(req,(SFDC_MDF_Claim__c)req.R00N30000002DjDcEAK__r[0]) );
                    } else {
                        tempmdfReqWrapperList.add( new mdfReqWrapper(req));
                    }
                }
                totalList.add(tempmdfReqWrapperList);
            }
        }
        if(remainder > 0){
            List<MDFReqWrapper> tempmdfReqWrapperList = new List<MDFReqWrapper>();
            for(integer i=(recordSize*quotient); i<allRequests.size(); i++){
                SFDC_MDF__c req = allRequests[i];
                if ((req.R00N30000002DjDcEAK__r).size() > 0) {
                    tempmdfReqWrapperList.add( new mdfReqWrapper(req,(SFDC_MDF_Claim__c)req.R00N30000002DjDcEAK__r[0]) );
                } else {
                    tempmdfReqWrapperList.add( new mdfReqWrapper(req));
                }
            }
            totalList.add(tempmdfReqWrapperList);
        }
        totalListSize = totalList.size();
        mdfReqWrapperList = totalList[currentPageNumber];
    }
    return mdfReqWrapperList;
  }
  
  public class MDFReqWrapper {
    public SFDC_MDF__c mdfRequest {get;set;}
    public SFDC_MDF_Claim__c mdfClaim {get;set;}
    
    public mdfReqWrapper(SFDC_MDF__c mdfRequest) {
     this.mdfRequest = mdfRequest; 
    }
    
    public mdfReqWrapper (SFDC_MDF__c mdfRequest, SFDC_MDF_Claim__c mdfClaim) {
      this.mdfRequest = mdfRequest;
      this.mdfClaim   = mdfClaim;
    }
    
  }
  
  public PageReference deleteMDFRequest() {
    //String recordId = ApexPages.currentPage().getParameters().get('recordID');
   //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
   String recordId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('recordID'));
        
    List<SFDC_MDF__c> mdfList = new List<SFDC_MDF__c>();
        
    mdfList = [SELECT Id,Status__c FROM SFDC_MDF__c WHERE Id=: recordId] ;
        
    if (MDFList.size() > 0) {
            
      if (mdfList[0].Status__c == 'Approved') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING,'You can\'t delete approved request.'));
        return null ;
      }
      delete mdfList; 
    }
        
    PageReference pr = Page.MDFList;
    pr.setRedirect(true);
        
    return pr;
  }
    
  public PageReference redirectToNewMDFRequest() {
    //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
    //String retURL = ApexPages.currentPage().getParameters().get('sfdc.tabName');
      String retURL = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('sfdc.tabName'));
     //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
      retURL= EncodingUtil.urlEncode('/apex/MDFList?sfdc.tabName'+ retURL, 'UTF-8');
    //retURL = '/apex/MDFList?sfdc.tabName'+ retURL;
    PageReference pr = Page.mdfNewRequestPage;
    pr.getParameters().put('retURL',retURL);
    return pr;
  }
  
  public void doNext(){
      if(currentPageNumber < (totalListSize-1)){
          currentPageNumber++;
      }else{
          currentPageNumber = (totalListSize-1);
      }
  }
  
  public void doPrevious(){
      if(currentPageNumber > 0){
          currentPageNumber --;
      }else{
          currentPageNumber = 0;
      }
  }
  
}