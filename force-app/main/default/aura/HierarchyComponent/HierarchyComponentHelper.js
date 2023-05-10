({
	getData : function (cmp) {
        var action = cmp.get("c.getAccountHierarchyData");       
        action.setParams({ 
            "accId" : cmp.get("v.accId")            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var tempJson = JSON.parse(data); 
                console.log(tempJson)
                cmp.set('v.items', tempJson);
                cmp.set('v.selected', cmp.get("v.accId"));
                
                var selEvent =  $A.get("e.c:HRYRecordSelection");    
                selEvent.setParams({"selRecordId" :  cmp.get("v.accId")});
                selEvent.fire(); 
            }    
        });
        $A.enqueueAction(action);
    },
})