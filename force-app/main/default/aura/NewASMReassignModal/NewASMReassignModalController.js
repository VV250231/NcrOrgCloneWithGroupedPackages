({
    doInit : function(component, event, helper) {
        
    },
    closeModal : function(component, event, helper) {
        var isStd = component.get("v.isStandard");
        console.log('isStd'+isStd);
        if(!isStd){
        if(helper.validatePOInCancel(component)){
            component.set("v.isASMyourSelf",false);
            component.set("v.showModal",false); 
            component.set("v.AccountName","");
            component.set('v.ASMHirarchy',[]);
            component.set('v.selectRole',false);
            component.set("v.currentPage",component.get("v.currentPage"));
            component.set("v.currentTab",component.get("v.currentTab"));
            var arrDir = component.get("v.arrowDirection")=='arrowup'? 'arrowdown' : 'arrowup';
            //alert(arrDir);
            component.set("v.arrowDirection",arrDir);
            var isasc =  component.get("v.isAsc")== true? false : true;
            component.set("v.isAsc",false);
            var p = component.get("v.parent");
            p.callParentdoInit();
        }else{
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "title": "ERROR!",
                "message": "Error on this Page. Please assign PO/Billing Person as it is mandatory",
                "type": "ERROR"
            }); 
            toastEvent.fire();
        }}else{
            var p = component.get("v.parent");
            p.closeModal();
        }
    },
    
    autoPopulate : function(component, event, helper){
        var ASM = event.getParam("ASM");
        var PO = event.getParam("PO");
        var CA = event.getParam("CA");
        
        if( typeof(ASM) !='undefined' || ASM !=null){
            component.set('v.ASMUser',ASM);
        }
        if( typeof(CA) !='undefined' || CA !=null){
            component.set('v.CAUser',CA.ObjRecord);
            component.set('v.CASelItem',CA);
        }
        if( typeof(PO) !='undefined' || PO !=null){
            component.set('v.POUser',PO.ObjRecord);
            component.set('v.POSelItem',PO);
        }
    },
    
    addASMRole : function(component, event, helper){
        var asmValue = component.get("v.ASMHirarchy");
        //alert('asm '+asmValue);
        var asmHirarchyObj = {"userObj":null,"ObjRecord" : null,"selItem":null,"RoleName":null,"Id" : null,"AccountId" : null,"Master" :null};
        console.log('this is nnsdk=== '+JSON.stringify(asmHirarchyObj));
        console.log(asmValue[0].AccountId);
        asmHirarchyObj.AccountId = asmValue[0].AccountId;
        asmHirarchyObj.Master = component.get("v.accMaster");
        asmValue.push(asmHirarchyObj);
        console.log('this is nnsdk '+JSON.stringify(asmHirarchyObj));
        //alert('this is add '+asmValue);
        component.set("v.ASMHirarchy",asmValue);
    },
    removeASMRole : function(component, event, helper){
        var objIndex = event.getSource().get("v.tabindex");
        var asmValue = component.get("v.ASMHirarchy");
        var rolestodel = [];
        console.log('asmValue'+JSON.stringify(asmValue[objIndex]));
        //if(asmValue[objIndex].Id)
        if(asmValue[objIndex].hasOwnProperty('Id') && typeof asmValue[objIndex].Id === 'string' && asmValue[objIndex].Id.length>0)
        {rolestodel.push(asmValue[objIndex].Id);
        }
        console.log('rolestodelete'+rolestodel);
      
        if(rolestodel.length>0){
        //var selectedEventId = event.target.id;
        	var msg ='Are you sure you want to delete this item?';
        	if (!confirm(msg)) {
                
            	console.log('No');
            	return false;
        	} else {
                 var newASMList = asmValue.splice(objIndex, 1);
        		component.set("v.ASMHirarchy",asmValue);
            	console.log('Yes');
                component.set("v.rolesToDelete",rolestodel);
        		helper.deleteRole(component);
            //Write your confirmed logic
        	}
           
        }else{
             var newASMList = asmValue.splice(objIndex, 1);
        		component.set("v.ASMHirarchy",asmValue);
        }
    },
    
    EditAccRecord : function(component,event,helper){
        if(helper.validatePO(component)){
            if(!helper.findDuplicates(component)){
            	helper.saverecord(component,event);
            }
        }
    }, 
    click:function(component,event,helper){
        //alert();
        var roleName = component.get("v.selectedRole");
        if(roleName=='Select Role'){
            component.set('v.selectRoledisabled',true);
        }else{
            component.set('v.selectRoledisabled',false);
        }
    },
    clickNext : function(component,event,helper){
    	  component.set('v.selectRole',false);
        var roleName = component.get("v.selectedRole");
       // alert(roleName);
        var roles = component.get("v.AccountSupportList");
        var selectedRoles = [];
        var Asmhirachyobj = [];
        var Asmhirachy = [];
        for(var value in roles){
            if(roles[value].isChecked){
                //alert(JSON.stringify(roles[value]));
                if(roleName =='PO/Billing Person'){
                   selectedRoles =  roles[value].poroles;
                }
                else if(roleName =='Customer Advocate'){
                    selectedRoles =  roles[value].caroles;
                }
                else if(roleName =='Account Service Manager'){
                    selectedRoles =  roles[value].asmroles;
                }else{
                    if(roles[value].otherRoles)
                   		selectedRoles =  roles[value].otherRoles;
                }
                 console.log('selectedRoles'+JSON.stringify(selectedRoles));
                for(var obj in selectedRoles){
                   //alert(selectedRoles[obj].Role);
                   if(selectedRoles[obj].Role == roleName){
                    Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
			"ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
			"RoleName":"","Id" :"","Master" : "","AccountId" : ""};
             Asmhirachyobj.userObj.attributes.url = Asmhirachyobj.userObj.attributes.url+selectedRoles[obj].UserId; 
             Asmhirachyobj.userObj.attributes.Name = selectedRoles[obj].UserName;
           	Asmhirachyobj.userObj.attributes.Id = selectedRoles[obj].UserId;
             Asmhirachyobj.userObj.attributes.Quicklook_ID__c = selectedRoles[obj].QuicklookID;
             Asmhirachyobj.userObj.attributes.Email = selectedRoles[obj].Email;
             Asmhirachyobj.selItem.text = selectedRoles[obj].UserName;
             Asmhirachyobj.userObj.Name = selectedRoles[obj].UserName;
             Asmhirachyobj.userObj.Id = selectedRoles[obj].UserId;
             Asmhirachyobj.userObj.Quicklook_ID__c = selectedRoles[obj].QuicklookID;
             Asmhirachyobj.userObj.Email = selectedRoles[obj].Email;
             Asmhirachyobj.ObjRecord = Asmhirachyobj.userObj;
             Asmhirachyobj.RoleName = selectedRoles[obj].Role;
             Asmhirachyobj.Id = selectedRoles[obj].Id;
             Asmhirachyobj.AccountId = roles[value].accountId;
             Asmhirachyobj.ExtId = selectedRoles[obj].ExtId;
             Asmhirachyobj.Master = roles[value].master;
             Asmhirachy.push(Asmhirachyobj);
                   }
                    }
            }
        }
        console.log('after  Ass '+JSON.stringify(Asmhirachy));
        component.set('v.ASMHirarchy',Asmhirachy);
        //console.log('Asmhirachy ====>    bulk after   '+JSON.stringify(roles));
	},
    goPrev:function(component,event,helper){
        var p = component.get("v.parent");
            p.goPrev();
    }
})