global class adobe_tools {
    
    private static final string INTEGRATION_KEY = '3AAABLblqZhAT1r-0EDpwMtove_mSdNLB12l2Wdlc1YjBrdmIfP1_ZR5oTwlkrN2zoVwhVe_optRZReGfiK3Qr-K2gmFrhsxG';

    private static final string API_VERSION = 'v5';
    
    @RemoteAction
    webService static List<String> formData( List<String> agreementIds ) { return MapToList( formData_get(INTEGRATION_KEY, getAgreementID( agreementIds.get( 0 ) ) ) ); }

    global static Map<String,String> formData_get( String Access_Token, String agreementId ) {
        
        Map<String, String> response = new Map<String, String>();
        
        List<String> filelines = new List<String>();
        
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint( 'https://api.na1.echosign.com/api/rest/' + API_VERSION + '/agreements/' + agreementId + '/formData' );
        req.setMethod( 'GET' );
        req.setHeader( 'Content-Type', 'application/json' );
        req.setHeader( 'Access-Token', Access_Token );
        req.setHeader( 'agreementId', agreementId );
        
        Http http = new Http();
        HttpResponse res;
        
        if( !test.isrunningTest() ) { res = http.send( req ); } 
        if( !test.isrunningTest() ) { filelines = res.getBody().split('\n'); } else {
            
            filelines.add('"completed","email","role","first","last","title","company","agreementId","mergeCompanyName","mergeEmail","mergeFirstName","mergeLastName"');
            filelines.add('"2016-06-24 13:20:07","cmerrill.adobe+sign@gmail.com","SIGNER","Chris","Merrill","","","3AAABLblqZhCbFbVEHydxTmjMPpe7ShL_gKDTGi4zPzSnM6-CaZ7PROqaePaBwEw6W9IGcj589zh4YgSWcQEU1OXt6SGvpnzG","Merrill Company INC.","cmerrill.adobe+sign@gmail.com","Christopher","Merrill sr."');
        }
        
        List<String> f_keys = filelines.get(0).split(',');
        List<String> f_vals = filelines.get(1).split(',');
        
        for (Integer i = 0, j = 0; i < f_keys.size(); i++) {
        
            if( f_keys.get(i) != '"agreementId"') {
                
                response.put( f_keys.get(i).remove('"').capitalize(), f_vals.get(i).remove('"') );
                
            } // </if -
        
        } // </for -
        
        return response;
        
    }
    
    private static string getAgreementID( id aID) {
        
        List<echosign_dev1__SIGN_Agreement__c> a = [ SELECT echosign_dev1__Document_Key__c FROM echosign_dev1__SIGN_Agreement__c WHERE id = :aID limit 1];
        
        if( !a.isEmpty()) {
            return a.get(0).echosign_dev1__Document_Key__c;
        } else {  return null; } 
        
    }
    
    private static list<String> MapToList( Map<String, String> inMap ) {
        
        List<String> response = new list<String>();
        
        for( String k : inMap.keyset() ) {
            response.add( k + ':' + inMap.get(k) );
        }
        
        return response;
        
    }

}