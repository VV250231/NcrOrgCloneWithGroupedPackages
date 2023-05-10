({
	changeSpinner: function (component, event, helper)
    {
        var toggleText = component.find("spinner");
        
        if(component.get("v.showSpinner"))
        {
            $A.util.removeClass(toggleText,'slds-hide');
        }
        else
        {
            $A.util.addClass(toggleText,'slds-hide');
        }
	}
})