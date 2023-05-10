({
    unrender: function (component,event, helper) {
        this.superUnrender();
        //alert(event.getSource().getLocalId());
        $A.get('e.force:refreshView').fire();
    }

})