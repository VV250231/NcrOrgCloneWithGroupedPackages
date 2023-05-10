public class SoupERPResult {
    
	public class Invoice {
        @AuraEnabled
		public String InvoiceNumber;
        @AuraEnabled
		public String CountryCode;
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
		public String QuoteNumber;
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
	}
    @AuraEnabled
	public ERPInvoiceHeaderResponseABM ERPInvoiceHeaderResponseABM;

	public class ERPInvoiceHeaderResponse {
        @AuraEnabled
		public Invoices Invoices;
	}

	public class RequestHeader {
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

	public class ERPInvoiceHeaderResponseABM {
        @AuraEnabled
		public RequestHeader RequestHeader;
        @AuraEnabled
		public ERPInvoiceHeaderResponse ERPInvoiceHeaderResponse;
	}

	@AuraEnabled 
	public static SoupERPResult parseResponse(String json) {
	  SoupERPResult DeseriObj= (SoupERPResult)System.JSON.deserialize(json, SoupERPResult.class);
      return DeseriObj;  
	}
}