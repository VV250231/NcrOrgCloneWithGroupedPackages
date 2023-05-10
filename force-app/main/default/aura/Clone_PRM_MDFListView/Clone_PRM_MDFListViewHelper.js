({

    getMDFRequestHelper : function(cmp,next,prev,offset,con) {
        offset = offset || 0;
        con = con || '';
        var action = cmp.get("c.getMDFRequestController");
        action.setParams({
            "next" : next,
            "prev" : prev,
            "off" : offset ,
            "whereCondtion" : con
        });
        action.setCallback(this,function(res){
            var state = res.getState();   
            //alert(state);         
            if(state=="SUCCESS"){
              	var result = res.getReturnValue();
              	cmp.set('v.offset',result.offst);
                console.log(result.lstMDFDetails)
              	cmp.set('v.mdfDetailRecords',result.lstMDFDetails);	
              	cmp.set('v.next',result.hasnext);
              	cmp.set('v.prev',result.hasprev);
              	cmp.set('v.conditon',result.condition);
               
              	//var listView = cmp.find("ListView");
                //$A.util.removeClass(listView, "slds-hide");
                //$A.util.addClass(listView, "slds-show");  
                cmp.set('v.isListView',true);
                cmp.set('v.isDetailView',false);
                
                //var outputArea = cmp.find("OutputArea");
                //$A.util.removeClass(outputArea, "slds-show");  
                //$A.util.addClass(outputArea, "slds-hide");
                
                
            }
        });        
        $A.enqueueAction(action);
    },
    getDeleteMDFRequest : function(cmp, next, prev, idd){
        var action = cmp.get("c.deleteMDFRequest");
        action.setParams({
            "next" : next,
            "prev" : prev,
            "off" : 0, 
            "mdfId" : idd
        });
        action.setCallback(this,function(res){
            var state = res.getState();   
            //alert(state);         
            if(state=="SUCCESS"){
              	var result = res.getReturnValue();
              	cmp.set('v.offset',result.offst);
                console.log(result.lstMDFDetails)
              	cmp.set('v.mdfDetailRecords',result.lstMDFDetails);
              	cmp.set('v.next',result.hasnext);
              	cmp.set('v.prev',result.hasprev);
              	cmp.set('v.conditon',result.condition);
              	cmp.set("v.isOpen", false);        
                /*var listView = cmp.find("ListView");
                $A.util.removeClass(listView, "slds-hide");
                $A.util.addClass(listView, "slds-show");  
                
                var outputArea = cmp.find("OutputArea");
                $A.util.removeClass(outputArea, "slds-show");  
                $A.util.addClass(outputArea, "slds-hide");*/
                
                cmp.set('v.isListView',true);
                cmp.set('v.isDetailView',false);
            }
        });        
        $A.enqueueAction(action);
    },
    
    changeView : function(cmp, next, prev, selectedValue){
        var action = cmp.get("c.changeViewSelection");
        action.setParams({
            "next" : next,
            "prev" : prev,
            "off" : 0, 
            "val" : selectedValue
        });
        action.setCallback(this,function(res){
            var state = res.getState();   
            //alert(state);         
            if(state=="SUCCESS"){
              var result = res.getReturnValue();
              cmp.set('v.offset',result.offst);
                console.log(result.lstMDFDetails)
              cmp.set('v.mdfDetailRecords',result.lstMDFDetails);
              cmp.set('v.next',result.hasnext);
              cmp.set('v.prev',result.hasprev);
              cmp.set('v.conditon',result.condition);
              
            }
        });        
        $A.enqueueAction(action);
    },
   
   
})