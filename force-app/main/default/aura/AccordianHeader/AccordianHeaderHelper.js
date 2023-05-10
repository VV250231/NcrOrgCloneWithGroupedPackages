({
	Update_BundleName : function(component,event) {
       var BundleName=component.get("v.BundleName");
      
        if(BundleName && typeof BundleName !== "undefined"){
                    var action = component.get("c.UpdateBundleName");
                    action.setParams({ 
                    
                    BundleId : component.get("v.BundleId"),
                    BundleName:component.get("v.BundleName")
                
                 });
        
                // Create a callback that is executed after 
                // the server-side action returns
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") { 
                        //alert('success');
                        
                        var FloatMsgEvent = $A.get("e.c:FloatMsgEvent"); 
                        FloatMsgEvent.setParams({
                        "Msg" : "Name Update Successfull"+' '+component.get("v.BundleName"),
                        "Category" : "Success",
                        "isShow" : "True"
                       });
                       FloatMsgEvent.fire();
                    }
                    else if (state === "INCOMPLETE") {
                        // do something
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                         errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");   
                         }
                    }
                });
                $A.enqueueAction(action);
        }
         
        else{
             
             alert('Please Enter Bundle Name');
	      }
    }, 
    
   
})