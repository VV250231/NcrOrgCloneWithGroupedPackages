({
    logActivity : function(component) {        
        var sourceObj;
        var recId = component.get("v.recordId");
        if(recId!= null){
            if(recId.substring(0,3)==="001"){
                sourceObj = "Account";           
            }
            else if(recId.substring(0,3)==="006"){
                sourceObj = "Opportunity";           
            }
        }
        else{
            sourceObj = "Seismic Tab"; 
        }  
        var action = component.get("c.logSesmicActivity");
        action.setParams({sourceObject:sourceObj});       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //seismic log activity login
            }
            else {
               // console.log(a.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Error in logging Siesmic activity',           
                    type: 'error',                    
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})