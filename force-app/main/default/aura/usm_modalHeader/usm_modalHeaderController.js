({
	showUSMError : function(component, event, helper) {
        console.log('showUSMError');
        var message = event.getParam("showError");
        console.log('message' + message);
        var fieldName = event.getParam("fieldName");
        console.log('fieldName'+ fieldName);
        var isSucess = event.getParam("isSucess");
        console.log('isSucess' + isSucess);
        if(isSucess){
            
            component.set("v.sucessMessage", true);
            component.set("v.fieldName", fieldName);
        }else{
           if(message){
            component.set("v.errorMessage", true);
            component.set("v.fieldName", fieldName);
            }else{
                component.set("v.errorMessage", false);
            } 
        }
        
		
	}
})