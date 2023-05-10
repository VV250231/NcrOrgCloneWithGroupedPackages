({
	rerender : function(cmp, helper) {
    	this.superRerender();
    	// custom rerendering here
    	var ischecked = cmp.get("v.checked");
        if(ischecked) {
            cmp.find("yeschkbox").set("v.value", true);
            cmp.find("nochkbox").set("v.value", false);
        } else {
            cmp.find("yeschkbox").set("v.value", false);
            cmp.find("nochkbox").set("v.value", true);         
        }
	}
})