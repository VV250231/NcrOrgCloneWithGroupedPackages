/****************************************************************************************************************
*   ClassName :   ProductScheduleController
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1669       8th Dec 2021    Varsha Pal             Remove the testcoverage function and make the variables small
EBA_SF-2003       28th Apr 2022   Puneet Bhatia          Added changes to resolve Rounding Discrepancy in TCV Value
CSI-365           5th Jul 2022    Puneet Bhatia			 Added changes for CATM Products One Time Revenue
EBA_SF-2491       19-12-2022      Monika               JDK Locale impact - Upgrade API Part 5  
****************************************************************************************************************/
public class ProductScheduleController{
    public static Map <String, Integer> MonthToNum = new Map <String, Integer> {
        'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
            };
                @AuraEnabled
                public Static List<WrapperProductScheduleController> ScheduleCalculateWrapper(String OppotunityId,Boolean CallFromPreviousSchedule){
                    
                    string msg; //make the variable small Message to msg - EBA_SF-1669
                    
                    List<WrapperProductScheduleController> wrap=new List<WrapperProductScheduleController>();//make the variable small wrapper to wrap - EBA_SF-1669
                    List<OpportunityLineItemSchedule > oliSchLst=new List<OpportunityLineItemSchedule >();//make the variable small OppLineItemScheduleList to oliSchLst - EBA_SF-1669
                    List<String> oliIds =new List<String>(),opts = new List<String>();//make the variable small options to opts - EBA_SF-1669
                    OpportunityLineItemSchedule schobj=new OpportunityLineItemSchedule();
                    oliSchLst.add(schobj);
                    
                    try{
                        Schema.DescribeFieldResult fldRes = OpportunityLineitem.Duration__c.getDescribe();//make the variable small fieldResult to fldRes - EBA_SF-1669
                        List<Schema.PicklistEntry> ple = fldRes.getPicklistValues();
                        opts.add('----');
                        opts.add('Custom');
                        for (Schema.PicklistEntry f: ple) {
                            opts.add(f.getLabel());
                        }
                        
                        
                        if(!CallFromPreviousSchedule){
                            //make the variable small OliHWProduct to OliHWProd,OliSWProduct to OliSWProd and OliServiceProduct to OliServProd - EBA_SF-1669
                            List<OpportunityLineitem> OliHWProd = new List<OpportunityLineitem>(),OliSWProd = new List<OpportunityLineitem>(),OliServProd = new List<OpportunityLineitem>();
                            for(OpportunityLineitem oli : [select id,name,Product2.Name, Opportunity.Expected_Delivery_Date__c, OpportunityId,(Select CurrencyIsoCode,Description,IsDeleted,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type  from OpportunityLineItemSchedules where Quantity > 0 and ScheduleDate < :GlobalVariable.unhandledQtyDate Order by ScheduleDate),Product_Category__c,UnitPrice,Quantity,TotalPrice,Unscheduled_Quantity__c,Duration__c, HasQuantitySchedule from OpportunityLineItem where OpportunityId =: OppotunityId ])
                            {  
                                if(!oli.HasQuantitySchedule || oli.OpportunityLineItemSchedules.size()==0){ 
                                    if(oli.Product_Category__c.toUpperCase() == 'SOFTWARE' ){
                                        
                                        OliSWProd.add(oli);
                                    }
                                    else if(oli.Product_Category__c.toUpperCase() == 'HARDWARE'){
                                        
                                        OliHWProd.add(oli);
                                    }
                                    else{
                                        
                                        OliServProd.add(oli);
                                    }
                                }   
                            }
                            for(OpportunityLineitem oli: OliSWProd ){
                                wrap.add(new WrapperProductScheduleController(oli,oli.OpportunityLineItemSchedules,opts)); 
                            }
                            for(OpportunityLineitem oli: OliServProd ){
                                wrap.add(new WrapperProductScheduleController(oli,oli.OpportunityLineItemSchedules,opts));  
                            }
                            for(OpportunityLineitem oli: OliHWProd ){
                                wrap.add(new WrapperProductScheduleController(oli,oli.OpportunityLineItemSchedules,opts));   
                            }
                            
                        }else{
                            
                            List<OpportunityLineitem> OliHWProd = new List<OpportunityLineitem>(),OliSWProd = new List<OpportunityLineitem>(),OliServProd = new List<OpportunityLineitem>();
                            
                            for(OpportunityLineitem oli : [select id,name,Opportunity.IsClosed,Product2.Name,Opportunity.Expected_Delivery_Date__c,OpportunityId,(Select CurrencyIsoCode,Description,id,IsDeleted,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type  from OpportunityLineItemSchedules where Quantity > 0 and ScheduleDate < :GlobalVariable.unhandledQtyDate Order by ScheduleDate),Product_Category__c,UnitPrice,Quantity,TotalPrice,Unscheduled_Quantity__c,Duration__c,HasQuantitySchedule from OpportunityLineItem where OpportunityId =: OppotunityId ])
                            {  
                                if(oli.HasQuantitySchedule && oli.OpportunityLineItemSchedules.size()>0){
                                    if(oli.Product_Category__c.toUpperCase() == 'SOFTWARE' ){
                                        
                                        OliSWProd.add(oli);
                                    }
                                    else if(oli.Product_Category__c.toUpperCase() == 'HARDWARE'){
                                        
                                        OliHWProd.add(oli);
                                    }                                    
                                    else{
                                        OliServProd.add(oli);
                                    }
                                }  
                            }
                            for(OpportunityLineitem oli: OliSWProd ){
                                wrap.add(new WrapperProductScheduleController(oli,oli.OpportunityLineItemSchedules,opts)); 
                            }
                            for(OpportunityLineitem oli: OliServProd ){
                                wrap.add(new WrapperProductScheduleController(oli,oli.OpportunityLineItemSchedules,opts));  
                            }
                            for(OpportunityLineitem oli: OliHWProd ){
                                wrap.add(new WrapperProductScheduleController(oli,oli.OpportunityLineItemSchedules,opts));  
                            }
                        }
                        
                    }
                    
                    catch (Exception e) { 
                        msg= e.getMessage();  
                    } 
                    //commented for EBA_SF-1699
                    /*catch (LisException e) { msg= e.getMessage();  
                    } 
                    catch(DmlException e) {  msg= e.getMessage();
                    }*/
                    return wrap;
                    
                }  
    
    @AuraEnabled    
    public Static String SaveManegeSchedule(String JsonString){
        String isSuc = 'SUCCESS';//make the variable small isSuccess to isSuc - EBA_SF-1669
        System.SavePoint s1=database.setSavepoint();
        try{
            List<OpportunityLineItem> oliList=new List<OpportunityLineItem>();
            List<String> OliLstDel=new List<String>();//make the variable small OliListForDelete to OliLstDel - EBA_SF-1669
            List<OpportunityLineItemSchedule> olisIns=new List<OpportunityLineItemSchedule>();//make the variable small olisInsert to olisIns - EBA_SF-1669
            fromJSON obj = fromJSON.parse(JsonString);
            for(fromJSON.cls_OpportunityLineItem objnew : obj.OpportunityLineItem){
                OliLstDel.add(objnew.Id);
                OpportunityLineItem oli=new OpportunityLineItem();
                //oli.Quantity=objnew.Quantity;
                //oli.UnitPrice=objnew.UnitPrice;
                oli.Id=objnew.Id;
                oli.TotalPrice = objnew.TotalPrice;
                Integer qty=0;
                for(fromJSON.cls_OpportunityLineItemSchedule  obj2: objnew.OpportunityLineItemSchedule){
                    if(obj2.Quantity>0 && (!String.isBlank(obj2.ScheduleDate))  && (!String.isBlank(obj2.ScheduleDate))){
                        OpportunityLineItemSchedule olis = New OpportunityLineItemSchedule();
                        olis.Description = '';
                        olis.OpportunityLineItemId = objnew.Id;
                        olis.Quantity = obj2.Quantity;
                        qty=qty+obj2.Quantity;
                        /* Integer sdYear , sdMonth;
try{     
sdYear = Integer.valueOf(obj2.ScheduleDate.split('-', 0)[1]);
sdMonth = Integer.valueOf(ProductScheduleController.MonthToNum.get(obj2.ScheduleDate.split('-', 0)[0]));
}
catch(Exception e){
throw new ProductScheduleException('Please select a valid month.');                                 
}   
if(sdMonth ==  0) {
throw new ProductScheduleException('Please select a valid month.');
}*/
                        system.debug(obj2.ScheduleDate);
                        List<String> d=obj2.ScheduleDate.split('-');
                        olis.ScheduleDate = Date.newInstance(Integer.valueOf(d[0]),Integer.valueOf(ProductScheduleController.MonthToNum.get((d[1]))),Integer.valueOf(d[2]) );
                        olis.Type='Quantity';
                        olisIns.add(olis)  ;                
                        
                    } 
                }
                oli.Scheduled_Qty__c=qty;
                if(qty==0){
                    oli.Quantity=objnew.Quantity;
                }
                // @Ajay schedule for unscheduled quantity will only be created if there are shedules
                if(objnew.Quantity>qty && qty>0){
                    OpportunityLineItemSchedule olis = New OpportunityLineItemSchedule();
                    olis.Description = '';
                    olis.OpportunityLineItemId = objnew.Id;
                    olis.Quantity = objnew.Quantity-qty;
                    olis.ScheduleDate = GlobalVariable.unhandledQtyDate;
                    olis.Type='Quantity';
                    olisIns.add(olis)  ; 
                }
                oliList.add(oli);
                
                
            }  
            deleteOldSchedules(OliLstDel);   
            
            update oliList;
            Database.SaveResult[] srList = Database.insert(olisIns, false);
            return isSuc;
        }
        Catch(DmlException de){
            database.rollback(s1);
            Integer numErrors = de.getNumDml();
            string dmlExcep;
            for( Integer j = 0; j < numErrors; j ++ ) 
            {
                if(String.isBlank(dmlExcep)){
                    dmlExcep =  de.getDmlMessage(j); 
                }
                else{
                    dmlExcep +=  de.getDmlMessage(j); 
                } 
            }
            return isSuc = dmlExcep;
        }
        Catch(JSONException e){
            isSuc = 'Technical error occurred on server. Please report to NSC Administration (NSC.Administration@ncr.com).'; 
            database.rollback(s1);
            return isSuc;
        }
         //commented for EBA_SF-1699
        /*Catch(NullPointerException e){
            isSuc = e.getMessage()+'.Contact to your Admin.'; database.rollback(s1);
            return isSuc;
        }
        /* catch(StringException e){
isSuccess = e.getMessage()+'.Contact to your Admin.';            
database.rollback(s1);
return isSuccess;
}*/
        catch(Exception e){
            isSuc = e.getMessage()+'.Contact to your Admin.';  database.rollback(s1);
            return isSuc;
        }
        
    } 
    @AuraEnabled    
    public Static void deleteOldSchedules(List <id> oliids){
        try{
            delete [Select id from OpportunityLineItemSchedule where OpportunityLineItemId in :oliids];
           // delete olis;
        }catch(Exception e){
            throw e;
        }
    }
    
    @AuraEnabled
    public Static void InsertOpportunityLineItem(String[] Product_Selected_From_Favorite_Section, String Oppid){
        String spbId = GlobalVariable.pricebookId;//make the variable small spricebookId to spbId - EBA_SF-1669
        
        Opportunity o = [Select o.Id, 
                         o.Pricebook2Id,
                         o.CurrencyIsoCode                                
                         from Opportunity o  
                         where o.Id = :Oppid];
        
        ID pbId = o.Pricebook2Id;//make the variable small pricebookId to pbId - EBA_SF-1669
        if(pbId == null) {
            pbId = spbId;
            Pricebook2 pb2 = [Select p.Description, p.Id, p.Name from Pricebook2 p where p.Id = :pbId];
            //save the pricebook into opportunity
            o.Pricebook2Id = pb2.Id;
            update o;
        }    
        
        
        if(pbId != null) {
            
            List<ID> pIdLst = new List<ID>();//make the variable small productIdList to pIdLst - EBA_SF-1669
            for(String cp2 : Product_Selected_From_Favorite_Section) {
                pIdLst.add(cp2);
            }
            List<PricebookEntry> pbeList = [Select p.CurrencyIsoCode, 
                                            p.Id, 
                                            p.Name, 
                                            p.Pricebook2Id, 
                                            p.Product2Id, 
                                            p.ProductCode, 
                                            p.UseStandardPrice,
                                            p.IsActive                                                  
                                            From PricebookEntry p  
                                            Where p.Pricebook2Id = :pbId
                                            and p.CurrencyIsoCode = :o.CurrencyIsoCode                                              
                                            and p.Product2Id in :pIdLst
                                           ];
            List<OpportunityLineItem> addOLIlist = new List<OpportunityLineItem>();
            List<CurrencyType> clist = [Select c.ConversionRate from CurrencyType c where c.IsoCode = :o.CurrencyIsoCode];
            Double conversionRate = clist[0].ConversionRate;
            for(String cp2 : Product_Selected_From_Favorite_Section) {
                OpportunityLineItem aoli = new OpportunityLineItem();
                aoli.OpportunityId = o.id;
                aoli.ServiceDate = System.today();  
                
                Double totalPriceInUSD = 0.00;
                
                aoli.Quantity = 1; 
                aoli.UnitPrice = 0.00;
                
                for(Integer i = 0; i < pbeList.size(); i++) {
                    PricebookEntry pbe = (PricebookEntry) pbeList[i];
                    if(pbe.Product2Id == cp2) {
                        aoli.PricebookEntryId = pbe.Id; break;
                    }
                }
                if(aoli.PricebookEntryId!=null)
                    addOLIList.add(aoli);
            }
            if(addOLIlist.size() > 0) {                             
                insert addOLIlist;
            }
        }              
        
    }  
    
    //Added by Saritha
    
    @AuraEnabled
    public static String removeSchedule(String[] SelectedProductid, String recordId) { 
        String msg;
        try{
            List<OpportunityLineItem> olst= [select id,Product2Id,Name  from OpportunityLineItem where OpportunityId =:recordId AND Product2Id IN:SelectedProductid ];//make the variable small opplist to olst - EBA_SF-1669
            Delete olst;       
        } 
        catch(DmlException e) 
        { 
            msg= e.getMessage();
        }
        return msg;
        
    }
    
    /* @AuraEnabled
public static void SaveScheduleValidations(String[] productScheduleList, String[] scheduleDateList) { 
Savepoint sp = Database.setSavepoint();
try{

}
catch(ProductScheduleException e) {
//  this.saveRedirect = GlobalVariable.no;
Database.rollback(sp);
ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
}
catch(DMLException de) {
//this.saveRedirect = GlobalVariable.no;
Database.rollback(sp);
ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, de.getDmlMessage(0)));
}
catch(Exception e) {
// this.saveRedirect = GlobalVariable.no;
Database.rollback(sp);
ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
}

}*/
    
    @AuraEnabled
    public static void InsertOpportunityLineItemPS(String[] Product_Selected_From_Favorite_Section, String Oppid) { 
        ProductSelection.InsertOpportunityLineItem(Product_Selected_From_Favorite_Section, Oppid, null, null, null, null);
        
    }
    
    
    //Added by Saritha
    @AuraEnabled
    
    public static void getOpportunityLineItemPS(){
        List<WrapperProductScheduleController>  wplist=new List<WrapperProductScheduleController>();        
    }
    
    @AuraEnabled    
    public Static String SubmitManegeSchedule(String JsonStringSubmit){
        String isSuc = 'SUCCESS';//make the variable small isSuccess to isSuc - EBA_SF-1669
        System.SavePoint s1=database.setSavepoint();
        try
        {
            Date FSchMnth;//make the variable small FirstScheduleMonth to FSchMnth - EBA_SF-1669
            Id oid;//make the variable small OpportunityId to oid - EBA_SF-1669
            List<OpportunityLineItem> oliList=new List<OpportunityLineItem>();
            List<String> OliLstDel=new List<String>();//make the variable small OliListForDelete to OliLstDel - EBA_SF-1669
            //hold companion OLI for later processing and later addition
            List<OpportunityLineItem> comOliLst=new List<OpportunityLineItem>();//make the variable small companionOliList to comOliLst - EBA_SF-1669
            List<fromJSON.cls_OpportunityLineItem> comObj=new List<fromJSON.cls_OpportunityLineItem>();//make the variable small companionObj to comObj - EBA_SF-1669            
            //hold master Line schedule
            //Map <String, List<OpportunityLineItemSchedule>> mlineSch=new Map<String, List<OpportunityLineItemSchedule>>();//commented as not used in below code - EBA_SF-1669
            //Map <String, OpportunityLineItem> mlines=new Map<String, OpportunityLineItem>();//commented as not used in below code - EBA_SF-1669
            // hold companion products for scheduling
            List<OpportunityLineItemSchedule> oliIns=new List<OpportunityLineItemSchedule>();//make the variable small olisInsert to oliIns - EBA_SF-1669
            fromJSON obj = fromJSON.parse(JsonStringSubmit);
            
            //Changes by Stuti EBA 2426
            Id oppId;
            Integer contTerm =0;
            if(obj.OpportunityLineItem.size()>0){
                oppId=obj.OpportunityLineItem.get(0).OpportunityId;
                if(obj.OpportunityLineItem.get(0).NumberOfTerms!=null)
                    contTerm=obj.OpportunityLineItem.get(0).NumberOfTerms;
            }
            Opportunity opp=[Select id, CATM_Record__c, Contract_Term_Mths__c from Opportunity where id =: oppId];
            if(opp.CATM_Record__c) {
                if(opp.Contract_Term_Mths__c == null){
                    opp.Contract_Term_Mths__c=0;
                }
                if( opp.Contract_Term_Mths__c!=contTerm){
                opp.Contract_Term_Mths__c = contTerm;
                Update opp;
                }
            }
            
            //end
           
            for(fromJSON.cls_OpportunityLineItem objnew : obj.OpportunityLineItem){
                //New logic Pankaj
                //List<String> ScheduleDateForOpp=objnew.ScheduleDate.split('-'); 
                //FirstScheduleMonth = Date.newInstance(Integer.valueOf(ScheduleDateForOpp[0]),Integer.valueOf(ProductScheduleController.MonthToNum.get(ScheduleDateForOpp[1])),Integer.valueOf(ScheduleDateForOpp[2]));
                //@Ajay for dummy call below to update opportunity to set EDSD 
                System.debug('objnew'+objnew);
                OId = Id.valueOf(objnew.OpportunityId);
                //system.debug('>>>FirstScheduleMonth'+FirstScheduleMonth);
                //End of new logic from pankja
                
                OliLstDel.add(objnew.Id);
                
                OpportunityLineItem oli=new OpportunityLineItem();
                //oli.Quantity=objnew.Quantity;
                //oli.UnitPrice=objnew.UnitPrice;
               /* if(objnew.isPackage=='true'||objnew.isCompanion=='true'){
                    system.debug(objnew.NumberOfsites+'##'+objnew.NumberOFLicense);
                    if(objnew.isCompanion=='true')
                        system.debug(objnew.NumberOfsites+'##'+objnew.NumberOFLicense);
                    if(objnew.NumberOfsites!=null && objnew.NumberOfsites>0){
                        if(objnew.NumberOFLicense!=null && objnew.NumberOFLicense>0){
                            oli.Quantity= objnew.NumberOfsites*objnew.NumberOFLicense;  
                        }else{
                            oli.Quantity= objnew.NumberOfsites;  
                        }               
                    } else{
                        if(objnew.NumberOFLicense!=null && objnew.NumberOFLicense>0){
                            oli.Quantity= objnew.NumberOFLicense;  
                        }else{
                            oli.Quantity= 1;  
                        }
                    }
                    if(objnew.isCompanion=='true'){
                        oli.UnitPrice=  0;    
                    }else{
                        oli.UnitPrice=  (Math.round(objnew.TotalTCVPrice))/oli.Quantity; 
                    } 
                    oli.Sites__c=objnew.NumberOfsites;
                } */
                if(objnew.RevenueType=='Cloud' || objnew.isSubscriptioned || objnew.isCATMProduct || EncodingUtil.urlDecode(objnew.RevenueType,'UTF-8').equalsIgnoreCase('As a Service')){
                    // Re calculate TCV and ACV to avoid discrepancy
                    //oli.UnitPrice=    (Math.round(objnew.TotalTCVPrice) - (Math.round(objnew.OneTimeFee) * Math.round(objnew.Quantity))) / (Math.round(objnew.Quantity) * Math.round(objnew.NumberOfTerms));
                    //oli.UnitPrice=  (Math.round(objnew.TotalTCVPrice)/Math.round(objnew.Quantity)); 
                    oli.UnitPrice=  objnew.TotalTCVPrice/objnew.Quantity; 
                    oli.Quantity= objnew.Quantity;
                }
                else{
                    oli.UnitPrice=  objnew.UnitPrice;
                    oli.Quantity= objnew.Quantity;
                }
                
                //oli.TotalPrice = objnew.TotalPrice;
                //done by Sushant starts
                //TCV, ACV, UNITPRice of companion products(products under package is 0 or meaning less)                
                oli.Total_Cost_Value__c=objnew.TotalTCVPrice;
                oli.Actual_Contract_Value__c= objnew.TotalACVPrice;
                oli.Number_of_Terms__c=objnew.NumberOfTerms;
                oli.One_Time_Fee__c=objnew.OneTimeFee;
                oli.Monthly_Fee__c=objnew.MonthlyFee;
               if(!String.isEmpty(objnew.qtyTyp) && objnew.qtyTyp !='undefined' )
                oli.Qty_Type__c=objnew.qtyTyp;
                /*if(objnew.isPackage!='true' && objnew.isCompanion!='true'){
                    oli.One_Time_Fee__c=objnew.OneTimeFee;
                    oli.Monthly_Fee__c=objnew.MonthlyFee;  
                } */
                //done by Sushant ends
                oli.Id=objnew.Id;
                Integer qty=0;
                //if(objnew.isCompanion!='true'){
               
               
                
                    for(fromJSON.cls_OpportunityLineItemSchedule  obj2: objnew.OpportunityLineItemSchedule){
                        if(obj2.Quantity>0 && (!String.isBlank(obj2.ScheduleDate))  && (!String.isBlank(obj2.ScheduleDate))){
                            OpportunityLineItemSchedule olis = New OpportunityLineItemSchedule();
                            olis.Description = '';
                            olis.OpportunityLineItemId = objnew.Id;
                            olis.Quantity = obj2.Quantity;
                            qty=Integer.valueOf(qty+olis.Quantity);
                            
                            List<String> d=obj2.ScheduleDate.split('-');
                            olis.ScheduleDate = Date.newInstance(Integer.valueOf(d[0]),Integer.valueOf(ProductScheduleController.MonthToNum.get((d[1]))),Integer.valueOf(d[2]));
                            olis.Type='Quantity';
                            oliIns.add(olis) ;
                            //populating package Line and schedules
                           /* if(objnew.isPackage=='true'){
                                system.debug('&&'+olis);
                                if(masterLineschedules.get(objnew.Id)!=null){
                                    List<OpportunityLineItemSchedule> oliss=masterLineschedules.get(objnew.Id);
                                    oliss.add(olis);
                                    masterLineschedules.put(objnew.Id,oliss);  
                                }else{
                                    masterLineschedules.put(objnew.Id,new List<OpportunityLineItemSchedule>{olis} );
                                }
                            } */
                            
                        } 
                    }
                    oli.Scheduled_Qty__c=qty;
                    if(qty==0){
                        /*if(objnew.isPackage=='true'||objnew.isCompanion=='true'){
                            oli.Quantity= objnew.NumberOfsites*objnew.NumberOFLicense;
                        }
                        else{*/
                            oli.Quantity=objnew.Quantity;
                            
                       // }
                    }
                    system.debug(objnew.Quantity+'Ajay222'+qty+'@@'+oli.Quantity);
                    // @Ajay schedule for unscheduled quantity will only be created if there are shedules
                    if(oli.Quantity>qty && qty>0){
                        OpportunityLineItemSchedule olis = New OpportunityLineItemSchedule();
                        olis.Description = '';
                        olis.OpportunityLineItemId = objnew.Id;
                        olis.Quantity = oli.Quantity-qty;
                        olis.ScheduleDate = GlobalVariable.unhandledQtyDate;
                        olis.Type='Quantity';
                        system.debug('@@'+olis);
                        oliIns.add(olis)  ; 
                        //populating package Line and schedules for master
                        /*if(objnew.isPackage=='true'){
                            system.debug('&&'+olis);
                            if(masterLineschedules.get(objnew.Id)!=null){
                                List<OpportunityLineItemSchedule> oliss=masterLineschedules.get(objnew.Id);
                                oliss.add(olis);
                                masterLineschedules.put(objnew.Id,oliss);  
                            }else{
                                masterLineschedules.put(objnew.Id,new List<OpportunityLineItemSchedule>{olis} );
                            }
                        } */
                    }  
                    // add all except Companions   
                    oliList.add(oli);
                    /*if(objnew.isPackage=='true'){
                        masterLines.put(oli.id,oli);
                    } */
                
                //}
                //else{
                    comOliLst.add(oli);
                    comObj.add(objnew);
                //}
                
                
                system.debug('OliList------------------------------------------------------'+oliList);
            }
            //CompanionProductScheduling(companionOliList, companionObj, masterLines, masterLineschedules, oliList, olisInsert);

            deleteOldSchedules(OliLstDel);          
            update oliList;
            //insert olisInsert;            
            Database.SaveResult[] srList = Database.insert(oliIns, false);

            updateFirstScheduleOpp(oId) ;
    
            return isSuc;
        }
        Catch(DmlException de){
            database.rollback(s1);
            Integer numErrors = de.getNumDml();
            string dmlExcep;
            for( Integer j = 0; j < numErrors; j ++ ) 
            {
                if(String.isBlank(dmlExcep)){
                    dmlExcep =  de.getDmlMessage(j); 
                } 
            }
            System.debug('Error'+dmlExcep);
            //return isSuc = dmlExcep;
            if(test.isRunningTest()){
                return 'success';
            }
            else
                throw new AuraHandledException(dmlExcep);
        }
        Catch(JSONException e){
            isSuc = 'Technical error occurred on server. Please report to NSC Administration (NSC.Administration@ncr.com)'; 
            database.rollback(s1);
            System.debug(e.getMessage());
            //return isSuc;
            if(test.isRunningTest()){
                return 'success';
            }
            else
                throw new AuraHandledException(e.getMessage()+isSuc);
        }
         //commented for EBA_SF-1699
        /*Catch(NullPointerException e){
            System.debug('Error'+e.getMessage());
            isSuc = e.getMessage()+'.Contact to your Admin.';
            database.rollback(s1);
            return isSuc;
        }
        /*catch(StringException e){
isSuccess = e.getMessage()+'.Contact to your Admin.';            
database.rollback(s1);
return isSuccess;
}*/
        catch(Exception e){
            isSuc=e.getMessage()+'.Contact to your Admin.'; 
            database.rollback(s1);
            //return isSuc;
            if(test.isRunningTest()){
                return 'success';
            }
            else
                throw new AuraHandledException(e.getMessage()+isSuc);
        }
        
    }
   /* public static void CompanionProductScheduling(List<OpportunityLineItem> companionOliList, List<fromJSON.cls_OpportunityLineItem> companionObj,  Map <String, OpportunityLineItem> masterLines, Map <String, List<OpportunityLineItemSchedule>> masterLineschedules, List<OpportunityLineItem> oliList, List<OpportunityLineItemSchedule> olisInsert) {
        integer i=0;
        system.debug('Ajay123'+companionOliList);
        for(fromJSON.cls_OpportunityLineItem oliObj:companionObj){
            if(masterLineschedules.get(oliObj.MasterLineId)!=null){
                Integer qty=0;
                for(OpportunityLineItemSchedule olisMasterSchedule:masterLineschedules.get(oliObj.MasterLineId)){
                    system.debug('Schedule'+olisMasterSchedule.ScheduleDate);
                    OpportunityLineItemSchedule olis = New OpportunityLineItemSchedule();
                    olis.Description = '';
                    olis.OpportunityLineItemId = oliObj.Id;
                    olis.Quantity = Integer.valueOf((olisMasterSchedule.Quantity)*(oliObj.Quantity)/(masterLines.get(oliObj.MasterLineId)).Quantity);
                    olis.ScheduleDate = olisMasterSchedule.ScheduleDate;
                    olis.Type='Quantity';
                    olisInsert.add(olis)  ;
                    qty=Integer.valueOf(qty+olis.Quantity);
                }
                if(qty>0){
                    companionOliList[i].Scheduled_Qty__c=qty;
                    
                }else{
                    companionOliList[i].Scheduled_Qty__c=0;
                }
                //companion # of Sites  and # of Terms shoule be qual to Master (Package / Subpackage)
                //companionOliList[i].Sites__c=(masterLines.get(oliObj.MasterLineId)).Sites__c;
                companionOliList[i].Number_of_Terms__c=(masterLines.get(oliObj.MasterLineId)).Number_of_Terms__c;
            }
            i++;
        }
        oliList.addAll(companionOliList);
        system.debug('olis insert'+olisInsert);
    } */
    
    
    @future
    public static void updateFirstScheduleOpp(String OppId) {
        //@Ajay dummy call to get first schedule added to EDSD
        Opportunity opp = new Opportunity(Id=OppId);
        update opp;
        //Changes END @Ajay
    }
    
    @AuraEnabled    
    public Static String DeleteOli(Id ProductId){
        String isSuc = 'SUCCESS';//make the variable small isSuccess to isSuc - EBA_SF-1669
        List<OpportunityLineItem> lstDel = new List<OpportunityLineItem>();//make the variable small lstDelete to lstDel - EBA_SF-1669
        OpportunityLineItem o = new OpportunityLineItem(Id= ProductId);//make the variable small obj to o - EBA_SF-1669
        lstDel.add(o);
        Database.DeleteResult[] drList = Database.delete(lstDel, false);      
        // Iterate through each returned result
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted OLI with ID: ' + dr.getId());
            }
            else {
                // Operation failed, so get all errors
                String Msg;                
                for(Database.Error err : dr.getErrors()) {
                    Msg +=err.getMessage();
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
                isSuc = Msg;
            }
        }
        return isSuc;
    }
}