public class FinancialAccountDetailController {
    //This String should be similar to all fields getting queried so that we can use this to fetch all picklist values.
    //When you add a field and update query, Add field in string as well.
    public static String allFields='id, Account_Region__c, Name,lob__c,  Industry, branch_scheduler__c,core_dpv_provider__c,core_dpv_software__c,core_dpv_interface__c,cash_management__c,transaction_fraud__c,host_switch_network__c,retail_online_banking_vendor__c,retail_online_banking_ced__c,retail_mobile_banking_vendor__c,retail_mrdc_provider__c,retail_bill_payment_vendor__c,business_banking_vendor__c,business_banking_ced__c,business_mrdc__c,business_bill_payment_vendor__c,business_bill_payment_ced__c,online_account_opening_provider__c,security_provider__c,pfm_vendor__c,website_hosting__c,addons__c,atm_hardware_vendors__c,itm_hardware_vendors__c,atm_recyclers__c,atm_manufacture_model_family__c,deployment__c,contract_renewal__c,host_hardware_platform__c,contract_renewal_for_hw__c,operating_system_sw__c,multi_vendor_sw_strategy__c,atm_itm_application_software_vendors__c,atm_itm_application_software_version__c,interactive_banker__c,interactive_teller__c,marketing_sw__c,white_listing__c,bios_management__c,hard_disk_encryption__c,core_integrations__c,sw_distribution__c,monitoring_incident_mgmt__c,cash_and_transaction_balancing__c,transaction_monitoring__c,flm__c,slm__c,turnkey_installation_services__c,rdc_to_back_office_connection__c,back_office_processing__c,archive__c,atm__c,branch__c,mobile__c,commercial__c,small_business__c,additional_comments__c,cc_processor__c,debit_card_processor__c,security_fraud_solution_1__c,security_fraud_solution_2__c,esb__c,core_dpv_provider_ced__c,omni_platform__c,managed_services__c,flm_contract_renewal_date__c,slm_contract_renewal_date__c,teller__c,teller_cash_recycler__c,of_Diebold_ATMs__c,of_Diebold_ITMs__c,of_Digital_Banking_Enrolled_Users__c,of_Hyosung_ATMs__c,of_Hyosung_ITMs__c,of_TCRs__c,Commercial_Deposit_OAO__c,Consumer_Deposit_OAO__c,CRM__c,Appointment_Scheduler__c,Marketing_Mgmt__c,Chat_Video_Solutions__c,Telephony_Systems__c,P2P__c,A2A__c,Wires_Platform__c,AO_Commercial_Loan_OAO__c,AO_Consumer_Loans_Auto_HELOC__c,AO_Consumer_Mortgage_OAO__c,LSP_Commercial_Loans__c,LSP_Consumer_Loans_Auto_HELOC__c,LSP_Consumer_Mortgage__c,ATMaaS__c,Enterprise_Service_Bus__c'; 
    @AuraEnabled
    public static Account getAccount(Id Accountid) 
    {  
        Account a=Database.query('Select '+allFields+ '  FROM Account WHERE Id =:Accountid');
        if(a.lob__c!=null && a.lob__c.toUpperCase()=='FINANCIAL'){
            return a;
        }else{
            return null;
        }
    } 
    
    @AuraEnabled    
    public static account saveAccount(account acc) 
    { 
        update acc; 
        return acc; 
    } 
    
    @AuraEnabled
    public static Map<String, String> getLabels() {
        String type='Account';
        Map<String, Schema.SObjectType> schmMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchm = schmMap.get(type);
        Map<String, Schema.SObjectField> fldMap = leadSchm.getDescribe().fields.getMap();
        
        Map<String, String> fldsLbl = new Map<String, String>();
        for (String fldName: fldMap.keySet()) {             
            fldsLbl.put(fldName, fldMap.get(fldName).getDescribe().getLabel());
        }    
        return fldsLbl;
    }
    @AuraEnabled
    public static Map<String,  List<String>> getOpts(String regn, Id Accountid) { 
        Account acctRecds = getAccount(Accountid) ;
        
        Map<String,Set<String>> exclVal=new Map<String,Set<String>>();
        //Set<String> includePickList = new Set<String>();
        List<String> SpltLst = New List<String>();
        List <TechnologyFields__mdt> t=[Select FieldApi__c, ExcludedValues__c from TechnologyFields__mdt where Region__c=:regn];
        for(TechnologyFields__mdt tf:t){
            IF(!string.isBlank(tf.ExcludedValues__c)) SpltLst=tf.ExcludedValues__c.toLowerCase().replaceAll('; ',';').split(';');
            if(exclVal.get(tf.FieldApi__c)!=null){
                exclVal.get(tf.FieldApi__c.toLowerCase()).addAll(SpltLst);
            }else{
                Set<String> ss=new Set<String>(SpltLst);
                //ss.addAll(SpltLst);
                exclVal.put(tf.FieldApi__c.toLowerCase(),ss);
            }
        }
        //Fetching field picklist values
        //Schema.sObjectType sobj_type = Account.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobj_dscrb =  Account.getSObjectType().getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> fld_map = sobj_dscrb.fields.getMap(); //get a map of fields for the passed sobject
        Map<String, List<String>> pcklstfldmap=new Map<String, List<String>>();
        
        
        Set<String> techFields=new Set<string>();
        if(!String.isEmpty(allFields))
            techFields.addAll((allFields.toLowerCase().replaceAll(' ','').replaceAll('\t','')).split(','));
        for(String s:fld_map.keySet()){
            List<String> acctRec=new List<String>();
            //system.debug('@@'+s);
            if(s.endsWith('__c') && techFields.contains(s.toLowerCase())){
                String acctRecd =  String.valueOf(acctRecds.get(s));
                
                if(String.isNotBlank(acctRecd) ){
                    acctRec = acctRecd.split(';');    
                }
                
            }
            //    List<Schema.PicklistEntry> pick_list_values1 = acctRecd.get(s);
            
            try{
                List<Schema.PicklistEntry> pck_lst_vals = fld_map.get(s).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                List <String> pklistval=new List <String>();
                if(techFields.contains(s.toLowerCase())){
                    for (Schema.PicklistEntry a : pck_lst_vals) { //for all values in the picklist list  
                        //system.debug('@@'+a.getLabel().toLowerCase()+'##'+excludeVal.get(s.toLowerCase()).contains(a.getLabel().toLowerCase())+'**'+excludeVal.get(s.toLowerCase()));
                        if(exclVal.get(s.toLowerCase())==null || !exclVal.get(s.toLowerCase()).contains(a.getLabel().toLowerCase()))
                           
                        pklistval.add(a.getLabel()); //add the value and label to our final list
                    }
                    for(String pklstval : acctRec)
                    {
                      
                        if(!pklistval.contains(pklstval)) {
                            pklistval.add(pklstval);   
                        }
                    }
                   
                    if(pklistval.size()>0)
                        pcklstfldmap.put(s.toLowerCase(),pklistval);  
                }
                
            }catch(Exception e){
                system.debug('###'+s);
            }
            
        }
        return pcklstfldmap;
    }
    
    
    @AuraEnabled
    public static Map<String, List<String>> getHeatMapYellowProductsMetadata() {
        
        Map<String, List<String>> fldLblvsProdLstMap = new Map<String, List<String>>() ;
        for( Account_Heatmap_Yellow_Products__mdt heatMapmdt : [SELECT MasterLabel, DeveloperName, Product_List__c 
                                                                         FROM Account_Heatmap_Yellow_Products__mdt ] ) {
                                                                             fldLblvsProdLstMap.put(heatMapmdt.MasterLabel , new List<String>() ) ;
                                                                             if(String.isNotEmpty(heatMapmdt.Product_List__c) ) {
                                                                                 if(heatMapmdt.Product_List__c.contains(',')) {
                                                                                     for(String str :heatMapmdt.Product_List__c.split(',') ) {
                                                                                         fldLblvsProdLstMap.get(heatMapmdt.MasterLabel).add(str.trim().toLowerCase()) ;
                                                                                     }
                                                                                 } else {
                                                                                     fldLblvsProdLstMap.get(heatMapmdt.MasterLabel).add(heatMapmdt.Product_List__c.trim().toLowerCase()) ;
                                                                                 }
                                                                             }
                                                                             
                                                                             
                                                                         }
        return fldLblvsProdLstMap ;
    }
    
    
    @AuraEnabled
    public static Map<String, Boolean> getHeatMapData(String acctId) {
        //HeatmapWrapper wrapperData  = new HeatmapWrapper() ;
        Map<String, Boolean> fldLblToPrdYellowMap = new Map<String, Boolean>{'Archive' => false ,
            'ATM' => false,
            'ATM_Hardware_Vendors' => false,
            'ATM_Recyclers' => false,
            'ATM_ITM_Application_Software_Version' => false,
            'Back_Office_Processing' => false,
            'BIOS_Management' => false,
            'Branch' => false ,
            'Branch_Scheduler' => false,
            'Cash_and_transaction_balancing' => false,
            'Cash_Management' => false, 
            'Commercial' => false ,
            'Core_Integrations' => false,
            'Hard_Disk_Encryption' => false,
            'Host_Switch_Network' => false,
            'Interactive_Banker' => false,
            'Interactive_Teller' => false ,
            'ITM_Hardware_Vendors' => false, 
            'Marketing_SW' => false, 
            'Mobile' => false, 
            'Monitoring_Incident_Mgmt' => false ,
            'RDC_to_Back_Office_Connection' => false ,
            'SW_Distribution' => false ,
            'Transaction_Fraud' => false ,
            'Transaction_monitoring' => false ,
            'White_Listing' => false , 
            'Retail_Online_Banking_Vendor'=> false ,
            'Retail_Mobile_Banking_Vendor'=> false ,
            'Business_Banking_Vendor' => false,
            'Managed_Services' => false
            } ;
                
                if(String.isNotEmpty( acctId) )  {
                    //wrapperData.acctRecd = getAccount(acctId) ;
                    Map<String, List<String>> fldLblvsPrdLstMap  = getHeatMapYellowProductsMetadata() ;
                    //Map<String, String> fieldLabelsMap= getLabels() ;
                    //wrapperData.labelsMap = fieldLabelsMap ;
                    //List<Opportunity> oppLst = new List<Opportunity>() ;
                    List<OpportunityLineItem> oppPrdLst = new List<OpportunityLineItem>() ;
                    oppPrdLst = [SELECT Id, Name, Product2.Name FROM OpportunityLineItem 
                                       WHERE Opportunity.AccountId =:acctId 
                                       AND Opportunity.isclosed = false 
                                       AND (Opportunity.RecordType.Name = 'Include in Funnel' OR Opportunity.RecordType.Name = 'Indirect - Include in Funnel Distributor' OR Opportunity.RecordType.Name = 'Indirect - Include in Funnel Reseller' ) ] ;
                    //oppList = [SELECT Id, (SELECT Id, Name, Product2.Name FROM OpportunityLineItems ) FROM Opportunity WHERE AccountId =:acctId] ;
                    //system.assert(false , '>>>>' + oppProductsList[0].Product2.Name +  '?? ' + oppProductsList[1].Product2.Name) ;
                    if(!oppPrdLst.isEmpty() ) {
                        //System.assert(false, '>>>>>>>'+ fieldLabelvsProductListMap.get('Branch Scheduler')) ;
                        for(OpportunityLineItem OLI : oppPrdLst) {
                            String prdName = OLI.Product2.Name.toLowerCase();
                            
                            if(fldLblvsPrdLstMap.get('Archive').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Archive' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('ATM').contains(prdName)) {
                                fldLblToPrdYellowMap.put('ATM' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('ATM Hardware Vendors').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('ATM_Hardware_Vendors' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('ATM Recyclers').contains(prdName)) {
                                fldLblToPrdYellowMap.put('ATM_Recyclers' , true) ;
                                // break ; 
                            }
                            if(fldLblvsPrdLstMap.get('ATM/ITM Application Software Version').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('ATM_ITM_Application_Software_Version' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Back Office Processing').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Back_Office_Processing' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('BIOS Management').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('BIOS_Management' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Branch').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Branch' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Branch Scheduler').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Branch_Scheduler' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Cash and transaction balancing').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Cash_and_transaction_balancing' , true) ;
                                // break ;
                            }
                            
                            if(fldLblvsPrdLstMap.get('Cash Management').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Cash_Management' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Commercial').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Commercial' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Core Integrations').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Core_Integrations' , true) ;
                                // break ;
                            }
                            
                            
                            if(fldLblvsPrdLstMap.get('Hard Disk Encryption').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Hard_Disk_Encryption' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Host/Switch/Network').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Host_Switch_Network' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Interactive Banker').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Interactive_Banker' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Interactive Teller').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Interactive_Teller' , true) ;
                                // break ;
                            }
                            
                            if(fldLblvsPrdLstMap.get('ITM Hardware Vendors').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('ITM_Hardware_Vendors' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Marketing SW').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Marketing_SW' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Mobile').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Mobile' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Monitoring / Incident Mgmt').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Monitoring_Incident_Mgmt' , true) ;
                                // break ;
                            }
                            
                            if(fldLblvsPrdLstMap.get('RDC to Back Office Connection').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('RDC_to_Back_Office_Connection' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('SW Distribution').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('SW_Distribution' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Transaction Fraud').contains(prdName)) {
                                fldLblToPrdYellowMap.put('Transaction_Fraud' , true) ;
                                // break ;
                            }
                            
                            if(fldLblvsPrdLstMap.get('Transaction monitoring').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Transaction_monitoring' , true) ;
                                // break ;
                            }
                            
                            if(fldLblvsPrdLstMap.get('White Listing').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('White_Listing' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Retail Online Banking Vendor').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Retail_Online_Banking_Vendor' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Retail Mobile Banking Vendor').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Retail_Mobile_Banking_Vendor' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Business Banking Vendor').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Business_Banking_Vendor' , true) ;
                                // break ;
                            }
                            if(fldLblvsPrdLstMap.get('Managed Services').contains(prdName) ) {
                                fldLblToPrdYellowMap.put('Managed_Services' , true) ;
                                // break ;
                            }
                            
                        }
                        // return fieldLabelToProductYellowMap ;
                    }
                    
                    // wrapperData.fieldLabeltoProductsYellowMap = fieldLabelToProductYellowMap;
                    
                    // return fieldLabelToProductYellowMap ; 
                }
        return fldLblToPrdYellowMap;
    } 
    
    
}