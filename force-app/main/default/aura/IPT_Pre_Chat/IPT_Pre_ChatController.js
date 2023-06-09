({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    onInit: function(cmp, evt, hlp) {
        // Get pre-chat fields defined in setup using the prechatAPI component
        var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        var action = cmp.get("c.getUserDetail");
        var user;
        action.setCallback(this,function(response){
            user = response.getReturnValue(); 
            // Get pre-chat field types and attributes to be rendered
            var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(prechatFields,user);
            
            // Make asynchronous Aura call to create pre-chat field components
            $A.createComponents(
                prechatFieldComponentsArray,
                function(components, status, errorMessage) {
                    if(status === "SUCCESS") {
                        cmp.set("v.prechatFieldComponents", components);
                    }
                }
            );
        })
        
        $A.enqueueAction(action);
        
    },
    
    /**
     * Event which fires when start button is clicked in pre-chat
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    handleStartButtonClick: function(cmp, evt, hlp) {
        hlp.onStartButtonClick(cmp);
    }
});