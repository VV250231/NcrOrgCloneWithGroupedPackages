({
    helperMethod : function() {
        
    },
    checkaccess : function(component, event, helper)
    {
        var action = component.get("c.checkaccess");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.checkaccess", a.getReturnValue());
                var numbers = component.get("v.checkaccess");
                
                if(numbers.length == 0){
                    component.set("v.toggleaccesserror", "true");
                }
                else{
                    component.set("v.allowaccess", "true");
                    helper.getusertable(component, event, helper);
                    helper.getroletable(component, event, helper);
                    helper.getsalesorgtable(component, event, helper);
                    //   helper.getuserroledetails(component, event, helper);
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
    },
    getuserroledetails : function(component, event, helper){
        var action = component.get("c.cgetroledetails");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.rolesassigned", a.getReturnValue());
                var numbers = component.get("v.rolesassigned");
                if(numbers.length == 0){
                    //      component.set("v.toggleerrorfromserver", "true");
                }
                else{
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
        
    },
    
    getusertable : function(component, event, helper){
        var action = component.get("c.cgetusertable");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.tableauuserobject", a.getReturnValue());
                var numbers = component.get("v.tableauuserobject");
                if(numbers.length == 0){
                    component.set("v.toggleerrorfromserver", "true");
                }
                else{
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
        
    },
    
    getsalesorgtable : function(component, event, helper){
        var action = component.get("c.cgetsaleorgtable");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.tableausalesorg", a.getReturnValue());
                var numbers = component.get("v.tableausalesorg");
                if(numbers.length == 0){
                    //  component.set("v.toggleerrorfromserver", "true");
                }
                else{
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
        
    },
    getroletable : function(component, event, helper){
        var action = component.get("c.cgetroletable");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.userroleobject", a.getReturnValue());
                var numbers = component.get("v.userroleobject");
                if(numbers.length == 0){
                    component.set("v.toggleerrorfromserver", "true");
                }
                else{
                    //component.set("v.allowaccess", "true");
                    helper.firstreadonlyuser(component, event, helper);
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
    },
    firstreadonlyuser : function(component, event, helper){
        var action = component.get("c.ctableauuserreadonly");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.tableauuserobjectupdate", a.getReturnValue());
                var numbers = component.get("v.tableauuserobjectupdate");
                if(numbers.length == 0){
                    component.set("v.toggleerrorfromserver", "true");
                }
                else{
                    // component.set("v.allowaccess", "true");
                    // helper.getsalesorgtable(component, event, helper);
                    // rolesassigned
                    var rlsstring = [];
                    if(numbers.TRole1UserName__c != null){rlsstring.push({"roleid": numbers.TRole1__c, "rolename": numbers.TRole1UserName__c});}
                    if(numbers.TRole2UserName__c != null){rlsstring.push({"roleid": numbers.TRole2__c, "rolename": numbers.TRole2UserName__c});}
                    if(numbers.TRole3UserName__c != null){rlsstring.push({"roleid": numbers.TRole3__c, "rolename": numbers.TRole3UserName__c});}
                    
                    component.set("v.rolesassigned", rlsstring);
                    helper.evaluateupdatecheckboxnumbers(component, event, helper);
                }
                component.set("v.toggleloader", "false");
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
    },
    searchkeysalesorgser : function(component, event, helper)
    {
        component.set("v.toggleerrorfromserver", "false");
        component.set("v.spin",true);
        component.set("v.togglesearchcriteria", "false");
        var action = component.get("c.searchsalesorgg");
        var searchvalue = component.get("v.searchkeyvaluesales");
        if(searchvalue ==null){
            component.set("v.togglesearchcriteria", "true");
        }
        else{
            action.setParams({
                "searchkey":searchvalue
            });
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    component.set("v.tableausalesorg", a.getReturnValue());
                    var numbers = component.get("v.tableausalesorg");
                    if(numbers.length == 0){
                        //     document.getElementById(searchvaluee).style.display="Block";
                    }
                    
                } else if (a.getState() === "ERROR") { 
                    component.set("v.toggleerrorfromserver", "true");
                    $A.log("Errors", a.getError()); 
                }
                
            });
            component.set("v.spin",false);
            $A.enqueueAction(action);
        }
    },
    searchkeytabuser : function(component, event, helper)
    {
        component.set("v.toggleerrorfromserver", "false");
        component.set("v.togglesearchcriteria", "false");
        component.set("v.spin",true);
        
        var action = component.get("c.gettabuser");
        var searchvalue = component.find("searchkeytabuser").get("v.value");
        
        var searchvaluee =  event.getSource().get("v.value");
        document.getElementById(searchvaluee).style.display="None";
        if(searchvalue ==null){
            component.set("v.togglesearchcriteria", "true");
        }
        else{
            action.setParams({
                "searchkey":searchvalue
            });
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    component.set("v.tableauuserobject", a.getReturnValue());
                    var numbers = component.get("v.tableauuserobject");
                    if(numbers.length == 0){
                        document.getElementById(searchvaluee).style.display="Block";
                    }
                    
                } else if (a.getState() === "ERROR") { 
                    component.set("v.toggleerrorfromserver", "true");
                    $A.log("Errors", a.getError()); 
                }
                
            });
            component.set("v.spin",false);
            $A.enqueueAction(action);
        }
    },
    searchkeyrolename : function(component, event, helper)
    {	
        component.set("v.toggleerrorfromserver", "false");
        component.set("v.togglesearchcriteria", "false");
        component.set("v.spin",true);
        var action = component.get("c.getrolename");
        var searchvaluee =  event.getSource().get("v.value");
        var searchvalue = component.find(searchvaluee).get("v.value");
        if(searchvalue ==null){
            component.set("v.togglesearchcriteria", "true");
        }
        else{
            action.setParams({
                "searchkey":searchvalue
            });
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    component.set("v.userroleobject", a.getReturnValue());
                    var numbers = component.get("v.userroleobject");
                    if(numbers.length == 0){
                        document.getElementById(searchvaluee).style.display="Block";
                    }
                    
                } else if (a.getState() === "ERROR") { 
                    component.set("v.toggleerrorfromserver", "true");
                    $A.log("Errors", a.getError()); 
                }
                
            });
            component.set("v.spin",false);
            $A.enqueueAction(action);
        }
    },
    getuserrecord : function(component, event, helper){
        var action = component.get("c.gettuserrecord");
        var searchvalue = event.getSource().get("v.value");
        component.set("v.spin",true);
        action.setParams({
            "IDD":searchvalue
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.tableauuserobjectupdate", a.getReturnValue());
                var numbers = component.get("v.tableauuserobjectupdate");
                var rlsstring = [];
                if(numbers.TRole1UserName__c != null){rlsstring.push({"roleid": numbers.TRole1__c, "rolename": numbers.TRole1UserName__c});}
                if(numbers.TRole2UserName__c != null){rlsstring.push({"roleid": numbers.TRole2__c, "rolename": numbers.TRole2UserName__c});}
                if(numbers.TRole3UserName__c != null){rlsstring.push({"roleid": numbers.TRole3__c, "rolename": numbers.TRole3UserName__c});}
                
                component.set("v.rolesassigned", rlsstring);
                helper.evaluateupdatecheckboxnumbers(component, event, helper);
                
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
            
        });
        $A.enqueueAction(action);
        component.set("v.spin",false);
        helper.evaluateupdatecheckboxnumbers(component, event, helper);
        
    },
    
    updatecreatecheckifsfdcuser : function(component, event, helper){
        var action = component.get("c.udpdatetabrecord");
        var searchvalue = component.get("v.tableauuserobjectupdate");
        component.set("v.spin",true);
        action.setParams({
            "tabrecord":searchvalue
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    type:"success",
                    title: "Success !",
                    message: 'User has been successfully Updated !',
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                component.set("v.spin",false);
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
                component.set("v.spin",false);
            }
            
        });
        $A.enqueueAction(action);
        
    },
    updatetabrecordd : function(component, event, helper){
        
        var actionvalidate = component.get("c.checkifuserisfdc");
        var searchvalidate = component.get("v.tableauuserobjectupdate.UserQlookID__c");
        component.set("v.spin",true);
        
        actionvalidate.setParams({
            "searchkey":searchvalidate
        }); 
        actionvalidate.setCallback(this, function(av) {
            if (av.getState() === "SUCCESS") {
                if(av.getReturnValue() == true){
                    helper.updatecreatecheckifsfdcuser(component, event, helper);
                    component.set("v.spin",false);
                }
                if(av.getReturnValue() == false){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        type:"error",
                        title: "Error !",
                        message: 'User is not active Salesforce User !',
                    });
                    toastEvent.fire();
                    component.set("v.spin",false);
                    
                }
                
            }
            else if (av.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", av.getError()); 
            }
            
        });
        $A.enqueueAction(actionvalidate);
        
        
    },
    createcheckifsfdcuser : function(component, event, helper){
        
        var actionvalidate = component.get("c.validateifuserexist");
        var searchvalidate = component.get("v.UserQlookID__c");
        component.set("v.spin",true);
        
        actionvalidate.setParams({
            "searchkey":searchvalidate
        }); 
        actionvalidate.setCallback(this, function(av) {
            if (av.getState() === "SUCCESS") {
                if(av.getReturnValue() == true){
                    helper.createtabuser(component, event, helper);
                    component.set("v.spin",false);
                }
                if(av.getReturnValue() == false){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        type:"error",
                        title: "Error !",
                        message: 'User is not active Salesforce User !',
                    });
                    toastEvent.fire();
                    component.set("v.spin",false);
                    
                }
                
            }
            else if (av.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.spin",false);
                $A.log("Errors", av.getError()); 
            }
            
        });
        $A.enqueueAction(actionvalidate);
        
        
    },
    createrecords : function(component, event, helper){
        
        var actionvalidate = component.get("c.validateifuserexist");
        var searchvalidate = component.get("v.UserQlookID__c");
        component.set("v.spin",true);
        actionvalidate.setParams({
            "searchkey":searchvalidate
        }); 
        actionvalidate.setCallback(this, function(av) {
            if (av.getState() === "SUCCESS") {
                if(av.getReturnValue() == true){
                    component.set("v.spin",false);
                    helper.createcheckifsfdcuser(component, event, helper);
                }
                if(av.getReturnValue() == false){
                    component.set("v.spin",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        type:"error",
                        title: "Error !",
                        message: 'User already exist with this Qlook ID !',
                    });
                    toastEvent.fire();
                    
                }
                
            }
            else if (av.getState() === "ERROR") { 
                component.set("v.spin",false);
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", av.getError()); 
            }
            
        });
        $A.enqueueAction(actionvalidate);
        
        
    },
    createtabuser : function(component, event, helper){
        component.set("v.spin",true);
        var action = component.get("c.createtabrecordd");
        var searchvalue = component.get("v.tableauuserobjectinsert");
        var rolestring = [];
        rolestring = component.get("v.rolesassignedcreate");
        var TRole1 ;
        if(rolestring.length == 1){ TRole1= rolestring[0].roleid };
        var TRole2 ;
        if(rolestring.length == 2){ TRole1= rolestring[1].roleid };
        var TRole3 ;
        if(rolestring.length == 3){ TRole1= rolestring[2].roleid };
        action.setParams({
            "UserName":component.get("v.UserName__c"),
            "UserQlookID": component.get("v.UserQlookID__c"),
            "IfSFDCUser":component.get("v.IfSFDCUser__c"),
            "IsActive": component.get("v.IsActive__c"),
            "OwnershipAccess":component.get("v.OwnershipAccess__c"),
            "RoleLevelAccess": component.get("v.RoleLevelAccess__c"),
            "SalesOrgAccess": component.get("v.SalesOrgAccess__c"),
            "InteractorPublisher":component.get("v.InteractorPublisher__c"),
            "TRole1":TRole1,
            "TRole2":TRole2,
            "TRole3":TRole3
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                component.set("v.spin",false);
                toastEvent.setParams({
                    mode: 'sticky',
                    type:"success",
                    title: "Success !",
                    message: 'User has been successfully Updated !',
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                component.set("v.spin",false);
                $A.log("Errors", a.getError()); 
            }
            
        });
        $A.enqueueAction(action);
    },
    evaluateupdatecheckboxnumbers : function(component, event, helper){
        
        component.set("v.spin",true);
        var list = component.get("v.rolesassigned");
        if(list.length == 3){
            component.set("v.disablecheckboxupdate",true);
        }
        if(list.length > 3){
            component.set("v.disablecheckboxupdate",true);
        }
        if(list.length < 3){
            component.set("v.disablecheckboxupdate",false);
        }
        
        var list2 = component.get("v.rolesassignedcreate");
        if(list2.length == 3){
            component.set("v.disablecheckboxcreate",true);
        }
        if(list2.length > 3){
            component.set("v.disablecheckboxcreate",true);
        }
        if(list2.length < 3){
            component.set("v.disablecheckboxcreate",false);
        }
        component.set("v.spin",false);
        
    },

    scriptroleupdatehelper : function(component, event, helper)
    {
        var action = component.get("c.scriptgetnewroles");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                //component.set("v.checkaccess", a.getReturnValue());
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
    },  
    scriptrolenamehelper : function(component, event, helper)
    {
        var action = component.get("c.scriptupdatenewroles");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                //component.set("v.checkaccess", a.getReturnValue());
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
    },  
    updatescriptupdatehelper : function(component, event, helper)
    {
        var action = component.get("c.scriptcreaterolelevelscript");
        component.set("v.spin",true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                //component.set("v.checkaccess", a.getReturnValue());
            } else if (a.getState() === "ERROR") { 
                component.set("v.toggleerrorfromserver", "true");
                $A.log("Errors", a.getError()); 
            }
        });
        component.set("v.spin",false);
        $A.enqueueAction(action);
    },  
})