({
	redirect_myncr :  function(component, event, helper) {
        //var url1="/apex/qb_landing_page?oppno="+component.get("v.recordId");
        $A.get("e.force:closeQuickAction").fire();
        var url1="https://portal.ncr.com/";
        window.open(url1,'_blank');    
    }
})