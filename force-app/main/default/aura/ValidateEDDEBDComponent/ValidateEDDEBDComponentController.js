({
	doInit : function(component, event, helper) { 
       
        
             
    }, 
    updateDate:function(component, event, helper) {  
        helper.updateDate(component, event, helper); 
            
    },
   
   passRecordId: function(component, event, helper){     
       debugger ;
            component.set("v.passId", event.getParam("passRecordId"));
            component.set("v.showModalA",'N'); 
            component.set("v.callFromSelectPage", event.getParam("callFromSelectPage"));
        	helper.loadEBDEDD(component,event, helper);
        },
    CloseMe:function(component, event, helper){ 
        component.set("v.showModalNotification",'N');
    }
})