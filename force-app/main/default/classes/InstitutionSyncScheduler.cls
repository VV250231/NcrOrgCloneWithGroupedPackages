global class InstitutionSyncScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
    makeCallOut('100','100');   
    }
    global static HttpResponse makeCallOut(String recLimit , String recOffset){
        
        String endPoint = 'https://banks.data.fdic.gov/api/institutions?sort_order=ASC&limit='+recLimit+'&offset='+recOffset;
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        
        try{
            req.setEndpoint (endPoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            res = http.send(req);
            system.debug('status code ' +res.getStatusCode());
            if(res.getStatusCode() == 200){
                string resBody = res.getBody();
                resBody = resBody.replaceAll('"limit"', '"limit_Z"');
                system.debug('resBody  '+resBody);
                //resBody = resBody.replaceAll('"data":\\[', '"dataList":\\[');
                FDICInstitutionsWrapper wrp = (FDICInstitutionsWrapper)JSON.deserialize(resBody, FDICInstitutionsWrapper.class);
                system.debug('data  '+wrp.meta);
                system.debug('data   totals '+wrp.totals );
                system.debug('data   data '+wrp.data);
                system.debug('size   ==='+wrp.data.size());
                if(!wrp.data.IsEmpty()){
                    system.debug('size   ==='+wrp.data.size());
                    Database.executeBatch(new InstitutionSyncBatch(wrp.data,recLimit,recOffset));
                }
            }
        }catch (Exception ex) {
            system.debug('Exception  '+ex);
        }
        return res;
    }
    
}