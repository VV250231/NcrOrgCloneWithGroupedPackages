({
	redirectToPage : function(component, event, helper) 
    {
        console.log(component.get("v.selectedSpotLight"));
        if (component.get("v.selectedSpotLight") == 'Partner Feature Friday') 
        {
            component.set("v.isPFF", true);
            component.set("v.isMDF", false);
            component.set("v.isPME", false);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", false);
            component.set("v.isSelection", false);
        }
       	else if (component.get("v.selectedSpotLight") == 'MDF Success Story') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", true);
            component.set("v.isPME", false);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", false);
            component.set("v.isSelection", false);
        }
        
        else if (component.get("v.selectedSpotLight") == 'Partner Ambassador Event') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", false);
            component.set("v.isPME", true);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", false);
            component.set("v.isSelection", false) ;
           
        }
        else if (component.get("v.selectedSpotLight") == 'Significant Customer Win') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", false);
            component.set("v.isPME", false);
            component.set("v.isSCW", true);
            component.set("v.isMBRT", false);
            component.set("v.isSelection", false);
        }
      	else if (component.get("v.selectedSpotLight") == 'Miscellaneous Business Related Topic') 
        {
            component.set("v.isPFF", false);
            component.set("v.isMDF", false);
            component.set("v.isPME", false);
            component.set("v.isSCW", false);
            component.set("v.isMBRT", true);
            component.set("v.isSelection", false);
		}
    },
    
    cancelRequest: function(component, evt, helper) {
      	component.set("v.isPFF", false);
        component.set("v.isMDF", false);
        component.set("v.isPME", false);
        component.set("v.isSCW", false);
        component.set("v.isMBRT", false);
        component.set("v.isSelection", true);
    }
})