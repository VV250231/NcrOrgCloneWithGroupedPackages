/****************************************************************************************************************
*   ClassName :   cpq_QteToOppSync
*   Description :   
*   Author      :   
*   Version     :   50
# Modification History.: 
/*
# Last Modified by......:  Monika
# Last Modified Date..: 04/07/2021 (MM/DD/YYYY)
EBA_SF-1209 - Handle exception for Job-cpq_QteToOppSync

Story No#         Date            DevName                Description
EBA_SF-1697     4 Jan 2021      Varsha Pal               Added the criteria to check the amendment order form when autopay setup is changed to true or manual
                                                         before auto closing the CPQ opportunity
                                                         Change the criteria for closing the opportunity if Eligible for ERP is true or true-manual to check 
                                                         if fulfillment order status is Order Booked
****************************************************************************************************************/
public class cpq_QteToOppSync implements Queueable {
    private List<SBQQ__Quote__c> qteL;
    private Map<id,SBQQ__Quote__c> oldQteMap;
    private String calledFm='SQ';
    List <String> oppStages = new List<String>();
    Set<Opportunity> PmtOnyQt= new Set<Opportunity>();
    List <String> PamntOnlyOpp = new List<String>();
    Set<String> PamntOnlyQt= new Set<String>();
    public cpq_QteToOppSync(){}
    public cpq_QteToOppSync(List<SBQQ__Quote__c> qteL, Map<id,SBQQ__Quote__c> oldQteMap) {       
        this.qteL = qteL;
        this.oldQteMap=oldQteMap;
    }
    public cpq_QteToOppSync(List<SBQQ__Quote__c> qteL,String calledFm) {
        this.qteL = qteL;
        this.calledFm=calledFm;
    }
    public void execute(QueueableContext context) {
        
        Map<id,Opportunity> finalUpdateM=new Map<id,Opportunity>();
        Map<id,SBQQ__Quote__c> qtMap=new Map<id,SBQQ__Quote__c>();
        //By Sushant-EBA_SF-759- Starts        
        Set<id> CloseBookOpps=new Set<id>();  
        Set<id> oppids=new Set<id>();        
        Set<id> clsngOppids=new Set<id>();   
        Map<id,id> closeBookqtMap=new Map<id,id>(); 
        for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) { //it will fetch all the Stages of Opportunity
            oppStages.add(value.getValue());
        }
        if(qteL!=null && qteL.size()>0){
            for(SBQQ__Quote__c q:qteL) {
                if(q.SBQQ__Primary__c){
                    oppids.add(q.SBQQ__Opportunity2__c);
                    closeBookqtMap.put(q.id,q.SBQQ__Opportunity2__c);
                }
                if(q.SBQQ__Primary__c && q.ApprovalStatus__c!=null && oldQteMap !=null && oldQteMap.get(q.id).ApprovalStatus__c==null){
                    clsngOppids.add(q.SBQQ__Opportunity2__c);
                }                
                qtMap.put(q.id,q);
                if(q.SBQQ__LineItems__r.size() == 0 && calledFm =='NPS'){
                     PamntOnlyQt.add(q.Id);                               
                }
            }
        }
        //identify EED update list
        EDD_RDD_sync_eval(finalUpdateM, oppids, qtMap);
        // Closing Opp
        setOppClosing(clsngOppids, finalUpdateM);
        //Setting Opp Closed/Booked
        if(closeBookqtMap.size()>0) {
            Oppty_CloseBook_Sync_eval_CD(finalUpdateM,calledFm,closeBookqtMap);  
        }
        
        if(finalUpdateM.size()>0){            
            CheckRecursive.cpqSpclHdlg=true;
            update finalUpdateM.values();
        }
    }
    /**** Ajay Dixit--ADDED Payments Rep some logic to EDD RDD eval- 10-05-2021--EBA_SF-1290---------------***/
    public void EDD_RDD_sync_eval(Map<id,Opportunity> finalUpdateM, set<Id> oppids, Map<id,SBQQ__Quote__c> qtMap) {
        /**Ajay Dixit---EBA_SF-1290---**/
        Map<Id,Id> offcOppMap = new Map<Id, Id>();
        if(qtMap != null && qtMap.size() > 0) {
            qtMap = new Map<id,SBQQ__Quote__c>([Select id, SBQQ__Primary__c,SBQQ__Ordered__c,SBQQ__Account__r.AutoPay_Setup__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                                                qtc_Requested_Delivery_Date__c, qtc_Has_Payments_Processing__c,Payments_Application_Signee__c from SBQQ__Quote__c where id in :qtMap.keySet()]); 
        }
        if(oppids.size()>0){
            List<Opportunity> oppL=[Select id,CPQ__c,StageName,isClosed, Expected_Delivery_Date__c,Payments_Application_Signee__c, SBQQ__PrimaryQuote__c,Channel_Office__c, Payments_Rep__c from Opportunity where id in :oppids];
            for(Opportunity o:oppL){
               
                if(qtMap.get(o.SBQQ__PrimaryQuote__c)!=null && qtMap.get(o.SBQQ__PrimaryQuote__c).qtc_Requested_Delivery_Date__c!=o.Expected_Delivery_Date__c){
                    if(finalUpdateM.get(o.id)!=null){
                        finalUpdateM.get(o.id).Expected_Delivery_Date__c=qtMap.get(o.SBQQ__PrimaryQuote__c).qtc_Requested_Delivery_Date__c;
                    }else{
                        o.Expected_Delivery_Date__c=qtMap.get(o.SBQQ__PrimaryQuote__c).qtc_Requested_Delivery_Date__c;
                        o.Skip_Validation_Rule_for_Lead_Conversion__c=true;                        
                        finalUpdateM.put(o.id, o);
                    }                     
                }
                
                if(qtMap.get(o.SBQQ__PrimaryQuote__c)!=null && qtMap.get(o.SBQQ__PrimaryQuote__c).Payments_Application_Signee__c!=o.Payments_Application_Signee__c && o.isClosed==false){
                    if(finalUpdateM.get(o.id)!=null){
                        finalUpdateM.get(o.id).Payments_Application_Signee__c=qtMap.get(o.SBQQ__PrimaryQuote__c).Payments_Application_Signee__c;
                    }else{
                        o.Payments_Application_Signee__c =qtMap.get(o.SBQQ__PrimaryQuote__c).Payments_Application_Signee__c;
                        o.Skip_Validation_Rule_for_Lead_Conversion__c=true;                        
                        finalUpdateM.put(o.id, o); 
                    } 
                } 
                
                /**Ajay Dixit---EBA_SF-1290---**/
                SBQQ__Quote__c q=qtMap.get(o.SBQQ__PrimaryQuote__c);
                if(q!=null){
                    //Removing Payments Rep
                    if(q.qtc_Has_Payments_Processing__c==false && o.Payments_Rep__c!=null) {
                        if(finalUpdateM.get(o.id)!=null){
                            finalUpdateM.get(o.id).Payments_Rep__c=null;
                        }else{
                            o.Payments_Rep__c=null;
                            o.Skip_Validation_Rule_for_Lead_Conversion__c=true;                        
                            finalUpdateM.put(o.id, o);
                        }    
                    }else if(q.qtc_Has_Payments_Processing__c || test.isRunningTest()){
                        offcOppMap.put(o.Channel_Office__c, o.Id);
                    }
                } 
            }// end of OPP Loop
            // if Channel Offive map has some values then do calc fpr Payments Rep
            if(offcOppMap.size()>0 || test.isRunningTest()){
                setPaymentsRep(offcOppMap, finalUpdateM, oppL);
            }
        }
        
    }
    //By Sushant-EBA_SF-759- Starts
    // change By Shiv(sm250665) in get quotes from opp.SFCPQBLG-308- Added OR qtc_Bill_To_Site__r.AutoPay_Setup__c='Manual'
    public void Oppty_CloseBook_Sync_eval_CD(Map<id,Opportunity> finalUpdateM,String calledFm,Map<id,id>oppWithQlistMap) {
        
        Map<Id,String> QtOrdIntMap = new Map<Id,String>();
        Map<Id,SBQQ__Quote__c> quoteMapId = new Map<Id,SBQQ__Quote__c>();
        
        List<Opportunity> oppL=[Select id, StageName,CPQ__c,SBQQ__PrimaryQuote__c, Is_Manual_Closed_Booked_Allowed__c,(select id,NCR_Payments_Application_Status__c from NCR_Payments_Sites__r)
                                from Opportunity where id in :oppWithQlistMap.values() AND CPQ__c = true AND isClosed = false];
         //get quote details
        List<SBQQ__Quote__c> QuoteDetails=[Select id,SBQQ__Opportunity2__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Primary__c,qtc_Bill_To_Site__r.AutoPay_Setup__c,qtc_Order_Authorization_Accepted_Date__c,qtc_EligibleForERP__c,SBQQ__Type__c
                                           from SBQQ__Quote__c where SBQQ__Opportunity2__c in :oppL and SBQQ__Primary__c=true];
        for(SBQQ__Quote__c qt:QuoteDetails){
            quoteMapId.put(qt.Id, qt);
        }
        //added for EBA_SF-1697 to find the fulfillment order status related to quote start condition
        for(qtc_FulfillmentOrder__c qf : [Select Order_Interface_Status__c,qtc_Quote__c from qtc_FulfillmentOrder__c where qtc_Quote__c in :QuoteDetails]){
            QtOrdIntMap.put(qf.qtc_Quote__c,qf.Order_Interface_Status__c);
        }
        //added for EBA_SF-1697 to find the fulfillment order status related to quote end condition

        //get customer docs from quote 
        List<customer_document__c> QuoteDocs=[Select  Document_Type__c,Document_Status__c from customer_document__c 
                                              where Quote__r.SBQQ__Opportunity2__r.id=:oppL];
        Set<Id> aQid = new Set<Id>();
        for (SBQQ__Quote__c q : QuoteDetails){
            if(q.SBQQ__Type__c=='Amendment'){
                aQid.add(q.id);
            }
        }
        //added for EBA_SF-1697 to find the Amendment Order form if it is completed for Amendment type quote start condition
        Set<Id> amFormQid = new Set<Id>();
        if(!aQid.isEmpty()){
            for(customer_document__c cd :[Select  Document_Type__c,Document_Status__c,Quote__c from customer_document__c where Quote__c in :aQid and Document_Status__c='Completed' and Document_Type__c='AE Amendment']){
                amFormQid.add(cd.Quote__c);
            }
        }
        //added for EBA_SF-1697 to find the Amendment Order form if it is completed for Amendment type quote end condition
        //get quotes from opp
        Map<Id, SBQQ__Quote__c> oppQuote= new Map<Id, SBQQ__Quote__c>([Select id,SBQQ__Opportunity2__c,SBQQ__Primary__c,qtc_Bill_To_Site__r.AutoPay_Setup__c,qtc_Order_Authorization_Accepted_Date__c, qtc_EligibleForERP__c,qtc_Payments_Only_Quote__c,
                                                                       (Select id from SBQQ__LineItems__r where Service_Offer_Category__c='Payments Processing') 
                                                                       from SBQQ__Quote__c where Id IN :oppWithQlistMap.keySet() AND SBQQ__Opportunity2__c in :oppL 
                                                                       and SBQQ__Primary__c=true 
                                                                       and (qtc_Bill_To_Site__r.AutoPay_Setup__c='True' OR qtc_Bill_To_Site__r.AutoPay_Setup__c='Manual')]);
        
        if(calledFm == 'NPS' && PamntOnlyQt != null && PamntOnlyQt.size()>0){
            for (SBQQ__QuoteLine__c  qli : [Select SBQQ__Quote__r.SBQQ__Opportunity2__c,Service_Offer_Category__c from SBQQ__QuoteLine__c where SBQQ__Quote__c  IN : PamntOnlyQt and Service_Offer_Category__c != null])  {
                if(!PamntOnlyOpp.contains(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                    PamntOnlyOpp.add(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c); 
                }
            }
        }
        
        if(oppL != NULL && !oppL.isEmpty()){
            //Quote Ordered Logic
            for(Opportunity o:oppL){
                if(o.StageName !='Closed/Booked' && quoteMapId.size()>0 && o.CPQ__c && calledFm=='SQ'){
                    SBQQ__Quote__c sq = quoteMapId.get(o.SBQQ__PrimaryQuote__c);
                    if(sq!=null){
                        Boolean qtOrdered = sq.qtc_Ordered_Custom__c && (sq.SBQQ__Type__c!='Amendment' || (sq.SBQQ__Type__c=='Amendment'&& amFormQid.contains(sq.id)));
                        Boolean erpOrderBooked = sq.qtc_EligibleForERP__c!=null && sq.qtc_EligibleForERP__c.contains('TRUE') && QtOrdIntMap.get(sq.id)=='Order Booked' 
                            					 && ((sq.SBQQ__Type__c!='Amendment'&&sq.qtc_Order_Authorization_Accepted_Date__c!=null)||
                                                     (sq.SBQQ__Type__c=='Amendment'&& amFormQid.contains(sq.id)));
                        Boolean autoSetupDone =  sq.qtc_Bill_To_Site__r.AutoPay_Setup__c=='True' || 
                            					 sq.qtc_Bill_To_Site__r.AutoPay_Setup__c=='Manual' ||
                            					(getNonPmntsOnlyQte(new List <SBQQ__Quote__c> {sq} ).size() ==0);
                        if((qtOrdered) || (erpOrderBooked) && (autoSetupDone)){
                            if(finalUpdateM.get(o.id)!=null){
                                finalUpdateM.get(o.id).Is_Manual_Closed_Booked_Allowed__c=true;
                                finalUpdateM.get(o.id).StageName='Closed/Booked';
                                finalUpdateM.get(o.id).Closed_Booked_Comments__c='Subscription- Auto Close';
                            }else{
                                CloseBookOppPut(finalUpdateM,o);
                            } 
                        }
                    }   
                }
                
                if(calledFm =='CD' || calledFm == 'AC' || calledFm == 'FO') {
                    SBQQ__Quote__c oppPrmQt = oppQuote.get(o.SBQQ__PrimaryQuote__c); 
                    
                    Boolean closedBookedFlag = false;
                    if(oppPrmQt != NULL) {
                        Boolean erpOrderBooked = oppPrmQt.qtc_EligibleForERP__c!=null && ((oppPrmQt.qtc_EligibleForERP__c.contains('TRUE') 
                                                 && QtOrdIntMap.get(oppPrmQt.id)=='Order Booked')
                                                 || oppPrmQt.qtc_EligibleForERP__c.contains('FALSE'));
                        Boolean paymentOnlyQuote = oppPrmQt.qtc_Payments_Only_Quote__c!=null && oppPrmQt.qtc_Payments_Only_Quote__c=='Yes';
                        if((erpOrderBooked) ||(paymentOnlyQuote)){
                            if ((oppPrmQt.SBQQ__LineItems__r == NULL || oppPrmQt.SBQQ__LineItems__r.isEmpty())) {
                                closedBookedFlag = true;            
                            } else {
                                if (o.NCR_Payments_Sites__r != NULL && o.NCR_Payments_Sites__r.size()>0) {
                                    for (NCR_Payments_Site__c ps : o.NCR_Payments_Sites__r) {
                                        if(ps.NCR_Payments_Application_Status__c=='ApprovedAndBoarded') { 
                                            closedBookedFlag = true; 
                                            break; 
                                        }     
                                    }
                                }else{
                                    closedBookedFlag = true;  
                                }   
                            }  
                        }
                    }
                    
                    if(closedBookedFlag) {
                        if (finalUpdateM.get(o.id)!=null){
                            finalUpdateM.get(o.id).Is_Manual_Closed_Booked_Allowed__c=true;
                            finalUpdateM.get(o.id).StageName='Closed/Booked';
                            finalUpdateM.get(o.id).Closed_Booked_Comments__c='Subscription- Auto Close';
                        } else {
                            CloseBookOppPut(finalUpdateM,o);
                        }      
                    }
                }
                
                SBQQ__Quote__c oppPrmQt = oppQuote.get(o.SBQQ__PrimaryQuote__c);
                boolean qtchk = false;
                if(oppPrmQt!=null&&oppPrmQt.qtc_Payments_Only_Quote__c!=null&&oppPrmQt.qtc_Payments_Only_Quote__c=='Yes'){
                    qtchk = true;
                }else{
                    qtchk =oppPrmQt!=null&&((oppPrmQt.qtc_EligibleForERP__c!=null &&((oppPrmQt.qtc_EligibleForERP__c?.contains('TRUE') && QtOrdIntMap.get(oppPrmQt.id)=='Order Booked')  || oppPrmQt.qtc_EligibleForERP__c?.contains('FALSE')))); 
                }
                if((o.CPQ__c && QuoteDocs !=null && calledFm=='NP'&& qtchk
                   && (oppPrmQt.SBQQ__LineItems__r != null) && (oppPrmQt.SBQQ__LineItems__r.size() > 0)) || (PamntOnlyOpp != null && PamntOnlyOpp.contains(o.id))) {
                       if(o.StageName !='Closed/Booked'){
                           if(finalUpdateM.get(o.id)!=null){
                               finalUpdateM.get(o.id).Is_Manual_Closed_Booked_Allowed__c=true;
                               finalUpdateM.get(o.id).StageName='Closed/Booked';
                               finalUpdateM.get(o.id).Closed_Booked_Comments__c='Subscription- Auto Close';
                           }else{
                               CloseBookOppPut(finalUpdateM,o);                                   
                           }  
                       } 
                   }
            }
        }
    }
    //By Sushant-EBA_SF-759- Ends 
    public void setOppClosing(set<Id> clsngOppids,Map<id,Opportunity> finalUpdateM) {        
        List<Opportunity> oppL=[Select id, CPQ__c, StageName from Opportunity where isClosed = False and id in :clsngOppids];
        for(Opportunity o:oppL){
            system.debug(o.StageName+'+++>');
            if(oppStages.indexOf(o.StageName) < oppStages.indexOf(System.Label.Stage_Offering)){  //label Stage_Offering is used to set Stage to offering
                if(finalUpdateM.get(o.id)!=null){ finalUpdateM.get(o.id).StageName=System.Label.Stage_Offering;  //label Stage_Offering is used to set Stage to offering
                }else{
                    o.StageName=System.Label.Stage_Offering;    //label Stage_Offering is used to set Stage to offering
                    o.Skip_Validation_Rule_for_Lead_Conversion__c=true; finalUpdateM.put(o.id, o) ;
                } 
            }
        }
    }
    public void CloseBookOppPut(Map<id,Opportunity> finalUpdateM, Opportunity o) {  
        
        o.Is_Manual_Closed_Booked_Allowed__c=true;
        o.StageName='Closed/Booked';
        o.Closed_Booked_Comments__c='Subscription- Auto Close';
        o.Skip_Validation_Rule_for_Lead_Conversion__c=true;
        finalUpdateM.put(o.id, o) ;
        System.debug('finalUpdateM pouplated:'+finalUpdateM);
    }
    /**Ajay Dixit---EBA_SF-1290---**/
    public void setPaymentsRep( Map<Id,Id> offcOppMap,Map<id,Opportunity> finalUpdateM, List <Opportunity> oppL) {
        Map<Id,Id> oppPymntRepMap = new Map<Id, Id>();//Map of opportunity with Payment rep id(user id)
        if(!offcOppMap.isEmpty()){
            getChnlOffPmntsRep(offcOppMap,oppPymntRepMap);
            // Populating FinalUpdate Map with Payments rep details, Not overwriting if Payment Rep field is not null      
            for(Opportunity o:oppL){
                Id opprep=oppPymntRepMap.get(o.id);
                if(opprep!=null && o.Payments_Rep__c==null){  
                    if(finalUpdateM.get(o.id)!=null){
                        finalUpdateM.get(o.id).Payments_Rep__c=opprep;
                    }else{
                        o.Payments_Rep__c=opprep; o.Skip_Validation_Rule_for_Lead_Conversion__c=true; finalUpdateM.put(o.id, o) ;
                    } 
                }
            }
        } 
        
    }
    public void getChnlOffPmntsRep(Map<Id,Id> offcOppMap, Map<Id,Id> oppPymntRepMap) {     
        for(Account accmbrObj : [Select Id,CDM_Account_Type__c, (Select Id, AccountId,UserId From AccountTeamMembers WHERE TeamMemberRole =:Label.ATM_Role_PMNTSREP limit 1) From Account Where id IN: offcOppMap.keySet()]){
            if(accmbrObj.CDM_Account_Type__c ==Label.CDM_ACCTYP_LO   || accmbrObj.CDM_Account_Type__c ==Label.CDM_ACCTYP_PRTNR){
                if(accmbrObj.AccountTeamMembers.size()>0){
                    oppPymntRepMap.put(offcOppMap.get(accmbrObj.id),accmbrObj.AccountTeamMembers[0].UserId);
                }
            }
        }
    }
    
    //Retun List of Quote Ids which are non Payments only Qtes
    public Set<Id> getNonPmntsOnlyQte(List<SBQQ__Quote__c> sqL) {  
        Set<id> nonnpsonlyQteIds=new Set<id>();
        List<SBQQ__Quote__c> nonNpsQL=[Select id,(Select id from SBQQ__LineItems__r where Service_Offer_Category__c !='Payments Processing' and Service_Offer_Category__c !=null) from SBQQ__Quote__c where id in:sqL];
        for(SBQQ__Quote__c nnps:nonNpsQL){
            if(nnps.SBQQ__LineItems__r!=null && !nnps.SBQQ__LineItems__r.isEmpty()){ nonnpsonlyQteIds.add(nnps.id); 
            }
        }
        return nonnpsonlyQteIds;
    }
}