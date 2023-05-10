({
	myAction : function(component, event, helper) {
		
	}, 
    doInit : function(component, event, helper)
    {       
        helper.loadalldetails(component, event, helper);
    },
    togglereportview  : function(component, event, helper)
    {       
        var value = component.get("v.togglereports");
        if(value == true){
            component.set("v.togglereports",false);  
        }
        if(value == false){
            component.set("v.togglereports",true);  
        }
    },
    hidereportview  : function(component, event, helper)
    {       
        component.set("v.togglereports",false);  
    },
    openrecyclebin  : function(component, event, helper)
    {       
        component.set("v.togglereports",false); 
        window.open("/search/UndeletePage",'_blank');
    },
    
})