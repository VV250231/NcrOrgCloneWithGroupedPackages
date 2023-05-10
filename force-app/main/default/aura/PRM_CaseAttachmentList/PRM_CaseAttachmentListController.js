({
	cAttachmentDetails: function(component, event, helper) {
         var idParam = helper.getJsonFromUrl().cid;
        var action = component.get("c.getAttachments");
        action.setParams({
            recId: idParam
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('Ncru:' + state);
            if (state === "SUCCESS") {
                
                component.set("v.lstAttachment", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    openFile : function(component, event, helper) 
    {
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
        var url1;
        url1="/PartnerCentral/servlet/servlet.FileDownload?file="+idd;
        window.open(url1,'_blank'); 
    },
    
})