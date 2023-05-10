({
	getSolutionName : function(component, event, helper) {
		
	},
    getProductList : function(component, event, helper){
            var action = component.get("c.getProducts");
            action.setParams({  
                  SolutionId : component.get("v.selItem.val"),
                  recordId :   component.get("v.OppId")
             });
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    console.log(JSON.stringify(a.getReturnValue()));
                    component.set("v.prodname",a.getReturnValue());
                    component.set("v.noOfProductCount",a.getReturnValue().length);
                    console.log(component.get("v.noOfProductCount"));
                }
                else if (a.getState() === "ERROR") { 
                    $A.log("Errors", a.getError());
                }
            }); 
        $A.enqueueAction(action);
    },
    fireCheckAllCheckboxes : function(component, event, helper){
        var TheCheckBoxes = component.find("TheCheckBox");
        for (var i = 0; i < TheCheckBoxes.length; i++){
            TheCheckBoxes[i].set("v.value",true);
        }
    },
    fireUncheckAllCheckboxes : function(component, event, helper){
        var TheCheckBoxes = component.find("TheCheckBox");
        for (var i = 0; i < TheCheckBoxes.length; i++){
            TheCheckBoxes[i].set("v.value",false);
        }
    },
    sortProdList :function(component, event, helper){
        var favSch=[];
        var fav=[];
        var sch=[];
        var remaining=[];
        for (var i = 0; i < component.get("v.prodname").length; i++) {
            if(component.get("v.prodname")[i].favselected && component.get("v.prodname")[i].HasSchedule){
                favSch.push(component.get("v.prodname")[i]);
                component.get("v.prodname")[i].SetsortColor=true;
            }
            else if(component.get("v.prodname")[i].favselected){
                fav.push(component.get("v.prodname")[i]);
                //component.get("v.prodname")[i].SetsortColor=true;
            }else if(component.get("v.prodname")[i].HasSchedule){
                sch.push(component.get("v.prodname")[i]);
                component.get("v.prodname")[i].SetsortColor=true;
            }else{
                remaining.push(component.get("v.prodname")[i]);
                component.get("v.prodname")[i].SetsortColor=false;
            }
            
        }
        var newArray = [];
        
        newArray=newArray.concat(favSch);
        newArray=newArray.concat(fav);
        newArray=newArray.concat(sch);
        newArray=newArray.concat(remaining);          
        component.set("v.prodname", newArray);
        var  TheCheckBoxes= component.find("TheCheckBox"); 
        
        for (var i=0;i<TheCheckBoxes.length;i++){               
            TheCheckBoxes[i].set("v.value",false);
            
        }
        
    },
    SingleFavProduct :function(component,event,helper){
         var RenderProducts = component.get("v.prodname");
         var object=[];
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        var index;
        for (var i = 0; i < component.get("v.prodname").length; i++) {
            var str = component.get("v.prodname")[i].prd.Id;
            object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:component.get("v.prodname")[i].favselected};
            if(str.toUpperCase()==(idd.toUpperCase())){
                index=i;
                object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:false};
                //component.get("v.prodname")[i].favselected=false;
                break;
            }
        }
        
        RenderProducts.splice(index,1,object[index]);
        component.set("v.prodname",RenderProducts);

        var action = component.get("c.removeFavourite"); 
        action.setParams({ "ProductId": idd });		  
        action.setCallback(this, function(response){
            var state = response.getState();           
            if (state === "SUCCESS") 
            {
                var appEvent1 = $A.get("e.c:psaddfavEvent_PS");            	
                appEvent1.fire(); 
                //Adding success message
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Removed From Favorites Succesfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();  
                
            }
            
        });
        $A.enqueueAction(action);
        // sorting
        this.sortProdList(component, event, helper);
    },
    SingleUnFavProduct :function(component,event,helper){
        var RenderProducts = component.get("v.prodname");
		var index;
        var object=[];
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        
        for (var i = 0; i < component.get("v.prodname").length; i++) {
            object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:component.get("v.prodname")[i].favselected};
            var str = component.get("v.prodname")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                index=i;
                object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:true};
                //component.get("v.prodname")[i].favselected=true;
                break;
            }
        }  
        
        RenderProducts.splice(index,1,object[index]);
        component.set("v.prodname",RenderProducts);
        
        
        var action = component.get("c.addFavourite"); 
        action.setParams({ "ProductId": idd });
        action.setCallback(this, function(response){
            var state = response.getState();           
            if (state === "SUCCESS") 
                
            {
                var appEvent1 = $A.get("e.c:psaddfavEvent_PS");
                appEvent1.fire(); 
                //Adding success message
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Added to Favorites Succesfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();  
                
            }
            
        });
        
        $A.enqueueAction(action);
        // sorting
        this.sortProdList(component, event, helper);
    },
    SingleUnScheduleProduct :function(component,event,helper){
        debugger;
        console.log('single unschedule product');
         var RenderProducts = component.get("v.prodname");
		var index;
        var object=[];
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        
        
        for (var i = 0; i < component.get("v.prodname").length; i++) {
            object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:component.get("v.prodname")[i].favselected};
            var  str = component.get("v.prodname")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
              index = i;
               object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:true,favselected:component.get("v.prodname")[i].favselected};
                break;
            }
        }
       
        RenderProducts.splice(index,1,object[index]);
        console.log('added'+RenderProducts);
        component.set("v.prodname",RenderProducts);
        // sorting
        this.sortProdList(component, event, helper);
        
         if(component.get("v.ScreenName") == 'PS'){
            var appEvent = $A.get("e.c:InsertScheduleEvent");
            appEvent.setParams({
                "ProductIds" : idd});
            appEvent.fire();
         }else{
             var appEvent1 = $A.get("e.c:ceEvent");
            appEvent1.setParams({
                "ProductIds" : idd});
            appEvent1.fire(); 
         }
        
        var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
        FloatMsgEvent.setParams({
            "Msg" : "Product Is Added to Item to Schedule Succesfully.",
            "Category" : "Success",
            "isShow" : "True"
        });
        FloatMsgEvent.fire();
        
        //$A.enqueueAction(action);
    },
    SingleScheduleProduct :function(component,event,helper){
        debugger;
        console.log('single schedule product');
        var RenderProducts = component.get("v.prodname");
		var index;
        var object=[];
        var idd = component.get("v.unScheduleId") ; 
        
        for (var i = 0; i < component.get("v.prodname").length; i++) {
             object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:component.get("v.prodname")[i].favselected};
            var str = component.get("v.prodname")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                index=i;
                object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:false,favselected:component.get("v.prodname")[i].favselected};
                //component.get("v.prodname")[i].HasSchedule=false; 
                break;                  
            }
        }
        
       
        RenderProducts.splice(index,1,object[index]);
        component.set("v.prodname",RenderProducts);
        
         if(component.get("v.ScreenName") == 'PS'){
            var appEvent = $A.get("e.c:RemoveScheduleEvent");
            appEvent.setParams({
                "ProductIds" : idd});
            appEvent.fire();
         }else{
             var appEvent1 = $A.get("e.c:ceEventDelete");
            appEvent1.setParams({
                "ProductIds" : idd});
            appEvent1.fire();
         }
        
        
        var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
        FloatMsgEvent.setParams({
            "Msg" : "Product Removed From Scheduled Succesfully.",
            "Category" : "Success",
            "isShow" : "True"
        });
        FloatMsgEvent.fire(); 
        
        
        // sorting
        this.sortProdList(component, event, helper);
       
        document.getElementById('SolutionModal').style.display='none';
        document.getElementById('SolutiongreyBackground').style.display='none';
        // $A.enqueueAction(action);
    },
    bulkfavourite :function(component,event,helper){
        //debugger;
        var isfav=false;
        //var checkedProds = component.find( "TheCheckBox" );
        
        var prodIds = [];
        var favNew=[];
        var selectedprod = [];
        if(component.get("v.prodname").length == 1){
            var checkedProds = component.find( "TheCheckBox" );
            if(checkedProds.get("v.value")){
                selectedprod.push(checkedProds.get("v.text")); 
            }
        }else if(component.get("v.prodname").length >1){
            var checkedProds = component.find( "TheCheckBox" );
            for (var i = 0; i < checkedProds.length ; i++){
            
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push(checkedProds[i].get("v.text")); 
                
            }
          }
        }
        
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            //console.log(component.get("v.prodname").length);
            for (var k = 0; k <selectedprod.length ; k++){
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    if(component.get("v.prodname")[j].favselected==true){
                        continue;
                    }
                    else{
                        isfav=true;
                        break;
                    }     
                }
            }
            
        }
        //syncing prodname
        
        
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    component.get("v.prodname")[j].favselected=isfav;  
                }
            }                
        }
        
        // sorting
        this.sortProdList(component, event, helper);
        var allChk = component.find( "SelectAllCheckBox" );
        allChk.set("v.value",false);
        if(isfav){
            var appfavEventNew = $A.get("e.c:psaddfavEvent_PS");
            appfavEventNew.setParams({
                "ProductIds" : selectedprod
            });
            appfavEventNew.fire();
                
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Products Added to Favorite  Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire(); 
        }else {

            if(selectedprod.length<=0){ 
                var FloatMsgEventNew = $A.get("e.c:FloatMsgEvent");
                FloatMsgEventNew.setParams({
                    "Msg" : "Please select any product to Add or Remove from favorite List",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEventNew.fire();  
                
            }else{              
                           var appEventNew = $A.get("e.c:psdeletefavEvent_PS");
                            appEventNew.setParams({
                                "ProductIds" : selectedprod});
                            appEventNew.fire();
                           var FloatMsgEvent1 = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent1.setParams({
                                "Msg" : "Product Removed From Favorites Succesfully.",
                                "Category" : "Success",
                                "isShow" : "True"
                            });
                            FloatMsgEvent1.fire();
            } 
        }   
    },
    bulkSchedule :function(component,event,helper){

        var isfav=false;
        
        
        var prodIds = [];
        var favNew=[];
        var selectedprod = [];
        console.log('Wrapper'+component.get("v.prodname"));
        if(component.get("v.prodname").length == 1){
            var checkedProds = component.find( "TheCheckBox" );
            if(checkedProds[0]){
               if(checkedProds[0].get("v.value")){
                selectedprod.push(checkedProds[0].get("v.text")); 
              } 
            }
            else{
               if(checkedProds.get("v.value")){
                selectedprod.push(checkedProds.get("v.text")); 
              }  
            }
        }else if(component.get("v.prodname").length >1){
            var checkedProds = component.find( "TheCheckBox" );
            for (var i = 0; i < checkedProds.length ; i++){
            
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push(checkedProds[i].get("v.text")); 
                
            }
          }
        }
        
        console.log('selectedprod'+selectedprod);
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            //console.log(component.get("v.prodname").length);
            for (var k = 0; k <selectedprod.length ; k++){
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    if(component.get("v.prodname")[j].HasSchedule==true){
                        continue;
                    }
                    else{
                        isfav=true;
                        break;
                    }     
                }
            }
            
        }
        //syncing prodname
        
       
       
        
        var allChk = component.find( "SelectAllCheckBox" );
        allChk.set("v.value",false);
        if(isfav){
            if(component.get("v.ScreenName") == 'PS'){
                console.log("in screen"+component.get("v.ScreenName"));
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : selectedprod});
                appEvent.fire();
            }else{
                 console.log("in screen"+component.get("v.ScreenName"));
                var appEvent2 = $A.get("e.c:ceEvent");
                appEvent2.setParams({
                    "ProductIds" : selectedprod});
                appEvent2.fire();
            }
            
            
            
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Added to Schedule List Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();  
            // sorting
            
            
            for (var j = 0; j < component.get("v.prodname").length; j++) {
                for (var k = 0; k < selectedprod.length ; k++){  
                    if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                        component.get("v.prodname")[j].HasSchedule=isfav;  
                    }
                }                
            }
            
            
            this.sortProdList(component, event, helper);  
        }else {
            
            
            if(selectedprod.length<=0){ 
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Please select any product to Add or Remove from Scheduler List",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();  
                
            }else{
                //alert('enterelase');
                
                document.getElementById('SolutionBulkModal').style.display='block';
                
                component.set("v.bulkUnScheduleIds", selectedprod);
                if(selectedprod.length==1){
                    for (var j = 0; j < component.get("v.prodname").length; j++) {
                        for (var k = 0; k < selectedprod.length ; k++){  
                            if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                                component.set("v.ProductCount", component.get("v.prodname")[j].prd.Name);  
                                component.set("v.MessageDifference", true);
                            }
                        }                
                    }
                    
                }else{
                    component.set("v.ProductCount", selectedprod.length);
                    component.set("v.MessageDifference", false);
                }
                
            } 
        }
        
        
    },
    BulkunScheduleProduct:function(component,event,helper){
        //debugger;
        document.getElementById('SolutionBulkModal').style.display='None';
        //document.getElementById("grayoutbackground").style.display = "block";
        
          if(component.get("v.ScreenName") == 'PS'){
                var appEvent = $A.get("e.c:RemoveScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : component.get("v.bulkUnScheduleIds")});
                appEvent.fire();
          }else{
              var appEvent2 = $A.get("e.c:ceEventDelete");
                appEvent2.setParams({
                    "ProductIds" : component.get("v.bulkUnScheduleIds")
                    
                });
                appEvent2.fire();
          }

        var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
        FloatMsgEvent.setParams({
            "Msg" : "Product Removed From Schedule List Succesfully.",
            "Category" : "Success",
            "isShow" : "True"
        });
        FloatMsgEvent.fire(); 
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < component.get("v.bulkUnScheduleIds").length ; k++){  
                if(component.get("v.bulkUnScheduleIds")[k] == component.get("v.prodname")[j].prd.Id){  
                    component.get("v.prodname")[j].HasSchedule=false;  
                }
            }                
        }
        this.sortProdList(component, event, helper);
        
    }
})