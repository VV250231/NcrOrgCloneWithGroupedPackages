({
    /*doInit : function(component, event, helper) {
        var action = component.get("c.loggedInAs");
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                    component.set("v.usertype",result); 
                }
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },*/
    download : function(component, event, helper) {
        var newsUrl='';
        if(component.get("v.usertype")=='Guest'){
            newsUrl='/resource/TableauPortalNewsLetter?'  ;
        }else{
            newsUrl='/sfc/servlet.shepherd/document/download/0690g0000072WGtAAM?operationContext=S1'  ; 
            
        }
        window.open(newsUrl, '_blank');
        
    }
})