public class InvoiceSummeryController {
    
    
    @AuraEnabled
    Public Static Invoicesummerywrap GetInvoiceSummery(String jonString){
        List<PardateTableDataToDisputeInvoice>  InvoiceParceObj =  new List<PardateTableDataToDisputeInvoice>();
        InvoiceParceObj = PardateTableDataToDisputeInvoice.ParseSummeryData(jonString);
        Invoicesummerywrap SummeryObj = new Invoicesummerywrap();
        if(InvoiceParceObj.size() > 0){
           
            if(String.isNotBlank(InvoiceParceObj[0].MCN)){
                SummeryObj.MCN = String.valueOf(InvoiceParceObj[0].MCN);
            } 
            
            if(String.isNotBlank(InvoiceParceObj[0].CountryCode)){
                SummeryObj.CountryCode = String.valueOf(InvoiceParceObj[0].CountryCode);
            } 
            
            if(String.isNotBlank(InvoiceParceObj[0].CustomerName)){
                SummeryObj.CustomerName = String.valueOf(InvoiceParceObj[0].CustomerName);
            } 
            
            if(String.isNotBlank(InvoiceParceObj[0].CurrencyCode)){
                SummeryObj.CurrencyCode=String.valueOf(InvoiceParceObj[0].CurrencyCode);
            }
            	
            for(PardateTableDataToDisputeInvoice Invobj : InvoiceParceObj){
                
                if(String.isNotBlank(Invobj.OriginalBalance))
                SummeryObj.OriglanBalance = SummeryObj.OriglanBalance+Decimal.ValueOf(Invobj.OriginalBalance);
                
                if(String.isNotBlank(Invobj.LineAmount))
                SummeryObj.LineAmount = SummeryObj.LineAmount+Decimal.ValueOf(Invobj.LineAmount);
                
                if(String.isNotBlank(Invobj.FreightAmount))
                SummeryObj.FreightAmount = SummeryObj.FreightAmount+Decimal.ValueOf(Invobj.FreightAmount);
                
                if(String.isNotBlank(Invobj.TotalInvoiceAmount))
                SummeryObj.TotalInvoiceAmount = SummeryObj.TotalInvoiceAmount+Decimal.ValueOf(Invobj.TotalInvoiceAmount);
                
                if(String.isNotBlank(Invobj.TaxAmount))
                SummeryObj.TaxAmount = SummeryObj.TaxAmount+Decimal.ValueOf(Invobj.TaxAmount);
                if(String.isNotBlank(Invobj.BalanceDue))
                SummeryObj.BalanceDue = SummeryObj.BalanceDue+Decimal.ValueOf(Invobj.BalanceDue);
                if(String.isNotBlank(Invobj.CurrencyCode))
                SummeryObj.CurrencyCode=String.ValueOf(SummeryObj.CurrencyCode);
                    
                
                
            }
            
        }
        
        return SummeryObj;
    }
    
    
    Public Class Invoicesummerywrap{
        
        @AuraEnabled
        Public String CustomerName;
        @AuraEnabled
        Public String CountryCode;
        @AuraEnabled
        Public String MCN;
        @AuraEnabled
        Public decimal  OriglanBalance=0.00;
        @AuraEnabled
        Public decimal  LineAmount=0.00;
        @AuraEnabled
        Public decimal FreightAmount=0.00;
        @AuraEnabled
        Public decimal TotalInvoiceAmount=0.00;
        @AuraEnabled
        Public decimal TaxAmount=0.00;
        @AuraEnabled
        Public decimal BalanceDue=0.00;
        @AuraEnabled
        Public String CurrencyCode;
        
    }
}