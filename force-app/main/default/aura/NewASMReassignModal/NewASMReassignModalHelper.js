({
    validatePOInCancel:function(component){
        console.log('fromAPOCCommunity'+component.get("v.fromAPOCCommunity"));
        if(component.get("v.fromAPOCCommunity")){
            var roles = component.get('v.ASMHirarchy');
            console.log('roles'+JSON.stringify(roles));
            var POchecked = false;
            for(var obj in roles){
                console.log('roles'+JSON.stringify(roles[obj]));
                if(roles[obj].RoleName!= null &&roles[obj].RoleName!='Select Role'){
                    if(roles[obj].selItem!=null){
                        if(roles[obj].RoleName =='PO/Billing Person'){
                            POchecked = true;  
                        }
                    }
                }
            }
            return POchecked;
        }else{
            return true;
        }
    },
    validatePO :function(component){
      //  debugger;
        var roles = component.get('v.ASMHirarchy');
        console.log('roles'+JSON.stringify(roles));
        var POchecked = false;
        var isError = true;
        for(var obj in roles){
            console.log('roles'+JSON.stringify(roles[obj]));
           if(roles[obj].RoleName!= null &&roles[obj].RoleName!='Select Role'){
               if(roles[obj].selItem!=null){
                   if(roles[obj].RoleName =='PO/Billing Person'){
                       POchecked = true;  
                   }
               }
               else{
                	isError = false; 
               }
           }else{
               isError = false; 
           }
            
        }
        if(!POchecked){
            
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "title": "ERROR!",
                "message": "Error on this Page. Please assign PO/Billing Person as it is mandatory",
                "type": "ERROR"
            }); 
            toastEvent.fire();
        }
        else if(!isError){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "message": "Error on this Page. Please fill the user/role name or delete the extra added row.",
                "type": "ERROR"
            }); 
            toastEvent.fire();
        }
        console.log('value returned'+POchecked&&isError);
        return POchecked&&isError;
    },
	saverecord : function(component, event, helper){
        //debugger;
        component.set("v.spinner", true);
        var asmHierarchyObj = component.get('v.ASMHirarchy');
        var asmHierarchy = JSON.stringify(component.get('v.ASMHirarchy'));
        //alert('this is AAAS '+asmHierarchy);
       	console.log('asmHierarchy==> helper djahdjad  '+asmHierarchy);
        //var role = {"Id": null, "Account__c":null, "Email2__c":null, "Master_Number__c":null, "Role_User_Qlook_Id__c":null, "Role_User_Name__c": null, "Role_Name__c":null};
        var roles= [];
        var action = component.get('c.editRecord');
        //alert('this asmHierarchyObj type '+typeof asmHierarchyObj);
        var obj ;
        //alert('asmHierarchyObj '+asmHierarchyObj.length);
        for(obj in asmHierarchyObj){
            var role = {"Id": null, "Account__c":null, "Email2__c":null, "Master__c":null, "Role_User_Qlook_Id__c":null, "NCR_Employee_Detail__c": null, "Role_Name__c":null};
            console.log('this is obj '+obj+' ===>'+JSON.stringify(asmHierarchyObj[obj]));
            console.log('asmHierarchyObj[obj].ObjRecord.attributes.Id; '+asmHierarchyObj[obj].Id);
            console.log('asmHierarchyObj[obj].ObjRecord.attributes.Quicklook_ID__c; '+asmHierarchyObj[obj].AccountId);
           // role.Id = asmHierarchyObj[obj].Id;
           //alert(JSON.stringify(asmHierarchyObj[obj]));
            console.log('hhhhhhhh'+JSON.stringify(asmHierarchyObj[obj]));
           	role.External_Id__c = asmHierarchyObj[obj].ExtId;
            role.Account__c = asmHierarchyObj[obj].AccountId;
           	//role.Email2__c = asmHierarchyObj[obj].ObjRecord.Email;
           	//alert(asmHierarchyObj[obj].Master);
            var accMaster = component.get("v.accMaster");
            role.Master__c = accMaster;
            
            //alert(role.Master__c);
            role.QuickLook_ID__c = asmHierarchyObj[obj].ObjRecord.Quicklook_ID__c;
            console.log('yyyyyy'+asmHierarchyObj[obj].ObjRecord.Quicklook_ID__c);
            //role.Name = asmHierarchyObj[obj].ObjRecord.Name;
            role.Role_Name__c = asmHierarchyObj[obj].RoleName;
            role.NCR_Employee_Detail__c = asmHierarchyObj[obj].ObjRecord.Id;// changed for EBA_SF-1263 by Varsha
            role.Action__c = 'Create';
            //alert('bhmgj '+JSON.stringify(role));
            roles.push(role);
            
       }
        console.log('asmHierarchy==> final  '+JSON.stringify(roles));
         action.setParams({
            roleL : roles
        });
        //alert('kajshdkajh');
        action.setCallback(this,function(response){
            
            //alert('this is state '+response.getState());
            if(response.getState() =='SUCCESS'){
                //alert();
               
                
               
                if(response.getReturnValue()!=null)
                {
                var toastEvent = $A.get("e.force:showToast");
               	toastEvent.setParams({
             	 "title": "ERROR!",
              	 "message": response.getReturnValue(),
             	 "type": "ERROR"
              	 }); 
                 toastEvent.fire();
                
                component.set("v.spinner",false);
            }
                else{
                 // alert();
                  var p = component.get("v.parent");
                var asmHirarchyObj = {"userObj":null,"ObjRecord" : null,"selItem":null,"RoleName":null,"Id" : null,"AccountId" : "","Master" :""};
                //alert(component.get("v.isAsc"));
                
                var arrDir = component.get("v.arrowDirection")=='arrowup'? 'arrowdown' : 'arrowup';
                //alert(arrDir);
                component.set("v.arrowDirection",arrDir);
                var isasc =  component.get("v.isAsc")== true? false : true;
                component.set("v.isAsc",false);
                    if(component.get("v.isStandard")){    
                      
                        p.closeModal();
                    }else{
                        if(component.get("v.fromAPOCCommunity")){
                            console.log('**********0');
						 	component.set("v.currentPage",component.get("v.currentPage"));
                        	component.set("v.currentTab",component.get("v.currentTab"));
                        }else{
                              console.log('**********1');
                      		component.set("v.currentPage",0);
                        }
                       	p.callParentdoInit();
                    }
                    component.set("v.showModal",false);
                component.set("v.spinner",false);
                     component.set('v.ASMHirarchy',asmHirarchyObj);
                     var toastEvent = $A.get("e.force:showToast");
               	toastEvent.setParams({
             	 "title": "SUCCESS!",
              	 "message": "This Record Changes are saved.",
             	 "type": "SUCCESS"
              	 }); 
                 toastEvent.fire();
                }
            }
            
        });
        $A.enqueueAction(action);
        //component.set('v.isbulkUpdate',false);
            },
    
    deleteRole : function(component){
        var rolesIds = component.get("v.rolesToDelete");
        // alert(JSON.stringify(rolesIds));
        var roles= [];
        var action = component.get('c.deleteRecord');
        for(var obj in rolesIds){
            var role = {"Id": null};
            role.Id = rolesIds[obj];
            roles.push(role);
        }
       // alert(JSON.stringify(roles));
        action.setParams({
            roles : roles
        });
         action.setCallback(this,function(response){
            
            //alert('this is state '+response.getState());
             if(response.getState() =='SUCCESS'){
                 var toastEvent = $A.get("e.force:showToast");
               	toastEvent.setParams({
             	 "title": "SUCCESS!",
              	 "message": "THIS ROLE IS DELETED FROM DATABASE.",
             	 "type": "SUCCESS"
              	 }); 
                 toastEvent.fire();
             }else{
                 var toastEvent = $A.get("e.force:showToast");
               	toastEvent.setParams({
             	 "title": "ERROR!",
              	 "message": "Some unknown error occured.",
             	 "type": "ERROR"
              	 }); 
                 toastEvent.fire();
             }
         });
        $A.enqueueAction(action);
    },
    findDuplicates : function(component) {
    	var roles = component.get('v.ASMHirarchy');
       	var index = 0;
       	var isDup = false;
        while(index<roles.length){
            var currentObj = roles[index];
            var roleName;
            var userName;
            for(var i=index+1;i<roles.length;i++){
                if(currentObj.RoleName==roles[i].RoleName){
                    if(currentObj.ObjRecord.Quicklook_ID__c == roles[i].ObjRecord.Quicklook_ID__c){
                        isDup = true;
                        roleName= roles[i].RoleName;
                        userName = roles[i].ObjRecord.User_Name__c;
                        break;
                    }
                }
            }
            if(isDup){
                break;
            }
            index= index+1;
        }
        console.log('isDup'+isDup);
        if(isDup){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "message": roleName+" role with the name "+userName+" already exists. Please use a different name.",
                "type": "ERROR"
            }); 
            toastEvent.fire();
            component.set("v.spinner", false);
        }
        return isDup;
    }
})