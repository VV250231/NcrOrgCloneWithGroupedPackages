public class PardateTableDataToDisputeInvoice {
    
    public String BalanceDue;
    public String CountryCode;
    public String CurrencyCode;
    public String CustomerName;
    public String CustomerTrxID;
    public String FreightAmount;
    public String InvoiceDate;
    public String InvoiceNumber;
    public String InvoiceStatus;
    public String LineAmount;
    public String MCN;
    public String OriginalBalance;
    public String PONumber;
    public String QuoteNumber;
    public String RelatedOrder;
    public String Source;
    public String SummaryInvoice;
    public String TaxAmount;
    public String TotalInvoiceAmount;
    public String TransactionType;
    
    
    public static String parse(String json,String DisputeRecordId) {
        //return (List<PardateTableDataToDisputeInvoice>) System.JSON.deserialize(json, List<PardateTableDataToDisputeInvoice>.class);
        String Msg='';
        
        if(String.isNotBlank(json)){ 
            
            //return (PardateTableDataToDisputeInvoice) System.JSON.deserialize(json, PardateTableDataToDisputeInvoice.class);
            List<PardateTableDataToDisputeInvoice> InvoiceObj = new List<PardateTableDataToDisputeInvoice>();
            InvoiceObj=(List<PardateTableDataToDisputeInvoice>) System.JSON.deserialize(json, List<PardateTableDataToDisputeInvoice>.class);
            List<Dispute_Invoices__c> DisputeInvoiceList= new List<Dispute_Invoices__c>();
            //system.debug('InvoiceObj'+ (PardateTableDataToDisputeInvoice) System.JSON.deserialize(json, PardateTableDataToDisputeInvoice.class));       
            //InvoiceObj = (PardateTableDataToDisputeInvoice) System.JSON.deserialize(json, PardateTableDataToDisputeInvoice.class);
            System.debug('InvoiceObj---->'+InvoiceObj);
            for(PardateTableDataToDisputeInvoice Obj : InvoiceObj){
                
                System.debug('obj----'+System.JSON.serializePretty((Object)obj, false)); 
                Dispute_Invoices__c DisputeInvoiceObj = new Dispute_Invoices__c();
                
                if(String.isNotBlank(Obj.MCN)){
                    DisputeInvoiceObj.MCN__c=Obj.MCN; 
                    DisputeInvoiceObj.Name='Dispute Invoice-'+Obj.InvoiceNumber;
                } 
                
                if(String.isNotBlank(Obj.BalanceDue)){
                    DisputeInvoiceObj.Balance_Due__c=Decimal.valueOf(Obj.BalanceDue);
                }
                
                
                DisputeInvoiceObj.Country_Code__c=Obj.CountryCode;
                DisputeInvoiceObj.CurrencyIsoCode=obj.CurrencyCode;
                DisputeInvoiceObj.Customer_Name__c=Obj.CustomerName;
                DisputeInvoiceObj.Customer_Trx_ID__c= safeDecimal(Obj.CustomerTrxID); //Decimal.valueOf(Obj.CustomerTrxID);
                DisputeInvoiceObj.Dispute__c=DisputeRecordId;
                DisputeInvoiceObj.Freight_Amount__c= safeDecimal(Obj.FreightAmount);  // Decimal.valueOf(Obj.FreightAmount) 
                
                if(String.isNotBlank(Obj.InvoiceDate)){
                    system.debug('::: '+Obj.InvoiceDate);
                    //system.debug('???? ' + parseStringToDate(Obj.InvoiceDate)); 
                    DisputeInvoiceObj.Invoice_Date__c=parseStringToDate(Obj.InvoiceDate);//work on this
                } 
                
                DisputeInvoiceObj.Invoice_Number__c=Obj.InvoiceNumber;
                DisputeInvoiceObj.Line_Amount__c=safeDecimal(Obj.LineAmount); //Decimal.valueOf(Obj.LineAmount); safeDecimal
                DisputeInvoiceObj.Original_Balance__c= safeDecimal(Obj.OriginalBalance); //Decimal.valueOf(Obj.OriginalBalance); 
                DisputeInvoiceObj.PO_Number__c=obj.PONumber;
                DisputeInvoiceObj.Related_Order__c =Obj.RelatedOrder;
                DisputeInvoiceObj.Source__c=Obj.Source;
                DisputeInvoiceObj.Summary_Invoice__c=Obj.SummaryInvoice;
                DisputeInvoiceObj.Tax_Amount__c=safeDecimal(Obj.TaxAmount); //Decimal.valueOf(Obj.TaxAmount);
                DisputeInvoiceObj.Total_Invoice_Amount__c=safeDecimal(Obj.TotalInvoiceAmount);  //Decimal.valueOf(Obj.TotalInvoiceAmount);
                DisputeInvoiceObj.Transaction_Type__c=Obj.TransactionType; 
                DisputeInvoiceList.add(DisputeInvoiceObj);
                
            }
            if(DisputeInvoiceList.size()>0){
                System.debug('DisputeInvoiceList---->'+DisputeInvoiceList);
                insert DisputeInvoiceList;
                try{
                    //Send Dispute to ERPCloud if SF is Dispute ROR                    
                    if(DisputeUtil.getDspROR() == 'SF') { 
                        CaseTriggerHandler caseHndlr = new CaseTriggerHandler(); 
                        List <Case> c= [Select id, latestCaseCommentId__c, RecordTypeId from Case where id=:DisputeRecordId];
                        caseHndlr.Dispute_syncToERPCloud(c, null, true); 
                    }
                }catch(Exception e){
                    system.debug('Exception calling ERP Service through RPA');
                }
                
                Msg='Success';
            }
            
        }
        
        return Msg;
    }
    
    public static Decimal safeDecimal(String inpVal) {
        return (String.isNotBlank(inpVal) ? Decimal.valueOf(inpVal) : null);  	
    }
    
    
    Public Static Date parseStringToDate(String dateString){
        List <String> dateParts = dateString.toLowerCase().split('-');
        //day 0 mon 1 year 2
       	//system.debug(' months.get(dateParts[0])'+ Integer.valueOf(dateParts[0]));
        //system.debug(' months.get(dateParts[1])'+ Integer.valueOf(dateParts[1]));
        //system.debug(' months.get(dateParts[2])'+ Integer.valueOf(dateParts[2].substring(0,2)));
        Integer month,day,year;
        if(UserInvoiceAuthanticationCCAD.getERPSysType()=='ERP OnPremise'){
            Map <String, Integer> months = new Map <String, Integer> {'jan'=>1, 'feb'=>2
            , 'mar'=>3, 'apr'=>4, 'may'=>5, 'jun'=>6, 'jul'=>7, 'aug'=>8, 'sep'=>9
            , 'oct'=>10, 'nov'=>11, 'dec'=>12};
        	month = months.get(dateParts[1]);
        	day = Integer.valueOf(dateParts[0]);
        	year = Integer.valueOf(dateParts[2]);
        }else{
            month = Integer.valueOf(dateParts[1]);
        	day = Integer.valueOf(dateParts[2].substring(0,2));
        	year = Integer.valueOf(dateParts[0]);
            
        }
        Date parsedDate = Date.newInstance(year,month,day);
        //system.debug('parsedDate'+dateParts);  
        return parsedDate;
    } 
    
    Public Static List<PardateTableDataToDisputeInvoice> ParseSummeryData(String json){
        return (List<PardateTableDataToDisputeInvoice>) System.JSON.deserialize(json, List<PardateTableDataToDisputeInvoice>.class);
    }
}