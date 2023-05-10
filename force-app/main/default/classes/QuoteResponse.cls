global class QuoteResponse {

        webservice String status;
        webservice String message;
        webservice String output;

        global QuoteResponse() {
            System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement 
        }

        global QuoteResponse(String status, String message){
            this.status = status;
            this.message = message;
        }
    }