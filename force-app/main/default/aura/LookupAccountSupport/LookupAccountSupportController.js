({
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
     //   alert('selItem '+JSON.stringify(component.get('v.selItem')));
		helper.serverCall(component, event, helper);
	},
    clearSelection : function(component, event, helper){
        
        helper.clearSelection(component, event, helper);
    } 
})