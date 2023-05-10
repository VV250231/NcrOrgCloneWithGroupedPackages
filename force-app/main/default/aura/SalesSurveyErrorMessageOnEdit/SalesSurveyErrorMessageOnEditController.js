({
    doInit: function(cmp, event, helper) {

          helper.openAlert(cmp, event);
           var navEvt = $A.get("e.force:navigateToSObject");
         navEvt.setParams({
          "recordId": cmp.get("v.recordId"),
          "slideDevName": "related"
        });
          navEvt.fire();
            
    }
});