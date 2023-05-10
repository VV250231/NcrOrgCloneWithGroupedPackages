({
    generateNavURL : function(cmp, evt, helper) {
    	 var navService = cmp.find("navService");
        var pageReference = {
            
            "type": "standard__component",
            "attributes": {
                "componentName": "c__CustomerHierarchy"    
            },    
            "state": {
                "c__showHierarchy" : "true",
                "c__recordId" :  cmp.get("v.recordId")
            }
        };
        cmp.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            cmp.set("v.url", url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            cmp.set("v.url", defaultUrl);
        }));    
    }
})