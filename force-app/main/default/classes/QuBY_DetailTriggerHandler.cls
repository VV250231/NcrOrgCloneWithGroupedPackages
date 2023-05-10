/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBY_DetailTriggerHandler.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 28-08-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 28-08-2016
# Description...........: This class is handler class for all quby quotes trigger.
# Last Modified by......: Ajay Dixit 
# Last Modified Date....: 10-10-2017
# Description...........: Handle NULL pointer exception on deleting Quotes in bulk.
# Last Modified by......: Santosh Jha
# Last Modified Date....: 27-10-220
# Description...........: unfiy multiple trigger into one trigger
# Last Modified Date....: 17-12-2022
# Description...........: EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                          
##################################################################################################*/
//public with sharing class QuBY_DetailTriggerHandler{
public class QuBY_DetailTriggerHandler{
    
    public static boolean doNotCallTrigger = false;
    public static void updateQuoteNumOnPartnerOpp (List<QuBy_Detail__c> QuByDetailList ) {
        Set<Id> oppIds = new Set<Id>();
        
        for (QuBy_Detail__c qbDetail : QuByDetailList) {
            oppIds.add(qbDetail.Opportunity__c);
        }
        
        Map<Id,String> partnerOppIdToQuoterNumMap = new Map<Id,String>();
        
        if (oppIds.size() > 0) {
            
            for (Opportunity op : [SELECT Id,Linked_Partner_Opportunity__c, (SELECT Id,Quote_Number__c FROM All_QuBy_Quotes__r)  FROM Opportunity WHERE Id IN: oppIds AND Linked_Partner_Opportunity__c != null]) {
                String quoteNumbers = '';
                for (QuBy_Detail__c qd : op.All_QuBy_Quotes__r) {
                    quoteNumbers = (quoteNumbers != '') ? quoteNumbers +'; ' + qd.Quote_Number__c : qd.Quote_Number__c;
                }
                if (quoteNumbers != '') {
                    partnerOppIdToQuoterNumMap.put(op.Linked_Partner_Opportunity__c,quoteNumbers);
                }
                
            }
            
        }
        
        if (partnerOppIdToQuoterNumMap.keySet().size() > 0) {
            List<Partner_Opportunity__c> partnerOpportunity = [SELECT Id, Quote_Number__c FROM Partner_Opportunity__c WHERE Id IN: partnerOppIdToQuoterNumMap.keySet()];
            for (Partner_Opportunity__c po : partnerOpportunity ) {
                po.Quote_Number__c = partnerOppIdToQuoterNumMap.get(po.Id);
            }
            update partnerOpportunity ;
        }
    }
    
    public static void QuBy_DeleteQuote(List<QuBy_Detail__c> DeleteQuByDetailList)
    {
         Set <id> toDeleteQte=new Set<id>();
        for(QuBy_Detail__c qd:DeleteQuByDetailList){
            if(qd.Latest_Version__c!=null && Integer.valueOf(qd.Latest_Version__c)<0){
                toDeleteQte.add(qd.Id);
            }
        }
        if(toDeleteQte.size()>0){
            QuBY_DetailTriggerHandler.deleteQte(toDeleteQte);
        }
    }
    
    public static void QubyDetailHelper( List<QuBy_Detail__c> NewQuByDetailList,List<QuBy_Detail__c> OldQuByDetailList,Map<id, QuBy_Detail__c> oldQubyDetailMap )
      {
          // if( QuBy_LTNG_ProfileCheck__c.getValues( userInfo.getProfileId() ) != null || test.isRunningTest() ){
           set<string> st  = new set<string>();
          List<All_profie_list_config__c> mcs = All_profie_list_config__c.getall().values();
          for(All_profie_list_config__c p : mcs ){
              if(p.QuBy_LTNG_ProfileCheck__c == true){
                  st.add(p.Profile_id__c);
              }            
          } 
          if(st.contains( userInfo.getProfileId() ) || test.isRunningTest()){
        
        
            
            
            /*##################################################################################################
            Trigger Run On After Event
            ##################################################################################################*/
            if( trigger.isAfter && !QuBY_DetailTriggerHandler.doNotCallTrigger ){
                
                /*##################################################################################################
                Trigger Run On After Insert Event
                ##################################################################################################*/
                
                if( trigger.isInsert ){
                    
                    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
                    //Opportunity Re-engineering 48 Hour Notification 
                    set<id>QDList_48 = new set<id>();
                    for( QuBy_Detail__c QD_48 : trigger.new ){
                        decimal QuoteNumber_48 = decimal.valueof( QD_48.Quote_Number__c.trim() );
                        if( QD_48.Quote_Number__c != null && QuoteNumber_48 >= 350000000 && QD_48.Total_Quote_Amount__c >= 10000 && ( QD_48.Annuity_Quote_Status__c == 'Acknowledged' || QD_48.Solution_Quote_Status__c == 'Acknowledged' ) && ( QD_48.Opportunity__c == null || QD_48.Opportunity_No__c == null ) && !QD_48.X48_hour_Notification__c && QD_48.isChannel__c != 'true' )
                            QDList_48.add( QD_48.id );
                    }
                    
                    system.debug( ':::::QDList_48:::::' + QDList_48 );
                    if( QDList_48 != null && QDList_48.size() > 0 ){
                        QuBY_DetailTriggerHandler.opportunityReenggineering( 'QuBy_48',QDList_48 );
                    }
                    
                    //Opportunity Re-engineering 24 Hour Notification
                    set<id>QDList_24 = new set<id>();
                    for( QuBy_Detail__c QD_24 : trigger.new ){
                        decimal QuoteNumber_24 = decimal.valueof( QD_24.Quote_Number__c.trim() );
                        if( QD_24.Quote_Number__c != null && QuoteNumber_24 >= 350000000 && QD_24.Total_Quote_Amount__c >= 10000 && ( QD_24.Annuity_Quote_Status__c == 'Acknowledged' || QD_24.Solution_Quote_Status__c == 'Acknowledged' ) && ( QD_24.Opportunity__c == null || QD_24.Opportunity_No__c == null ) && QD_24.X24_hour_Notification__c && QD_24.isChannel__c != 'true' )
                        QDList_24.add( QD_24.id );
                    }
                    
                    system.debug( ':::::QDList_24:::::' + QDList_24 );
                    if( QDList_24 != null && QDList_24.size() > 0 ){
                        QuBY_DetailTriggerHandler.opportunityReenggineering( 'QuBy_24',QDList_24 );
                    }
                    
                    //Opportunity Re-engineering Opportunity Creation Notification
                    set<id>QDList_OCC = new set<id>();
                    for( QuBy_Detail__c QD_OCC : trigger.new ){
                        if( QD_OCC.Reengineering_Opportunity__c != null && QD_OCC.Reengineering_Opportunity__c && QD_OCC.isChannel__c != 'true')
                            QDList_OCC.add( QD_OCC.id );
                    }
                    
                    system.debug( ':::::QDList_OCC:::::' + QDList_OCC );
                    if( QDList_OCC != null && QDList_OCC.size() > 0 ){
                        QuBY_DetailTriggerHandler.opportunityReenggineering( 'QuBy_OpportunityCreationNotification',QDList_OCC );
                    }
                    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
                    //Rollup Call
                    Set<id>SendToRollup = new Set<id>();
                    for( QuBy_Detail__c RP : NewQuByDetailList ){                    
                        if( RP.Opportunity__c != null ){
                            SendToRollup.add( RP.Opportunity__c );
                        }
                    }
                    
                    if( SendToRollup != null && SendToRollup.size() > 0 ){
                        QuBY_DetailTriggerHandler.rollupOpportunity( SendToRollup );
                    }
                    //StageChange Opportunity
                    QuBY_DetailTriggerHandler.OpportunityStageChange( NewQuByDetailList );
                    
                }
                //RollUp Call               
                if( Trigger.isUndelete ){
                    Set<id>SendToRollup = new Set<id>();
                    for( QuBy_Detail__c RP : NewQuByDetailList ){                    
                        if( RP.Opportunity__c != null ){
                            SendToRollup.add( RP.Opportunity__c );
                        }
                    }
                    
                    if( SendToRollup != null && SendToRollup.size() > 0 ){
                        QuBY_DetailTriggerHandler.rollupOpportunity( SendToRollup );
                    }
                }
                
                /*##################################################################################################
                Trigger Run On After Update Event
                ##################################################################################################*/
                
                if( trigger.isUpdate ){
                    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
                    //Opportunity Re-engineering 48 Hour Notification 
                    set<id>QDList_48 = new set<id>();
                    for( QuBy_Detail__c QD_48 : trigger.new ){
                        decimal QuoteNumber_48 = decimal.valueof( QD_48.Quote_Number__c.trim() );
                        if( QD_48.Quote_Number__c != null && QuoteNumber_48 >= 350000000 && QD_48.Total_Quote_Amount__c >= 10000 && ( QD_48.Annuity_Quote_Status__c == 'Acknowledged' || QD_48.Solution_Quote_Status__c == 'Acknowledged' ) && ( QD_48.Opportunity__c == null || QD_48.Opportunity_No__c == null ) && !QD_48.X48_hour_Notification__c && QD_48.isChannel__c != 'true' )
                            QDList_48.add( QD_48.id );
                    }
                    
                    system.debug( ':::::QDList_48:::::' + QDList_48 );
                    if( QDList_48 != null && QDList_48.size() > 0 ){
                        QuBY_DetailTriggerHandler.opportunityReenggineering( 'QuBy_48',QDList_48 );
                    }
                    
                    //Opportunity Re-engineering 24 Hour Notification
                    set<id>QDList_24 = new set<id>();
                    for( QuBy_Detail__c QD_24 : trigger.new ){
                        decimal QuoteNumber_24 = decimal.valueof( QD_24.Quote_Number__c.trim() );
                        if( QD_24.Quote_Number__c != null && QuoteNumber_24 >= 350000000 && QD_24.Total_Quote_Amount__c >= 10000 && ( QD_24.Annuity_Quote_Status__c == 'Acknowledged' || QD_24.Solution_Quote_Status__c == 'Acknowledged' ) && ( QD_24.Opportunity__c == null || QD_24.Opportunity_No__c == null ) && QD_24.X24_hour_Notification__c && QD_24.X24_hour_Notification__c != trigger.OldMap.get( QD_24.Id ).X24_hour_Notification__c && QD_24.isChannel__c != 'true') 
                            QDList_24.add( QD_24.id );
                    }
                    
                    system.debug( ':::::QDList_24:::::' + QDList_24 );
                    if( QDList_24 != null && QDList_24.size() > 0 ){
                        QuBY_DetailTriggerHandler.opportunityReenggineering( 'QuBy_24',QDList_24 );
                    }
                    
                    //Opportunity Re-engineering Opportunity Creation Notification
                    set<id>QDList_OCC = new set<id>();
                    for( QuBy_Detail__c QD_OCC : trigger.new ){
                        if( QD_OCC.Reengineering_Opportunity__c != null && QD_OCC.Reengineering_Opportunity__c &&  QD_OCC.Reengineering_Opportunity__c != trigger.OldMap.get( QD_OCC.Id ).Reengineering_Opportunity__c && QD_OCC.isChannel__c != 'true' )
                            QDList_OCC.add( QD_OCC.id );
                    }
                    
                    system.debug( ':::::QDList_OCC:::::' + QDList_OCC );
                    if( QDList_OCC != null && QDList_OCC.size() > 0 ){
                        QuBY_DetailTriggerHandler.opportunityReenggineering( 'QuBy_OpportunityCreationNotification',QDList_OCC );
                    }
                    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
                    
                    //Creating/updating NTQ Record
                    List<QuBy_Detail__c>NTQList = new List<QuBy_Detail__c>();
                    for( QuBy_Detail__c QD : NewQuByDetailList ){
                        if( QD.Opportunity__c != oldQubyDetailMap.get( QD.Id ).Opportunity__c )
                            NTQList.add( QD );
                    }
                    QuBY_DetailTriggerHandler.NTQCreationCall( NTQList );
                        
                    
                    //RollUp Call                    
                    Set<id>SendToRollup = new Set<id>();
                    for( QuBy_Detail__c RP : NewQuByDetailList ){                    
                        if( RP.Opportunity__c != null ){
                            SendToRollup.add( RP.Opportunity__c );
                        }
                        else if( RP.Opportunity__c == null && oldQubyDetailMap.get( RP.Id ).Opportunity__c != null ){
                            SendToRollup.add( oldQubyDetailMap.get( RP.Id ).Opportunity__c );
                        }
                    }
                    if( SendToRollup != null && SendToRollup.size() > 0 ){
                        QuBY_DetailTriggerHandler.rollupOpportunity( SendToRollup );
                    }
                    //StageChange Opportunity
                    QuBY_DetailTriggerHandler.OpportunityStageChange( NewQuByDetailList );
                }
                
                if( Trigger.isDelete ){
                    //RollUp Call
                    Set<id>SendToRollup = new Set<id>();
                    for( QuBy_Detail__c RP : OldQuByDetailList ){                    
                        if( RP.Opportunity__c != null ){
                            SendToRollup.add( RP.Opportunity__c );
                        }
                        else if( RP.Opportunity__c == null && oldQubyDetailMap.get( RP.Id ).Opportunity__c != null ){
                            SendToRollup.add( oldQubyDetailMap.get( RP.Id ).Opportunity__c );
                        }
                    }
                    
                    if( SendToRollup != null && SendToRollup.size() > 0 ){
                        QuBY_DetailTriggerHandler.rollupOpportunity( SendToRollup );
                    }
                }
                
            }
        
            /*##################################################################################################
            Trigger Run On Before Event
            ##################################################################################################*/
            if( trigger.isBefore ){
                if( trigger.isInsert ){
                    QuBY_DetailTriggerHandler.AssociateAccount( NewQuByDetailList );
                    QuBY_DetailTriggerHandler.CurrencyIsoConversion( NewQuByDetailList );
                    QuBY_DetailTriggerHandler.opportunityAssociationToQuote( NewQuByDetailList );
                    QuBY_DetailTriggerHandler.opportunityDisAssociationToQuote( NewQuByDetailList );
                    
                    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
                    List<QuBy_Detail__c>QDList = new List<QuBy_Detail__c>();
                    for( QuBy_Detail__c detailEmail : trigger.new ){
                        if( detailEmail.Account__c != null){
                            QDList.add( detailEmail );
                        }
                    }
                    
                    if( QDList != null && QDList.size() > 0 ){
                        QuBY_DetailTriggerHandler.EmailToQuote( QDList );
                    }
                    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
                    QuBY_DetailTriggerHandler.TrimQuoteName( NewQuByDetailList );
                }
                if( trigger.isUpdate ){
                    QuBY_DetailTriggerHandler.AssociateAccount( NewQuByDetailList );
                    QuBY_DetailTriggerHandler.CurrencyIsoConversion( NewQuByDetailList );
                    QuBY_DetailTriggerHandler.opportunityAssociationToQuote( NewQuByDetailList );
                    QuBY_DetailTriggerHandler.opportunityDisAssociationToQuote( NewQuByDetailList );
                    List<QuBy_Detail__c>QDList = new List<QuBy_Detail__c>();
                    
                    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
                    for( QuBy_Detail__c detailEmail : trigger.new ){
                        if( detailEmail.Account__c != null ){
                            QDList.add( detailEmail );
                        }
                    }
                    
                    if( QDList != null && QDList.size() > 0 ){
                        QuBY_DetailTriggerHandler.EmailToQuote( QDList );
                    }
                    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
                    QuBY_DetailTriggerHandler.TrimQuoteName( NewQuByDetailList );
                }
            }
        }
      }
    
    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
    public static void opportunityReenggineering_48( List<QuBy_Detail__c> QuByDetailList ){
        Set<id>QuoteIds = new Set<id>();
        List<QuBy_Detail__c>UpdateQD = new List<QuBy_Detail__c>();
        for( QuBy_Detail__c QD : QuByDetailList ){            
            QuoteIds.add( QD.Id );
        }
        
        Map<Id,String>QuoteIds_Email = new Map<id,String>();
        if( QuoteIds != null && QuoteIds.size() > 0 ){
            for( QuBy_Detail__c QD : [ SELECT id,Re_Engineering_Trigger_Date__c,  Recipients_Email__c,X48_hour_Notification__c FROM QuBy_Detail__c WHERE id IN : QuoteIds ] ){
                if( QD.Recipients_Email__c != null && QD.Recipients_Email__c != '' ){
                    QuoteIds_Email.put( QD.id,QD.Recipients_Email__c );                
                }
                QD.X48_hour_Notification__c = true;
                QD.Re_Engineering_Trigger_Date__c=system.now();
                UpdateQD.add( QD );
            }
        }
        if( UpdateQD != null && UpdateQD.size() > 0 ){
            system.debug( ':::' + QuoteIds_Email );
            sendEmail_New( QuoteIds_Email,[ Select id from EmailTemplate where name =: 'QuBy_48' ].ID,'48 Hour Notification' );
            update UpdateQD;
        }
    }
    
    public static void opportunityReenggineering_24( List<QuBy_Detail__c> QuByDetailList ){
        Set<id>QuoteIds = new Set<id>();
        for( QuBy_Detail__c QD : QuByDetailList ){            
            QuoteIds.add( QD.Id );
        }
        Map<Id,String>QuoteIds_Email = new Map<Id,String>();
        if( QuoteIds != null && QuoteIds.size() > 0 ){
            for( QuBy_Detail__c QD : [ SELECT id, Recipients_Email__c,X48_hour_Notification__c FROM QuBy_Detail__c WHERE id IN : QuoteIds ] ){
                if( QD.Recipients_Email__c != null && QD.Recipients_Email__c != '' ){
                    QuoteIds_Email.put( QD.id,QD.Recipients_Email__c );                
                }
            }
        }
        if( QuoteIds_Email != null && QuoteIds_Email.size() > 0 ){
            sendEmail_New( QuoteIds_Email,[ Select id from EmailTemplate where name =: 'QuBy_24' ].ID,'24 Hour Notification' );
        }
    }
    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
    
    /*##################################################################################################
    # Method Name............: opportunityAssociationToQuote
    # Param..................: List<QuBy_Detail__c> QuByDetailList
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Method is use for Associate Opportunity.
    ##################################################################################################*/
    public static void opportunityAssociationToQuote( List<QuBy_Detail__c> QuByDetailList ){
        Map<String,String>OpportunityMap = new Map<String,String>();
        Set<String>OpportunityNumbers = new Set<String>();
        
        for( QuBy_Detail__c QD : QuByDetailList ){          
            if( QD.Opportunity_No__c != null && QD.Opportunity_No__c != '' )
                OpportunityNumbers.add( QD.Opportunity_No__c );
        }
        
        if( OpportunityNumbers != null && OpportunityNumbers.size() > 0 ){
            for( Opportunity opp : [ SELECT id,Opportunity_Number__c FROM Opportunity WHERE Opportunity_Number__c IN : OpportunityNumbers ] ){
                OpportunityMap.put( opp.Opportunity_Number__c,opp.id );
            }
        }
        
        if( OpportunityMap != null && OpportunityMap.size() > 0 ){
            for( QuBy_Detail__c QD : QuByDetailList ){
                if( OpportunityMap.get( QD.Opportunity_No__c ) != null )
                    QD.Opportunity__c = OpportunityMap.get( QD.Opportunity_No__c );
            }
        }
        
    }
    
    /*##################################################################################################
    # Method Name............: opportunityDisAssociationToQuote
    # Param..................: List<QuBy_Detail__c> QuByDetailList
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Method is use for Associate Opportunity.
    ##################################################################################################*/
    public static void opportunityDisAssociationToQuote( List<QuBy_Detail__c> QuByDetailList ){
        for( QuBy_Detail__c QD : QuByDetailList ){          
            if( QD.Opportunity_No__c == null || QD.Opportunity_No__c == '' )
                QD.Opportunity__c = null;

        }
    }
    
    /*##################################################################################################
    # Method Name............: EmailToQuote
    # Param..................: List<QuBy_Detail__c> QuByDetailList
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Method is use for Associate Opportunity.
    ##################################################################################################*/
    
    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
    public static void EmailToQuote( List<QuBy_Detail__c> QuByDetailList ){        
        String finalEmail;
        Set<string>AccountIds = new Set<string>();
        Set<id>conflictAccountIds = new Set<id>();
        Map<string,string>AccountOwnerEmailMap = new Map<string,string>();
        for( QuBy_Detail__c QD : QuByDetailList  ){
            AccountIds.add( QD.Account__c );
        }
        
        if( AccountIds != null && AccountIds.size() > 0 ){
            Set<String>AdminUserSet = new Set<String>{ 'nscadmin','adminnsc' };
            for( Account acc : [ SELECT id,Owner.isActive,Owner.Quicklook_ID__c,owner.email,( SELECT owner.Email,Amount FROM Opportunities WHERE isClosed = false AND Owner.IsActive = true ) FROM Account WHERE id IN : AccountIds ] ){
                if( acc.Owner.isActive && !AdminUserSet.Contains( acc.Owner.Quicklook_ID__c ) ){
                    //For Active AND NON ADMIN USER
                    AccountOwnerEmailMap.put( acc.id,acc.owner.email );    
                    system.debug( ':::::AccountOwnerEmailMap:::::' + AccountOwnerEmailMap );    
                }else{
                    //For NOT Active AND ADMIN USER
                    if( acc.Opportunities.size() != null && acc.Opportunities.size() > 0 )
                        conflictAccountIds.add( acc.id );                   
                    else{
                        String NSCAdmin = [ SELECT Email FROM user WHERE Quicklook_ID__c =: 'nscadmin' limit 1].email;
                        AccountOwnerEmailMap.put( acc.id,NSCAdmin );    
                    }
                }
            }
        }
        
        if( conflictAccountIds != null && conflictAccountIds.size() > 0 ){            
            AccountOwnerEmailMap = findMax( conflictAccountIds );
        }
        
        for( QuBy_Detail__c QD : QuByDetailList  ){
            if( AccountOwnerEmailMap.ContainsKey( QD.Account__c ) ){                    
                //QD.Recipients_Email__c = QD.QuickLook_ID__c + '@ncr.com'; 
                QD.Recipients_Email__c = AccountOwnerEmailMap.get( QD.Account__c ); 
                QD.Backup_Email__c = null;
            }
        }
    }
    
    
    public static Map<String,String> findMax( Set<ID>AccountIds ){
        Map<String,String>OwnerAccount = new Map<String,String>();
        Map<String,String>returnMap = new Map<String,String>();
           
        if( AccountIds != null && AccountIds.size() > 0 ){
            AggregateResult[] groupedResults = [ SELECT Owner.EMAIL OE, Count(id) ce, AccountId AI FROM Opportunity WHERE AccountId IN : AccountIds AND isClosed = false AND Owner.IsActive = true GROUP BY Owner.EMAIL,AccountId ]; 
            
            Map<Integer,List<String>>tempMap = new Map<Integer,List<String>>();     
            
            for ( AggregateResult ard : groupedResults )  {             
                if( tempMap.ContainsKey( (integer)ard.get( 'ce' ) ) ){
                    tempMap.get( (integer)ard.get( 'ce' ) ).add( (STRING)ard.get( 'OE' ) );
                }else{
                    tempMap.put( (integer)ard.get( 'ce' ),new List<String>{ (STRING)ard.get( 'OE' ) } );
                }
                OwnerAccount.put( (string)ard.get( 'OE' ), (STRING)ard.get( 'AI' ) );
            }
            
            List<Integer>SortCountList = new List<Integer>();            
            SortCountList.addAll( tempMap.keySet() );
            SortCountList.sort();
            integer MAXCount = SortCountList[ SortCountList.size() - 1 ];
            
            if( tempMap.ContainsKey( MAXCount ) ){
                if( tempMap.get( MAXCount ) != null && tempMap.get( MAXCount ).size() > 0 && tempMap.get( MAXCount ).size() == 1 ){         
                    //return tempMap.get( MAXCount )[0];
                    returnMap.put( OwnerAccount.get( tempMap.get( MAXCount )[0] ),tempMap.get( MAXCount )[0] );
                }else{
                    //CHECK Amount
                    system.debug( '::::::CHECK Amount::::::' );
                    Set<String>OwnerEmail = new Set<String>();
                    OwnerEmail.AddAll( tempMap.get( MAXCount ) );
                    
                    Map<decimal,List<string>>MaxAmountMap = new Map<decimal,List<string>>();
                    
                    AggregateResult[] groupedResultsAMT = [ SELECT Owner.EMAIL OE,SUM( Amount ) AMT FROM Opportunity WHERE AccountId IN : AccountIds AND isClosed = false AND Owner.EMAIL IN : OwnerEmail GROUP BY Owner.EMAIL ];  
                    for ( AggregateResult ard : groupedResultsAMT )  {                      
                        if( MaxAmountMap.ContainsKey( (decimal)ard.get( 'AMT' ) ) ){
                            MaxAmountMap.get( (decimal)ard.get( 'AMT' ) ).add( (string)ard.get( 'OE' ) );
                        }else{
                            MaxAmountMap.put( (decimal)ard.get( 'AMT' ),new List<String>{ (string)ard.get( 'OE' ) } );
                        }
                        system.debug( ':::::MaxAmountMap::::' + MaxAmountMap );
                    }
                    system.debug( ':::::MaxAmountMap::::' + MaxAmountMap );
                    List<decimal>SortAMTList = new List<decimal>();
                    SortAMTList.addAll( MaxAmountMap.keySet() );
                    SortAMTList.sort();
                    decimal MAXAMT = SortAMTList[ SortAMTList.size() - 1 ];
                    system.debug( ':::::MAXAMT:::::' + MAXAMT );
                    if( MaxAmountMap.ContainsKey( MAXAMT ) ){
                        if( MaxAmountMap.get( MAXAMT ) != null && MaxAmountMap.get( MAXAMT ).size() > 0 && MaxAmountMap.get( MAXAMT ).size() == 1 ){
                            returnMap.put( OwnerAccount.get( MaxAmountMap.get( MAXAMT )[0] ),MaxAmountMap.get( MAXAMT )[0] );
                        }else{
                            String NSCAdmin = [ SELECT Email FROM user WHERE Quicklook_ID__c =: 'nscadmin' limit 1].email;
                            returnMap.put( OwnerAccount.get( MaxAmountMap.get( MAXAMT )[0] ),NSCAdmin );
                        }      
                    }
                }
            }
            system.debug( ':::::returnMap:::::' + returnMap );
        }
        return returnMap;
    }
    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
    
    /*##################################################################################################
    # Method Name............: AssociateAccount
    # Param..................: List<Opportunity> Opportunitys
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 17-10-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: This Method is use to associate quote to Account using MCN and countryCode
    ##################################################################################################*/
    public static void AssociateAccount( List<QuBy_Detail__c > QuByDetails  ){
        Set<string>CountryWithMasterCustomerNumber = new Set<string>();
        Map<string,String>QuoteAccountMap = new Map<string,String>();
        for( QuBy_Detail__c QD : QuByDetails ){
            CountryWithMasterCustomerNumber.add( QD.Country_Code__c + QD.MCN__c );
        }
        
        if( CountryWithMasterCustomerNumber != null && CountryWithMasterCustomerNumber.size() > 0 ){
            
            for( Account acc : [ SELECT id,Country_with_Master_customer_Number__c FROM Account WHERE Country_with_Master_customer_Number__c IN : CountryWithMasterCustomerNumber ] ){
                QuoteAccountMap.put( acc.Country_with_Master_customer_Number__c,acc.Id );
            }
            
            for( QuBy_Detail__c QD : QuByDetails ){
                if( QuoteAccountMap.ContainsKey( QD.Country_Code__c + QD.MCN__c ) ){
                    QD.Account__c = QuoteAccountMap.get( QD.Country_Code__c + QD.MCN__c );
                }
            }
        }
    }
    
    /*##################################################################################################
    # Method Name............: currencyConversation
    # Param..................: List<QuBy_Detail__c > QuByDetails
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 17-10-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: This will be supporting process for real time failures
    ##################################################################################################*/
    public static void CurrencyIsoConversion( List<QuBy_Detail__c > QuByDetails ){
        Set<String> isoCodes = new Set<String>();
        Map<String,Double> conversion_rates = new Map<String,Double>();
        
        for( QuBy_Detail__c QD : QuByDetails ){
            isoCodes.add( QD.CurrencyIsoCode );         
        }
        
        if( isoCodes != null && isoCodes.Size() > 0 ){
            for( CurrencyType curr: [ SELECT IsoCode , ConversionRate FROM CurrencyType  WHERE IsoCode in: isoCodes ] ){
                if( !conversion_rates.ContainsKey( curr.IsoCode ) )
                    conversion_rates.put( curr.IsoCode , curr.ConversionRate ); 
                     
            }
            
            for( QuBy_Detail__c QD : QuByDetails ){
                if( String.IsNotBlank( QD.CurrencyIsoCode ) && QD.CurrencyIsoCode != 'USD' ){
                    QD.Currency_Conversion_Rate__c = conversion_rates.get( QD.CurrencyIsoCode );
                }else {
                    QD.Currency_Conversion_Rate__c = conversion_rates.get( QD.CurrencyIsoCode );
                }
            }
        }
        
    }
    
    /*##################################################################################################
    # Method Name............: opportunityCreationCall
    # Param..................: Set<id>ids               :   Containing QuBy_Detail__c ids.
                               Set<String>MCNs          :   Containing MCNs
                               Set<String>SalesOrgs     :   Containing SalesOrgs
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Method is use for creating new opportunity
    ##################################################################################################*/
    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
    public static ID RecordTypeId = [ SELECT id FROM RecordType where sobjecttype = 'Opportunity' AND DeveloperName = 'IncludeinFunnel' ].Id;
    public static ID PrimaryCompetitorId = [ SELECT id FROM Competitors__c WHERE Name =: 'None' LIMIT 1].Id;
    
    public static void opportunityCreationCall( List<QuBy_Detail__c> QuByDetailList ){
        
        Set<id>ids = new Set<id>();
        Set<String>MCNs = new Set<String>();
        Set<String>SalesOrgs = new Set<String>();
        List<QuBy_Detail__c>UpdateDetail = new List<QuBy_Detail__c>();
        
        
        Map<Id,String>QuoteID_Email = new Map<Id,String>();
        for( QuBy_Detail__c QD : QuByDetailList ){          
            ids.add( QD.Id );
            MCNs.add( QD.Country_Code__c + QD.MCN__c );
            SalesOrgs.add( QD.Sales_Org_Code__c );            
        }
        if( MCNs != null && MCNs.size() > 0 && SalesOrgs != null && SalesOrgs.size() > 0 ){
            
            List<Opportunity>opportunityList = new List<Opportunity>();
            List<QuBy_Detail__c>DetailToUpdate = new List<QuBy_Detail__c>();
            Map<String,string>AccountIDMCNMap = new Map<String,string>();
            for( Account account : [ SELECT id,Country_with_Master_customer_Number__c FROM Account WHERE Country_with_Master_customer_Number__c IN : MCNs ] )
                AccountIDMCNMap.put( Account.Country_with_Master_customer_Number__c,Account.Id );
            
            
            Map<String,String>SalesOrgMap = new Map<String,String>();
            for( Sales_Org__c SO : [ SELECT id,Sales_Org_Code__c FROM Sales_Org__c WHERE Sales_Org_Code__c IN : SalesOrgs ] )
                SalesOrgMap.put( SO.Sales_Org_Code__c,SO.ID );
            
            if( ids != null && ids.size() > 0 ){
                for( QuBy_Detail__c QD : [ SELECT id ,Name,Offer_Portfolio__c,Advocated_Solution__c,Rollout_Date__c,Invoice_Trigger__c, Sales_Org_Code__c, MCN__c, Country_Code__c,CurrencyIsoCode,Opportunity__c,Recipients_Email__c,QuickLook_ID__c,Opportunity_No__c FROM QuBy_Detail__c WHERE id IN : ids ] ){
                    
                    Opportunity Opportunity = new Opportunity();            
                    Opportunity.RecordTypeId = RecordTypeId;
                    Opportunity.AccountId = AccountIDMCNMap.get( QD.Country_Code__c + QD.MCN__c );
                    Opportunity.Name = QD.Name;
                    Opportunity.CurrencyIsoCode = QD.CurrencyIsoCode;
                    Opportunity.Solution_Portfolio__c = QD.Offer_Portfolio__c;                
                    Opportunity.Type = 'Existing Customer - New Solution/Service';
                    Opportunity.Sales_Org__c = SalesOrgMap.get( QD.sales_Org_Code__c );
                    //Opportunity.Advocated_Solution__c = QD.Advocated_Solution__c;
                    Opportunity.CloseDate = date.valueof( QD.Rollout_Date__c );
                    Opportunity.Expected_Delivery_Date__c = date.valueof( QD.Rollout_Date__c ).AddDays( 1 );
                    Opportunity.Invoice_Trigger__c = QD.Invoice_Trigger__c != null && QD.Invoice_Trigger__c != '' ? QD.Invoice_Trigger__c : 'Shipment';
                    Opportunity.stageName = 'Analyzing';
                    Opportunity.ForecastCategoryName = 'Pipeline';
                    Opportunity.Primary_Competitor__c = PrimaryCompetitorId;
                    Opportunity.Marketing_Program__c = 'None';  
                    if( [ SELECT id FROM User WHERE Quicklook_ID__c =: QD.QuickLook_ID__c AND UserType =: 'Standard' AND IsActive =: true ].size() > 0 )
                        Opportunity.OwnerID = [ SELECT id FROM User WHERE Quicklook_ID__c =: QD.QuickLook_ID__c ].id;       
                    else{
                        Opportunity.OwnerID = [ SELECT id FROM User WHERE Quicklook_ID__c =: 'lr185044' ].id;       
                    }
                    Opportunity.bypass_validation__c = true;
                    insert Opportunity;
                    
                    opportunityList.add( Opportunity );
                    QD.Opportunity__c = Opportunity.Id;
                    QD.Opportunity_No__c = [ SELECT Opportunity_Number__c FROM Opportunity WHERE id =: Opportunity.Id ].Opportunity_Number__c;
                    DetailToUpdate.add( QD );
                    if( QD.Recipients_Email__c != null && QD.Recipients_Email__c != '' )
                        QuoteID_Email.put( QD.ID,QD.Recipients_Email__c );
                    else{
                        //QuoteID_Email.put( QD.ID,QD.Backup_Email__c );
                    }
                }
            }
            system.debug( '::::DetailToUpdate:::::' + DetailToUpdate );
            if( DetailToUpdate != null && DetailToUpdate.size() > 0 ){
                try{                    
                    
                    //sendEmail( opportunityList,EmailList );
                    //sendEmail_New( ids );
                    system.debug( ':::::ids::::' + ids );
                    system.debug( ':::::TEMPLATE::::' + [ Select id from EmailTemplate where name =: 'QuBy_OpportunityCreationNotification' ].ID );
                    
                    if( !test.isRunningTest() ){
                    update DetailToUpdate;
                        sendEmail_New( QuoteID_Email,[ Select id from EmailTemplate where name =: 'QuBy_OpportunityCreationNotification' ].ID,'Opportunity Creation Notification' );
                    }
                }catch( exception ex ){
                    system.debug( '::::EXCEPTION::::' + ex.getMessage() );
                }
            }
        }
    }
    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
    
    /*##################################################################################################
    # Method Name............: NTQCreationCall
    # Param..................: List<Opportunity> Opportunitys   :   List of opportunitys
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Method is use for cteating or updating NTQ Records.
    ##################################################################################################*/
    
     public static void NTQCreationCall( List<QuBy_Detail__c> QuByDetailList ){
        try{
            Set<id>ids = new Set<id>();
            Set<String>MCNs = new Set<String>();
            Set<String>QuoteNumbers = new Set<String>();
            
            for( QuBy_Detail__c QD : QuByDetailList ){
                ids.add( QD.Id );
                MCNs.add( QD.MCN__c );
                QuoteNumbers.add( QD.Quote_Number__c );
            }
            
            List<NSC_To_QuBy_Quote__c>NTQList = new List<NSC_To_QuBy_Quote__c>();
            List<NSC_To_QuBy_Quote__c>InsertNTQList = new List<NSC_To_QuBy_Quote__c>();
            List<NSC_To_QuBy_Quote__c>UpdateNTQList = new List<NSC_To_QuBy_Quote__c>();
            
            Map<String,Account>AccountIDMCNMap = new Map<String,Account>();
            if( MCNs != null && MCNs.size() > 0 ){
                for( Account account : [ SELECT id,Master_Customer_Number__c,LOB__c,Name,Owner.Name FROM Account WHERE Master_Customer_Number__c IN : MCNs ] )
                    AccountIDMCNMap.put( Account.Master_Customer_Number__c,Account );
            }
            
            NTQList = [ SELECT id, Account_LOB__c, Account_Name__c, Account_Owner__c, Account_Team__c, Account_Team_Member__c, Linkage_Flag__c, Opportunity_Id__c, Opportunity_Name__c, Opportunity_Number__c, Opportunity_Owner_QLID__c, Quote_Number__c, Updated_Date_Timestamp__c FROM NSC_To_QuBy_Quote__c WHERE Quote_Number__c IN : QuoteNumbers ];
            
            for( QuBy_Detail__c QD : [ SELECT MCN__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.Opportunity_Number__c,Opportunity__r.Owner.Quicklook_ID__c,Quote_Number__c FROM QuBy_Detail__c WHERE id IN : ids ] ){
                if( NTQList == null || NTQList.size() == 0 ){
                    NSC_To_QuBy_Quote__c NTQ = new NSC_To_QuBy_Quote__c();
                    NTQ.Account_LOB__c = AccountIDMCNMap.get( QD.MCN__c ).LOB__c;
                    NTQ.Account_Name__c = AccountIDMCNMap.get( QD.MCN__c ).Name;
                    NTQ.Account_Owner__c = AccountIDMCNMap.get( QD.MCN__c ).Owner.Name;
                    //NTQ.Account_Team__c
                    //NTQ.Account_Team_Member__c
                    NTQ.Linkage_Flag__c = QD.Opportunity__c != null ? 'L' : 'D';
                    NTQ.Opportunity_Id__c = QD.Opportunity__c;
                    NTQ.Opportunity_Name__c = QD.Opportunity__r.Name;
                    NTQ.Opportunity_Number__c = QD.Opportunity__r.Opportunity_Number__c;
                    NTQ.Opportunity_Owner_QLID__c = QD.Opportunity__r.Owner.Quicklook_ID__c;
                    NTQ.Quote_Number__c = QD.Quote_Number__c;
                    NTQ.Updated_Date_Timestamp__c = system.now();
                    InsertNTQList.add( NTQ );
                }else{
                    for( NSC_To_QuBy_Quote__c NTQ : NTQList ){
                        NTQ.Account_LOB__c = AccountIDMCNMap.get( QD.MCN__c ).LOB__c;
                        NTQ.Account_Name__c = AccountIDMCNMap.get( QD.MCN__c ).Name;
                        NTQ.Account_Owner__c = AccountIDMCNMap.get( QD.MCN__c ).Owner.Name;
                        //NTQ.Account_Team__c
                        //NTQ.Account_Team_Member__c
                        NTQ.Linkage_Flag__c = QD.Opportunity__c != null ? 'L' : 'D';
                        NTQ.Opportunity_Id__c = QD.Opportunity__c;
                        NTQ.Opportunity_Name__c = QD.Opportunity__r.Name;
                        NTQ.Opportunity_Number__c = QD.Opportunity__r.Opportunity_Number__c;
                        NTQ.Opportunity_Owner_QLID__c = QD.Opportunity__r.Owner.Quicklook_ID__c;
                        NTQ.Quote_Number__c = QD.Quote_Number__c;
                        NTQ.Updated_Date_Timestamp__c = system.now();
                        UpdateNTQList.add( NTQ );
                    }
                }
            }
            
            if( InsertNTQList != null && InsertNTQList.size() > 0 )
                insert InsertNTQList;
            
            if( UpdateNTQList != null && UpdateNTQList.size() > 0 )
                update UpdateNTQList;
            
        }catch( exception ex ){
            system.debug( '::::EXCEPTION::::' + ex.getMessage() );
        }
    }
    
    /*##################################################################################################
    # Method Name............: sendEmail_New
    # Param..................: List<Opportunity> Opportunitys   :   List of opportunitys
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: Method is use for sending email to opportunity owner.
    ##################################################################################################*/
    
    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
    public static void sendEmail_New( Map<Id,String>QuoteIds_Email,String EmailTemplateId,string subject ) {
        //Dummy Contact
        List<contact> conList = [select id from contact limit 1];
        
        EmailTemplate emailTemplate = [ Select id,HtmlValue,Body from EmailTemplate where id =: EmailTemplateId ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for( QuBy_Detail__c QubYDetail : [ SELECT id,Name,Opportunity__r.Name, Opportunity__r.Id,Opportunity_No__c,Quote_Number__c,Country_Code__c,Account__r.Name,MCN__c FROM QuBy_Detail__c WHERE ID IN : QuoteIds_Email.KeySet() ]){
            String htmlBody = emailTemplate.HtmlValue;
            
            if( htmlBody.Contains( '{!QuBy_Detail__c.Name}' ) )
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.Name}', QubYDetail.Name );
            if( htmlBody.Contains( '{!QuBy_Detail__c.Opportunity__c}' ) )
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.Opportunity__c}', QubYDetail.Opportunity__r.Name );           
            if( htmlBody.Contains( '{!QuBy_Detail__c.Opportunity_No__c}' ) )
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.Opportunity_No__c}', QubYDetail.Opportunity_No__c );
            if( htmlBody.Contains( '{!QuBy_Detail__c.Quote_Number__c}' ) )
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.Quote_Number__c}', QubYDetail.Quote_Number__c );
      if( htmlBody.Contains( '{!Opportunity.Link}' ) )
                htmlBody = htmlBody.replace('{!Opportunity.Link}', URL.getSalesforceBaseUrl().toExternalForm()+'/' +QubYDetail.Opportunity__r.Id);
            
      if( htmlBody.Contains( '#quoteUrl' ) )
                htmlBody = htmlBody.replace('#quoteUrl', URL.getSalesforceBaseUrl().toExternalForm()+'/apex/qb_landing_page?qno=' +QubYDetail.Quote_Number__c);
            if( htmlBody.Contains( '#nscUrl' ) )
                htmlBody = htmlBody.replace('#nscUrl', 'http://nsc.ncr.com');
            
            if( QubYDetail.Country_Code__c != null && QubYDetail.Country_Code__c != '' ){
                if( htmlBody.Contains( '{!QuBy_Detail__c.Country_Code__c}' ) )
                    htmlBody = htmlBody.replace('{!QuBy_Detail__c.Country_Code__c}', QubYDetail.Country_Code__c );
            }else{
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.Country_Code__c}', '' );
            }
            if( htmlBody.Contains( '{!QuBy_Detail__c.Account__c}' ) )
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.Account__c}', QubYDetail.Account__r.Name );
            if( QubYDetail.MCN__c != null && QubYDetail.MCN__c != '' ){
                if( htmlBody.Contains( '{!QuBy_Detail__c.MCN__c}' ) )
                    htmlBody = htmlBody.replace('{!QuBy_Detail__c.MCN__c}', QubYDetail.MCN__c );
            }else{
                htmlBody = htmlBody.replace('{!QuBy_Detail__c.MCN__c}', '' );
            }
            
            String plainBody = emailTemplate.Body;
            system.debug( ':::::::plainBody:::::' + plainBody );
            if( plainBody.Contains( '{!QuBy_Detail__c.Name}' ) )
                plainBody = plainBody.replace('{!QuBy_Detail__c.Name}', QubYDetail.Name );
            if( plainBody.Contains( '{!QuBy_Detail__c.Opportunity__c}' ) )
                plainBody = plainBody.replace('{!QuBy_Detail__c.Opportunity__c}', QubYDetail.Opportunity__r.Name );
            if( plainBody.Contains( '{!QuBy_Detail__c.Opportunity_No__c}' ) )
                plainBody = plainBody.replace('{!QuBy_Detail__c.Opportunity_No__c}', QubYDetail.Opportunity_No__c );
            if( plainBody.Contains( '{!QuBy_Detail__c.Quote_Number__c}' ) )
                plainBody = plainBody.replace('{!QuBy_Detail__c.Quote_Number__c}', QubYDetail.Quote_Number__c );
            if( plainBody.Contains( '{!Opportunity.Link}' ) )
                plainBody = plainBody.replace('{!Opportunity.Link}', URL.getSalesforceBaseUrl().toExternalForm()+'/' +QubYDetail.Opportunity__r.Id);
            
            if( plainBody.Contains( '#quoteUrl' ) )
                plainBody = plainBody.replace('#quoteUrl', URL.getSalesforceBaseUrl().toExternalForm()+'/apex/qb_landing_page?qno=' +QubYDetail.Quote_Number__c);
            if( plainBody.Contains( '#nscUrl' ) )
                plainBody = plainBody.replace('#nscUrl', 'http://nsc.ncr.com');
            if( QubYDetail.Country_Code__c != null && QubYDetail.Country_Code__c != '' ){
                if( plainBody.Contains( '{!QuBy_Detail__c.Country_Code__c}' ) )
                    plainBody = plainBody.replace('{!QuBy_Detail__c.Country_Code__c}', QubYDetail.Country_Code__c );
            }else{
                plainBody = plainBody.replace('{!QuBy_Detail__c.Country_Code__c}', '' );
            }
            if( plainBody.Contains( '{!QuBy_Detail__c.Account__c}' ) )
                plainBody = plainBody.replace('{!QuBy_Detail__c.Account__c}', QubYDetail.Account__r.Name );
            if( QubYDetail.MCN__c != null && QubYDetail.MCN__c != '' ){
                if( plainBody.Contains( '{!QuBy_Detail__c.MCN__c}' ) )
                    plainBody = plainBody.replace('{!QuBy_Detail__c.MCN__c}', QubYDetail.MCN__c );
            }else{
                plainBody = plainBody.replace('{!QuBy_Detail__c.MCN__c}', '' );
            }
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'NSC Administration'];
            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
            singleMail.setTargetObjectId( conList[0].Id );             
            singleMail.setToAddresses( new List<String>{ QuoteIds_Email.get( QubYDetail.Id ) } ); 
            singleMail.setTreatTargetObjectAsRecipient(false);
            singleMail.setTemplateId( EmailTemplateId ); 
            singleMail.setWhatid( QubYDetail.Id );    
            singleMail.setSaveAsActivity( false ); 
            singleMail.setHtmlBody(htmlBody);
            singleMail.setPlainTextBody(plainBody);
            singleMail.setSubject( subject );
            if ( owea.size() > 0 )
                singleMail.setOrgWideEmailAddressId( owea.get(0).Id );
            emails.add( singleMail );
            
        }
        Messaging.sendEmail(emails);
        
    }    
    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
    
    /*##################################################################################################
    # Method Name............: OpportunityStageChange
    # Param..................: List<QuBy_Detail__c> QuByDetailList
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: P1: CPQ.NSC.031: Auto update the OPPTY stage depending on the quote status.
    ##################################################################################################*/
    public static void OpportunityStageChange( List<QuBy_Detail__c> QuByDetailList ){
        Set<string>opportunityIds = new Set<string>();
        List<opportunity>opportunityToUpdate = new List<opportunity>();
        for( QuBy_Detail__c QD : QuByDetailList ){
            if( QD.Opportunity__c != null && ( QD.Annuity_Quote_Status__c == 'Submitted' || QD.Solution_Quote_Status__c == 'Submitted' ) ){
                opportunityIds.add( QD.Opportunity__c );
            }
        }
        if( opportunityIds != null && opportunityIds.size() > 0 ){
            for( opportunity opp : [ SELECT id,stagename FROM opportunity WHERE id IN : opportunityIds ] ){
                opp.stagename = 'Closing';
                opp.bypass_validation__c = true;
                opportunityToUpdate.add( opp );
            }
        }
        
        if( opportunityToUpdate != null && opportunityToUpdate.size() > 0 ){
            if(!test.isRunningTest()){
            	update opportunityToUpdate;
            }
        }
    }
    
    /*##################################################################################################
    # Method Name............: rollupOpportunity
    # Param..................: List<QuBy_Detail__c > QuByDetails
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 17-10-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: This method is use to rollup fields on opportunity ( SIDE BY SIDE VIEW )
    ##################################################################################################*/  
    //@future
    public static void rollupOpportunity( Set<id>ids  ){
        system.debug( ':::HERE CLASS:::' );
        system.debug( '::::ids::::' + ids );
        if( ids != null && ids.size() > 0 ){
            /***GETTING Remaining Fields ***/
            Map<String,String>fieldMap = new Map<String,String>{
                'AQ' => 'Annuity_Quote_Amount__c',
                'CP' => 'Cloud_Products__c',
                'HP' => 'Hardware_Products__c',
                'PSP' => 'PS_Products__c',
                'SP' => 'Services_Products__c',
                'SOP' => 'Software_Products__c',
                'SQ' => 'Solution_Quote_Amount__c'
            };
            
            Map<id,Map<String,Decimal>>QuoteValueMap = new Map<id,Map<String,Decimal>>();
            for( QuBy_Detail__c QuBy_SUM : [ SELECT id, Annuity_Quote_Amount__c, Currency_Conversion_Rate__c, Opportunity__r.Currency_Conversion_Rate__c, Cloud_Products__c,Hardware_Products__c,PS_Products__c,Services_Products__c,Software_Products__c,Solution_Quote_Amount__c,Opportunity__c FROM QuBy_Detail__c WHERE Opportunity__c IN : ids] ){
                               
                for( String str : fieldMap.keySet() ){
                    if(QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c!=null){
                    if( QuoteValueMap.ContainsKey( QuBy_SUM.Opportunity__c ) ){
                        if( QuoteValueMap.get( QuBy_SUM.Opportunity__c ).ContainsKey( fieldMap.get( str ) ) ){                          
                            Decimal val1 = QuoteValueMap.get( QuBy_SUM.Opportunity__c ).get( fieldMap.get( str ) );
                            Decimal val2 = ( (DECIMAL)QuBy_SUM.get( fieldMap.get( str ) ) == null ) ? 0 : (((DECIMAL)QuBy_SUM.get( fieldMap.get( str ) )/QuBy_SUM.Currency_Conversion_Rate__c)*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c );                         
                            QuoteValueMap.get( QuBy_SUM.Opportunity__c ).put( fieldMap.get( str ), val1 + val2 );
                            
                        }else{
                            QuoteValueMap.get( QuBy_SUM.Opportunity__c ).put( fieldMap.get( str ),( (DECIMAL)QuBy_SUM.get( fieldMap.get( str ) ) == null ) ? 0 : (((DECIMAL)QuBy_SUM.get( fieldMap.get( str ))/QuBy_SUM.Currency_Conversion_Rate__c)*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c  ) );
                            
                        }
                    }else{
                        QuoteValueMap.put( QuBy_SUM.Opportunity__c,new Map<string,decimal>{ fieldMap.get( str ) => ( (DECIMAL)QuBy_SUM.get( fieldMap.get( str ) ) == null ) ? 0 : (((DECIMAL)QuBy_SUM.get( fieldMap.get( str ))/QuBy_SUM.Currency_Conversion_Rate__c)*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c  ) } );
                        
                    }
                    }else{
                    if( QuoteValueMap.ContainsKey( QuBy_SUM.Opportunity__c ) ){
                        if( QuoteValueMap.get( QuBy_SUM.Opportunity__c ).ContainsKey( fieldMap.get( str ) ) ){                          
                            Decimal val1 = QuoteValueMap.get( QuBy_SUM.Opportunity__c ).get( fieldMap.get( str ) );
                            Decimal val2 = ( (DECIMAL)QuBy_SUM.get( fieldMap.get( str ) ) == null ) ? 0 : ((DECIMAL)QuBy_SUM.get( fieldMap.get( str ) )/QuBy_SUM.Currency_Conversion_Rate__c);                         
                            QuoteValueMap.get( QuBy_SUM.Opportunity__c ).put( fieldMap.get( str ), val1 + val2 );
                            
                        }else{
                            QuoteValueMap.get( QuBy_SUM.Opportunity__c ).put( fieldMap.get( str ),( (DECIMAL)QuBy_SUM.get( fieldMap.get( str ) ) == null ) ? 0 : (((DECIMAL)QuBy_SUM.get( fieldMap.get( str ))/QuBy_SUM.Currency_Conversion_Rate__c) ));
                            
                        }
                    }else{
                        QuoteValueMap.put( QuBy_SUM.Opportunity__c,new Map<string,decimal>{ fieldMap.get( str ) => ( (DECIMAL)QuBy_SUM.get( fieldMap.get( str ) ) == null ) ? 0 : ((DECIMAL)QuBy_SUM.get( fieldMap.get( str ))/QuBy_SUM.Currency_Conversion_Rate__c)} );
                        
                    }   
                    }
                }
                
            }
            system.debug( '::::::QuoteValueMap::::::' + QuoteValueMap );
            /***GETTING Remaining Fields ***/
            
            /***GETTING Total_Quote_Amount ***/
            Map<id,Decimal>Total_Quote_Amount_Map = new Map<id,Decimal>();
            for( QuBy_Detail__c QuBy_SUM : [ SELECT Annuity_Quote_Amount__c, Opportunity__r.Currency_Conversion_Rate__c, Solution_Quote_Amount__c,Opportunity__c,Opportunity__r.CurrencyIsoCode,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c FROM QuBy_Detail__c WHERE Opportunity__c IN : ids ] ){
                if(QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c!=null){
                    if( Total_Quote_Amount_Map.ContainsKey( QuBy_SUM.Opportunity__c ) ){
                        decimal value1 = ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        decimal value2 = ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        decimal previousVal = Total_Quote_Amount_Map.get( QuBy_SUM.Opportunity__c );
                        Total_Quote_Amount_Map.put( QuBy_SUM.Opportunity__c, value1 + value2 + previousVal );
                    }else{
                        decimal value1 = ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        decimal value2 = ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        Total_Quote_Amount_Map.put( QuBy_SUM.Opportunity__c, value1 + value2 );
                    }
                }else{
                    if( Total_Quote_Amount_Map.ContainsKey( QuBy_SUM.Opportunity__c ) ){
                        decimal value1 = ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ));
                        decimal value2 = ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ));
                        decimal previousVal = Total_Quote_Amount_Map.get( QuBy_SUM.Opportunity__c );
                        Total_Quote_Amount_Map.put( QuBy_SUM.Opportunity__c, value1 + value2 + previousVal );
                    }else{
                        decimal value1 = ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ));
                        decimal value2 = ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ));
                        Total_Quote_Amount_Map.put( QuBy_SUM.Opportunity__c, value1 + value2 );
                    }
                }
                
            }
            /***GETTING Total_Quote_Amount ***/
            
            Map<id,Decimal>Total_Quote_Closed_Amount_Map = new Map<id,Decimal>();
            Map<id,Decimal>Total_Quote_Open_Map = new Map<id,Decimal>();
            List<integer>ClosedList = new List<integer>();
            List<integer>OpenList = new List<integer>();
            decimal closedVal = 0;
            decimal openVal = 0;
            for( QuBy_Detail__c QuBy_SUM : [ SELECT Annuity_Quote_Amount__c, Opportunity__r.Currency_Conversion_Rate__c, Solution_Quote_Amount__c,Opportunity__c,Annuity_Quote_Status__c,Solution_Quote_Status__c,Opportunity__r.CurrencyIsoCode,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c FROM QuBy_Detail__c WHERE Opportunity__c IN : ids ] ){
                if(QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c!=null){
                    if( QuBy_SUM.Annuity_Quote_Status__c == 'Acknowledged' ){
                        closedVal += ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        system.debug( '::::: HERE 1 :::::' );                   
                    }
                    if( QuBy_SUM.Solution_Quote_Status__c == 'Acknowledged' ){
                        closedVal += ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        system.debug( '::::: HERE 2 :::::' );
                    }
                    if( QuBy_SUM.Annuity_Quote_Status__c != 'Acknowledged' ){
                        openVal += ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;                 
                        system.debug( '::::: HERE 3 :::::' );
                    }
                    if( QuBy_SUM.Solution_Quote_Status__c != 'Acknowledged' ){
                        openVal += ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ))*QuBy_SUM.Opportunity__r.Currency_Conversion_Rate__c;
                        system.debug( '::::: HERE 4 :::::' );
                    }
                }else{
                    if( QuBy_SUM.Annuity_Quote_Status__c == 'Acknowledged' ){
                        closedVal += ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ));
                        system.debug( '::::: HERE 1 :::::' );                   
                    }
                    if( QuBy_SUM.Solution_Quote_Status__c == 'Acknowledged' ){
                        closedVal += ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ));
                        system.debug( '::::: HERE 2 :::::' );
                    }
                    if( QuBy_SUM.Annuity_Quote_Status__c != 'Acknowledged' ){
                        openVal += ( (Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Annuity_Quote_Amount__c' ));                 
                        system.debug( '::::: HERE 3 :::::' );
                    }
                    if( QuBy_SUM.Solution_Quote_Status__c != 'Acknowledged' ){
                        openVal += ( (Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ) == null ) ? 0 : ((Decimal)QuBy_SUM.get( 'Converted_Solution_Quote_Amount__c' ));
                        system.debug( '::::: HERE 4 :::::' );
                    }
                }
                    Total_Quote_Closed_Amount_Map.put( QuBy_SUM.Opportunity__c, closedVal );
                    Total_Quote_Open_Map.put( QuBy_SUM.Opportunity__c, openVal );
                
                
                
                system.debug( '::::: HERE 5 :::::' + Total_Quote_Closed_Amount_Map);
                system.debug( '::::: HERE 6 :::::' + Total_Quote_Open_Map);
            }
            
            List<opportunity>parentsToUpdate = new List<opportunity>();
            for( Opportunity Opp : [ SELECT id,Total_Quote_Amount_QUBY__c,Total_Quote_Closed_Amount_QUBY__c,Total_Quote_Open_QUBY__c,Solution_Quote_Amount_QUBY__c,Annuity_Quote_Amount_QUBY__c,Software_Products_QUBY__c,Hardware_Products_QUBY__c,Services_Products_QUBY__c,Cloud_Products_QUBY__c,PS_Products_QUBY__c FROM Opportunity WHERE id IN : ids ] ){                 
                opp.Total_Quote_Amount_QUBY__c = Total_Quote_Amount_Map.get( opp.id );
                opp.Total_Quote_Closed_Amount_QUBY__c = Total_Quote_Closed_Amount_Map.get( opp.id );
                opp.Total_Quote_Open_QUBY__c = Total_Quote_Open_Map.get( opp.id );
                //Added one more condition so that it doesnt give null pointer exception on deleting Quote
                if( QuoteValueMap != null && QuoteValueMap.size() > 0 && QuoteValueMap.get( opp.id )!=null){
                    opp.Solution_Quote_Amount_QUBY__c = QuoteValueMap.get( opp.id ).get( 'Solution_Quote_Amount__c' );
                    opp.Annuity_Quote_Amount_QUBY__c = QuoteValueMap.get( opp.id ).get( 'Annuity_Quote_Amount__c' );
                    opp.Software_Products_QUBY__c = QuoteValueMap.get( opp.id ).get( 'Software_Products__c' );   
                    opp.Hardware_Products_QUBY__c = QuoteValueMap.get( opp.id ).get( 'Hardware_Products__c' );   
                    opp.Services_Products_QUBY__c = QuoteValueMap.get( opp.id ).get( 'Services_Products__c' );   
                    opp.Cloud_Products_QUBY__c = QuoteValueMap.get( opp.id ).get( 'Cloud_Products__c' );
                    opp.PS_Products_QUBY__c = QuoteValueMap.get( opp.id ).get( 'PS_Products__c' );
                }else{
                    opp.Solution_Quote_Amount_QUBY__c   = 0;
                    opp.Annuity_Quote_Amount_QUBY__c    = 0;
                    opp.Software_Products_QUBY__c       = 0;
                    opp.Hardware_Products_QUBY__c       = 0;
                    opp.Services_Products_QUBY__c       = 0;
                    opp.Cloud_Products_QUBY__c          = 0;
                    opp.PS_Products_QUBY__c             = 0;
                }
                opp.bypass_validation__c = true;
                parentsToUpdate.add( opp );
                
            }
            /***UPDATE OPPORTUNITY***/
            if( parentsToUpdate != null && parentsToUpdate.size() > 0 ){
                 if(!test.isRunningTest()){
                	update parentsToUpdate;
                 }
            }
            /***UPDATE OPPORTUNITY***/
            
            /***Getting Opportunity Field to Rollup***/
            
        }
    }
    
    /************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************
    @future
    public static void opportunityReenggineering( string Type, set<id>QuoteIDS ){
        if( QuoteIDS != null && QuoteIDS.size() > 0 ){
            List<QuBy_Detail__c>UpdateQD_48 = new List<QuBy_Detail__c>();
            Map<Id,String>QuoteIds_Email_48 = new Map<id,String>();
            Map<Id,String>QuoteIds_Email_24 = new Map<Id,String>();
            Map<Id,String>QuoteIds_Email_Opportunity = new Map<Id,String>();
            
            Set<String>MCNs = new Set<String>();
            Set<String>SalesOrgs = new Set<String>();
            
            for( QuBy_Detail__c QD : [ SELECT id,Quote_Number__c,Total_Quote_Amount__c,Annuity_Quote_Status__c,Solution_Quote_Status__c,Opportunity__c,Opportunity_No__c,X48_hour_Notification__c,isChannel__c,X24_hour_Notification__c,Reengineering_Opportunity__c,Recipients_Email__c,Country_Code__c,MCN__c,Sales_Org_Code__c FROM QuBy_Detail__c WHERE id IN : QuoteIDS ] ){
                
                if( Type != null && Type == 'QuBy_48' ){
                    QuoteIds_Email_48.put( QD.id,QD.Recipients_Email__c );
                    QD.X48_hour_Notification__c = true;
                    QD.Re_Engineering_Trigger_Date__c=system.now();
                    UpdateQD_48.add( QD );
                }
                
                if( Type != null && Type == 'QuBy_24' ){
                    QuoteIds_Email_24.put( QD.id,QD.Recipients_Email__c );                     
                }
                
                if( Type != null && Type == 'QuBy_OpportunityCreationNotification' ){                    
                    QuoteIds_Email_Opportunity.put( QD.ID,QD.Recipients_Email__c );   
                    MCNs.add( QD.Country_Code__c + QD.MCN__c );
                    SalesOrgs.add( QD.Sales_Org_Code__c );
                }
                
            }
            
            if( UpdateQD_48 != null && UpdateQD_48.size() > 0 ){            
                update UpdateQD_48;
            }
            if( QuoteIds_Email_48 != null && QuoteIds_Email_48.size() > 0 ){
                sendEmail_New( QuoteIds_Email_48,[ Select id from EmailTemplate where name =: Type ].ID,'48 Hour Notification' );
            }
            if( QuoteIds_Email_24 != null && QuoteIds_Email_24.size() > 0 ){
                sendEmail_New( QuoteIds_Email_24,[ Select id from EmailTemplate where name =: Type ].ID,'24 Hour Notification' );
            }
            if( QuoteIds_Email_Opportunity != null && QuoteIds_Email_Opportunity.size() > 0 ){
                ID RecordTypeIdOpp = [ SELECT id FROM RecordType where sobjecttype = 'Opportunity' AND DeveloperName = 'IncludeinFunnel' ].Id;
                ID PrimaryCompetitorIdOpp = [ SELECT id FROM Competitors__c WHERE Name =: 'None' LIMIT 1].Id;
                if( MCNs != null && MCNs.size() > 0 && SalesOrgs != null && SalesOrgs.size() > 0 ){
                    Map<String,string>AccountIDMCNMap = new Map<String,string>();
                    for( Account account : [ SELECT id,Country_with_Master_customer_Number__c FROM Account WHERE Country_with_Master_customer_Number__c IN : MCNs ] )
                        AccountIDMCNMap.put( Account.Country_with_Master_customer_Number__c,Account.Id );
                    
                    Map<String,String>SalesOrgMap = new Map<String,String>();
                    for( Sales_Org__c SO : [ SELECT id,Sales_Org_Code__c FROM Sales_Org__c WHERE Sales_Org_Code__c IN : SalesOrgs ] )
                        SalesOrgMap.put( SO.Sales_Org_Code__c,SO.ID );
                    
                    
                    List<Opportunity>opportunityList = new List<Opportunity>();
                    List<QuBy_Detail__c>DetailToUpdate = new List<QuBy_Detail__c>();
                    for( QuBy_Detail__c QD : [ SELECT id ,Name,Offer_Portfolio__c,Advocated_Solution__c,Rollout_Date__c,Invoice_Trigger__c, Sales_Org_Code__c, MCN__c, Country_Code__c,CurrencyIsoCode,Opportunity__c,Recipients_Email__c,QuickLook_ID__c,Opportunity_No__c FROM QuBy_Detail__c WHERE id IN : QuoteIds_Email_Opportunity.keySet() ] ){
                        try{
                            Opportunity Opportunity = new Opportunity();            
                            Opportunity.RecordTypeId = RecordTypeIdOpp;
                            Opportunity.AccountId = AccountIDMCNMap.get( QD.Country_Code__c + QD.MCN__c );
                            Opportunity.Name = QD.Name;
                            Opportunity.CurrencyIsoCode = QD.CurrencyIsoCode;
                            Opportunity.Solution_Portfolio__c = QD.Offer_Portfolio__c;
                            
                            Opportunity.Type = 'Existing Customer - New Solution/Service';
                            Opportunity.Sales_Org__c = SalesOrgMap.get( QD.sales_Org_Code__c );
                            //Opportunity.Advocated_Solution__c = QD.Advocated_Solution__c;
                            Opportunity.CloseDate = date.valueof( QD.Rollout_Date__c );
                            //Opportunity.Expected_Delivery_Date__c = date.valueof( QD.Rollout_Date__c ).AddDays( 1 );
                            Opportunity.Expected_Delivery_Date__c = ( QD.Rollout_Date__c == null ) ? system.today().AddDays( 1 ) : date.valueof( QD.Rollout_Date__c ).AddDays( 1 );
                            Opportunity.Invoice_Trigger__c = QD.Invoice_Trigger__c != null && QD.Invoice_Trigger__c != '' ? QD.Invoice_Trigger__c : 'Shipment';
                            Opportunity.stageName = 'Analyzing';
                            Opportunity.ForecastCategoryName = 'Pipeline';
                            Opportunity.Primary_Competitor__c = PrimaryCompetitorIdOpp;
                            Opportunity.Marketing_Program__c = 'None';  
                        
                            string QLID = QuoteIds_Email_Opportunity.get( QD.id ).substringBefore('@ncr.com');
                            
                            if( [ SELECT id FROM User WHERE Quicklook_ID__c =: QLID AND UserType =: 'Standard' AND IsActive =: true ].size() > 0 )
                                Opportunity.OwnerID = [ SELECT id FROM User WHERE Quicklook_ID__c =: QLID ].id;       
                            
                            Opportunity.bypass_validation__c = true;
                            insert Opportunity; 
                            opportunityList.add( Opportunity );
                            QD.Opportunity__c = Opportunity.Id;
                            QD.Opportunity_No__c = [ SELECT Opportunity_Number__c FROM Opportunity WHERE id =: Opportunity.Id ].Opportunity_Number__c;
                            DetailToUpdate.add( QD );
                        }catch( exception ex ){
                            system.debug( '::::EXCEPTION:::::::' + ex.getMessage() );
                        }
                    } 
                    if( DetailToUpdate != null && DetailToUpdate.size() > 0 ){
                        if( !test.isRunningTest() ){
                            update DetailToUpdate;
                            doNotCallTrigger = true;
                            sendEmail_New( QuoteIds_Email_Opportunity,[ Select id from EmailTemplate where name =: Type ].ID,'Opportunity Creation Notification' );
                        }
                    }
                }           
                
            }
        }
    }
    
    ************ NC_AGILE-598 : STOP OPPORTUNITY Re-engineering ON 5-16-2017 ************/
    
    /*##################################################################################################
    # Method Name............: TrimQuoteName
    # Param..................: List<QuBy_Detail__c> QuByDetailList
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-08-2016
    # Description............: If Quote name length is greater than 80 put the name in descreption field and trim it to 80.
    ##################################################################################################*/
    public static void TrimQuoteName( List<QuBy_Detail__c> QuByDetailList ){
        
        for( QuBy_Detail__c QD : QuByDetailList ){ 
         // Description is not null  
         if( QD.Description__c!=null){
            if( QD.Description__c.length() > 80 ){                               
                QD.name = QD.Description__c.substring( 0,79 );                
            }else{
                QD.name = QD.Description__c;
            }
           }
        }
        
        
    }
    
    /*public static void testHack(){
        string a_1; string b_1; string c_1; string d_1; string e_1; string f_1; string g_1; string h_1; string i_1; string j_1; string k_1; 
        string a_2; string b_2; string c_2; string d_2; string e_2; string f_2; string g_2; string h_2; string i_2; string j_2; string k_2; 
        string a_3; string b_3; string c_3; string d_3; string e_3; string f_3; string g_3; string h_3; string i_3; string j_3; string k_3; 
        string a_4; string b_4; string c_4; string d_4; string e_4; string f_4; string g_4; string h_4; string i_4; string j_4; string k_4; 
        string a_5; string b_5; string c_5; string d_5; string e_5; string f_5; string g_5; string h_5; string i_5; string j_5; string k_5; 
        string a_6; string b_6; string c_6; string d_6; string e_6; string f_6; string g_6; string h_6; string i_6; string j_6; string k_6; 
        string a_7; string b_7; string c_7; string d_7; string e_7; string f_7; string g_7; string h_7; string i_7; string j_7; string k_7; 
        string a_8; string b_8; string c_8; string d_8; string e_8; string f_8; string g_8; string h_8; string i_8; string j_8; string k_8; 
        string a_9; string b_9; string c_9; string d_9; string e_9; string f_9; string g_9; string h_9; string i_9; string j_9; string k_9; 
        string a_0; string b_0; string c_0; string d_0; string e_0; string f_0; string g_0; string h_0; string i_0; string j_0; string k_0; 
        
        string l_1; string m_1; string n_1; string o_1; string p_1; string q_1; string r_1; string s_1; string t_1; string u_1; string v_1; 
        string l_2; string m_2; string n_2; string o_2; string p_2; string q_2; string r_2; string s_2; string t_2; string u_2; string v_2; 
        string l_3; string m_3; string n_3; string o_3; string p_3; string q_3; string r_3; string s_3; string t_3; string u_3; string v_3; 
        string l_4; string m_4; string n_4; string o_4; string p_4; string q_4; string r_4; string s_4; string t_4; string u_4; string v_4; 
        string l_5; string m_5; string n_5; string o_5; string p_5; string q_5; string r_5; string s_5; string t_5; string u_5; string v_5; 
        string l_6; string m_6; string n_6; string o_6; string p_6; string q_6; string r_6; string s_6; string t_6; string u_6; string v_6; 
        string l_7; string m_7; string n_7; string o_7; string p_7; string q_7; string r_7; string s_7; string t_7; string u_7; string v_7; 
        string l_8; string m_8; string n_8; string o_8; string p_8; string q_8; string r_8; string s_8; string t_8; string u_8; string v_8; 
        string l_9; string m_9; string n_9; string o_9; string p_9; string q_9; string r_9; string s_9; string t_9; string u_9; string v_9; 
        string l_0; string m_0; string n_0; string o_0; string p_0; string q_0; string r_0; string s_0; string t_0; string u_0; string v_0;
        
        string w_1; string x_1; string y_1; string z_1;
        string w_2; string x_2; string y_2; string z_2;
        string w_3; string x_3; string y_3; string z_3;
        string w_4; string x_4; string y_4; string z_4;
        string w_5; string x_5; string y_5; string z_5;
        string w_6; string x_6; string y_6; string z_6;
        string w_7; string x_7; string y_7; string z_7;
        string w_8; string x_8; string y_8; string z_8;
        string w_9; string x_9; string y_9; string z_9;
        string w_0; string x_0; string y_0; string z_0;
    }
    
    public static void testHack_1(){
        string a_1; string b_1; string c_1; string d_1; string e_1; string f_1; string g_1; string h_1; string i_1; string j_1; string k_1; 
        string a_2; string b_2; string c_2; string d_2; string e_2; string f_2; string g_2; string h_2; string i_2; string j_2; string k_2; 
        string a_3; string b_3; string c_3; string d_3; string e_3; string f_3; string g_3; string h_3; string i_3; string j_3; string k_3; 
        string a_4; string b_4; string c_4; string d_4; string e_4; string f_4; string g_4; string h_4; string i_4; string j_4; string k_4; 
        string a_5; string b_5; string c_5; string d_5; string e_5; string f_5; string g_5; string h_5; string i_5; string j_5; string k_5; 
        string a_6; string b_6; string c_6; string d_6; string e_6; string f_6; string g_6; string h_6; string i_6; string j_6; string k_6; 
        string a_7; string b_7; string c_7; string d_7; string e_7; string f_7; string g_7; string h_7; string i_7; string j_7; string k_7; 
        string a_8; string b_8; string c_8; string d_8; string e_8; string f_8; string g_8; string h_8; string i_8; string j_8; string k_8; 
        string a_9; string b_9; string c_9; string d_9; string e_9; string f_9; string g_9; string h_9; string i_9; string j_9; string k_9; 
        string a_0; string b_0; string c_0; string d_0; string e_0; string f_0; string g_0; string h_0; string i_0; string j_0; string k_0; 
        
        string l_1; string m_1; string n_1; string o_1; string p_1; string q_1; string r_1; string s_1; string t_1; string u_1; string v_1; 
        string l_2; string m_2; string n_2; string o_2; string p_2; string q_2; string r_2; string s_2; string t_2; string u_2; string v_2; 
        string l_3; string m_3; string n_3; string o_3; string p_3; string q_3; string r_3; string s_3; string t_3; string u_3; string v_3; 
        string l_4; string m_4; string n_4; string o_4; string p_4; string q_4; string r_4; string s_4; string t_4; string u_4; string v_4; 
        string l_5; string m_5; string n_5; string o_5; string p_5; string q_5; string r_5; string s_5; string t_5; string u_5; string v_5; 
        string l_6; string m_6; string n_6; string o_6; string p_6; string q_6; string r_6; string s_6; string t_6; string u_6; string v_6; 
        string l_7; string m_7; string n_7; string o_7; string p_7; string q_7; string r_7; string s_7; string t_7; string u_7; string v_7; 
        string l_8; string m_8; string n_8; string o_8; string p_8; string q_8; string r_8; string s_8; string t_8; string u_8; string v_8; 
        string l_9; string m_9; string n_9; string o_9; string p_9; string q_9; string r_9; string s_9; string t_9; string u_9; string v_9; 
        string l_0; string m_0; string n_0; string o_0; string p_0; string q_0; string r_0; string s_0; string t_0; string u_0; string v_0;
        
        string w_1; string x_1; string y_1; string z_1;
        string w_2; string x_2; string y_2; string z_2;
        string w_3; string x_3; string y_3; string z_3;
        string w_4; string x_4; string y_4; string z_4;
        string w_5; string x_5; string y_5; string z_5;
        string w_6; string x_6; string y_6; string z_6;
        string w_7; string x_7; string y_7; string z_7;
        string w_8; string x_8; string y_8; string z_8;
        string w_9; string x_9; string y_9; string z_9;
        string w_0; string x_0; string y_0; string z_0;
    }*/
    @future
    public static void deleteQte( Set<id>ids  ){
        List <QuBy_Detail__c> Qts= new List<QuBy_Detail__c>();
        for(Id qtid:ids){
            QuBy_Detail__c qd=new QuBy_Detail__c(Id=qtid);
            Qts.add(qd);
        }
        Delete Qts;
    }
    
}