({
	handleApplicationEvent : function(cmp, event) {
        var selectedRow = event.getParam("selectedRow");
        if(event.getParam("isAvailableCount")){
            var totelRows = event.getParam("totelRows");
            console.log('totelRows>>>>>>' + totelRows);
            cmp.set("v.totelQuots", totelRows);
        }else{
            console.log('handleApplicationEvent selectedRow' + selectedRow);
            // set the handler attributes based on event data
            cmp.set("v.selectedRowsCount", selectedRow);
        }
        
        
		
       
    },
    associateQuots : function(cmp, event) {
        var appEvent = $A.get("e.c:AssociteQuotsEvent");
        //appEvent.setParams({ });
        appEvent.fire();
       
    },
    
    handleCloseEvent : function(component, event, helper) {
		console.log('handleCloseEvent>>>');
        var message = event.getParam("msg");
        component.find("overlayLib").notifyClose();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success!",
            message: message,
            type: "success"
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();

	}
    
})