({
	myAction : function(component, event, helper) {
		
	},
    SG_Errorpop : function(component, event, helper) {
        var $j = jQuery.noConflict();
        var t = $j(location).attr('host');
        var id=component.get("v.recordId");
        /* ########################################## */
        component.set("v.toggleerror","false");
        /* ########################################## */
        helper.checkifnsspulselineitems(component,event,helper);
    },
    showerror: function(component, event, helper) {
        helper.showToast(component,event,helper);
    }
})