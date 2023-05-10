({
	CollectValue : function(cmp, event,helper) {
		var myEvent = $A.get("e.c:LeftToRightComEvent");
        myEvent.setParams({
            "SelectedProduct": cmp.get("v.productId"),
            "Status" : cmp.get("v.liked")
            }); 
        myEvent.fire();
        var liked = cmp.get("v.liked"); 
        var liked = cmp.get("v.liked");
        cmp.set("v.liked", liked); 
	}
})