({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAllRoleNames");
        action.setCallback(this,function(response){
            var state =  response.getState();
            console.log('state '+state);
            if(state = 'SUCCESS'){
                var rolenames = response.getReturnValue();
                rolenames.unshift('Select Role');
                component.set("v.ManageRoles",rolenames);
            }
        });
        $A.enqueueAction(action);
        
    },
    callParentdoInit : function(component,event,helper){
      	var p = component.get("v.parent");
        if(p){
        	p.callParentdoInit();
        }  
    },
	closeModal : function(component, event, helper) {
        //alert();
        component.set("v.showModal",false);
        component.set("v.ASMHirarchy",JSON.parse(JSON.stringify([{'userObj':null,'selItem':null,'RoleName':null}])));
        console.log(JSON.stringify(component.get("v.ASMHirarchy")));
        if(component.get("v.isStandard")){
       		helper.gotoList(component);  
        }
	},
    handleLookUpEvent : function(component, event, helper){
       //alert();
        //var action = component.get("c.getselRec");
        var selectedItem = component.get("v.selItem");
        var objname = event.getParam('objType');
         var actionEvent =  event.getParam('Action');
        var isStd = component.get("v.isStandard");
        if(!isStd){
            if(objname == 'Account'){
                if(actionEvent =='Clear Selection'){
                    console.log("clear selection");
                    component.set('v.errorText',"");
                    component.set("v.isNext",true);
                    component.set("v.isSave",true);
                    
                    component.set("v.IsAccountExist",true);
                    component.set("v.ShowUSerSection",false);
                }
                else{
                    helper.getSelAccsupport(component, event);
                }
            }
        }else{
            if(actionEvent =='Clear Selection'){
                component.set("v.isSave",true);
            }else{
                component.set("v.isSave",false); 
            }
        }
    },
    goNext : function(component, event, helper){
        //alert(JSON.stringify(component.get("v.selItem")));
        var isStd = component.get("v.isStandard");
        var accRecord =  component.get('v.selItem');
        component.set("v.accName",accRecord.Name+'/'+accRecord.Master_Customer_Number__c);
        component.set("v.accMaster",accRecord.Master_Customer_Number__c);
        if(!isStd){
            component.set('v.isNext',false);
            console.log('ASMHirarchy'+JSON.stringify(component.get("v.ASMHirarchy")));
            if(component.get("v.ASMHirarchy").length ==0){
            	component.set("v.ASMHirarchy",JSON.parse(JSON.stringify([{'userObj':null,'selItem':null,'RoleName':null,"AccountId" : accRecord.Id,"Master" :accRecord.Master_Customer_Number__c}])));
            }
            console.log(JSON.stringify(component.get("v.ASMHirarchy")));
        }else{
          
            helper.populateExistingRoles(component,accRecord);
        }
    },
    goPrev : function(component, event, helper){
          component.set('v.isNext',true);     
    },
    /*removeASMRole : function(component, event, helper){
        var objIndex = event.getSource().get("v.tabindex");
        var asmValue = component.get("v.ASMHirarchy");
        var newASMList = asmValue.splice(objIndex, 1);
        component.set("v.ASMHirarchy",asmValue);
    },
    addASMRole : function(component, event, helper){
        var asmValue = component.get("v.ASMHirarchy");
        //alert('asm '+asmValue);
        var asmHirarchyObj = {"userObj":null,"selItem":null,"RoleName":null};
        asmValue.push(asmHirarchyObj);
        console.log(JSON.stringify(asmValue));
        component.set("v.ASMHirarchy",asmValue);
    },*/
    toggleLookup : function(component, event, helper) {
       
        if(component.get("v.toggleLookup") == true){
             component.set("v.toggleLookup",false);
             component.set("v.accSelItem",null);
            component.set("v.selItem",null);
             component.set("v.isNext",true);
            component.set("v.isSave",true);
        }else{
        	component.set("v.toggleLookup",true);
            component.set("v.accSelItem",null);
            component.set("v.selItem",null);
            component.set("v.isNext",true);
           component.set("v.isSave",true);
        }	
	},
    
    /*saveAccRecord : function(component,event,helper){
        component.set("v.spinner", true);
        var account =JSON.stringify(component.get("v.selItem"));
        console.log('account'+account);
        var asmHierarchy = JSON.stringify(component.get('v.ASMHirarchy'));
       	console.log('asmHierarchy'+asmHierarchy); 
        var POchecked=false;
        var isError=false;
        var roles = component.get('v.ASMHirarchy');
        for(var obj in roles){
           // debugger;
           //alert(JSON.stringify(roles[obj]))
           if(roles[obj].RoleName!= null &&roles[obj].selItem!=null&&roles[obj].RoleName!='Select Role'){
               if(roles[obj].RoleName =='PO/Billing Person'){
                   if(roles[obj].selItem){
                       POchecked = true;  
                   }
                   
               }
           }else{
                isError = true; 
               var toastEvent = $A.get("e.force:showToast");
           		
               	toastEvent.setParams({
             	 "title": "ERROR!",
              	 "message": "Error on this Page. Please fill the user name or delete the extra added row.",
             	 "type": "ERROR"
              	 }); 
                 toastEvent.fire();
               component.set("v.spinner", false);
               
           }
        }
        if(POchecked&&!isError){
           // debugger;     
            if(!helper.findDuplicates(component)){ 
		       
  		var action = component.get("c.newAccRecord");
        action.setParams({   
            accountRec : account,
            asmHierarchy : asmHierarchy
          
        });
        action.setCallback(this,function(response){
           
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
           
            toastEvent.setParams({
              "title": "Success!",
              "message": "Record was Saved Successfully.",
              "type": "Success"
            }); 
            console.log('State ==> '+state);
            
         if(component.get("v.isStandard")){
       		helper.gotoList(component);  
        }
            else{
                var p = component.get("v.parent");
                var rec = response.getReturnValue();
                console.log('Alert '+ JSON.stringify(rec));
                var accList = component.get("v.AccountSupportListMain");
                console.log('this is record '+JSON.stringify(rec));
                if(rec!=null)
                accList.unshift(rec[0]);
                component.set("v.AccountSupportListMain",accList);
    			p.doFilter();
                component.set("v.showModal", false);
            }
            
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
        }
        }
        else if(!isError){
            var toastEvent = $A.get("e.force:showToast");
           		
               	toastEvent.setParams({
             	 "title": "ERROR!",
              	 "message": "Error on this Page. Please assign PO/Billing Person as it is mandatory",
             	 "type": "ERROR"
              	 }); 
                 toastEvent.fire();
            component.set("v.spinner", false);
        }
    },*/
    
        
})