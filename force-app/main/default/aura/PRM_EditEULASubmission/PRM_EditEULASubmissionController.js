({
	 doInit : function(component, event, helper) {
        var action = component.get("c.getEditEULASubmissionDetail");
        var idParam = helper.getJsonFromUrl().esid;
        //alert(idParam);
        action.setParams({
            "recId" : idParam
        })
      	component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            component.set("v.country", a.getReturnValue().lstCountry);
           
            component.set("v.objEULA", a.getReturnValue().objE);
            component.find("Country").set("v.value", a.getReturnValue().objE.Country__c)
            //component.find("Country").set("v.value", "-- None --");
            component.set("v.Spinner", false);
        })
        
        $A.enqueueAction(action);
    },
    
     cancel : function(component, event, helper) {
         var action = component.get("c.getEditEULASubmissionDetail");
         var idParam = helper.getJsonFromUrl().esid;
         $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/eula-submission-record?esid=" + idParam
                }).fire();
     },
    
    cSaveEULA : function(component, event, helper) {
       
        if(helper.isValidate(component, event, helper))
        {
		component.set("v.Spinner", true); 
        var action = component.get("c.saveEditedEULA");
        action.setParams({
            "objES" : component.get("v.objEULA")
        })
      
        action.setCallback(this,function(a){
            
            //alert(a.getReturnValue());
             $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/eula-submission-record?esid=" + a.getReturnValue()
                }).fire();
            
            component.set("v.Spinner", false); 
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