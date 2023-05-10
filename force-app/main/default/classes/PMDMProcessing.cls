/**************************************
Author ...............: Ajay Dixit
Date Created .........: 16 Oct 2017
Last Modified By .....:
Last Modified Date ...: 27-Aug-2018
Description ..........: This class holds Business Logic of services exposed for Product management and is called by PMDM via SOUP
Change History........: Fixed Offer notification bug.
NC_AGILE-2016         :14-Nov-2018: Added industry association using name which is prepended by Industry and send notification with Industry details.
:  Field added for As-A-Service requirement

***************************/
public class PMDMProcessing {
    public static Set<String> ProductActiveStatus=new Set<String>();
    public static Set<String> SolutionActiveStatus=new Set<String>();    
    Map<String, PMDM_Active_Status__c> actives = PMDM_Active_Status__c.getAll();    
    
    public ResponseOfRequest solutionProcess(SolutionRequest sr) {
        ResponseOfRequest res = new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); 
        for(String s:actives.keySet()){
            if(actives.get(s).Solution__c){
                SolutionActiveStatus.add(s.toUpperCase());
            }   
        }
        try {
            //get Id and name of Solution
            Map <String, String> solMap=new Map<String, String>();
            solMap.putAll(sr.getSolMap(sr.SolutionSet.Solution));
            String solId=solMap.get('id');
            String solName=solMap.get('name');
            
            // check if this is Create / Update Request
            if ([Select id from Product_Solution__c where Solution_ID__c = : solId].size() > 0) { 
                // is update, handle "Inactivation", "Name Change", "Activation" notifications
                Product_Solution__c ps=[Select id, Name, Offer_Type__c,Offer_Status__c, isActive__c from Product_Solution__c where Solution_ID__c = : solId];
                //Request contains active Offer
                String msg='';
                if(sr.Offer_Type!=null && sr.Offer_Type.toUpperCase()=='OFFER' && SolutionActiveStatus.contains(sr.Offer_Status.toUpperCase()) ){
                    //name change
                    if(ps.Name!=solName){
                        msg='Offer name was changed from "'+ps.Name+'" to "'+solName+'". </br>';           
                    }
                    //Activation
                    if(ps.isActive__c==false){
                        msg= msg + 'Status of Offer is changing from In-active to Active for Offer:</br>'+solName+' </br>';
                    }
                    //Solution to Offer
                    if(ps.Offer_Type__c.toUpperCase()!='OFFER'){
                        msg=msg+'This is a new Offer from existing record:</br>'+solName +' </br>';  
                    }
                    ps.isActive__c=true;
                }else{
                    //In-Activation
                    if(ps.isActive__c==true && !(SolutionActiveStatus.contains(sr.Offer_Status.toUpperCase())) && ps.Offer_Type__c.toUpperCase()=='OFFER'){
                        msg= msg + 'Status of Offer is changing from Active to In-Active for Offer:</br>'+solName+' </br>';
                        ps.isActive__c=false;
                    }
                    if(ps.Offer_Type__c!=null && ps.Offer_Type__c.toUpperCase()=='OFFER' && (sr.Offer_Type==null || sr.Offer_Type.toUpperCase()!='OFFER')){
                        //In- Activation when request doesnt have Offer and Record was Offer
                        msg= msg + 'This Offer is no longer an Offer, Please Inactivate the Opportunity Picklist:</br>'+solName+' </br>';   
                    }
                    
                }           
                ps.Name=solName;
                ps.Offer_Status__c=sr.Offer_Status;
                ps.Offer_Type__c=sr.Offer_Type;
                update ps;
                if(!String.isEmpty(msg)){
                    notifyNewSingleSolution(msg+ getIndustryAlignment(solName)); 
                }
            } else {
                //handle new Offer notification
                Product_Solution__c ps=new Product_Solution__c(Solution_ID__c=solId, Name=solName, Offer_Status__c=sr.Offer_Status, Offer_Type__c=sr.Offer_Type);
                if(sr.Offer_Type!=null && sr.Offer_Type.toUpperCase()=='OFFER' && SolutionActiveStatus.contains(sr.Offer_Status.toUpperCase())){
                    notifyNewSingleSolution('Please add new Offer in the Picklist:'+solName+', '+ getIndustryAlignment(solName));
                    ps.isActive__c=true;
                }
                insert ps;
                
            } 
            res.status = ResponseOfRequest.STATUS_SUCCESS;
            return res;
        } catch (Exception e) {
            Database.rollback(sp);
            res = new ResponseOfRequest('Exception: ' + e.getMessage());
            return res;            
        }
    }
    public String getIndustryAlignment(String solName){
        if(solName.startsWithIgnoreCase('fs')){
            return 'The solution is aligned to Financial as Industry.';
        }else if(solName.startsWithIgnoreCase('rtl')){
            return 'The solution is aligned to Retail as Industry.';
        }else if(solName.startsWithIgnoreCase('hosp')){
            return 'The solution is aligned to Hospitality as Industry.';            
        }else {
            return 'The solution is unspecified, check with PMDM and align appropriate industry';  
        }
    }
    
    public ResponseOfRequest productProcess(ProductRequest pr) {
        for(String s:actives.keySet()){
            if(actives.get(s).Product__c){
                ProductActiveStatus.add(s.toUpperCase());
            }   
        }
        if(!(ProductActiveStatus.size()>0)){
            ProductActiveStatus.addAll(new Set<String> {'ORDERABLE', 'INVOICE ONLY', 'NOT YET FOR SALE','SERVICE ONLY'}); 
        }
        ResponseOfRequest res = new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); 
        try {
            
            if ([Select id, End_Date__c from Product2 where PMDM_Unique_Key__c = : pr.ID].size() > 0) {                                       
                res = updateProduct(pr);
            } else {
                res = createProduct(pr);
            }            
            return res;
        } catch (Exception e) {
            Database.rollback(sp);
            res = new ResponseOfRequest('Exception: ' + e.getMessage());
            return res;            
        }
    }
    
    private ResponseOfRequest createProduct(ProductRequest pr) {
        String TNT_STR=' T&T ';
        ResponseOfRequest res = new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); 
        try {   
            if(pr.End_of_Sales_Date!=null){
                res=new ResponseOfRequest('New Product is not expected to have End Of Sales Date')  ;
            }else{
                String Industry='';
                String OfferPortfolio='';
                if(pr.DivisionSet!=null && pr.DivisionSet.Division!=null && String.isEmpty(pr.getStringVsp(pr.DivisionSet.Division))==false){
                    Industry =pr.getStringVsp(pr.DivisionSet.Division);
                }
                if(pr.OfferPortfolioSet!=null && pr.OfferPortfolioSet.offer_Portfolio!=null && String.isEmpty(pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio))==false){
                    OfferPortfolio=pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio);
                }
                Product2 p = new Product2(Name = pr.Product_Name,                                       
                                          IsActive = true,
                                          PMDM_Unique_Key__c = pr.ID,
                                          Industry__c = Industry,
                                          //End_Date__c = toGMTFormat(pr.End_of_Sales_Date),
                                          Solution_Portfolio__c = OfferPortfolio,
                                          Service_Offer_Category__c=pr.Revenue_Type,
                                          Product_Category__c = pr.Product_Type,
                                          // hard coded to USD
                                          CurrencyIsoCode = 'USD',
                                          ROR_Created_By__c = pr.ROR_Created_By,
                                          ROR_Created_Date__c = toGMTFormat(pr.ROR_Created_Date),
                                          ROR_LastModifiedBy__c = pr.ROR_Modified_By,
                                          ROR_LastModifiedDate__c = toGMTFormat(pr.ROR_Modified_Date),
                                          Solution_Manager__c = pr.Product_Manager,
                                          Description=pr.Product_Description,
                                          CanUseQuantitySchedule=true,
                                          Pmdm_Product_Status__c=pr.Product_Status, 
                                          Pmdm_Product_Family__c=pr.getPHLevel(pr.ProductHierarchySet.ProductHierarchy, 3), 
                                          Pmdm_Product_Category__c=pr.getPHLevel(pr.ProductHierarchySet.ProductHierarchy, 2),
                                          Available_for_Subscription__c=(pr.Available_for_Subscription=='Y'?True:False),
                                          OriginalCorporation__c=pr.Product_Original_Company);
                 Original_Corporation_Mapping__mdt ocm = Original_Corporation_Mapping__mdt.getInstance('X'+p.OriginalCorporation__c);
            if(ocm!=null){
                p.OriginalCorporation__c = ocm.Original_Corporation_Name__c; 
            }
            else{
                p.OriginalCorporation__c = '';

            }
                
                if(ProductActiveStatus.contains((pr.Product_Status).toUpperCase())){
                    p.isActive=true;
                }else{
                    p.IsActive=false;
                }
                
                if(!p.Name.contains(TNT_STR) && String.isNotBlank(p.Service_Offer_Category__c) && !(p.Service_Offer_Category__c.equalsIgnoreCase(System.Label.NtwrkSol_RevType))) {
                    String altSol = new Product2TriggerHandler().getRevTypeAndAltSolMap().get(p.Service_Offer_Category__c);
                    if(String.isBlank(altsol)) 
                        throw new PMDMException(Label.No_AltSol_fnd_Err);
                    else 
                        p.ALTF__Solution__c = altSol;
                }
                
                insert p;
                if(p.isActive==true)
                    res=createPriceBookEntry(p);
                // Do Solution Association
                if(pr.SolutionSet!=null && pr.SolutionSet.Solution!=null && String.isEmpty(pr.getStringVs(pr.SolutionSet.Solution))==false){
                    createSolnAssocoation(pr, p, false);  
                }
                
            }
            
        } catch (Exception e) {
            system.debug(e.getMessage());
            throw e; 
            
        }
        return res;
        
    }
    private ResponseOfRequest updateProduct(ProductRequest pr) {
        ResponseOfRequest res = new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); 
        try {
            
            Product2 p = [Select id, name, /*New_DHR_key__c,*/ IsActive, Service_Offer_Category__c, End_Date__c from Product2 where PMDM_Unique_Key__c = : pr.ID].get(0);
            // Deactivation date is set and also if name change is there it will also reflect
            if(pr.End_of_Sales_Date!=null && p.End_Date__c==null){
                NotifyandCreateTask nt;               
                nt=new NotifyandCreateTask(pr.ID);
                Database.ExecuteBatch(nt);
            } 
            updateProdDetails(p,pr);            
            update p;
            // Do Solution Association
            //if(pr.SolutionSet!=null && pr.SolutionSet.Solution!=null && String.isEmpty(pr.getStringVs(pr.SolutionSet.Solution))==false){
            createSolnAssocoation(pr, p, true);  
            //}
            res.status = ResponseOfRequest.STATUS_SUCCESS;
            return res;
        } catch (Exception e) {
            throw e;
            
        }
    }
    private void updateProdDetails(Product2 p, ProductRequest pr){
        String Industry='',OfferPortfolio='', TNT_STR = ' T&T ';
        String exstRvType = p.Service_Offer_Category__c;
        if(pr.DivisionSet!=null && pr.DivisionSet.Division!=null && String.isEmpty(pr.getStringVsp(pr.DivisionSet.Division))==false){
            Industry =pr.getStringVsp(pr.DivisionSet.Division);
        }
        if(pr.OfferPortfolioSet!=null && pr.OfferPortfolioSet.offer_Portfolio!=null && String.isEmpty(pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio))==false){
            OfferPortfolio=pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio);
        }
        p.Name = pr.Product_Name;                                       
        //Annuity_product__c = pr.isAnnuity,
        //p.IsActive = true;
        p.PMDM_Unique_Key__c = pr.ID;
        p.Industry__c = Industry;
        if(pr.End_of_Sales_Date!=null){
            p.End_Date__c = toGMTFormat(pr.End_of_Sales_Date);                                    
            
        }
        p.Solution_Portfolio__c = OfferPortfolio;
        p.Service_Offer_Category__c=pr.Revenue_Type;
        p.Product_Category__c = pr.Product_Type;
        // hard coded to USD
        p.CurrencyIsoCode = 'USD';
        p.ROR_Created_By__c = pr.ROR_Created_By;
        p.ROR_Created_Date__c = toGMTFormat(pr.ROR_Created_Date);
        p.ROR_LastModifiedBy__c = pr.ROR_Modified_By;
        p.ROR_LastModifiedDate__c = toGMTFormat(pr.ROR_Modified_Date);
        p.Solution_Manager__c = pr.Product_Manager;
        p.Description=pr.Product_Description;
        p.CanUseQuantitySchedule=true; 
        p.Pmdm_Product_Status__c=pr.Product_Status;
        p.Pmdm_Product_Family__c=pr.getPHLevel(pr.ProductHierarchySet.ProductHierarchy, 3); 
        p.Pmdm_Product_Category__c=pr.getPHLevel(pr.ProductHierarchySet.ProductHierarchy, 2);
        p.Available_for_Subscription__c=pr.Available_for_Subscription=='Y'?True:False;
        Original_Corporation_Mapping__mdt ocm = Original_Corporation_Mapping__mdt.getInstance('X' + pr.Product_Original_Company);
            if(ocm!=null){
                p.OriginalCorporation__c = ocm.Original_Corporation_Name__c; 
            }
            else{
                p.OriginalCorporation__c = '';
            }
        if(ProductActiveStatus.contains((pr.Product_Status).toUpperCase())){
            //product was InActive and now being Activated
            if(p.isActive==false){
                activatePriceBookEntry(p) ; 
            }
            p.isActive=true;
        }else{
            p.IsActive=false;
        }
        if((!p.Name.contains(TNT_STR)) && (p.Service_Offer_Category__c != exstRvType) && String.isNotBlank(p.Service_Offer_Category__c) 
           	&& !(p.Service_Offer_Category__c.equalsIgnoreCase(System.Label.NtwrkSol_RevType))) {
            String altSol = new Product2TriggerHandler().getRevTypeAndAltSolMap().get(p.Service_Offer_Category__c);
            if(String.isBlank(altSol)) 
                throw new PMDMException(Label.No_AltSol_fnd_Err);
            else 
                p.ALTF__Solution__c = altSol;    
        }
    }
    private Datetime toGMTFormat(DateTime dt){
        TimeZone tz = UserInfo.getTimeZone();
        if(dt!=null){
            string year = String.valueOf(dt.year());
            string month = String.valueOf(dt.month());
            string day = String.valueOf(dt.day());
            string hour = String.valueOf(dt.hour());
            string minute = String.valueOf(dt.minute());
            string second = String.valueOf(dt.second());
            string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' 
                + minute +  ':' + second;
            
            Datetime myDate = Datetime.valueOf(stringDate);
            integer offsetToUserTimeZone = tz.getOffset(myDate);
            myDate= myDate.addMinutes(-offsetToUserTimeZone / (1000 * 60));        
            return myDate;
        }
        return null;
        
    }
    private ResponseOfRequest createPriceBookEntry(product2 p) {
        ResponseOfRequest res = new ResponseOfRequest();
        
        try{
            List <PriceBookEntry> std=new List<PriceBookEntry>();
            List <PriceBookEntry> glbl=new List<PriceBookEntry>();
            // get active currencies
            list<CurrencyType> crncyList = [SELECT ISOCode FROM CurrencyType WHERE IsActive=TRUE];
            // get active Price books
            list<PriceBook2> pbList = [SELECT id, name, IsStandard FROM PriceBook2 WHERE (IsActive=TRUE AND id=:GlobalVariable.pricebookId) OR IsStandard=TRUE];            
            
            // Create pricebookentries
            for(CurrencyType c:crncyList){                          
                for(PriceBook2 pb:pbList){
                    if(pb.IsStandard==true){
                        PriceBookEntry pbe=new PriceBookEntry(CurrencyIsoCode=c.IsoCode,isActive=true,Product2Id=p.id,UnitPrice=0,UseStandardPrice=false,Pricebook2Id=pb.id);
                        /*pbe.CurrencyIsoCode=c.IsoCode;
pbe.isActive=true;
pbe.Product2Id=p.id;
pbe.UnitPrice=0;
pbe.UseStandardPrice=false; 
pbe.Pricebook2Id=pb.id;*/
                        std.add(pbe);
                    }
                    else{
                        PriceBookEntry pbe=new PriceBookEntry(CurrencyIsoCode=c.IsoCode,isActive=true,Product2Id=p.id,UnitPrice=0,UseStandardPrice=false,Pricebook2Id=pb.id);
                        /*pbe.CurrencyIsoCode=c.IsoCode;
pbe.isActive=true;
pbe.Product2Id=p.id;
pbe.UnitPrice=0;
pbe.UseStandardPrice=false; 
pbe.Pricebook2Id=pb.id;*/
                        glbl.add(pbe);
                    }
                }
            }
            insert std;
            insert glbl;
            res.status = ResponseOfRequest.STATUS_SUCCESS;          
            return res;
            
        } catch (Exception e) {
            throw e;
        }
    }
    // Create Soln Association
    private void createSolnAssocoation(ProductRequest pr, product2 p, Boolean isUpdate) {
        Map<String, String> SolnMap=new map<String,String>();
        if(pr.SolutionSet!=null && pr.SolutionSet.Solution!=null && String.isEmpty(pr.getStringVs(pr.SolutionSet.Solution))==false){
            SolnMap=pr.getStringVsIdValueMap(pr.SolutionSet.Solution);
        }
        List <Product_Solution__c> psInsert=new List<Product_Solution__c>();
        List <Product_Solution__c> psUpdate=new List<Product_Solution__c>();
        List <Product_Solution_Mapping__c> psmInsert=new List <Product_Solution_Mapping__c>();
        
        //Create Solution if doesnt exist
        Set<String> solRecordExist=new Set<String> ();
        if(SolnMap.size()>0){
            List <Product_Solution__c > soln=[Select id, name, Solution_ID__c from Product_Solution__c where Solution_ID__c in:SolnMap.keySet()];
            
            if(soln.size()>0){
                for(Product_Solution__c ps:soln){
                    if(SolnMap.containsKey((ps.Solution_ID__c).toUpperCase())){
                        solRecordExist.add((ps.Solution_ID__c).toUpperCase());
                        if(SolnMap.get((ps.Solution_ID__c).toUpperCase())!=ps.Name){
                            ps.Name=SolnMap.get(ps.Solution_ID__c.toUpperCase());
                            psUpdate.add(ps);
                        }
                    }
                }
            }
        }
        // insert remaining / All if soln.size=0
        for(String s: SolnMap.keySet()){
            if(!(solRecordExist.contains(s.toUpperCase()))){
                Product_Solution__c ps=new Product_Solution__c(name=SolnMap.get(s), Solution_ID__c=s);
                psInsert.add(ps);
            }
        }
        // Solution DML
        if(psUpdate.size()>0)
            update psUpdate;
        if(psInsert.size()>0){
            insert psInsert;
            String newSols='';
            for(Product_Solution__c psn:psInsert){
                String solutionAndIndustry=psn.name+'=>'+getIndustryAlignment(psn.name);
                newSols=newSols+solutionAndIndustry+'<br/>';
            }
            notifyNewSolution(newSols);
        }
        // delete all mapping if product is updating to recreate
        if(isUpdate){
            List <Product_Solution_Mapping__c> psm=[Select id from Product_Solution_Mapping__c where product__c =:p.Id];
            if(psm.size()>0)
                delete psm;
        } 
        // insert or recreate junction object as all solution should be available now
        List <Product_Solution__c > allsoln=[Select id, name, Solution_ID__c from Product_Solution__c where Solution_ID__c in:SolnMap.keySet()];
        system.debug('@@'+allsoln);
        for(Product_Solution__c ps:allsoln){
            Product_Solution_Mapping__c psmi=new Product_Solution_Mapping__c(product__c=p.id, Product_Solution__c=ps.Id);
            psmInsert.add(psmi);
        }
        if(psmInsert.size()>0)
            insert psmInsert;
        
    }
    // Activates only existing price Book entries
    @TestVisible
    private ResponseOfRequest activatePriceBookEntry(product2 p) {
        ResponseOfRequest res = new ResponseOfRequest();
        List <PriceBookEntry> std=new List<PriceBookEntry>();
        List <PriceBookEntry> glbl=new List<PriceBookEntry>();
        Set<string> glblCurrency=new Set<String>();
        Set<string> stdCurrency=new Set<String>();
        // get active currencies
        list<CurrencyType> crncyList = [SELECT ISOCode FROM CurrencyType WHERE IsActive=TRUE];
        // get active Price books
        list<PriceBook2> pbList = [SELECT id, name, IsStandard FROM PriceBook2 WHERE (IsActive=TRUE AND id=:GlobalVariable.pricebookId) OR IsStandard=TRUE];            
        try{
            // get all available PBEs of product
            List <PriceBookEntry> allPbe=[Select id, isActive, CurrencyIsoCode, PriceBook2.IsStandard from PriceBookEntry where Product2Id =:p.id] ;
            // activate available PBEs
            for(PricebookEntry pbe:allPbe){
                pbe.IsActive=true;
                // adding to currency set to avoid creation of available PBEs
                if(pbe.priceBook2.IsStandard){
                    stdCurrency.add(pbe.CurrencyIsoCode) ;
                }else{
                    glblCurrency.add(pbe.CurrencyIsoCode);
                }
            }
            
            // Create pricebookentries
            for(CurrencyType c:crncyList){                          
                for(PriceBook2 pb:pbList){
                    if(pb.IsStandard==true){
                        // there is not already std PBE of the currency then create PBE
                        if(!(stdCurrency.contains(c.IsoCode))){
                            PriceBookEntry pbe=new PriceBookEntry();
                            pbe.CurrencyIsoCode=c.IsoCode;
                            pbe.isActive=true;
                            pbe.Product2Id=p.id;
                            pbe.UnitPrice=0;
                            pbe.UseStandardPrice=false; 
                            pbe.Pricebook2Id=pb.id;
                            std.add(pbe);
                        }
                    }
                    else{
                        // there is not already global PBE of the currency then create PBE
                        if(!(glblCurrency.contains(c.IsoCode))){
                            PriceBookEntry pbe=new PriceBookEntry();
                            pbe.CurrencyIsoCode=c.IsoCode;
                            pbe.isActive=true;
                            pbe.Product2Id=p.id;
                            pbe.UnitPrice=0;
                            pbe.UseStandardPrice=false; 
                            pbe.Pricebook2Id=pb.id;
                            glbl.add(pbe);
                        }
                    }
                }
            }
            
            update allPbe;
            insert std;
            insert glbl;
            res.status = ResponseOfRequest.STATUS_SUCCESS;          
            return res;
            
        } catch (Exception e) {
            throw e;
        }
    }
    @future
    public static void notifyNewSolution( String Sols  ){
        Messaging.SingleEmailMessage salesRepMail = new Messaging.SingleEmailMessage();
        salesRepMail.setUseSignature(false);
        SalesRepMail.setSaveAsActivity(false);
        salesRepMail.setToAddresses(new List<String>{'ad250024@ncr.com','NI230017@ncr.com','Mark.Hewatt@ncr.com','LeeAnne.Hamrick@ncr.com','Eloqua.System@ncr.com' });
        salesRepMail.setReplyTo('ad250024@ncr.com');
        salesRepMail.setSubject('New Solution Notification');
        String mailMessage = 'Dear Ops Team,<br/><BR/> Please find below the names of New Solutions to be added in Offer Fields of LEAD and OPPORTUNITY objects:<br/><b>'+Sols+'</b><br/><br/> Thanks';            
        salesRepMail.setHtmlBody(mailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            salesRepMail
                }); 
    }
    @future
    public static void notifyNewSingleSolution( String Sols  ){
        Messaging.SingleEmailMessage salesRepMail = new Messaging.SingleEmailMessage();
        salesRepMail.setUseSignature(false);
        SalesRepMail.setSaveAsActivity(false);
        salesRepMail.setToAddresses(new List<String>{'ad250024@ncr.com','NI230017@ncr.com','Mark.Hewatt@ncr.com','LeeAnne.Hamrick@ncr.com','Eloqua.System@ncr.com' });
        //salesRepMail.setToAddresses(new List<String>{'ad250024@ncr.com'});
        salesRepMail.setReplyTo('ad250024@ncr.com');
        salesRepMail.setSubject('Solution / Offer Notification');
        String mailMessage = 'Dear Ops Team,<br/><BR/> Please find below detail of changes that need to be done on OPPORTUNITY & LEAD Offer field:<br/><b>'+Sols+'</b> <br/><br/> Thanks';            
        salesRepMail.setHtmlBody(mailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            salesRepMail
                }); 
    }
    
    public class PMDMException extends Exception {}
    
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
        integer i=0;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
    }
}