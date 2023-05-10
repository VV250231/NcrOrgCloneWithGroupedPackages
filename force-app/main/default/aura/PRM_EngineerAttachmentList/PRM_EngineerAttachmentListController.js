({
    cAttachmentDetails: function(component, event, helper) {
       // var idParam = helper.getJsonFromUrl().recordId;
       	var idParam = component.get("v.myRecordId");
        var action = component.get("c.getEngineerAttachment");
        action.setParams({
            recId: idParam
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
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