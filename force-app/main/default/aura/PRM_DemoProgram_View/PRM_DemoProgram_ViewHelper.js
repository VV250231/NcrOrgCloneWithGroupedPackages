({
	
    fetchFiles : function(component){
        var action = component.get("c.getFiles");
        action.setParams({'recId' : component.get("v.recordId")});
        action.setCallback(this,function(response){
            component.set("v.fileLst",response.getReturnValue());
        })
        $A.enqueueAction(action);
    }
})