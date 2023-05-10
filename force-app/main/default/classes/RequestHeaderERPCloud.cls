public class RequestHeaderERPCloud {
    @AuraEnabled
    public ERPInvoiceHeaderRequest ERPInvoiceHeaderRequest;
    @AuraEnabled
    public String InvoiceList;
    @AuraEnabled
    public String MCN;
    
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
    
    public class ERPInvoiceHeaderRequest {
        @AuraEnabled
        public List<String> InvoiceList;
        @AuraEnabled
        public String MCN;
    }
    
    @AuraEnabled
    public static String parse(RequestHeaderERPCloud  Obj) {
        return JSON.serialize(Obj);
    }
}