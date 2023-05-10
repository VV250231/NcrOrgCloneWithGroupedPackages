/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_QuoteRelatedList.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 28-07-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 28-07-2016
# Description...........: All quotes associated with a single opportunity will
display quote values order numbers (if acknowledged) and displayed on the opportunity page.

##################################################################################################*/
public class QuBy_QuoteRelatedList{

    /*#################################################################################################################
    # Method Name............: isDisabled
    # Param..................: None                                               
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017                                                                             
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017                                                                             
    # Description............: This method is use to check if user have access of this whole component functionality.                               
    #################################################################################################################*/
    @AuraEnabled
    public static boolean isDisabled( ){
        /*if( QuBy_LTNG_ProfileCheck__c.getValues( userInfo.getProfileId() ) == null ){ 
            return true;
        }else{
            return false;
        }*/
         set<string> st  = new set<string>();
        List<All_profie_list_config__c> mcs = All_profie_list_config__c.getall().values();
        for(All_profie_list_config__c p : mcs ){
            if(p.QuBy_LTNG_ProfileCheck__c == true){
                st.add(p.Profile_id__c);
            }            
        } 
        if(! st.Contains( userInfo.getProfileId())){
            return true;
        }else{
            return false;
        }
    }
    
    /*#################################################################################################################
    # Method Name............: getRecords
    # Param..................: String opportunityId     :   Opportunity Record Id
    decimal pageNumber      :   PageNumber
    String pageSize          :  Page Size                                     
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017                                                                             
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017                                                                             
    # Description............: This method is use to fetch already associated quotes to the Opportunity.                                
    #################################################################################################################*/
    @AuraEnabled
    public static lightningTableWrapper getRecords( String opportunityId ){     
        
        //String queryString = 'Select id,Order_Type__c,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c,CreatedDate from QuBy_Detail__c WHERE Opportunity__c =: opportunityId AND ( Annuity_Modification_Date__c < LAST_N_DAYS:365 OR Solution_Modification_Date__c < LAST_N_DAYS:365 ) ORDER BY Annuity_Modification_Date__c DESC ';
      String queryString = 'Select id,Order_Type__c,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c,CreatedDate from QuBy_Detail__c WHERE Opportunity__c =: opportunityId  ORDER BY Annuity_Modification_Date__c DESC ';
 lightningTableWrapper ltw = new lightningTableWrapper();
       // ltw.total = [ Select count() from QuBy_Detail__c WHERE Opportunity__c =: opportunityId AND ( Annuity_Modification_Date__c < LAST_N_DAYS:365 OR Solution_Modification_Date__c < LAST_N_DAYS:365 ) ];
        ltw.total = [ Select count() from QuBy_Detail__c WHERE Opportunity__c =: opportunityId  ];
        List<dataWrapper> dataList = new List<dataWrapper>();
        for( QuBy_Detail__c QD : database.query( String.escapeSingleQuotes(queryString) ) ){
            dataList.add( new dataWrapper( QD ) );  
        }
        ltw.sObjectrecords = dataList;
        return ltw;
    }
    
    
    /*#################################################################################################################
    # Method Name............: availableQuotes
    # Param..................: List <String> disQuoteId         :   List of Quotes Id which we have to disAssociate.
    string OpportunityID             :  Opportunity Record Id.                                          
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: This method is use for Disassociating Existing Quote from opportunity.
    #################################################################################################################*/
    @AuraEnabled
    public static lightningTableWrapper getAvailableQuotes( String opportunityId ){
        string AccountMCN = [ SELECT Account.Master_Customer_Number__c FROM Opportunity WHERE ID =: opportunityId LIMIT 1 ].Account.Master_Customer_Number__c;
        string countryCode = [ SELECT Account.Account_Country_Code__c FROM Opportunity WHERE ID =: opportunityId LIMIT 1 ].Account.Account_Country_Code__c;
        //string isChannel='true';
        
        String queryString = 'Select id,Order_Type__c,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c,CreatedDate from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode  AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) ORDER BY Annuity_Modification_Date__c DESC ';
        //String queryString = 'Select id,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c from QuBy_Detail__c ';
        lightningTableWrapper ltw = new lightningTableWrapper();
        ltw.total = [ Select count() from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode  AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) ];
        //ltw.total = [ Select count() from QuBy_Detail__c ];
        List<dataWrapper> dataList = new List<dataWrapper>();
        for( QuBy_Detail__c QD : database.query( String.escapeSingleQuotes(queryString) ) ){
            dataList.add( new dataWrapper( QD ) );  
        }
        ltw.sObjectrecords = dataList;
        return ltw;
    }
    
    /*#################################################################################################################
    # Method Name............: availableQuotesInBatches
    # Param..................: string opportunityId :1opportunity Id and loffset and imits to fetch available Quotes.
    string OpportunityID             :  Opportunity Record Id.                                          
    # Created by.............: Ravikant Maurya                                                                 
    # Created Date...........: 09-07-2018
    # Last Modified by.......: Ravikant maurya 
    # Last Modified Date.....: 20-04-2017
    # Description............: This method is use for fetching defined size Quote from opportunity.
    #################################################################################################################*/
    @AuraEnabled
    public static lightningTableWrapper availableQuotesInBatches( String opportunityId, Integer limits , Integer offsets ){
        Integer intlimits = integer.valueof(limits);
        Integer intoffsets = integer.valueof(offsets);
        string AccountMCN = [ SELECT Account.Master_Customer_Number__c FROM Opportunity WHERE ID =: opportunityId LIMIT 1 ].Account.Master_Customer_Number__c;
        string countryCode = [ SELECT Account.Account_Country_Code__c FROM Opportunity WHERE ID =: opportunityId LIMIT 1 ].Account.Account_Country_Code__c;
        //string isChannel='true';
        
        String queryString = 'Select id,Order_Type__c,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c,CreatedDate from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode  AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) ORDER BY Annuity_Modification_Date__c DESC  Limit :intlimits Offset :intoffsets';
        
        //System.debug('@@@@'+queryString);
        //String queryString = 'Select id,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c from QuBy_Detail__c  Limit :intlimits Offset :intoffsets ';
        lightningTableWrapper ltw = new lightningTableWrapper();
        ltw.total = [ Select count() from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode  AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) ];
    
        List<dataWrapper> dataList = new List<dataWrapper>();
        for( QuBy_Detail__c QD : database.query( String.escapeSingleQuotes(queryString) ) ){
            dataList.add( new dataWrapper( QD ) );  
        }
        ltw.sObjectrecords = dataList;
        return ltw;
    }
    
    
    
    /*#################################################################################################################
    # Method Name............: search
    # Param..................: List <String> disQuoteId         :   List of Quotes Id which we have to disAssociate.
                               string OpportunityID             :   Opportunity Record Id.                                          
                               String searchstr
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: This method is use for search.
    #################################################################################################################*/
    @AuraEnabled
    public static lightningTableWrapper search( String opportunityId,string searchstr ){ 
         String SearchCondition = '%' + searchstr + '%';
        
        String queryString = 'Select id,Order_Type__c,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c,CreatedDate from QuBy_Detail__c WHERE Opportunity__c =: opportunityId AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) AND ( Quote_Number__c LIKE: SearchCondition OR Name LIKE: SearchCondition ) ORDER BY Annuity_Modification_Date__c DESC '; 
        //system.debug('::::queryString::::' + queryString);
        lightningTableWrapper ltw = new lightningTableWrapper();
        
        String countString = 'Select COUNT() from QuBy_Detail__c WHERE Opportunity__c =: opportunityId AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) AND ( Quote_Number__c LIKE: SearchCondition OR Name  LIKE: SearchCondition ) '; 
        ltw.total = Database.countQuery( countString );
        List<dataWrapper> dataList = new List<dataWrapper>();
        for( QuBy_Detail__c QD : database.query( String.escapeSingleQuotes(queryString) ) ){
            dataList.add( new dataWrapper( QD ) );  
        }
        //system.debug('::::dataList:::' + dataList );
        
        ltw.sObjectrecords = dataList;
        return ltw;
    }
    
    /*#################################################################################################################
    # Method Name............: searchAvailableQuotes
    # Param..................: List <String> disQuoteId         :   List of Quotes Id which we have to disAssociate.
    string OpportunityID             :  Opportunity Record Id.                                          
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: This method is use for Disassociating Existing Quote from opportunity.
    #################################################################################################################*/
    @AuraEnabled
    public static lightningTableWrapper searchAvailableQuotes( String opportunityId,string searchstr ){
        string AccountMCN = [ SELECT Account.Master_Customer_Number__c FROM Opportunity WHERE ID =: opportunityId LIMIT 1 ].Account.Master_Customer_Number__c;
        string countryCode = [ SELECT Account.Account_Country_Code__c FROM Opportunity WHERE ID =: opportunityId LIMIT 1 ].Account.Account_Country_Code__c;
        String SearchCondition = '%' + searchstr + '%';
        
        String queryString = 'Select id,Order_Type__c,Quote_Number__c,Name,ERP_Order_Number__c,MCN__c,Solution_Quote_Status__c, Annuity_Quote_Status__c,CurrencyIsoCode,Annuity_Modification_Date__c,Solution_Modification_Date__c,Converted_Annuity_Quote_Amount__c,Converted_Solution_Quote_Amount__c,Total_Quote_Amount__c,CreatedDate from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode AND  ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) AND ( Quote_Number__c LIKE: SearchCondition OR Name  LIKE: SearchCondition ) ORDER BY Annuity_Modification_Date__c DESC ';
        lightningTableWrapper ltw = new lightningTableWrapper();
        //ltw.total = [ Select count() from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode AND isChannel__c !=: isChannel AND Lastmodifieddate > LAST_N_DAYS:365 ];
        
        String countString = 'Select COUNT() from QuBy_Detail__c WHERE Opportunity__c = null AND MCN__c =: AccountMCN AND Country_Code__c =: countryCode  AND ( Annuity_Modification_Date__c = LAST_N_DAYS:365 OR Solution_Modification_Date__c = LAST_N_DAYS:365 ) AND ( Quote_Number__c LIKE: SearchCondition OR Name LIKE: SearchCondition ) '; 
        ltw.total = Database.countQuery( countString );
        
        List<dataWrapper> dataList = new List<dataWrapper>();
        for( QuBy_Detail__c QD : database.query( String.escapeSingleQuotes(queryString) ) ){
            dataList.add( new dataWrapper( QD ) );  
        }
        ltw.sObjectrecords = dataList;
        return ltw;
    }
    
    
    
    /*#################################################################################################################
    # Method Name............: disAssociateQuote
    # Param..................: List <String> disQuoteId         :   List of Quotes Id which we have to disAssociate.
    string OpportunityID             :  Opportunity Record Id.                                          
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: This method is use for Disassociating Existing Quote from opportunity.
    #################################################################################################################*/
    @AuraEnabled
    public static messageWrapper disAssociateQuote( List <String> disQuoteId,string OpportunityID ){        
        Set<string>allowedProfile = new Set<string>{ '04 NSC UI Administrator','System Administrator','02 NSC Administrator','01 GS Admin','03 PRM Admin' };        
            opportunity opportunity = [ SELECT stagename, isClosed FROM Opportunity WHERE id =: OpportunityID LIMIT 1];     
        String profileName = [ Select Name from Profile where Id =: UserInfo.getProfileId() ].Name;        
        
        messageWrapper MW = new messageWrapper();       
         
        if( opportunity.isClosed && !allowedProfile.Contains( profileName ) ){                                  
            MW.type = 'error';
            MW.Message = 'You cannot disassociate quote from a closed opportunity.';
        }else{
            if( disQuoteId != null && disQuoteId.size() > 0 ){
                List<QuBy_Detail__c>updateDetails = new List<QuBy_Detail__c>();
                for( QuBy_Detail__c QBDET : [ SELECT id,Opportunity__c,Opportunity_No__c FROM QuBy_Detail__c WHERE ID IN : disQuoteId ] ){
                    QBDET.Opportunity__c = null;
                    QBDET.Opportunity_No__c = null;
                    updateDetails.add( QBDET );
                }
                
                if( updateDetails != null && updateDetails.size() > 0 ){
                    try{
                        if ( Schema.sObjectType.QuBy_Detail__c.isUpdateable() ){
                          update updateDetails;
                            MW.type = 'success';
                          MW.Message = updateDetails.size() + ' Quote disassociate successfully.';
                        }else{                          
                            MW.type = 'error';
                            MW.Message = 'You are not authorized to Disassociate Quotes. Please Contact Sales Operations for Access.';    
                        }
                    }catch( exception QE ){
                        //system.debug( 'ERROR : ' + QE.getMessage() );
                        MW.type = 'error';
                        if(QE.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ) {
                            String tempStr = QE.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,') ;
                            String msg = tempStr.substringBefore(':') ;
                            MW.Message = msg;
                        } else if(QE.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                            String tempStr = QE.getMessage().substringAfter('FIELD_FILTER_VALIDATION_EXCEPTION,') ;
                            String msg = tempStr.substringBefore(':') ;
                            MW.Message = msg;
                        }
                        else {
                            //MW.Message = QE.getMessage();
                            MW.Message = 'Some internal error occured, Please contact your System Administrator.';
                        }
                    }
                }                
            }else{
                MW.type = 'info';
                MW.Message = 'Please select atleast one quote to disAssociate.';
            }
        }
        return MW;
    }
    
    /*##################################################################################################
    # Method Name............: associateQuote
    # Param..................: None                                               
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 28-07-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 28-07-2016
    # Description............: This method is use for associating QuBy Quote.                          
    ##################################################################################################*/
    @AuraEnabled
    public static messageWrapper associateQuote( List <String> QuoteId,string OpportunityID ){
        Set<string>allowedProfile = new Set<string>{ '04 NSC UI Administrator','System Administrator','02 NSC Administrator','01 GS Admin','03 PRM Admin' };
            opportunity opportunity = [ SELECT stagename, isClosed FROM Opportunity WHERE id =: OpportunityID LIMIT 1]; 
        String profileName = [ Select Name from Profile where Id =: UserInfo.getProfileId() ].Name;
        String oppNumber =[ SELECT Opportunity_Number__c FROM Opportunity WHERE id =: OpportunityID LIMIT 1 ].Opportunity_Number__c;
        
        messageWrapper MW = new messageWrapper();   
        
        if( opportunity.isClosed  && !allowedProfile.Contains( profileName ) ){
            MW.type = 'error';MW.Message = 'You cannot associate quote to a closed opportunity.';         
        }else{
            if( QuoteId != null && QuoteId.size() > 0 ){
                List<QuBy_Detail__c>updateDetails = new List<QuBy_Detail__c>();
                for( QuBy_Detail__c QBDET : [ SELECT id,Opportunity_No__c FROM QuBy_Detail__c WHERE ID IN : QuoteId ] ){
                    QBDET.Opportunity_No__c = oppNumber;                    
                    updateDetails.add( QBDET );
                }   
                if( updateDetails != null && updateDetails.size() > 0 ){
                    try{
                        if ( Schema.sObjectType.QuBy_Detail__c.isUpdateable() ){
                            update updateDetails;
                            
                            MW.type = 'success';
                            MW.Message = updateDetails.size() + ' Quote Associate successfully.';
                        }else{
                          MW.type = 'error';
                          MW.Message = 'You are not authorized to Associate Quotes. Please Contact Sales Operations for Access.';
                        }
                    }catch( exception QE ){
                        //system.debug( 'CUSTOM ERROR : ' + QE.getMessage() ); 
                        MW.type = 'error';
                        if(QE.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                            String tempStr = QE.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,') ;String msg = tempStr.substringBefore(':') ;MW.Message = msg;
                        } else if(QE.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                            String tempStr = QE.getMessage().substringAfter('FIELD_FILTER_VALIDATION_EXCEPTION,') ;String msg = tempStr.substringBefore(':') ;MW.Message = msg;
                        }
                        else {
                            //MW.Message = QE.getMessage();
                            MW.Message = 'Some internal error occured, Please contact your System Administrator.';
                        }
                        
                        
                    }
                    
                }
                
            }else{
                MW.type = 'info';MW.Message = 'Please select atleast one quote to Associate.';
            }
        }
        return MW;
    }
    
    /*#################################################################################################################
    # Method Name............: lightningTableWrapper
    # Param..................: None                                         
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: Wrapper for Pagination with data Wrapper List.
    #################################################################################################################*/
    public class lightningTableWrapper {
        @AuraEnabled
        public Integer page { get;set; }
        
        @AuraEnabled
        public Integer total { get;set; }
        
        @AuraEnabled
        public List<dataWrapper> sObjectrecords { get;set; }
    }
    
    /*#################################################################################################################
    # Method Name............: dataWrapper
    # Param..................: None                                         
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: Wrapper for showing table. Both Associate and Disassociate.
    #################################################################################################################*/
    public class dataWrapper{
        @AuraEnabled public string id{get;set;}    
        @AuraEnabled public string QuoteNumber{get;set;}        
        @AuraEnabled public string QuoteName{get;set;}
        @AuraEnabled public integer QuoteAmount{get;set;}       
        @AuraEnabled public string OrderNumber{get;set;}
        @AuraEnabled public string OrderType{get;set;}
        @AuraEnabled public string modificationDate{get;set;}
        @AuraEnabled public string SolutionQuoteStatus{get;set;}
        @AuraEnabled public string AnnuityQuoteStatus{get;set;}
        @AuraEnabled Public Date CreatedDate{get;set;}
        
        public dataWrapper( QuBy_Detail__c QD ){
            this.id = QD.Id;
            this.QuoteNumber = QD.Quote_Number__c;
            
            this.QuoteName = QD.Name;
            //this.CreatedDate = date.newinstance(QD.CreatedDate.year(), QD.CreatedDate.month(), QD.CreatedDate.day());
            
            if( ( QD.Annuity_Quote_Status__c != null && QD.Annuity_Quote_Status__c.toUpperCase() == 'ACKNOWLEDGED') || ( QD.Solution_Quote_Status__c != null && QD.Solution_Quote_Status__c.toUpperCase() == 'ACKNOWLEDGED' ) ){
                this.OrderNumber = QD.ERP_Order_Number__c;
            }else{
                this.OrderNumber = '-';
            }
            
            
            this.AnnuityQuoteStatus = QD.Annuity_Quote_Status__c;
            this.SolutionQuoteStatus = QD.Solution_Quote_Status__c;
            this.QuoteAmount = integer.valueof( QD.Total_Quote_Amount__c );
            
            if( QD.Annuity_Modification_Date__c == null && QD.Solution_Modification_Date__c == null  ){
                this.modificationDate = '';
            }else if( QD.Annuity_Modification_Date__c != null && QD.Solution_Modification_Date__c == null ){
                this.modificationDate = string.valueof( QD.Annuity_Modification_Date__c );              
            }else if( QD.Annuity_Modification_Date__c == null && QD.Solution_Modification_Date__c != null ){
                this.modificationDate = string.valueof( QD.Solution_Modification_Date__c );             
            }else if( QD.Solution_Modification_Date__c > QD.Annuity_Modification_Date__c ) {
                this.modificationDate = string.valueof( QD.Solution_Modification_Date__c );             
            }else{
                this.modificationDate = string.valueof( QD.Annuity_Modification_Date__c );
            }
           this.OrderType = QD.Order_Type__c; 
        }
    }
    
    /*#################################################################################################################
    # Method Name............: messageWrapper
    # Param..................: None                                         
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 20-04-2017
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 20-04-2017
    # Description............: Wrapper for showing Messages.
    #################################################################################################################*/
    public class messageWrapper{
        @AuraEnabled public string type{get;set;}           
        @AuraEnabled public string Message{get;set;}
    }
}