public class Generaterequestheader {
	
	public class ERPInvoiceHeaderRequestABM {
        @AuraEnabled
		public RequestHeader RequestHeader;
        @AuraEnabled
		public ERPInvoiceHeaderRequest ERPInvoiceHeaderRequest;
	}

	public class Invoice {
        @AuraEnabled
		public String InvoiceNumber;
        @AuraEnabled
		public String CountryCode;
	}
    
    
    @AuraEnabled
	public ERPInvoiceHeaderRequestABM ERPInvoiceHeaderRequestABM;

	public class RequestHeader {
        @AuraEnabled
		public String TransactionID;
        @AuraEnabled
		public String SourceSystem;
        @AuraEnabled
		public String Timestamp;
        @AuraEnabled
		public String TargetSystem;
	}

	public class Invoices{
        @AuraEnabled
		public List<Invoice> Invoice;
        
        public Invoices(){
            
            Invoice = new List<Invoice>();
        }
	}

	public class ERPInvoiceHeaderRequest {
        @AuraEnabled
		public Invoices Invoices;
	}
    @AuraEnabled
	public static String parse(Generaterequestheader  Obj) {
		return JSON.serialize(Obj);
	}
}