({
	doInit : function(component, event, helper) {
          
		helper.generateLegalDocument(component);
	},
    handleACHChange:function(component, event, helper){
    	var selectedOptionValue = event.getParam("value"); 
        //alert("Option selected with value: '" + selectedOptionValue + "'");
        var action = component.get("c.SaveACHContactOnQuote");
        var Options = [];
        action.setParams({
            "ConId":event.getParam("value"),
            "qid":component.get("v.recordId")
            
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                 var quote= component.get("v.Quote");
				//alert('Success'+response.getReturnValue()); 
                 component.set("v.achErrorMsg","");                       
                //alert(JSON.stringify(component.get("v.Quote")));
                
            }
            else{
                component.set("v.isGenerateDoc",false);
            }
        }); 
        $A.enqueueAction(action);
	},
    sendLegalDocument:function(component, event, helper){
        var quote= component.get("v.Quote");
        helper.sendLegalDocument(component,quote);
    }

})