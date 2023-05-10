({
	getDetail: function(component, event, helper) {
        var action = component.get("c.getPartnerAccountAttachment");
        //var idParam = helper.getJsonFromUrl().acid;
        //alert(component.get("v.recordId"));
        
        var idParam = component.get("v.recordId");
       
        action.setParams({
            accId: idParam
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('Ncru:' + state);
            if (state === "SUCCESS") {
                
                component.set("v.lstNoteAndAttachmentDetail", response.getReturnValue());
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