({
	render : function(cmp, helper) {
    var ret = this.superRender();
    //do custom rendering here
    cmp.set("v.TotalWeitage",Number(cmp.get("v.weightage")));
    var TotalWeitage=Number(cmp.get("v.TotalWeitage")) + Number(cmp.get("v.weightage"));
    //alert();   
    cmp.set("v.TotalWeitage",TotalWeitage);      
    return ret;
	},
})