public class OracleCloudToSFService {
    /*public class Invoice {
@AuraEnabled
public String OrgName;
@AuraEnabled
public String OrgId;
@AuraEnabled
public String CountryCode;
@AuraEnabled
public String InvoiceNumber;
@AuraEnabled
public String CustomerTrxID;
@AuraEnabled
public String MCN;
@AuraEnabled
public String CustomerName;
@AuraEnabled
public String Source;
@AuraEnabled
public String PONumber;
@AuraEnabled
public String RelatedOrder;
@AuraEnabled
public String QuoteNumber;

@AuraEnabled
public String SummaryInvoice;
@AuraEnabled
public String InvoiceDate;
@AuraEnabled
public String TransactionType;
@AuraEnabled
public String CurrencyCode;
@AuraEnabled
public String OriginalBalance;
@AuraEnabled
public String BalanceDue;
@AuraEnabled
public String LineAmount;
@AuraEnabled
public String TaxAmount;
@AuraEnabled
public String FreightAmount;
@AuraEnabled
public String TotalInvoiceAmount;
@AuraEnabled
public String InvoiceStatus;
}*/
    /*public class Invoices {
        @AuraEnabled
        public List<Invoice> Invoice;
    }
    @AuraEnabled
    public Invoices Invoices;
    //@AuraEnabled
    /*public ERPInvoiceHeaderResponseABM ERPInvoiceHeaderResponseABM;

/*  public class ERPInvoiceHeaderResponse {
@AuraEnabled
public Invoices Invoices;
}

/*    public class RequestHeader {
@AuraEnabled
public String TransactionID;
@AuraEnabled
public String Timestamp;
@AuraEnabled
public String Status;
}

public class Invoices {
@AuraEnabled
public List<Invoice> Invoice;
}

/* public class ERPInvoiceHeaderResponseABM {
@AuraEnabled
public RequestHeader RequestHeader;
@AuraEnabled
public ERPInvoiceHeaderResponse ERPInvoiceHeaderResponse;
}*/
    @AuraEnabled
    public List<InvoiceList> InvoiceList;
    
    
    public class InvoiceList {
        @AuraEnabled
        public String OrgId;
        @AuraEnabled
        public String OrgName;
        @AuraEnabled
        public String CountryCode;
        @AuraEnabled
        public String InvoiceNumber;
        @AuraEnabled
        public String CustomerTrxID;
        @AuraEnabled
        public String MCN;
        @AuraEnabled
        public String CustomerName;
        @AuraEnabled
        public String Source;
        @AuraEnabled
        public String PONumber;
        @AuraEnabled
        public String RelatedOrder;
        @AuraEnabled
        public String SummaryInvoice;
        @AuraEnabled
        public String InvoiceDate;
        @AuraEnabled
        public String TransactionType;
        @AuraEnabled
        public String CurrencyCode;
        @AuraEnabled
        public Decimal OriginalBalance;
        @AuraEnabled
        public Decimal BalanceDue;
        @AuraEnabled
        public Decimal LineAmount;
        @AuraEnabled
        public Decimal TaxAmount;
        @AuraEnabled
        public Decimal FreightAmount;
        @AuraEnabled
        public Decimal TotalInvoiceAmount;
        @AuraEnabled
        public String InvoiceStatus;
    }
    @AuraEnabled 
    public static OracleCloudToSFService parseResponse(String json) {
        System.debug('@@@@'+json);
        OracleCloudToSFService DeseriObj= (OracleCloudToSFService)System.JSON.deserialize(json, OracleCloudToSFService.class);
        System.debug('@@@@'+DeseriObj);
        return DeseriObj;  
    }
}