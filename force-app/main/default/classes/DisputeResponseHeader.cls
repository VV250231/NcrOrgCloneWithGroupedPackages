global class DisputeResponseHeader {
    global String TransactionID;
    global String Timestamp;
    global String Status;
    
    global DisputeResponseHeader() {}
    
    global DisputeResponseHeader(String transactionID, String timestamp, String status) {
        this.TransactionID = TransactionID;
        this.Timestamp= timestamp;
        this.Status= status;
    }
}