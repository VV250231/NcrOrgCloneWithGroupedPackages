/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/
public class MarketProductDetailController {
     
     @AuraEnabled
     public static List<TopLineWrap> getConsolatedData(Id recId ,String NoOfRec)
     {
          
        String OppId = String.valueOf(recId).trim(); 
        List<String> FeildLabel = new List<String>(); 
        Integer QuryLmt = Integer.valueOf(NoOfRec);
        List<TopLineWrap> WrapList= new List<TopLineWrap>();
        Map<Id,TopLineWrap> WrapMap = new Map<Id,TopLineWrap>();
        LIST<Opportunity> OppRedlst = new List<Opportunity>(); 
         
         if(String.isNotBlank(recId)){
             OppRedlst = [Select id,Name,CPQ__c,SBQQ__AmendedContract__c FROM Opportunity where id =:recId];
         }
         if(OppRedlst != null && OppRedlst.size()>0){ 
             if(OppRedlst[0].CPQ__c){
                 
                
                 for(AggregateResult ar : [SELECT Topline_Product_Lkp__r.Name Name,SUM(SBQQ__QuoteLine__r.SBQQ__Quantity__c),SUM(SBQQ__QuoteLine__r.SBQQ__PriorQuantity__c),SUM(Quantity) from OpportunityLineItem where OpportunityId =:recId  and Topline_Product_Lkp__c != null  Group By Topline_Product_Lkp__r.Name limit : QuryLmt]){
                     TopLineWrap wrapObj = new TopLineWrap(); 
                     wrapObj.IsCpq=OppRedlst[0].CPQ__c;
                     wrapObj.OppName=OppRedlst[0].Name;
                     wrapObj.MarketProductId =String.valueOf(ar.get('Name'));
                    
                     if(OppRedlst[0].SBQQ__AmendedContract__c != null && String.isNotBlank(OppRedlst[0].SBQQ__AmendedContract__c)){
                             Integer qnty= Integer.valueOf(ar.get('expr0'));
                             Integer qutyPrior=Integer.valueOf(ar.get('expr1'));
                             if(qutyPrior == null){
                                 qutyPrior=0;
                             }
                            
                             wrapObj.Quantity=Integer.valueOf(qnty-qutyPrior);
                     }
                     
                     else{
                         wrapObj.Quantity= Integer.valueOf(ar.get('expr2'));
                     }                    
                     WrapList.add(wrapObj);
             
                } 
             }
         }
         
         String  query = 'SELECT Id,Topline_Product_Lkp__c, Topline_Product_Lkp__r.Name,UnitPrice,Quantity,TotalPrice FROM OpportunityLineItem WHERE OpportunityId =:OppId';
         query = query + ' limit '+ QuryLmt;
         System.debug(query);
         for(OpportunityLineItem oliObj : DataBase.query(query)){
            
             if(!OppRedlst[0].CPQ__c){
                 TopLineWrap wrapObj = new TopLineWrap();
                 wrapObj.IsCpq=OppRedlst[0].CPQ__c;
                 wrapObj.OppName=OppRedlst[0].Name; 
                 wrapObj.MarketProductId=oliObj.Topline_Product_Lkp__r.Name;
                 wrapObj.Quantity=Integer.valueOf(oliObj.Quantity);
                 wrapObj.UnitPrice=Integer.valueOf(oliObj.UnitPrice);
                 wrapObj.TotalPrice=Double.valueOf(oliObj.TotalPrice);
                 WrapList.add(wrapObj);
                 
             }
             
         }
         
        return WrapList; 
         
         
     }
    
    
    Public class TopLineWrap{
        
        @AuraEnabled
        Public String MarketProductId;
        
        @AuraEnabled
        Public Decimal UnitPrice;
        
        @AuraEnabled
        Public Integer Quantity;
        
        @AuraEnabled
        Public Double TotalPrice;
        
        @AuraEnabled
        Public OpportunityLineItem OLI;
        
        @AuraEnabled 
        Public Boolean IsCpq;
        
        @AuraEnabled
        Public String OppName;
    }
    
   @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }
    
    
}