({
	sortBy: function(component, field, order) {
		//alert(field);
		//alert(order);
		var orderByField = field;
		var shortingOrder = order;
		
		var action = component.get("c.shorting");
		action.setParams({ pOrderByField : orderByField, pOshortingOrder : shortingOrder});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				component.set("v.approvals", response.getReturnValue());
			}
        });
        $A.enqueueAction(action);
	}

})