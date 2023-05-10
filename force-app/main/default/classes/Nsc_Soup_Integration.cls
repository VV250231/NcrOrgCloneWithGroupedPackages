public class Nsc_Soup_Integration {
    
    
    final static string SUCCESS_STATUS='SUCCESS';
    final static string FAILURE_STATUS='FAILURE';
    static Soup_Username__mdt   soup_cred;
    
    public static  void synchLOS_OM(list<id> dmgId){
        
        list<Deming__c>deminglist=new list<Deming__c>();
        // deminglist=[select Order_Id__c,Order_number__c,Customer_Acceptance_Date__c,Customer_Name__c,Ncr_Associate__c,isCustomerContacted__c,Customer_Contact_Name__c,Cadd_Status__c,Acceptance_time__c from deming__c where id=:dmgId];     
        deminglist=[select Order_Id__c,Order_number__c,Customer_Acceptance_Date__c,Customer_Name__c,Ncr_Associate__c,isCustomerContacted__c,Customer_Contact_Name__c,Cadd_Status__c,Acceptance_time__c,Reason_Of_Rejection__c from deming__c where id=:dmgId];
        
        //system.debug('@@@@@@'+deminglist);       
        // soup_cred=[select user_name__c,password__c, EndPoint__c from Soup_Username__mdt where DeveloperName='header'];
        //String userID=string.valueof(soup_cred.user_name__c);
        //String password=soup_cred.password__c;
        // String EndPoint=soup_cred.EndPoint__c;
        //system.debug('@@@@@@'+userID+'>>>>>>><<<<<<<'+password+'!!!!!'+EndPoint);
        //String jsonBody ='userID='+userID+'&password='+password; 
        
        try{
            for(deming__c dmg : deminglist){
                if(dmg.Order_Id__c!=null && dmg.Cadd_Status__c!=null  ){
                    
                    
                    
                    
                    
                    
                    
                    String bdy=generateRequestBody(new Uuid().getValue(), 'NSC', string.valueof(Datetime.now().format()), 'ERP', string.valueof(dmg.Order_Id__c),string.valueof(dmg.Order_number__c) ,string.valueof(dmg.Customer_Acceptance_Date__c), string.valueof(dmg.Customer_Contact_Name__c), NSCCommonInfoUtil.getIdOf('AtmPrcsUserId') ,string.valueof(dmg.isCustomerContacted__c), string.valueof(dmg.Cadd_Status__c), string.valueof(dmg.Acceptance_Time__c),string.valueOf(dmg.Reason_Of_Rejection__c));          
                    
                    system.debug('bdy@@@>>>' + bdy);
                    
                    HttpRequest req=new HttpRequest();
                    
                    HttpResponse res= new HttpResponse() ;
                    //Blob headerValue = Blob.valueOf(userID + ':' + password);
                    //String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                    Http h = new Http();
                    req.setBody(bdy);
                    req.setMethod('POST');
                   // req.setHeader('Authorization', authorizationHeader);
                    // req.setEndpoint('https://osbcert-ha.ncr.com/ext/EA/NSC/Services/NSCOrderHeaderUpdatePS?wsdl');
                    req.setEndpoint('callout:NSC_SOUP_Header');
                        // req.setEndpoint(EndPoint);
                        if(!Test.isRunningTest()) {
                            res = h.send(req);
                            System.debug(res.getStatus());
                            //system.debug('<><><><><'+res);
                            
                            
                            
                            if(res.getStatus()==SUCCESS_STATUS){
                                System.debug('Deming Record successfully synced with ERP');
                                // String respStr = parseXMLResponse(res.getBody());
                                
                                
                            }
                        } 
                    
                }
            }  
        }
        
        catch(Exception ex){
            system.debug('error occured'+ex.getMessage());
        }
        
        
    }
    @future(callout=true)
    public static  void synchLOS_OM_With_Future(list<id> dmgId){
        synchLOS_OM(dmgId);
    }
    
    
    
    
    
    private static String generateRequestBody(String transactionID, String sourceSystem, String timestamp, String targetSystem, String OrderID, String OrderNumber, string CustomerAcceptanceDate, string CustomerName,string NCRAssociate, string isCustomerContacted, string Status,string AcceptanceDate,string rejectionOfCode){
        String QuickLook;
        user usr=[select Quicklook_ID__c from user where id=:NCRAssociate];
        
        if(usr!=null)
            QuickLook =usr.Quicklook_ID__c;
        
        QuickLook='';
        AcceptanceDate='';
        isCustomerContacted='';
        
        
        
        if(String.isBlank(CustomerAcceptanceDate)) CustomerAcceptanceDate = '';
        
        if(string.isBlank(status)) status='';
        String ReasonOfRejct='Other';
        
        // if(Status=='Reject'){
        //   CustomerAcceptanceDate=string.valueof(system.today());
        
        //   }
        
        //  if(Status==null){
        //   CustomerAcceptanceDate=string.valueof(system.today());
        //  Status='';
        
        //   }
        
        String  SoupRequest='<?xml version=\"1.0\" encoding=\"utf-8\"?>'+
            '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<Body>'+
            '<OrderHeaderUpdateRequestABM xmlns="http://xmlns.ncr.com/SOUP/ABM/NSC/OrderHeaderUpdate/V1">' +
            '<RequestHeader>'+ 
            '<TransactionID xmlns="http://xmlns.ncr.com/SOUP/Common/2.0">'+transactionID+'</TransactionID>' +
            '<SourceSystem xmlns="http://xmlns.ncr.com/SOUP/Common/2.0">'+sourceSystem+'</SourceSystem>' +
            '<Timestamp xmlns="http://xmlns.ncr.com/SOUP/Common/2.0">'+timestamp+'</Timestamp>' +
            '<TargetSystem xmlns="http://xmlns.ncr.com/SOUP/Common/2.0">'+targetSystem+'</TargetSystem>' +
            '</RequestHeader>'+  
            '<OrderHeaderUpdateRequest>' +
            '<OrderID>'+OrderID+'</OrderID>'+
            '<OrderNumber>'+OrderNumber+'</OrderNumber>'+
            '<CustomerAcceptanceDate>'+CustomerAcceptanceDate+'</CustomerAcceptanceDate>'+
            '<CustomerName>'+CustomerName+'</CustomerName>'+
            '<NCRAssociate>'+NCRAssociate+'</NCRAssociate>'+
            '<isCustomerContacted>'+isCustomerContacted+'</isCustomerContacted>'+
            '<Status>'+Status+'</Status>'+
            '<CADDAcceptanceTimestamp>'+CustomerAcceptanceDate+'</CADDAcceptanceTimestamp>'+
            '<CADDRejectionReason>'+rejectionOfCode+'</CADDRejectionReason>'+
            '</OrderHeaderUpdateRequest>'+
            '</OrderHeaderUpdateRequestABM>'+
            ' </Body>'+
            '</Envelope>'; 
        
        return SoupRequest; 
        
    }
    
    
    
    public static list<Deming__c> generateData(){
        
        list<Deming__c> demList=new list<Deming__c>();
        
        
        return  demList  ;
    }
    /* public HttpResponse GenerateRequest( String bdy ){
HttpRequest req1=new HttpRequest();

HttpResponse res1= new HttpResponse() ;
// Blob headerValue = Blob.valueOf(userID + ':' + password);
// String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
Http h = new Http();
req1.setBody(bdy);
req1.setMethod('POST');
// req1.setHeader('Authorization', authorizationHeader);
req1.setEndpoint('https://osbdev-ha.ncr.com/ext/EA/NSC/Services/NSCOrderHeaderUpdatePS?wsdl');
res1 = h.send(req1);
system.debug('@@@@@Response'+res1);
return res1;

}*/
    
}