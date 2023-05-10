({
	navigateDetailPage : function(component,event,index){
        var record = component.get("v.AccountSupportList");
        var id = record[index].accountId;
        console.log('id '+id);
        console.log('Id of account '+id);
        
        var navEvt = $A.get("e.force:navigateToSObject");
       // alert('this is navigtion '+navEvt);
        navEvt.setParams({
            "recordId": id,
            "slideDevName": "detail"
        });
        navEvt.fire();        
    },
    filterList : function(component){
        //alert('filterList');
         component.set("v.spinner", true);
        var currentTab = component.get("v.currentTab");
        var accountList = component.get("v.AccountSupportListMain");
        //alert(JSON.stringify(accountList));
        var assignedList=[];
        var unAssignedASM=[];
        var unAssignedPO = [];
        var unAssignedCA =[];
        console.log('this is the size of total record '+accountList.length);
        for(var obj in accountList){
            console.log('obj'+JSON.stringify(accountList[obj]));
            if(accountList[obj]){
            assignedList.push(accountList[obj]);
            if(!accountList[obj].asmroles){
                unAssignedASM.push(accountList[obj]);
            }
            /*if(!accountList[obj].poroles){
                unAssignedPO.push(accountList[obj]);
            }*/
             if(!accountList[obj].caroles){
                unAssignedCA.push(accountList[obj]);
             }
            }
        }
        console.log('this is the size of total record 123 ==>  '+accountList.length);
       //	component.set("v.AccountSupportList",assignedList);
       //	
       //Made active by Sushant
       	component.set("v.AccountSupportListAssigned",assignedList);
        component.set("v.AccountSupportListUnassignedASM",unAssignedASM);
        component.set("v.AccountSupportListUnassignedPO",unAssignedPO);
        component.set("v.AccountSupportListUnassignedCA",unAssignedCA);
        var originalList=[];
        if(currentTab =='tab-default-1__item'){
            //originalList= component.get("v.AccountSupportListAssigned");
            component.set('v.AccountSupportList',assignedList);  
        }
        else if(currentTab =='tab-default-2__item'){
            //originalList = component.get("v.AccountSupportListUnassignedASM");
            component.set('v.AccountSupportList',unAssignedASM); 
        }
        /*else if(currentTab =='tab-default-3__item'){
            //originalList = component.get("v.AccountSupportListUnassignedPO");
            component.set('v.AccountSupportList',unAssignedPO); 
        }*/else{
            //originalList = component.get("v.AccountSupportListUnassignedCA");
            component.set('v.AccountSupportList',unAssignedCA); 
        }
        console.log('this is accoul support list for pegination '+JSON.stringify(assignedList[0]));
        //component.set('v.AccountSupportList',originalList);  
        component.set("v.spinner", false);  
    },
    
    
    sortHelper: function(component, event, field) {
      var arrowDirection = component.get("v.arrowDirection");
      var sortAsc = component.get("v.isAsc");  
      var sortField = component.get("v.selectedTabsoft");
        if(arrowDirection =='arrowup'){
            component.set("v.arrowDirection", 'arrowdown');
        }else{
            component.set("v.arrowDirection", 'arrowup');
        }
         
         //alert(component.get('v.AccountSupportList').length);
         var acc =  component.get('v.AccountSupportList');
         sortAsc = field == sortField? !sortAsc: true;
          acc.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        console.log('after sort '+JSON.stringify(acc));
        component.set("v.isAsc", sortAsc);
        //alert();
        //component.set("v.sortField", field);
        component.set('v.AccountSupportList',acc); 
        
       /*var sortAsc = component.get("v.isAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.records");
        sortAsc = field == sortField? !sortAsc: true;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.records", records);*/ 
      // call the onLoad function for call server side method with pass sortFieldName 
      
   },
    
    doPagination :  function(component,event){
        //alert('do pagibnation ');
        this.filterList(component);
        var accountList =component.get("v.AccountSupportList");
       //alert('l  '+accountList.length);
      
        var currentPage = component.get('v.currentPage');
        //alert('do pagibnation ');
        var pageSize = component.get('v.pageSize');
        var start = (currentPage-1)*pageSize;
        
        var showList =[];
        //var QlookId=accountList[0].QuickLookId;
        //alert('l  '+accountList.length);
        //alert('Current page '+currentPage*pageSize);
        for(start;currentPage*showList.length!=currentPage*pageSize;start++){
            
            if(accountList.length>start  ){
                
               // if(((QlookId == accountList[start].accSupport.PO_QLookId__c || QlookId == accountList[start].accSupport.CA_QuickLookId__c) || (accountList[start].accSupport.PO_QLookId__c   ==''  || accountList[start].accSupport.CA_QuickLookId__c =='' ))){
                    showList.push(accountList[start]); 
                    
                //}else if((QlookId == 'sm185526'||QlookId == 'ms185338' ||QlookId == 'tp124852' ||QlookId == 'sf250195')){
                    //showList.push(accountList[start]); 
                //}
                
            }else{
                
                break;
            }
            
        }
        
        component.set("v.totalPage",Math.ceil(accountList.length/component.get("v.pageSize")));
        if( component.get("v.totalPage") == 1)
            component.set("v.pageNumber",1);
        console.log('this is current page '+currentPage);
        console.log('this is component.get("v.totalPage") '+component.get("v.totalPage"));
        component.set("v.AccountSupportList",showList);
      	//alert('jkj '+showList.length);
        if(showList.length<=0){
            component.set("v.isNextDisabled",true);
        }
        else{
            component.set("v.isNextDisabled",false);
        }
        component.set("v.isdisabled",true);
        component.set("v.selectRole",true); 
        component.set("v.selectAllList",false);
        component.set("v.spinner", false);
        //console.log("start "+start);
        //component.set("v.AccountSupportList",showList);
        //alert('filtser class');
        //this.filterList(component,showList,accountList[0].QuickLookId,event);
    },
    
     handleTabHelper : function(component, event, helper){

        var currentTab = component.get("v.currentTab");
        var cmpTargetRemove = component.find(currentTab);        
        $A.util.removeClass(cmpTargetRemove, 'tabActive');
        $A.util.removeClass(cmpTargetRemove, 'slds-is-active');
        
        var cmpTarget = component.find(event.target.id);
        $A.util.addClass(cmpTarget, 'tabActive');
        $A.util.addClass(cmpTarget, 'slds-is-active');
        //component.set('v.SearchAccountSupport','');
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
      
    },
    addUpdatedRecInList : function(component,event){
        var aId = component.get("v.accId");
        console.log('aId'+aId);
         var action = component.get("c.getAPOCRcrd");
        action.setParams({
            accId : aId,
            allrole : false
        });
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                		var acc =response.getReturnValue(); 
                     	console.log('acc'+JSON.stringify(acc));	
                        var accList =  component.get("v.AccountSupportListMain");
                    	var index = accList.indexOf(accList.find(function(item) { return item.accountId === aId }));
                    	console.log('listIndex'+index);
                        accList.splice(index,1,acc[0]);
                        console.log('accList'+JSON.stringify(accList));
                        component.set("v.AccountSupportListMain",accList);
                        this.doPagination(component, event);
                     
                }
            }
        });
        $A.enqueueAction(action);  
    },
   
})