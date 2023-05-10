({
    doInit : function(component, event, helper) {
        var listofQtObj = [];
        let quoteId = component.get("v.quoteId");
         var action = component.get("c.getNotSignedQuotes");
         action.setParams({"quoteId":quoteId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = JSON.parse(response.getReturnValue());
                    var mapObj = new Map();
                    var temp = true;
                    for(var x in responseObj){
                        var qtNameAndSiteName = [];
                        if(responseObj[x].qtc_Bill_To_Site__c == null){
                            if(mapObj.has('')){
                                qtNameAndSiteName = mapObj.get('');
                                qtNameAndSiteName[0] = qtNameAndSiteName[0]+', '+responseObj[x].Name;
                                mapObj.set('',qtNameAndSiteName);
                            }else{
                                qtNameAndSiteName[0] = responseObj[x].Name;
                                qtNameAndSiteName[1] = '';
                                mapObj.set('',qtNameAndSiteName);
                            }
                        }else{
                           // if(responseObj[x].qtc_Bill_To_Site__r.AutoPay_Setup__c!='True' && responseObj[x].qtc_Multi_Site_Relationship__c=='Child' && temp ){
                             //   this.GetACHContact(component,quote.SBQQ__Account__c);
                               // component.set("v.isAutoPayNotSetup",true);
                                //temp=false;
                            //}
                            if(mapObj.has(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c)){
                                qtNameAndSiteName = mapObj.get(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c);
                                qtNameAndSiteName[0] = qtNameAndSiteName[0]+', '+responseObj[x].Name;
                                mapObj.set(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c,qtNameAndSiteName);
                            }else{
                                qtNameAndSiteName[0] = responseObj[x].Name;
                                qtNameAndSiteName[1] = responseObj[x].qtc_Bill_To_Site__r.Name;
                                mapObj.set(responseObj[x].qtc_Bill_To_Site__r.Site_Number__c,qtNameAndSiteName);
                            }
                        }
                    }
                    for(var objVar of mapObj.keys()){
                        var arry = mapObj.get(objVar);
                        var sobj = {
                            QuoteName:arry[0],
                            SiteNo:objVar,
                            SiteName:arry[1]
                        }
                        listofQtObj.push(sobj);
                    }
                    component.set('v.multiSiteDataColumns', [
                        {label: 'Quote name', fieldName: 'QuoteName', type: 'text'},
                        {label: 'Bill to site number', fieldName: 'SiteNo', type: 'text'},
                        {label: 'Bill to site name', fieldName: 'SiteName', type: 'text'}
                    ]);
                    component.set('v.multiSiteData',listofQtObj);
           
            }
        }); 
        $A.enqueueAction(action);
    }
		
})