({
	 doInit : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
      	component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            component.set("v.country", a.getReturnValue().lstCountry);
            component.find("Country").set("v.value", "-- None --");
            component.set("v.Spinner", false);
            
        })
        
        $A.enqueueAction(action);
    },
    
     cancel : function(component, event, helper) {
         
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/eula-submission-list-view"
                }).fire(); 
     }, 
    
    cSaveEULA : function(component, event, helper) {
         
        if(helper.isValidate(component, event, helper))
        {
		component.set("v.Spinner", true); 
        var action = component.get("c.saveEULA");
        action.setParams({
            "objES" : component.get("v.objEULA")
        })
      
        action.setCallback(this,function(a){
            component.set("v.Spinner", false); 
       //     alert(a.getReturnValue());
           $A.get("e.force:navigateToURL").setParams({ 
                  "url": "/eula-submission-record?esid=" + a.getReturnValue()
                }).fire();
        })
        
        $A.enqueueAction(action);
             }
        else
        {
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",  
                "type": "error",
                "message": "Review the errors on this page."
            });
            toastEvent.fire();
        }
     },
})