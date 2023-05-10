({
    doFilter : function(component, event, helper) {
        helper.doPagination(component, event);
    },
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var curPage = component.get("v.currentPage");
        if(curPage == 0 || component.get("v.isbulkUpdate")){
            if(curPage == 0 ){
                component.set("v.currentPage",1);
            }
            var searchString = component.get("v.SearchAccountSupport").toLowerCase();
            var action = component.get("c.getAPOCList");
            action.setParams({ 
                "searchString": searchString
            });
            action.setCallback(this,function(response){
                var state =  response.getState();
                console.log('state '+state);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                if(state = 'SUCCESS'){
                    component.set("v.AccountSupportListMain",response.getReturnValue());
                    var accList = component.get("v.AccountSupportListMain");
                    //console.log(JSON.stringify(accList[0].poroles));
                    accList.sort(function(a,b){
                        return new Date(b.chngDate) - new Date(a.chngDate);
                    });    
                    helper.doPagination(component, event);
                }
            });
            $A.enqueueAction(action);
        }
        else{
            helper.addUpdatedRecInList(component,event);
        }
        
        var action1 = component.get("c.getAllRoleNames");
        action1.setCallback(this,function(response){
            var state =  response.getState();
            console.log('state '+state);
            if(state = 'SUCCESS'){
                var rolenames = response.getReturnValue();
                rolenames.unshift('Select Role');
                component.set("v.ManageRoles",rolenames);
            }
        });
        $A.enqueueAction(action1);    
    },
    selectItem : function(component,event,helper){
        var selecctedItem = [];
        for(var selectedItem of component.get("v.AccountSupportList") ){
            if(selectedItem.isChecked){
                component.set("v.isdisabled",false);
                selecctedItem.push(selectedItem);
            }
        }
        console.log(JSON.stringify(selecctedItem));
        if(selecctedItem.length >0 && selecctedItem !='[]'){
            component.set("v.isdisabled",false);
        }else{
            component.set("v.isdisabled",true);
        }
    },
    
    reassignInBulk :function(component, event, helper) {
        component.set("v.showModal",true);
        component.set("v.isNew",false);
        var record =  component.get('v.AccountSupportList');
        var recordtoreassign = [];
        var obj;
        for(obj in record){
            if(record[obj].isChecked){
                recordtoreassign.push(record[obj].master);
            }
            
        }
        //alert('size of list '+recordtoreassign.length);
        component.set('v.recordToReassign',recordtoreassign);
        component.set("v.isbulkUpdate",true);
    },
    searchAccountSupport : function(component, event, helper) {
        var searchString = component.get("v.SearchAccountSupport").toLowerCase();
        var action = component.get("c.getAPOCList");
        /* Sushant Starts*/
        action.setParams({ 
            "searchString": searchString
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            console.log('state '+state);
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + 
                                errors[0].message);
                }
            } 
            if(state = 'SUCCESS'){
                component.set("v.AccountSupportListMain",response.getReturnValue());
               	component.set("v.currentPage",1);
                helper.doPagination(component, event);
                helper.sortHelper(component, event, 'accountName');
            }
        });
        
        $A.enqueueAction(action);
        /* Sushant Ends*/
        var currentTab = component.get("v.currentTab");
        var itemList;
        var originalList;
       
        if(currentTab =='tab-default-1__item'){
            itemList = component.get("v.AccountSupportListAssigned");
            originalList= component.get("v.AccountSupportListAssigned");
        }else if(currentTab =='tab-default-2__item'){
            itemList = component.get("v.AccountSupportListUnassignedASM");
            originalList = component.get("v.AccountSupportListUnassignedASM");
        }else if(currentTab =='tab-default-3__item'){
            itemList = component.get("v.AccountSupportListUnassignedPO");
            originalList = component.get("v.AccountSupportListUnassignedPO");
        }
        else{
        	itemList = component.get("v.AccountSupportListUnassignedCA");
            originalList = component.get("v.AccountSupportListUnassignedCA");
        }
        
        itemList = component.get("v.AccountSupportList");
        var newList = [];
        var item =0;
        var totalitem =itemList.length;
        console.log('totalitem '+totalitem);
        
        for ( item=0;item<totalitem;item++){
            var searchName = '';
            var searchMaster = '';
            //console.log('@@@@@@@@');
            searchName = itemList[item].accountName.toLowerCase();
            searchMaster = itemList[item].master.toLowerCase();
            if(searchString != null && searchString.length > 3 ){ 
                if(searchName.startsWith(searchString) || searchMaster.startsWith(searchString)){//
                    newList.push(itemList[item]);
                    //console.log('item in search ===> '+itemList[item]);
                }
            }
        }
        component.set('v.AccountSupportList',newList); 
        
        if(!searchString){ 
            component.set('v.AccountSupportList',originalList);  
        }
    },
    gotoDetail : function(component, event , helper){
        console.log('gotoDetials ');
        var indexvar = event.currentTarget.id;
        console.log("indexvar:::" + indexvar);
        helper.navigateDetailPage(component,event,indexvar);
    },
    showModal : function(component, event , helper){
        var buttonclicked = event.getSource().getLocalId();
        component.set("v.showModal",true);
        component.set('v.buttonName ',buttonclicked);
        if(event.getSource().getLocalId() == 'New'){
            component.set("v.isNew",true);
        }else{
            component.set("v.isNew",false);
        }
    },
    handleTab: function(component, event, helper){

        
        helper.handleTabHelper(component, event, helper);
    },
    /* handleTab : function(component, event, helper){
        var currentTab = component.get("v.currentTab");
        var cmpTargetRemove = component.find(currentTab);        
        $A.util.removeClass(cmpTargetRemove, 'tabActive');
        $A.util.removeClass(cmpTargetRemove, 'slds-is-active');
        
        var cmpTarget = component.find(event.target.id);
        $A.util.addClass(cmpTarget, 'tabActive');
        $A.util.addClass(cmpTarget, 'slds-is-active');
        component.set('v.SearchAccountSupport','');
        component.set("v.currentTab",event.target.id);
         //alert(event.target.id);
        component.set("v.currentPage",1);
        component.set("v.pageNumber",1); 
        if(event.target.id =='tab-default-1__item'){
            component.set("v.AccountSupportList",component.get("v.AccountSupportListAssigned"));
            //alert();
            component.set("v.isAsc",!component.get("v.isAsc"));
            helper.doPagination(component,event);
            //alert(!component.get("v.isAsc"));
            helper.sortHelper(component, event, 'accountName');
        }else if(event.target.id =='tab-default-2__item'){
            component.set("v.AccountSupportList",component.get("v.AccountSupportListUnassignedASM"));
            component.set("v.isAsc",!component.get("v.isAsc"));
            //alert();
            helper.doPagination(component,event);
            //alert(!component.get("v.isAsc"));
            helper.sortHelper(component, event, 'accountName');
        }else if(event.target.id =='tab-default-3__item'){
             component.set("v.AccountSupportList",component.get("v.AccountSupportListUnassignedPO"));
             component.set("v.isAsc",!component.get("v.isAsc"));
             //alert();
             helper.doPagination(component,event);
             // alert(!component.get("v.isAsc"));
             helper.sortHelper(component, event, 'accountName');
        }else{
            component.set("v.AccountSupportList",component.get("v.AccountSupportListUnassignedCA"));
            component.set("v.isAsc",!component.get("v.isAsc"));
            //alert();
            helper.doPagination(component,event);
            //alert(!component.get("v.isAsc"));
            helper.sortHelper(component, event, 'accountName');
        } 
        component.set("v.currentTab",event.target.id);
        //alert(event.target.id); 
      
    } */
    reassignByRow : function(component, event, helper){
        console.log('this is List '+JSON.stringify(component.get('v.AccountSupportList')));
        component.set("v.showModal",true);
        var rowIndex = event.getSource().get("v.tabindex");
        //alert('this is roles '+JSON.stringify(component.get('v.AccountSupportList')[0].poroles)); 
        var accRecord =  component.get('v.AccountSupportList')[rowIndex];
        component.set("v.accId",accRecord.accountId);
       // component.set("v.listIndex",rowIndex);
        console.log('this is '+accRecord.accountName+'/'+accRecord.master);
        component.set("v.accName",accRecord.accountName+'/'+accRecord.master);
        component.set("v.accMaster",accRecord.master);
        //alert(component.get("v.accMaster"));
        var PoRoles =  accRecord.poroles;
        var caRoles =  accRecord.caroles;
        var asmRoles = accRecord.asmroles;
        var otherRoles = accRecord.otherRoles; 
        //alert(accRecord.Id);
        var Asmhirachyobj  = {"userObj":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"selItem":{"val":null,"text":"",
			"ObjRecord":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/"},"Name":"","Id":"","Quicklook_ID__c":"","Phone":"","Email":""},"objName":"User"},
			"RoleName":"","Id" :"","Master" : "","AccountId" : ""};
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
        console.log('after  Ass '+JSON.stringify(Asmhirachy));
        component.set('v.ASMHirarchy',Asmhirachy);
        component.set('v.ASMHirarchy',Asmhirachy);
        if(event.getSource().getLocalId() == 'New'){
            component.set("v.isNew",true);
        }else{
            component.set("v.isNew",false);
        }
        //helper.PopulateUserRecord(component,event,asmQlId,POQlId,CAQlId);
        
        
    },
    
    sortAccounName : function(component, event, helper) {
        
        component.set("v.selectedTabsoft", 'accountName');
        
        helper.sortHelper(component, event, 'accountName');
    },
    sortMasterNumber : function(component, event, helper) {
        
        component.set("v.selectedTabsoft", 'master');
        //component.set("v.arrowDirection", 'arrowdown');
        //component.set("v.isAsc", false);
        helper.sortHelper(component, event, 'master');
    },
    selectAll : function(Component, Event, Helper){
        //alert();
        var accSupport =  Component.get('v.AccountSupportList');
        var isselectAll = Component.get('v.selectAllList');
        console.log('Is select All '+isselectAll);
        //alert();
        var obj ;
        var masterset=[];
        if(!isselectAll){
            if(accSupport.length>0){
                for(obj in accSupport){
                    
                    accSupport[obj].isChecked = true;
                    // console.log('is Checked '+JSON.stringify(accSupport[obj]));
                }
                Component.set("v.isdisabled",false);
            }
        }else{
            if(accSupport.length>0){
                for(obj in accSupport){
                    
                    accSupport[obj].isChecked = false;
                    // console.log('is Checked '+JSON.stringify(accSupport[obj]));
                }
                Component.set("v.isdisabled",true);
            }
        }
       //alert(JSON.stringify(masterset));
        Component.set('v.AccountSupportList',accSupport);
        console.log('this is true ');
    },
    
    prevPage : function(component,event,helper){
        component.set('v.spinner',true);
        var currentPage = parseInt(component.get('v.currentPage'))-1;
        
        
        component.set("v.currentPage",currentPage);
        component.set("v.pageNumber",currentPage);
        helper.doPagination(component,event);
        component.set('v.spinner',false);
    },
    
    gotopage : function(component,event,helper){
        // var currentpage = parseInt(component.get('v.currentPage'));
        component.set('v.spinner',true);
        var currentPage = component.get('v.pageNumber');
        
        component.set("v.currentPage",currentPage);
        helper.doPagination(component,event);
        component.set("v.isAsc", !component.get("v.isAsc"));
        helper.sortHelper(component, event, 'accountName');
        // component.set("v.AccountSupportList",showList);
        // component.set('v.spinner',false);
    },
    
    nextPage : function(component,event,helper){
        //alert();
        //component.set('v.spinner',true);
        var currentPage = parseInt(component.get('v.currentPage'))+1;
        // var currentPage = component.get("v.currentPage");
        component.set("v.currentPage",currentPage);
        component.set("v.pageNumber",currentPage);
        helper.doPagination(component,event);
        component.set('v.spinner',false);
    }
})