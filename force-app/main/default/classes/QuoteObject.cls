global class QuoteObject {
        webservice String appName;
        webservice String quoteName;
        webservice String quoteNumber;
        webservice String ERPOrderNumber; 
        webservice String MCN; 
        webservice Decimal quoteAmount;
        webservice String quoteCurrency; 
        webservice Datetime submittedDate; 
        webservice Datetime lastModifiedDate;
        webservice String versionNumber;
        webservice String Status;
        webservice String opportunityNumber;
        webservice String accountCountryCode;
        webservice String userQuickLookId;
        String orderId;
        String quoteAccountId;
        
        global String AccountId {
            get {
                return quoteAccountId; 
            } 
            set {
                this.quoteAccountId = value;
            }   
        }
        
        global String orderDetailId {
            get {
                return orderId; 
            } 
            set {
                this.orderId = value;
            }   
        }
        
    }