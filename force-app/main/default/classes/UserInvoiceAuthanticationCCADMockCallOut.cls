global class UserInvoiceAuthanticationCCADMockCallOut implements HttpCalloutMock{
   global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "ERPInvoiceHeaderResponseABM" : { "RequestHeader" : { "TransactionID" : "44b3aac5-b3e4-4e3e-9090-7723d9b7f4ba", "Timestamp" : "2020-07-23T16:58:46.629-04:00", "Status" : "SUCCESS"},"ERPInvoiceHeaderResponse" : { "Invoices" : {"Invoice" : [ { "InvoiceNumber" : "201820662","CountryCode" : "IT","CustomerTrxID" : "1325065184", "MCN" : "5134171","CustomerName" : "SIMLOU S.R.L.","Source" : "OKS_CONTRACTS","PONumber" : " ","QuoteNumber" : " ", "RelatedOrder" : "1066581", "SummaryInvoice" : " ", "InvoiceDate" : "30-MAR-2018", "TransactionType" : "Invoice-OKS", "CurrencyCode" : "EUR","OriginalBalance" : "2156.35","BalanceDue" : "0","LineAmount" : "1767.5", "TaxAmount" : "388.85","FreightAmount" : "0","TotalInvoiceAmount" : "2156.35","InvoiceStatus" : "Valid"}, { "InvoiceNumber" : "asdasdas", "CountryCode" : "IT","InvoiceStatus" : "Invalid invoice number and country code combination" } ] }} }}');
        response.setStatusCode(200);
        return response; 
    }
}