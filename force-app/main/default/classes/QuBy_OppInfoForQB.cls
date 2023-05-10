/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_OppInfoForQB.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 28-08-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 28-08-2016
# Description...........: This class use to construct json for parameters which we are sending to QuBy.
                          
##################################################################################################*/
public with sharing class QuBy_OppInfoForQB {
    public String oppJSON {get;set;}
    
    /*##################################################################################################
    # Method Name............: QuBy_OppInfoForQB ( Constructor )
    # Param..................: Standred Controller Instance                                               
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Standred Controller Constructor.                          
    ##################################################################################################*/
    public QuBy_OppInfoForQB(  ) {
        String QuoteNo = ApexPages.currentPage().getParameters().get('qno');
        if( QuoteNo != null ){
            
            List<QuBy_Detail__c> QB = [ SELECT id, name, Quote_Number__c FROM QuBy_Detail__c where Quote_Number__c =: QuoteNo ];
            if( QB.size()>0 ){
                system.JSONGenerator gen = system.JSON.createGenerator(true);
                //gen.writeStringField('LaunchType','openQuote');
                oppJSON=generateQtJson(QB.get(0));
            
            }
           
        }else{
            String oppid = ApexPages.currentPage().getParameters().get('oppno');
            if( oppid != null ){                
                Opportunity opp = [ SELECT id, name, Opportunity_Number__c, Expected_Delivery_Date__c, /*Advocated_Solution__c,*/ Invoice_Trigger__c, /*Solution_Portfolio__c, - P360 Initial Change-Ahad*/ Sales_Org_Code__c, Owner.Quicklook_id__c, Owner.Name, Owner.Global_ID__c, Account.Name, Account.Master_Customer_Number__c, Account.Account_Country_Code__c, Account.Industry  FROM Opportunity where id =: oppid ];
                User u=[Select quicklook_id__c from user where id=:UserInfo.getUserId()]  ;        
                oppJSON=generateOppJson(opp,u);
            }
            else{
                oppJSON=generateStdJson();
            }
        }
        
    }
    public  string generateOppJson(Opportunity opp, User u){
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject();
          gen.writeStringField('LaunchType','QuoteCreate');
          gen.writeStringField('id',opp.id);
          gen.writeStringField('OpportunityName',opp.name);
          gen.writeStringField('OpportunityNumber',opp.Opportunity_Number__c);
          if(opp.Expected_Delivery_Date__c!=null){
            gen.writeDateField('ExpectedDeliveryDate',opp.Expected_Delivery_Date__c);
            }
        /*  if(opp.Advocated_Solution__c!=null){
              //for p360 changes removing Advocated Solution, replacing by '';
          //gen.writeStringField('AdvocatedSolution',opp.Advocated_Solution__c); 
         
          }*/
         gen.writeStringField('AdvocatedSolution','');
          if(opp.Invoice_Trigger__c!=null){
          gen.writeStringField('InvoiceTrigger',opp.Invoice_Trigger__c); 
          }
          /*if(opp.Solution_Portfolio__c!=null){
              //for p360 changes removing OfferPortfolio, replacing by '';
          gen.writeStringField('OfferPortfolio','');
              } - P360 Initial Change-Ahad */ 
          if(opp.Sales_Org_Code__c!=null){
          gen.writeStringField('SalesOrgCode',opp.Sales_Org_Code__c);
              }
          gen.writeStringField('OpportunityOwnerQuicklook',opp.Owner.Quicklook_ID__c);
          if(opp.Owner.Name!=null){
          gen.writeStringField('OwnerFullName',opp.Owner.Name);
              }
         if(opp.Owner.Global_ID__c!=null){
          gen.writeStringField('OwnerGlobalId',opp.Owner.Global_ID__c);
              }
          //gen.writeStringField('AccountName',opp.Account.Name);
          gen.writeStringField('AccountName','');
          gen.writeStringField('MCN',opp.Account.Master_Customer_Number__c); 
          if(opp.Account.Industry!=null){
          gen.writeStringField('AccountLOB',opp.Account.Industry);
          }
          if(opp.Account.Account_Country_Code__c!=null){
          gen.writeStringField('AccountCountry',opp.Account.Account_Country_Code__c);
          }
          gen.writeStringField('UserQuicklook',u.Quicklook_ID__c);          
          gen.writeEndObject();
          //end of the parent JSON object  
          String jsonString = gen.getAsString();
          return jsonString;
     }
     /*
    public  string generateQtJson(QuBy__c qb){
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject();
          gen.writeStringField('LaunchType','QuoteOpen');
          gen.writeStringField('id',qb.id);
          gen.writeStringField('QuoteName',qb.name);
          gen.writeStringField('QuoteNumber',qb.Quote_Number__c);                    
          gen.writeEndObject();
          String jsonString = gen.getAsString();
          return jsonString;
     }
     */
    public  string generateQtJson(QuBy_detail__c qb){
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject();
          gen.writeStringField('LaunchType','QuoteOpen');
          gen.writeStringField('id',qb.id);
          gen.writeStringField('QuoteName',qb.name);
          gen.writeStringField('QuoteNumber',qb.Quote_Number__c);                    
          gen.writeEndObject();
          String jsonString = gen.getAsString();
          return jsonString;
     }
    public  string generateStdJson(){
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject();
          gen.writeStringField('LaunchType','QuoteBuilder');                 
          gen.writeEndObject();
          String jsonString = gen.getAsString();
          return jsonString;
     }
}