({
	myAction : function(component, event, helper) {
		
	},
    doInit : function(component, event, helper)
    {       
        helper.loadcreditdetails(component, event, helper);
        
    },
    redirect_myncr :  function(component, event, helper) {
        //var url1="/apex/qb_landing_page?oppno="+component.get("v.recordId");
        var url1="https://portal.ncr.com/";
        window.open(url1,'_blank');    
    }
})