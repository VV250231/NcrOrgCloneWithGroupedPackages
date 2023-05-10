({
	showUSMError : function(component, event, helper) {
        console.log('showUSMError');
        var message = event.getParam("showError");
        console.log('message1' + message);
        var fieldName = event.getParam("fieldName");
        console.log('fieldName'+ fieldName);
        //message=true;
        
           if(message){
            component.set("v.errorMessage", true);
            component.set("v.fieldName", fieldName);
            }else{
                component.set("v.errorMessage", false);
            } 
        
	}
})