({
	getApprovalHistory : function(component) {
        // Get a reference to the getApprovalHistory() function defined in the Apex controller
        var action = component.get("c.getApprovalHistory"); //component.get("v.recordId")
        var idParam = this.getJsonFromUrl().eid;
        //alert(idParam);
        action.setParams({
            "recId" : idParam
        });
        action.setCallback(this, function(a) {
            //alert(a.getReturnValue());
            component.set("v.approvalHistory",a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
})