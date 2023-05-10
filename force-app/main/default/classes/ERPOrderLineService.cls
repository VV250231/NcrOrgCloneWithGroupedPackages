public without sharing class ERPOrderLineService {
    final static string SUCCESS_STATUS='SUCCESS';
    final static string FAILURE_STATUS='FAILURE';
    static Soup_Username__mdt   soup_cred;
	
    public static  String synchOrdLine(String orderId){
        DateTime startTime=Datetime.now(); 
        System.debug('start Time ___'+startTime.getTime());
        String OrdrID='';
        Decimal HeaderAmount=0.0;
        String HeaderAmount1='';
        //Set<String> existingOrder= new Set<String>();
        Set<Decimal> existingLine= new Set<Decimal>();
        List<ERP_Order_Line__c> ERPlines = new List<ERP_Order_Line__c>();  
        List<ERP_Order_Line__c> ERPlinesToUpdate = new List<ERP_Order_Line__c>(); 
        List<Deming__c> demingToUpdate = new List<Deming__c>(); 
        List<Deming__c> Uniquedeming = new List<Deming__c>(); 
        //  Map<String,String> orderIDAmountMap= new Map<String, String>();
        Map<Decimal,Id> IdtoLineMap= new Map<Decimal,Id>();
        SObjectType objToken = Schema.getGlobalDescribe().get('ERP_Order_Line__c');
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        Map<String, SObjectField> fieldss= new Map<String, SObjectField>();
        // Map<String,map<String, String>> maps =new Map<String,map<String, String>>();
        for(String s: fields.keySet()){
            String s1 = s.remove('__c');
            System.debug('_________________'+s1);
            SObjectField val=fields.get(s);
            fieldss.put(s1,val);
            
        }
        //System.debug('______'+fieldss);
        Map<String,String> values =new Map<String,String>();
        Map<String,Map<String,String>> valuesMap =new Map<String,Map<String,String>>();
        //soup_cred=[select user_name__c,password__c, EndPoint__c from Soup_Username__mdt  where DeveloperName='OrderLines' limit 1];
        //String userID=string.valueof(soup_cred.user_name__c);
        //String password=soup_cred.password__c;
        //String EndPoint=soup_cred.EndPoint__c;
        //system.debug('@@@@@@'+userID+'>>>>>>><<<<<<<'+password+'!!!!!'+EndPoint);
        //String jsonBody ='userID='+userID+'&password='+password; 
        //for(String orderId : OrderIds){
            //  System.debug('+++++++'+(existingOrder.contains(orderId)));
            if(orderId != null){
                System.debug('#####'+orderId);
                String bdy=generateRequestBody(orderId, new Uuid().getValue(),'NSC','ERP');    
                system.debug('bdy@@@>>>' + bdy);
                HttpRequest req=new HttpRequest();
                HttpResponse res= new HttpResponse() ;
                //Blob headerValue = Blob.valueOf(userID + ':' + password);
                //String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                Http h = new Http();
                req.setBody(bdy);
                req.setMethod('POST');
                //req.setHeader('Authorization', authorizationHeader);
                //req.setEndpoint(EndPoint);
                req.setEndpoint('callout:NSC_SOUP_Order_Lines');
                req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
                req.setTimeout(30000);
                //System.debug(')))))))))'+req);
                DateTime startService=Datetime.now(); 
                res = h.send(req);
                DateTime endService=Datetime.now(); 
                Long resTimeService=endService.getTime()-startService.getTime();
                system.debug('<><><><>< Service Responded in:'+resTimeService);
                system.debug('<><><><><'+res.getBody());
                DOM.Document doc = new DOM.Document();
                String toParse = res.getBody();
                doc.load(toParse);
                DOM.XMLNode root = doc.getRootElement();
                String nms = root.getNameSpace();
                System.Debug('namespace: ' + nms);
                DOM.XMLNode body = root.getChildElement('Body', nms);
                // System.Debug('body: ' + body);
                Integer i=0;
                List<DOM.XMLNode> bodyChildrenList = body.getChildElements();
                // System.debug('%%%%size bodyChildrenList'+bodyChildrenList.size());
                for (DOM.XMLNode passThroughReqResponse : bodyChildrenList) {
                    System.Debug('passThroughReqResponse: ' + passThroughReqResponse.getName());
                    List<DOM.XMLNode> passThroughReqResultList = passThroughReqResponse.getChildElements();
                    for (DOM.XMLNode passThroughReqResult : passThroughReqResultList) {
                        System.Debug('passThroughReqResult: ' + passThroughReqResult.getName());
                        List<DOM.XMLNode> pickResponseList = passThroughReqResult.getChildElements();
                        for (DOM.XMLNode pickResponse : pickResponseList) {
                            System.Debug('pickResponse: ' + pickResponse.getName());
                            List<DOM.XMLNode> filesList = pickResponse.getChildElements();
                             System.debug(' File list size _ '+filesList.size());
                            for (DOM.XMLNode files : filesList) {
                               // System.debug('111'+files.getName());
                                /* if(files.getName()=='Order_Id'){
//  System.debug('_____here Order Id Found'+files.getText());
OrdrID=files.getText();
}
if(files.getName()=='Header_Amount'  && String.isNotBlank(files.getText())){
// System.debug('_____here header amount');
HeaderAmount=Decimal.valueOf(files.getText());
HeaderAmount1=files.getText();
}*/
                                List<DOM.XMLNode> fileList = files.getChildElements();
                                // System.debug('File list size'+fileList.size());
                                ERP_Order_Line__c line= new ERP_Order_Line__c();
                                System.debug('+++size'+fileList.size());
                                for (DOM.XMLNode file : fileList) {
                                    if(file.getName()=='Line_ID'){
                                     values=new Map<String,String>();
                                    values.put('Order_Id',orderId);    
                                    }
                                    
                                    System.debug('____getName'+file.getName()+'___getText'+file.getText());
                                    values.put(file.getName(),file.getText());
                                    System.debug('_____Values___'+values);
                                    if(file.getName()=='LINE_NOTE_DESC'){
                                     valuesMap.put(values.get('Line_ID'), values);   
                                    }
                                   // valuesMap.put(values.get('Line_ID'), values);
                                    String s= file.getName();
                                    if(valuesMap.size()>720){
                                        break;
                                    }

                                }
                            }
                        }
                    }
                }
            }
            System.debug('______ValuesMap_Size()__'+valuesMap.size());
            Integer i1=0;
            for(String str:valuesMap.keySet()){
                ERP_Order_Line__c line1= new ERP_Order_Line__c();
                System.debug('Line____Id___'+str);    
                line1.Order_Id__c=valuesMap.get(str).get('Order_Id');
                line1.Line_ID__c=Decimal.valueOf(str);
                line1.Ship_To_Customer__c=valuesMap.get(str).get('Ship_To_Customer');
                line1.Ship_To__C=valuesMap.get(str).get('Ship_To'); 
                if(String.isNotBlank(valuesMap.get(str).get('Line_Number'))){
                    line1.Line_Number__c=Decimal.valueOf(valuesMap.get(str).get('Line_Number'));    
                }
                line1.Ordered_Item__c=valuesMap.get(str).get('Ordered_Item'); 
                if(String.isNotBlank(valuesMap.get(str).get('Quantity'))){
                    line1.Quantity__c=Decimal.valueOf(valuesMap.get(str).get('Quantity'));      
                }            
                line1.UOM__c=valuesMap.get(str).get('UOM');  
                if(String.isNotBlank(valuesMap.get(str).get('Request_Date'))){
                    line1.Request_Date__c=setStringToDateFormat(valuesMap.get(str).get('Request_Date'));        
                }
                if(String.isNotBlank(valuesMap.get(str).get('Schedule_Ship_Date'))){
                    line1.Schedule_Ship_Date__c=setStringToDateFormat(valuesMap.get(str).get('Schedule_Ship_Date'));       
                }
                line1.Line_Status__c=valuesMap.get(str).get('Line_Status');  
                if(String.isNotBlank(valuesMap.get(str).get('Qty_Cancelled'))){
                    line1.Qty_Cancelled__c=Decimal.valueOf(valuesMap.get(str).get('Qty_Cancelled'));      
                } 
                if(String.isNotBlank(valuesMap.get(str).get('Qty_Shipped'))){
                    line1.Qty_Shipped__c=Decimal.valueOf(valuesMap.get(str).get('Qty_Shipped'));   
                }  
                line1.Order_Source__c=valuesMap.get(str).get('Order_Source');  
                line1.Order_Source_Reference__c=valuesMap.get(str).get('Order_Source_Reference');  
                line1.Partial_Invoice_Flag__c=valuesMap.get(str).get('Partial_Invoice_Flag');  
                line1.PS_Project_Number__c=valuesMap.get(str).get('PS_Project_Number');  
                line1.Cust_PO_Line_Number__c=valuesMap.get(str).get('Cust_PO_Line_Number');  
                line1.Cust_Product_Desc__c=valuesMap.get(str).get('Cust_Product_Desc');  
                if(String.isNotBlank(valuesMap.get(str).get('Unit_Selling_Price'))){
                    line1.Unit_Selling_Price__c=Decimal.valueOf(valuesMap.get(str).get('Unit_Selling_Price'));     
                } 
                if(String.isNotBlank(valuesMap.get(str).get('Extended_Price'))){
                    line1.Extended_Price__c=Decimal.valueOf(valuesMap.get(str).get('Extended_Price'));     
                }
                if(String.isNotBlank(valuesMap.get(str).get('Tax_Amount'))){
                    line1.Tax_Amount__c=Decimal.valueOf(valuesMap.get(str).get('Tax_Amount')); 
                }
                if(String.isNotBlank(valuesMap.get(str).get('Schedule_Arrival_Date'))){
                    line1.Schedule_Arrival_Date__c=setStringToDateFormat(valuesMap.get(str).get('Schedule_Arrival_Date'));      
                }
                line1.Shipping_Method__c=valuesMap.get(str).get('Shipping_Method');  
                line1.Ship_To_Customer__c=valuesMap.get(str).get('Ship_To_Customer');  
                line1.Ship_To__c=valuesMap.get(str).get('Ship_To');  
                line1.Ship_To_Contact__c=valuesMap.get(str).get('Ship_To_Contact');  
                line1.Bill_To_Contact__c=valuesMap.get(str).get('Bill_To_Contact');  
                line1.Bill_To__c=valuesMap.get(str).get('Bill_To');  
                line1.Bill_To_Customer__c=valuesMap.get(str).get('Bill_To_Customer');  
                line1.Ship_To_Address1__c=valuesMap.get(str).get('Ship_To_Address1');  
                line1.Ship_To_Address2__c=valuesMap.get(str).get('Ship_To_Address2');  
                line1.Ship_To_Address3__c=valuesMap.get(str).get('Ship_To_Address3');  
                line1.Ship_To_Address4__c=valuesMap.get(str).get('Ship_To_Address4');  
                line1.Ship_To_Address5__c=valuesMap.get(str).get('Ship_To_Address5');  
                line1.Bill_To_Address1__c=valuesMap.get(str).get('Bill_To_Address1');  
                line1.Bill_To_Address2__c=valuesMap.get(str).get('Bill_To_Address2');  
                line1.Bill_To_Address3__c=valuesMap.get(str).get('Bill_To_Address3');  
                line1.Bill_To_Address4__c=valuesMap.get(str).get('Bill_To_Address4');  
                line1.Bill_To_Address5__c=valuesMap.get(str).get('Bill_To_Address5');  
                line1.Deliver_To_Location__c=valuesMap.get(str).get('Deliver_To_Location');  
                line1.Deliver_To_Contact__c=valuesMap.get(str).get('.Deliver_To_Contact');  
                line1.Intermediate_Ship_To__c=valuesMap.get(str).get('Intermediate_Ship_To');  
                line1.SW_Release_Number__c=valuesMap.get(str).get('SW_Release_Number__c');  
                line1.SW_Media_Set__c=valuesMap.get(str).get('SW_Media_Set');  
                if(String.isNotBlank(valuesMap.get(str).get('SW_Key_Start_Date'))){
                    line1.SW_Key_End_Date__c=setStringToDateFormat(valuesMap.get(str).get('SW_Key_Start_Date'));     
                }
                if(String.isNotBlank(valuesMap.get(str).get('SW_Key_Start_Date'))){
                    line1.SW_Key_Start_Date__c=setStringToDateFormat(valuesMap.get(str).get('SW_Key_Start_Date'));   
                }
                if(String.isNotBlank(valuesMap.get(str).get('SW_Key_Number'))){
                    line1.SW_Key_Number__c=valuesMap.get(str).get('SW_Key_Number');      
                }
                
                line1.Product_Description__c=valuesMap.get(str).get('Product_Description'); 
                if(String.isNotBlank(valuesMap.get(str).get('Shipping_Date'))){
                    line1.Shipping_Date__c=setStringToDateFormat(valuesMap.get(str).get('Shipping_Date'));   
                }
                
                line1.Delivery_Status__c=valuesMap.get(str).get('Delivery_Status');  
                line1.Tracking_Number__c=valuesMap.get(str).get('Tracking_Number');  
                if(String.isNotBlank(valuesMap.get(str).get('Pro_Number'))){
                    line1.Pro_Number__c=Decimal.valueOf(valuesMap.get(str).get('Pro_Number'));    
                } 
                line1.Package_Number_Low__c=valuesMap.get(str).get('Package_Number_Low');  
                line1.Package_Number_High__c=valuesMap.get(str).get('Package_Number_High');  
                line1.EMS_Shipment_Number__c=valuesMap.get(str).get('EMS_Shipment_Number');  
                line1.Freight_Forwarder__c=valuesMap.get(str).get('Freight_Forwarder');  
                line1.EMS_Airway_Shipment_Number__c=valuesMap.get(str).get('EMS_Airway_Shipment_Number');  
                line1.Carrier_Name__c=valuesMap.get(str).get('Carrier_Name');  
                System.debug('________str'+str+'_____'+valuesMap.get(str).get('promise_date'));
                if(String.isNotBlank(valuesMap.get(str).get('PROMISE_DATE'))){
                    
                    line1.PROMISE_DATE__c=setStringToDateFormat(valuesMap.get(str).get('PROMISE_DATE'));     
                }
                
                if(String.isNotBlank(valuesMap.get(str).get('INSTALL_CERTIFICATION_DATE'))){
                    line1.INSTALL_CERTIFICATION_DATE__c=setStringToDateFormat(valuesMap.get(str).get('INSTALL_CERTIFICATION_DATE'));       
                }
                if(String.isNotBlank(valuesMap.get(str).get('CUST_AGREE_INV_ACCEPT_DATE'))){
                    line1.CUST_AGREE_INV_ACCEPT_DATE__c=setStringToDateFormat(valuesMap.get(str).get('CUST_AGREE_INV_ACCEPT_DATE'));      
                }
                if(String.isNotBlank(valuesMap.get(str).get('PRICING_DATE'))){
                    line1.PRICING_DATE__c=setStringToDateFormat(valuesMap.get(str).get('PRICING_DATE'));     
                } 
                line1.SERIAL_NUMBER__c=valuesMap.get(str).get('Schedule_Ship_Date');  
                line1.PROMISE_DATE_REASON_CODE__c=valuesMap.get(str).get('PROMISE_DATE_REASON_CODE'); 
                
                
                
                if(line1.Line_ID__c!=null ){
                    
                    ERPlines.add(line1);
                    
                    
                }
                
            }
            
            
            
            if(ERPlines.size()>0){
                insert ERPlines;    
            }
            
            if(Uniquedeming.size()>0){
                System.debug('_________________________'+Uniquedeming);
                demingToUpdate.addAll(Uniquedeming);
                System.debug('_________________________++'+demingToUpdate);
                update demingToUpdate;   
            }
            
        //}
        DateTime endTime=Datetime.now(); 
        System.debug('End Time ___'+endTime.getTime());
        Long resTime=endTime.getTime()-startTime.getTime();
        System.debug('Service with parsing time______'+resTime);
        return 'success';
    }
    
    
    
    
    
    private static String generateRequestBody(String OrderID,String transactionID, String sourceSystem, String targetSystem){
        
        
        String  SoupRequest='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ord="orderdetails.soup.ncr.com" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/2.0">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
            '<ord:OrderDetailsRequest>'+
            '<ns:RequestHeader>'+
            '<ns:TransactionID>'+transactionID+'</ns:TransactionID>'+
            '<ns:SourceSystem>'+sourceSystem+'</ns:SourceSystem>'+
            '<ns:Timestamp>?</ns:Timestamp>'+
            '<ns:TargetSystem>'+targetSystem+'</ns:TargetSystem>'+
            '</ns:RequestHeader>'+
            '<ord:Order_Id>'+OrderID+'</ord:Order_Id>'+
            '</ord:OrderDetailsRequest>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        
        return SoupRequest; 
        
    }  
    
    private Static Date setStringToDateFormat(String myDate) {
        // System.debug('!!!!!!!!!!!!'+myDate);
        String[] myDateOnly = myDate.split(' ');
        String[] strDate = myDateOnly[0].split('/');
        
        
        Integer myIntDate = integer.valueOf(strDate[0]);
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntYear = integer.valueOf(strDate[2]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
        return d;
        
    }
    
}