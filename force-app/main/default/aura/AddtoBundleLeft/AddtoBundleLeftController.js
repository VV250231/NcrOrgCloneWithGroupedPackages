({
	 CollectValue : function (cmp, event,helper) { 
        helper.CollectValue(cmp, event,helper);
    },
    TriggerSelectAllMethod:function(cmp,event,helper){
        
        if(cmp.get("v.TriggerSelectAll")){
            cmp.set("v.liked",true);
            helper.CollectValue(cmp, event,helper);
            
        }
        else{
            cmp.set("v.liked",false); 
            helper.CollectValue(cmp, event,helper);
        }
    }
})