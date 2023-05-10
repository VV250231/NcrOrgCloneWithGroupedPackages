({
	AddNewRow : function(component, event, helper){
        component.getEvent("AddRowEvt").fire();
    },
    RemoveRow : function(component, event, helper){
     // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
       component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    } 
})