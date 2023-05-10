({
	itemSelected : function(component, event, helper) {
        var target = event.target;   
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");  
        var objName = component.get("v.objectName");
        if(SelIndex){
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem.ObjRecord){
                component.set("v.selectedObject",selItem.ObjRecord);
                component.set("v.selItem",selItem);
                component.set('v.disbaledSave',false);
                var LookUp = $A.get("e.c:LookUpEvt");
                LookUp.setParams({
                "Action" : objName,
                "selItem" : selItem,   
                "selectedObject"  : selItem.ObjRecord,
                "asmIndex" : component.get('v.Index'),
                "type" : component.get('v.type'),
                "objType" : component.get('v.objectName')   
                });
                
                LookUp.fire();
               component.set("v.last_ServerResult",serverResult);
            } 
            
            component.set("v.server_result",null); 
        } 
	}, 
    serverCall : function(component, event, helper) {  
        var target = event.target;  
        var searchText = target.value; 
        var last_SearchText = component.get("v.last_SearchText");
        //Escape button pressed 
        if (event.keyCode == 27 || !searchText.trim()) { 
            helper.clearSelection(component, event, helper);
        }else if(searchText.trim() != last_SearchText  ){ 
            //Save server call, if last text not changed
            //Search only when space character entered
         
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_val = component.get("v.field_API_val");
            var field_API_search = component.get("v.field_API_search");
            var sub_fld_text = component.get("v.sub_fld_text");
            var limit = component.get("v.limit");
            
            var action = component.get('c.searchDB');
            action.setStorable();
            
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                fld_API_Val : field_API_val,
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText,
                sub_fld_text : sub_fld_text
            });
    
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);
            });
            
            component.set("v.last_SearchText",searchText.trim());
            
            $A.enqueueAction(action); 
        }else if(searchText && last_SearchText && searchText.trim() == last_SearchText.trim()){ 
            component.set("v.server_result",component.get("v.last_ServerResult"));
            
        }         
	},
    handleResponse : function (res,component,helper){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
           
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
                component.set("v.server_result",noResult); 
            	component.set("v.last_ServerResult",noResult);
            }else{
                component.set("v.server_result",retObj); 
            	component.set("v.last_ServerResult",retObj);
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            } 
        }
    },
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
			SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    clearSelection: function(component, event, helper){
        component.set("v.selItem",null);
        component.set("v.selectedObject",null);
        component.set("v.server_result",null);
        component.set('v.disbaledSave',true);
        var LookUp = $A.get("e.c:LookUpEvt");
        
        LookUp.setParams({
                "Action" : 'Clear Selection',
            	"asmIndex" : component.get('v.Index'),
                "type"   : component.get('v.type'),
                "objType" : component.get('v.objectName')   
                });
       LookUp.fire();
        
    } 
})