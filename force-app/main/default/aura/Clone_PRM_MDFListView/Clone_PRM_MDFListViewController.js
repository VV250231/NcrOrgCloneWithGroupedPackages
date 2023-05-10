({
    getMDFRequest : function(cmp, evt, helper) {
    	var next = false;
        var prev = false;
        //component.set("v.Spinner", true); 
        helper.getMDFRequestHelper(cmp,next,prev);
    },
    Next:function(cmp,event,helper){
        var next = true;
        var prev = false;
        var offset = cmp.get("v.offset");
        var con = cmp.get("v.conditon")
        helper.getMDFRequestHelper(cmp,next,prev,offset, con); 
    },
    Previous:function(cmp,event,helper){
        var next = false;
        var prev = true;
        var offset = cmp.get("v.offset");
        var con = cmp.get("v.conditon")
        helper.getMDFRequestHelper(cmp,next,prev,offset,con); 
    },
    onSelectChange: function (cmp, event, helper) {
        //Do something with the change handler
        var next = false;
        var prev = false;
        var selectedValue = cmp.find("levels").get("v.value");
        helper.changeView(cmp, next, prev, selectedValue);
    },
    
    deleteMdf:function(cmp, event, helper){
        var idx = event.currentTarget;
        var idd = idx.dataset.ids; 
       	
        var next = false;
        var prev = false;
        helper.getDeleteMDFRequest(cmp, next, prev, idd);
    },

    redirectToMdfRecord: function(cmp, event, helper){
   		var exbRdId = event.currentTarget.dataset.record;
   		cmp.set("v.recId", exbRdId);
        /*var listView = cmp.find("ListView");
        $A.util.removeClass(listView, "slds-show");
		$A.util.addClass(listView, "slds-hide");
        
        var outputArea = cmp.find("OutputArea");
        $A.util.addClass(outputArea, "slds-show");*/
        cmp.set('v.isListView',false);
        cmp.set('v.isDetailView',true);
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/mdf-detail?mid=" + exbRdId
                }).fire();
        
        //helper.getMDFDetails(cmp, event, helper,exbRdId);
        
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       	// make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     	// make Spinner attribute to false for hide loading spinner    
       	component.set("v.Spinner", false);
    },
  
    showNewRequest: function(cmp, evt, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/new-mdf-request"
                }).fire();
    },
})