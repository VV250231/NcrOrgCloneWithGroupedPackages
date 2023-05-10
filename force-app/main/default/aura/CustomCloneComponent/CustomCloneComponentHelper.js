({
    getData : function( component, event, helper ) {
        // get server action
        var action = component.get("c.getData");
        // set params        
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "isCloneWithProduct" : component.get("v.isCloneWithProduct"),
            "isCloneWithLink" : component.get("v.isCloneWithLink"),
            "isCloneWithoutProduct" : component.get("v.isCloneWithoutProduct")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if( component.isValid() && state == "SUCCESS" ) {
                var responseData = response.getReturnValue();                
                component.set("v.populateRecord",response.getReturnValue() );
                
                //set loading false
                $A.util.removeClass( component.find( 'spinnerDiv' ), 'slds-show' );
                $A.util.addClass( component.find( 'spinnerDiv' ), 'slds-hide' );
                
                component.set( "v.isLoading",false );
                //creating clone record window
                this.createCloneRecord( component, event, helper );
            } else if(state == "ERROR") {
                this.dismissAction( component, event, helper );
                var errorMsg = this.evalError(response.getError());
                var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                    "title": 'Error',
                    "message": errorMsg,
                    "type": 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    createCloneRecord : function( component, event, helper ){ 
        var data = component.get("v.populateRecord");
        var params = {};
        for( var i = 0; i < data.length; i++ ){            
            params["entityApiName"] = data[i].objectApiName,
                params["defaultFieldValues"] = {}  
            for( var j = 0; j < data[i].lstFieldsDetail.length; j++ ){
                if(data[i].lstFieldsDetail[j].fieldType=='Boolean'){
                    params["defaultFieldValues"][ data[i].lstFieldsDetail[j].fieldApiName ]=data[i].lstFieldsDetail[j].fieldValue.toUpperCase()=='TRUE'?true:false;
                }else{
                    params["defaultFieldValues"][ data[i].lstFieldsDetail[j].fieldApiName ] = data[i].lstFieldsDetail[j].fieldValue;
                }
            }
        }
        
        if (!$A.util.isEmpty(data) && !$A.util.isEmpty(data[0].recordTypeId)) {
            params["recordTypeId"] = data[0].recordTypeId; 
        }
        console.log(params);
        var createOpportunity = $A.get("e.force:createRecord");
        createOpportunity.setParams( params);
        
        createOpportunity.fire();
        
        // Close the action panel
        this.dismissAction( component, event, helper );
    },
    dismissAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();        
    },
 
    evalError : function(errors) {
        var errmsg = "Unknown error";
        if(errors) {
            if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].message))) // To show other type of exceptions
                errmsg = errors[0].message;
            if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].pageErrors)) && (!$A.util.isEmpty(errors[0].pageErrors))) {// To show DML exceptions
                errmsg = errors[0].pageErrors[0].message;
            }
            if(errors[0] && (!$A.util.isUndefinedOrNull(errors[0].fieldErrors))) {// To show DML exceptions
                if($A.util.isArray(errors[0].fieldErrors) && (!$A.util.isEmpty(errors[0].fieldErrors)))
                    errmsg = errors[0].fieldErrors[0].message;
                else if($A.util.isObject(errors[0].fieldErrors)) {
                    var fielderrMap = errors[0].fieldErrors;
                    for(key in fielderrMap) {
                        if((!$A.util.isUndefinedOrNull(fielderrMap[key][0].message))) {
                            errmsg = fielderrMap[key][0].message;   
                            break;
                        }
                    }
                }
            }   
        }
        return errmsg;
    }
})