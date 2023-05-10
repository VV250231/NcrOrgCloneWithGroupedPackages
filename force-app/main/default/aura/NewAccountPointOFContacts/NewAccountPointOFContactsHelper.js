({
    gotoList : function (component) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "ASM_Role_Hierarchy__c"
                });
                navEvent.fire();
            }
        });
        component.set("v.ASMHirarchy",JSON.parse(JSON.stringify([{'userObj':null,'selItem':null,'RoleName':null}])));
        component.set("v.isStandard",true);
        $A.enqueueAction(action);
    },
    getSelAccsupport : function(component,event) {
        var action = component.get("c.getselRec");
        var selectedItem = component.get("v.selItem");
        var objName = event.getParams("Action");
        var masterVal ='';
        if(selectedItem != null){
   			masterVal =	selectedItem.Master_Customer_Number__c;
        }
       
        action.setParams({
            master : masterVal
        });
        action.setCallback(this,function(response){
            
            if(response.getState() == 'SUCCESS'){
                
                
                if(response.getReturnValue() != null){
                   
                   component.set("v.errorText",$A.get("$Label.c.APOC_AccountSupportErrorMSG")); 
                    if(component.get('v.errorText') != null){
                     let button = component.find('disablebuttonid');
                     button.set('v.disabled',true);
                        
                    }
                    component.set("v.ShowUSerSection",false);
                    component.set("v.IsAccountExist",true);
                    component.set("v.isNext",true);
            		component.set("v.isSave",true);
                }else{
                    
                    component.set("v.errorText",'');
                    component.set("v.IsAccountExist",false);
                    component.set("v.ShowUSerSection",true);
                    component.set("v.isNext",true);
            		component.set("v.isSave",false);
                    
                } 
            }
        });
        $A.enqueueAction(action);
    },
    /*findDuplicates : function(component) {
    	var roles = component.get('v.ASMHirarchy');
       	var index = 0;
       	var isDup = false;
        while(index<roles.length){
            var currentObj = roles[index];
            console.log('currentObj'+JSON.stringify(currentObj));
            var roleName;
            var userName;
            for(var i=index+1;i<roles.length;i++){
                // alert(i);
                console.log('role'+JSON.stringify(roles[i]));
                if(currentObj.RoleName==roles[i].RoleName){
                    if(currentObj.userObj.Quicklook_ID__c == roles[i].userObj.Quicklook_ID__c){
                        isDup = true;
                        roleName= roles[i].RoleName;
                        userName = roles[i].userObj.Name;
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
    },*/
    populateExistingRoles : function(component,accRec) {
        var action = component.get("c.getAPOCRcrd");
        action.setParams({
            accId : accRec.Id,
            allrole : true
        });
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                	component.set("v.AccountSupportList",response.getReturnValue());
                    var accRecord = component.get('v.AccountSupportList')[0];
                    if(accRecord){
                        var PoRoles =  accRecord.poroles;
                        var caRoles =  accRecord.caroles;
                        var asmRoles = accRecord.asmroles;
                        var otherRoles = accRecord.otherRoles; 
                        //alert(accRecord.Id);
                        var Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
                                                                                                                                                                                                           "ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
                                              "RoleName":""};
                        var Asmhirachy  = [];
                        var obj;
                        //console.log('Before Ass '+JSON.stringify(Asmhirachy));
                        for(obj in PoRoles){
                            Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
                                                                                                                                                                                                           "ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
                                              "RoleName":"","Id" :"","Master" : "","AccountId" : ""};
                            Asmhirachyobj.userObj.attributes.url = Asmhirachyobj.userObj.attributes.url+PoRoles[obj].UserId; 
                            Asmhirachyobj.userObj.attributes.Name = PoRoles[obj].UserName;
                            Asmhirachyobj.userObj.attributes.Id = PoRoles[obj].UserId;
                            Asmhirachyobj.userObj.attributes.Quicklook_ID__c = PoRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.attributes.Email = PoRoles[obj].Email;
                            Asmhirachyobj.selItem.text = PoRoles[obj].UserName;
                            Asmhirachyobj.userObj.Name = PoRoles[obj].UserName;
                            Asmhirachyobj.userObj.Id = PoRoles[obj].UserId;
                            Asmhirachyobj.userObj.Quicklook_ID__c = PoRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.Email = PoRoles[obj].Email;
                            Asmhirachyobj.ObjRecord = Asmhirachyobj.userObj;
                            Asmhirachyobj.RoleName = PoRoles[obj].Role;
                            Asmhirachyobj.Id = PoRoles[obj].Id;//
                            Asmhirachyobj.Master = accRecord.master;
                            Asmhirachyobj.AccountId = accRecord.accountId;
                            Asmhirachyobj.ExtId = PoRoles[obj].ExtId;
                            Asmhirachy.push(Asmhirachyobj);
                        }
                        for(obj in caRoles){
                            Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
                                                                                                                                                                                                           "ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
                                              "RoleName":"","Id" :"","Master" : "","AccountId" : ""};
                            Asmhirachyobj.userObj.attributes.url = Asmhirachyobj.userObj.attributes.url+caRoles[obj].UserId; 
                            Asmhirachyobj.userObj.attributes.Name = caRoles[obj].UserName;
                            Asmhirachyobj.userObj.attributes.Id = caRoles[obj].UserId;
                            Asmhirachyobj.userObj.attributes.Quicklook_ID__c = caRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.attributes.Email = caRoles[obj].Email;
                            Asmhirachyobj.selItem.text = caRoles[obj].UserName;
                            Asmhirachyobj.userObj.Name = caRoles[obj].UserName;
                            Asmhirachyobj.userObj.Id = caRoles[obj].UserId;
                            Asmhirachyobj.userObj.Quicklook_ID__c = caRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.Email = caRoles[obj].Email;
                            Asmhirachyobj.ObjRecord = Asmhirachyobj.userObj;
                            Asmhirachyobj.RoleName = caRoles[obj].Role;
                            Asmhirachyobj.Id = caRoles[obj].Id;
                            Asmhirachyobj.Master = accRecord.master;
                            Asmhirachyobj.AccountId = accRecord.accountId;
                            Asmhirachyobj.ExtId = caRoles[obj].ExtId;
                            Asmhirachy.push(Asmhirachyobj);
                        }
                        for(obj in asmRoles){
                            Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
                                                                                                                                                                                                           "ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
                                              "RoleName":"","Id" :"","Master" : "","AccountId" : ""};
                            Asmhirachyobj.userObj.attributes.url = Asmhirachyobj.userObj.attributes.url+asmRoles[obj].UserId; 
                            Asmhirachyobj.userObj.attributes.Name = asmRoles[obj].UserName;
                            Asmhirachyobj.userObj.attributes.Id = asmRoles[obj].UserId;
                            Asmhirachyobj.userObj.attributes.Quicklook_ID__c = asmRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.attributes.Email = asmRoles[obj].Email;
                            Asmhirachyobj.selItem.text = asmRoles[obj].UserName;
                            Asmhirachyobj.userObj.Name = asmRoles[obj].UserName;
                            Asmhirachyobj.userObj.Id = asmRoles[obj].UserId;
                            Asmhirachyobj.userObj.Quicklook_ID__c = asmRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.Email = asmRoles[obj].Email;
                            Asmhirachyobj.ObjRecord = Asmhirachyobj.userObj;
                            Asmhirachyobj.RoleName = asmRoles[obj].Role;
                            Asmhirachyobj.Id = asmRoles[obj].Id;
                            Asmhirachyobj.Master = accRecord.master;
                            Asmhirachyobj.AccountId = accRecord.accountId;
                            Asmhirachyobj.ExtId = asmRoles[obj].ExtId;
                            Asmhirachy.push(Asmhirachyobj);
                        }
                        for(obj in otherRoles){
                            Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
                                                                                                                                                                                                           "ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
                                              "RoleName":"","Id" :"","Master" : "","AccountId" : ""};
                            Asmhirachyobj.userObj.attributes.url = Asmhirachyobj.userObj.attributes.url+otherRoles[obj].UserId; 
                            Asmhirachyobj.userObj.attributes.Name = otherRoles[obj].UserName;
                            Asmhirachyobj.userObj.attributes.Id = otherRoles[obj].UserId;
                            Asmhirachyobj.userObj.attributes.Quicklook_ID__c = otherRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.attributes.Email = otherRoles[obj].Email;
                            Asmhirachyobj.selItem.text = otherRoles[obj].UserName;
                            Asmhirachyobj.userObj.Name = otherRoles[obj].UserName;
                            Asmhirachyobj.userObj.Id = otherRoles[obj].UserId;
                            Asmhirachyobj.userObj.Quicklook_ID__c = otherRoles[obj].QuicklookID;
                            Asmhirachyobj.userObj.Email = otherRoles[obj].Email
                            Asmhirachyobj.ObjRecord = Asmhirachyobj.userObj;
                            Asmhirachyobj.RoleName = otherRoles[obj].Role;
                            Asmhirachyobj.Id = otherRoles[obj].Id;
                            Asmhirachyobj.Master = accRecord.master;
                            Asmhirachyobj.AccountId = accRecord.accountId;
                            Asmhirachyobj.ExtId = otherRoles[obj].ExtId;
                            Asmhirachy.push(Asmhirachyobj);
                        }
                        if(component.get("v.ASMHirarchy").length==0){
                       		component.set('v.ASMHirarchy',Asmhirachy);
                        }
                    }
                    else{
                        if(component.get("v.ASMHirarchy").length==0){
                            component.set("v.ASMHirarchy",JSON.parse(JSON.stringify([{'userObj':null,'selItem':null,'RoleName':null,"AccountId" : accRec.Id,"Master" :accRec.Master_Customer_Number__c}])));
                        }
                    }
                     component.set('v.isNext',false);
                    if(!component.get("v.isStandard")){
                        component.set('v.fromAPOCCommunity',"true");
                    }
                     component.set('v.isNext',false);
                }else{
                    
                    component.set("v.errorText",'');
                    component.set("v.IsAccountExist",false);
                    component.set("v.ShowUSerSection",true);
                    component.set("v.isNext",true);
            		component.set("v.isSave",false);
                    
                } 
            }
        });
        $A.enqueueAction(action);
             /*console.log('this is List '+JSON.stringify(component.get('v.AccountSupportList')));
        component.set("v.showModal",true);
        //alert('this is roles '+JSON.stringify(component.get('v.AccountSupportList')[0].poroles)); 
        var accRecord =  component.get('v.AccountSupportList')[rowIndex];
        console.log('this is '+JSON.stringify(accRecord));
        
        if(event.getSource().getLocalId() == 'New'){
            component.set("v.isNew",true);
        }else{
            component.set("v.isNew",false);
        }*/
	}
})