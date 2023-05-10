({
	doInit : function(component, event, helper) {
		/*
        window.addEventListener("message", function(event) {
            //if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                //return;
            //}
            // Handle the message
            console.log(event.data);
            alert(event.data);
        }, false);*/
        
        window.addEventListener("message", function(event) {
            location.reload();
            //$A.get('e.force:refreshView').fire();
            //$A.get("e.force:closeQuickAction").fire();
        }, false);
	}
})