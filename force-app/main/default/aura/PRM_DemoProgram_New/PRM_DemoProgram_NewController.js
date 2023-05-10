({
    doInit : function(component, event, helper) {
        //disable up, down, right, left arrow keys
        window.addEventListener("keydown", function(e) {
            if([37, 38, 39, 40].indexOf(e.keyCode) > -1) {
                e.preventDefault();
            }
        }, false);
        
        //disable mousewheel
        window.addEventListener("mousewheel", function(e) {
            e.preventDefault();
        }, false);
        
        window.addEventListener("DOMMouseScroll", function(e) {
            e.preventDefault();
        }, false);
    },
    
    handleSuccess  : function(component, event, helper) {
        var demoReq = event.getParams().response;
        
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/demo-program-view?recordId="+demoReq.id,
        });
        navEvt.fire();
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : "success",
            "message": "Request has been submitted successfully"
        });
        toastEvent.fire();
    },
    

    
    handleSubmit : function(component, event, helper) {
        //event.preventDefault(); To prevent default behaviour of 
        //var demoReq = event.getParams().fields;
        //console.log(JSON.stringify(demoReq));
    },
    
    handleCancel : function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/demo-program-list",
        });
        navEvt.fire();        
    }
})