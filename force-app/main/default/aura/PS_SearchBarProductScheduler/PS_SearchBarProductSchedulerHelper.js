({
    
    searchProducts: function(component) {
        component.set("v.ToogleSpinner",'slds-show');
        var action = component.get("c.getPrdrecords");
        action.setParams({                    
            "recordId" :component.get("v.passId")
        });
        action.setCallback(this, function(a) {
            
            component.set("v.prodname", a.getReturnValue());
            component.set("v.prodname2", component.get("v.prodname"));
            component.set("v.prodnameFltr", component.get("v.prodname"));
            
            //document.getElementById("searchwindow").style.display = "block";
            //document.getElementById("grayoutbackground").style.display = "block";
            
            component.set("v.ShowProduct",true);
            component.set("v.ToogleSpinner",'slds-hide');
            //document.getElementById("spinnerdiv").style.display = "None";
            if(component.get("v.Session") === 'Closed' && component.get("v.StoreDivisionAfterClose").length>0){
            var fltMsg = component.find( "clearbutton" );
            $A.util.addClass( fltMsg, "slds-show" );
             var TheDivCheckBox = component.find("inpcheckboxDiv");
            var DivArray = new Array();
            for(var i=0; i<component.get("v.StoreDivisionAfterClose").length;i++){
                DivArray.push(component.get("v.StoreDivisionAfterClose")[i]);
                    for (var j = 0; j < TheDivCheckBox.length ; j++){ 
                        //alert('checkbox name'+TheDivCheckBox[i].get("v.name"));
                        //alert('stored name'+component.get("v.StoreDivisionAfterClose")[i]);
                        if(TheDivCheckBox[j].get("v.name") === component.get("v.StoreDivisionAfterClose")[i]){                                 
                            TheDivCheckBox[j].set("v.value",true);  
                            //alert('set check'); 
                        }
                   }
            }
          component.set("v.ToogleSpinner",'slds-hide');       
          component.set("v.filterArray",DivArray); 
          component.set("v.tempfilterArray",DivArray);
          component.set("v.filter", true);
                
          
        }
            
        })
        
        //document.getElementById("spinnerdiv").style.display = "block";
        $A.enqueueAction(action);
    },
    
    CancelProductSearch:function(component){
        //Start of Close
        var Empty = new Array();
        component.set("v.filterArray",Empty);
        component.set("v.tempfilterArray",Empty);
        component.find("GetSearchtext").set("v.value",'');
        component.set("v.filter", false);
        component.set("v.Session", 'Closed');
        var fltMsg = component.find( "clearbutton" );            
        $A.util.removeClass( fltMsg, "slds-show" );
        $A.util.addClass( fltMsg, "slds-hide" );
        var TheCatCheckBox = component.find("inpcheckboxCat");       
        /*for (var i = 0; i < TheCatCheckBox.length ; i++){          
            if(TheCatCheckBox[i].get("v.value")){                                  
                TheCatCheckBox[i].set("v.value",false);
            }
        }
        
        var TheDivCheckBox = component.find("inpcheckboxDiv");
        for (var i = 0; i < TheDivCheckBox.length ; i++){             
            if(TheDivCheckBox[i].get("v.value")){                                 
                TheDivCheckBox[i].set("v.value",false);                  
            }
        }*/
        //End of Close
        //component.set("v.ModalControll", false);
        //document.getElementById('searchwindow').style.display='None';
        //document.getElementById('grayoutbackground').style.display='None';
        component.set("v.ShowProduct",false);
    },
    SearchFilterProducts:function(component,event, helper){
        var action = component.get("c.SearchFilteredProducts");
        var getFilterName = component.get("v.filterArray");
        
        action.setParams({
            "filterSelected":getFilterName,
            "searchKey": component.get("v.srchKey"),
            "recordId" :component.get("v.passId")
        });
        // sorting
        this.sortProdList(component, event, helper);
        action.setCallback(this, function(a) {
            component.set("v.prodname", a.getReturnValue());
            document.getElementById("spinnerdiv").style.display = "none";
        });
        document.getElementById("spinnerdiv").style.display = "block";
        $A.enqueueAction(action);
    },
    
    ClearAllFilters:function(component,event, helper){
        //remove all pills
        var Empty = new Array();
        component.set("v.filterArray",Empty);
        component.set("v.tempfilterArray",Empty);
        component.find("GetSearchtext").set("v.value",'');
        //var myEvent = $A.get("e.c:removeSearchText");
        
        //myEvent.fire();        //End of logic to remove pills
        //uncheck all checkboxes
        var TheCatCheckBox = component.find("inpcheckboxCat");       
        for (var i = 0; i < TheCatCheckBox.length ; i++){          
            if(TheCatCheckBox[i].get("v.value")){                                  
                TheCatCheckBox[i].set("v.value",false);
            }
        }
        
        var TheDivCheckBox = component.find("inpcheckboxDiv");
        for (var i = 0; i < TheDivCheckBox.length ; i++){             
            if(TheDivCheckBox[i].get("v.value")){                                 
                TheDivCheckBox[i].set("v.value",false);                  
            }
        }
        //End of logic to uncheck all checkboxes
        //Start logic to hide Clear Filter/Filters button
        var size = component.get("v.filterArray");
        if(size.length <= 0){
            component.set("v.filter", false);
           document.getElementById("spinnerdiv").style.display = "block";
            var action = component.get("c.SearchFilteredProducts");		
            action.setParams({		
            "filterSelected":component.get("v.filterArray"),		
            "searchKey": component.find("GetSearchtext").get("v.value"),		
            "recordId" :component.get("v.passId")		
            });         
            action.setCallback(this, function(a) {                
                var fltMsg = component.find( "clearbutton" );            
                $A.util.removeClass( fltMsg, "slds-show" );
                $A.util.addClass( fltMsg, "slds-hide" );
                component.set("v.body", ""); 
                component.set("v.prodname",a.getReturnValue());
                component.set("v.prodname2",a.getReturnValue());
                document.getElementById("spinnerdiv").style.display = "none";
                //Adding success message
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "All filters are removed.",
                    "Category" : "Success",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire(); 
                // sorting
                this.sortProdList(component, event, helper);
            }); 
            $A.enqueueAction(action); 
            
        }
        
        //End logic to hide Clear Filter/Filters button
    },
    allFilterbox : function(component) {
        document.getElementById("ModalWithFilters").style.display = "block";
    },
    getPiclkistvalues : function(component) {
        var action = component.get("c.getPrdCategorypickval");
        
        action.setCallback(this, function(a) {
            component.set("v.PrdCategorypickval",a.getReturnValue());    
        });
        $A.enqueueAction(action);        
    },
    getDivisionvalues : function(component) {
        var action = component.get("c.getPrdDivisionvalues"); 
        action.setCallback(this, function(response){
            var state = response.getState();           
            if (state === "SUCCESS") 
            {
               component.set("v.PrdDivisionval", response.getReturnValue());
                var item = new Array();
                var item1 = new Array();
                for(var i=0;i<response.getReturnValue().length;i++){		
                    if(response.getReturnValue()[i].selected){		
                        component.set("v.filter", true);		
                        item.push('Industry: '+response.getReturnValue()[i].FilterName);		
                        item1.push('Industry: '+response.getReturnValue()[i].FilterName);		
                    }		
                }		
                if(item.length>0){		
                     var fltMsg = component.find( "clearbutton" );		
                     $A.util.addClass( fltMsg, "slds-show" );		
                }		
                component.set("v.filterArray",item);		
                component.set("v.tempfilterArray",item);
                component.set("v.StoreDivisionAfterClose",item1);
            }   
        });
        $A.enqueueAction(action); 
        
    },
    fireCheckAllCheckboxes : function(component, event, helper){
        if(component.get( "v.prodname").length>0){
           var TheCheckBoxes = component.find("TheCheckBox");
            for (var i = 0; i < TheCheckBoxes.length; i++){
                TheCheckBoxes[i].set("v.value",true);
            } 
        }
 
    },
    fireUncheckAllCheckboxes : function(component, event, helper){
        if(component.get( "v.prodname").length>0){
           var TheCheckBoxes = component.find("TheCheckBox");
            for (var i = 0; i < TheCheckBoxes.length; i++){
                TheCheckBoxes[i].set("v.value",false);
            } 
        }
        
    },    
    RemovePill: function(component, event, helper){
        //var target = component.get("v.filterArray");//getting values in array
        var idx = event.currentTarget;
        var idd=idx.dataset.ids; 
        var fidx=component.get("v.filterArray").indexOf(idd);
        if (fidx>= 0) {
            component.get("v.filterArray").splice(fidx,1);                
        }
        component.set("v.filterArray", component.get("v.filterArray"));
        //this code is to enable Clear filter button and filter by text  
        var size = component.get("v.filterArray");
        if(size.length <= 0){
            component.set("v.filter", false);
            var fltMsg = component.find( "clearbutton" );
            $A.util.removeClass( fltMsg, "slds-show" );
            $A.util.addClass( fltMsg, "slds-hide" );
            component.set("v.body", ""); 
        }
        var TheCatCheckBox = component.find("inpcheckboxCat");       
        for (var i = 0; i < TheCatCheckBox.length ; i++){          
            if(TheCatCheckBox[i].get("v.name") === idd){ 
                TheCatCheckBox[i].set("v.value",false);
                //$A.get('e.force:refreshView').fire();
            }
        }
        
        var TheDivCheckBox = component.find("inpcheckboxDiv");
        for (var i = 0; i < TheDivCheckBox.length ; i++){
            if(TheDivCheckBox[i].get("v.name") === idd){                                 
                TheDivCheckBox[i].set("v.value",false);   
            }
        }
        // sorting
        // this.sortProdList(component, event, helper);
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
        //synching prodname2
        /*for (var i = 0; i < component.get("v.prodname2").length; i++) {
            
            var str = component.get("v.prodname2")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                component.get("v.prodname2")[i].favselected=false;
                break;
            }
        }*/
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
    sortProdList :function(component, event, helper){
        if(component.get("v.prodname").length ==0){
            return;
        }
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
    
    SingleUnFavProduct :function(component,event,helper){
        var RenderProducts = component.get("v.prodname");
		var index;
        var object=[];
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        document.getElementById("spinnerdiv").style.display = "block";
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
        
        //synching prodname2
        /*for (var i = 0; i < component.get("v.prodname2").length; i++) {
            var str = component.get("v.prodname2")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                component.get("v.prodname2")[i].favselected=true;
                break;
            }
        }*/
        RenderProducts.splice(index,1,object[index]);
        component.set("v.prodname",RenderProducts);
        
        document.getElementById("spinnerdiv").style.display = "None";
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
    SingleScheduleProduct :function(component,event,helper){
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
        
        /*for (var i = 0; i < component.get("v.prodname2").length; i++) {
            var str = component.get("v.prodname2")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                component.get("v.prodname2")[i].HasSchedule=false;                   
            }
        }*/
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
        document.getElementById("spinnerdiv").style.display = "None";
        document.getElementById('Modal').style.display='none';
        document.getElementById('greyBackground').style.display='none';
        document.getElementById('searchwindow').style.zIndex="9001";
        
        
        
        // $A.enqueueAction(action);
    },
    SingleUnScheduleProduct :function(component,event,helper){
         var RenderProducts = component.get("v.prodname");
		var index;
        var object=[];
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        
        document.getElementById("spinnerdiv").style.display = "block";
        
        for (var i = 0; i < component.get("v.prodname").length; i++) {
            object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:component.get("v.prodname")[i].HasSchedule,favselected:component.get("v.prodname")[i].favselected};
            var  str = component.get("v.prodname")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
              index = i;
               object[i] = {prd:component.get("v.prodname")[i].prd,ProductName:component.get("v.prodname")[i].ProductName,isselected:component.get("v.prodname")[i].isselected,Hasmultiple:component.get("v.prodname")[i].Hasmultiple,HasSchedule:true,favselected:component.get("v.prodname")[i].favselected};
                //component.get("v.prodname")[i].HasSchedule=true;
                //component.get("v.prodname2")[i].HasMultiple=false;
                break;
            }
        }
       
        /*for (j = 0; j < component.get("v.prodname2").length; j++) {
            var  str = component.get("v.prodname2")[j].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                component.get("v.prodname2")[j].HasSchedule=true;
                component.get("v.prodname2")[j].HasMultiple=false;
                
                break;
            }
        }*/
        RenderProducts.splice(index,1,object[index]);
        component.set("v.prodname",RenderProducts);
        // sorting
        this.sortProdList(component, event, helper);
        document.getElementById("spinnerdiv").style.display = "None"; 
        
        if(component.get("v.ScreenName") == 'PS'){
            var appEvent = $A.get("e.c:InsertScheduleEvent");
            appEvent.setParams({
                "ProductIds" : idd});
            appEvent.fire();
        }
        else{
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
    
    bulkfavourite :function(component,event,helper){
        var isfav=false;
        var checkedProds = component.find( "TheCheckBox" );
        
        var prodIds = [];
        var favNew=[];
        var selectedprod = [];
        for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push(checkedProds[i].get("v.text")); 
                
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
        
        for (var j = 0; j < component.get("v.prodname2").length; j++) {
            // console.log(component.get("v.prodname2").length);
            for (var k = 0; k <selectedprod.length ; k++){
                if(selectedprod[k] == component.get("v.prodname2")[j].prd.Id){  
                    if(component.get("v.prodname2")[j].favselected==true){
                        continue;
                    }
                    else{
                        isfav=true;
                        break;
                    }     
                }
            }
            
        }
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    component.get("v.prodname")[j].favselected=isfav;  
                }
            }                
        }
        for (var j = 0; j < component.get("v.prodname2").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname2")[j].prd.Id){  
                    component.get("v.prodname2")[j].favselected=isfav;  
                }
            }                
        }
        // sorting
        this.sortProdList(component, event, helper);
        var allChk = component.find( "SelectAllCheckBox" );
        allChk.set("v.value",false);
        if(isfav){
            var appfavEvent = $A.get("e.c:psaddfavEvent_PS");
            appfavEvent.setParams({
                "ProductIds" : selectedprod
            });
            appfavEvent.fire();
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Added to Favorites Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();  
            
        }else {
            
            var appEvent = $A.get("e.c:psdeletefavEvent_PS");
            appEvent.setParams({
                "ProductIds" : selectedprod});
            appEvent.fire();
            
            if(selectedprod.length<=0){ 
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Please select any product to Add or Remove from favorite List",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();  
                
            }else{
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Removed From Favorites Succesfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();  
            } 
        }
        
        
    },
    
    /* bulkSchedule :function(component,event,helper){
        var isSchedule=false;
        var isRun=false;
        var checkedProds = component.find( "TheCheckBox" );
        var prodIds = [];
        var scheduleNew=[];
        var multipleProducts=[];
        var multipleProducts1=[];
        
        var allChk = component.find("SelectAllCheckBox");
        for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                prodIds.push(checkedProds[i].get("v.text"));  
            }
        }
        
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < prodIds.length ; k++){  
                if(prodIds[k] == component.get("v.prodname")[j].prd.Id){ 
                    if(component.get("v.prodname")[j].HasSchedule==true){
                        continue;
                    }
                    else{
                        isSchedule=true;
                        break;
                    }                           
                }
            }              
        }
        
         for (var j = 0; j < component.get("v.prodname2").length; j++) {
            for (var k = 0; k < prodIds.length ; k++){  
                if(prodIds[k] == component.get("v.prodname2")[j].prd.Id){ 
                    if(component.get("v.prodname2")[j].HasSchedule==true){
                        continue;
                    }
                    else{
                        isSchedule=true;
                        break;
                    }                           
                }
            }              
        }
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < prodIds.length ; k++){  
                if(prodIds[k] == component.get("v.prodname")[j].prd.Id ){   
                    //alert('falseset');
                    component.get("v.prodname")[j].HasSchedule=isSchedule; 
                }
            }              
        }
        for (var j = 0; j < component.get("v.prodname2").length; j++) {
            for (var k = 0; k < prodIds.length ; k++){  
                if(prodIds[k] == component.get("v.prodname2")[j].prd.Id ){   
                    //alert('falseset');
                    component.get("v.prodname2")[j].HasSchedule=isSchedule; 
                }
            }              
        }
        // sorting
        this.sortProdList(component, event, helper); 
        
        if(isSchedule){
            // alert('alreadyscheduled');
            var appEvent = $A.get("e.c:InsertScheduleEvent");
            appEvent.setParams({
                "ProductIds" : prodIds});
            appEvent.fire();
            
            var appEvent = $A.get("e.c:ceEvent");
            appEvent.setParams({
                "ProductIds" : prodIds});
            appEvent.fire();
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Is Added to Item to Schedule Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
        else{ 
            
            if(prodIds.length<=0){
                // alert('enterfire');
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Please select any product to Add or Remove from schedule List",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();  
            }
            else{
                
                for (var j = 0; j < component.get("v.prodname").length; j++) {
                    for (var k = 0; k < prodIds.length ; k++){  
                        if(prodIds[k] == component.get("v.prodname")[j].prd.Id && component.get("v.prodname")[j].Hasmultiple==true){ 
                            component.get("v.prodname")[j].HasSchedule=true;
                            multipleProducts.push(component.get("v.prodname")[j].ProductName);
                            
                            for (var i = 0; i <multipleProducts.length; i++) {
                                multipleProducts1.push(multipleProducts[i].toUpperCase());
                                
                                isRun=true;
                            }
                        }
                    }              
                }
                this.sortProdList(component, event, helper);  
                if(isRun==true){
                    
                    // alert('firemultilpmethod');
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Multiple Instances found for Product  " +multipleProducts1+". Use Item to Schedule Section to Unschedule this Product",
                        "Category" : "Error",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire(); 
                    //this.sortProdList(component, event, helper);   
                }
                else{
                    isRun=false;
                    var appEvent = $A.get("e.c:RemoveScheduleEvent");
                    appEvent.setParams({
                        "ProductIds" : prodIds});
                    appEvent.fire();
                    var appEvent = $A.get("e.c:ceEventDelete");
                    appEvent.setParams({
                        "ProductIds" : prodIds});
                    appEvent.fire();                
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Is Removed From Item to Schedule Succesfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();
                    var checkedProds = component.find( "TheCheckBox" );
                    for (var i=0;i<checkedProds.length;i++){  
                        TheCheckBoxes[i].set("v.value",false);
                    }
                    
                }
            }
            
        } 
        var checkedProds = component.find( "SelectAllCheckBox" );
        allChk.set("v.value",false);
        
    },
*/
    
    bulkSchedule :function(component,event,helper){
        var isfav=false;
        var checkedProds = component.find( "TheCheckBox" );
        
        var prodIds = [];
        var favNew=[];
        var selectedprod = [];
        for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push(checkedProds[i].get("v.text")); 
                
            }
        }
        
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
        
        for (var j = 0; j < component.get("v.prodname2").length; j++) {
            // console.log(component.get("v.prodname2").length);
            for (var k = 0; k <selectedprod.length ; k++){
                if(selectedprod[k] == component.get("v.prodname2")[j].prd.Id){  
                    if(component.get("v.prodname2")[j].HasSchedule==true){
                        continue;
                    }
                    else{
                        isfav=true;
                        break;
                    }     
                }
            }
            
        }
        /*for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    component.get("v.prodname")[j].HasSchedule=isfav;  
                }
            }                
        }*/
        /*for (var j = 0; j < component.get("v.prodname2").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname2")[j].prd.Id){  
                    component.get("v.prodname2")[j].HasSchedule=isfav;  
                }
            }                
        }*/
        
        var allChk = component.find( "SelectAllCheckBox" );
        allChk.set("v.value",false);
        if(isfav){
            if(component.get("v.ScreenName") == 'PS'){
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : selectedprod});
                appEvent.fire();
            }else{
                var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                  "ProductIds" : selectedprod});
                appEvent.fire();
            }
            
            
            
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Added to Schedule List Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();
            // sorting
            
            document.getElementById("spinnerdiv").style.display = "none";
            
            for (var j = 0; j < component.get("v.prodname").length; j++) {
                for (var k = 0; k < selectedprod.length ; k++){  
                    if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                        component.get("v.prodname")[j].HasSchedule=isfav;  
                    }
                }                
            }
            
            for (var j = 0; j < component.get("v.prodname2").length; j++) {
                for (var k = 0; k < selectedprod.length ; k++){  
                    if(selectedprod[k] == component.get("v.prodname2")[j].prd.Id){  
                        component.get("v.prodname2")[j].HasSchedule=isfav;  
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
                
                document.getElementById('BulkModal').style.display='block';
                document.getElementById('searchwindow').style.zIndex="100";
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
                /*var appEvent = $A.get("e.c:RemoveScheduleEvent");
                    appEvent.setParams({
                        "ProductIds" : selectedprod});
                    appEvent.fire();
                    var appEvent = $A.get("e.c:ceEventDelete");
                    appEvent.setParams({
                        "ProductIds" : selectedprod});
                    appEvent.fire();
               var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Removed From Schedule List Succesfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire(); 
                */
            } 
        }
        
        
    },
    BulkunScheduleProduct:function(component,event,helper){
        document.getElementById('BulkModal').style.display='None';
        document.getElementById("searchwindow").style.display = "block";
        document.getElementById('searchwindow').style.zIndex="9001";
        document.getElementById("grayoutbackground").style.display = "block";
        
        if(component.get("v.ScreenName") == 'PS'){
            var appEvent = $A.get("e.c:RemoveScheduleEvent");
            appEvent.setParams({
                "ProductIds" : component.get("v.bulkUnScheduleIds")});
            appEvent.fire();
        }else{
            var appEvent = $A.get("e.c:ceEventDelete");
             appEvent.setParams({
               "ProductIds" : component.get("v.bulkUnScheduleIds")
            
             });
             appEvent.fire();
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
        
    },
    
    addSchedule :function(component,event,helper){
        
        //document.getElementById('searchwindow').style.display='None';
        //document.getElementById('grayoutbackground').style.display='None';
        var isSchedule=false;
        
        
        var prodIds = [];
        var scheduleNew=[];
        if(component.get( "v.prodname").length>0){
           var checkedProds = component.find( "TheCheckBox" ); 
            for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                prodIds.push(checkedProds[i].get("v.text"));  
            }
          }
        }
        
        if(prodIds.length>0){
            
            
            if(component.get("v.ScreenName") == 'PS'){
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : prodIds});
                appEvent.fire();
            }else{
                 var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                    "ProductIds" : prodIds});
                appEvent.fire();
            }
           
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Added To Schedule Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            document.getElementById('searchwindow').style.display='None';
            document.getElementById('grayoutbackground').style.display='None';
        }
        else{
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "No product is selected to make schedule,Please select the products from list.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();  
            component.set("v.ModalControll", false);
            //document.getElementById('searchwindow').style.display='block';
            
            //document.getElementById('grayoutbackground').style.display='block';
            
        }  
    },
    AddToBundle : function(component,event,helper){
 
        var checkedProds = component.find( "TheCheckBox" );
        var selectedprod = [];
        for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push({Id:checkedProds[i].get("v.text"),Name:checkedProds[i].get("v.name"),SelectstatusForProduct : false});
               //alert(checkedProds[i].get("v.name"));
            }
        }
        
        if(selectedprod.length>0){
            //alert(component.get("v.ToggelBundleComponent"));
            component.set("v.SelectedProductForBundle",selectedprod);
            //alert(component.get("v.passId"));
            helper.CreateAddProductToBundle(component,event,helper,selectedprod,component.get("v.passId"));
            
            
        }
        
        else{
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "No product is selected,Please select the products from list.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire(); */
            var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No product is selected,Please select the products from list.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
            
        }
    },
    
    AddToBundleForRefresh:function(component,event,helper){
        var checkedProds = component.find( "TheCheckBox" );
        var selectedprod = [];
        for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push({Id:checkedProds[i].get("v.text"),Name:checkedProds[i].get("v.name"),SelectstatusForProduct : false});
               
            }
        }
        /*if(selectedprod.length>0){
               var PassProductToBundle = $A.get("e.c:PassProductToBundle");
                PassProductToBundle.setParams({
                    "Products" : selectedprod
                    
                });
                PassProductToBundle.fire();   
        }*/
        component.set("v.SelectedProductForBundle",selectedprod);
    },
    
    CreateAddProductToBundle:function(component,event,helper,Obj,Oppid){
        $A.createComponent(
            "c:AddProductToBundle",
            {
                "SelectedProductForBundle": Obj,
                "OpportunityId":component.get("v.favOppId")
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    } 
})