({
	doInit : function(cmp, event, helper) {
        
	},
    handleValueChange:function(cmp, event, helper){
        alert(cmp.get("v.OppId"));
    },
    GetRecordValues:function(cmp,event,helper){
        helper.GetRecordValuesHelper(cmp);
    },
    handleApplicationEvent:function(cmp,event,helper){
        helper.GetRecordValuesHelper(cmp);
     }  
})