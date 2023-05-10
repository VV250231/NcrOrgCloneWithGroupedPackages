({  
    
    /* 
	     * Function that will dynamically construct the path (progressIndicator) bar based on the value of the "activeStages" attribute. 
	     */  
    initPath : function(component, event, helper) {  
        
        var progressIndicator = component.find('progressIndicator');  
        var body = [];  
        var action1 = component.get("c.getStageName");
        action1.setParams({ "recId" : component.get("v.recordId")});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentStage", response.getReturnValue().split(',')[0]);
                //alert(component.get("v.stageType"));
                
                component.set("v.recordtype", response.getReturnValue().split(',')[1]);
                var rectype= component.get("v.recordtype");
                
                // alert(component.get("v.recordtype"));
                var action = component.get('c.getStatusBar'); 
                
                
                // method name i.e. getEntity should be same as defined in apex class
                // params name i.e. entityType should be same as defined in getEntity method
                /* action.setParams({
            "entityType" : component.get('v.componentString') 
        });*/
                
                action.setCallback(this, function(a){
                    var state = a.getState(); // get the response state
                    if(state == 'SUCCESS') {
                       // alert('a.getReturnValue()' +JSON.stringify(a.getReturnValue()));
                        component.set('v.activeStages', a.getReturnValue());
                        var activeStages = component.get("v.activeStages");  
                        var ast = [];
                        for (var key in activeStages) {
                            var stg = activeStages[key];  
                            //alert('stg'+stg);
                            if(rectype.includes('Exclude from Funnel') && (stg.includes('NonFunnel')) || (stg.includes('Closed/Lost'))){
                                //alert('stage nameeeeeeeeeee');
                                ast.push(stg);
                            }
                            else if(rectype.includes('Include in Funnel Reseller') && (!stg.includes('NonFunnel'))){
                                ast.push(stg);
                                
                            }}
                        //component.set('v.currentStage', 'Closing');
                        // var activeStages = component.get("v.activeStages");  
                        //alert('activeStages' +activeStages);
                        //for each value in the activeStages list, we create a new element of "lightning:progressStep" and  
                        //we add it to the progressIndicator component to costruct our path.  
                        var stage;  
                        for (var key in ast) {  
                            
                            stage = ast[key];  
                          //  alert('stage' +stage);
                            $A.createComponent(  
                                "lightning:progressStep",  
                                {  
                                    "aura:id": "step_" + stage,  
                                    "label": stage,  
                                    "value": stage  
                                },  
                                function(newProgressStep, status, errorMessage){  
                                    // Add the new step to the progress array  
                                    if (status === "SUCCESS") {  
                                        body.push(newProgressStep);  
                                       // alert('newProgressStep');
                                        progressIndicator.set("v.body", body);  
                                    }  
                                    
                                    //Handle error cases here.  
                                }  
                            );
                        }
                    }
                    
                });
                $A.enqueueAction(action); 
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
        $A.enqueueAction(action1);
    }  
})