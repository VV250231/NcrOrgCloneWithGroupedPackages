({
	handleShowModal: function(component, evt, helper) {
        var navService = component.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = component.get("v.pageReference");
        evt.preventDefault();
        navService.navigate(pageReference);
        /*
        var modalBody;
         $A.createComponent("c:CustomerHierarchy", {recordId:component.get("v.recordId"), showHierarchy:true/*, acc:component.get("v.acc")*//*},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({                       
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "slds-modal_large ",
                       closeCallback: function() {                          
                       }
                   })
               }
           }); */
    },
    
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