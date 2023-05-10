({
	formPress : function(cmp, event, helper) {
		const SeletedProductCount =  cmp.get("v.SeletedProductCount"); 
        var searchKey=cmp.get("v.searchKey");
        if(!searchKey){
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please Enter a search String.",
                "Category" : "Warning",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire();
        }
        else{
     			if(parseInt(SeletedProductCount) > 0 && searchKey){
                	cmp.set("v.PrevSelectConfrm",true);
                }
                else{
                 helper.formPresshlpr(cmp, event, helper);
                }
        }
            
       
       
	},
    ToggleFilter:function(cmp,event,helper){
        //alert('ToggleFilter');
        cmp.set('v.TriggerFilterBox',true);
        cmp.set("v.TriggerSearchBox",false);
    },
    DisableToggleFilter:function(cmp,event,helper){
        //alert('DisableToggleFilter');
       cmp.set('v.TriggerFilterBox',false);
        cmp.set("v.TriggerSearchBox",true);
        
    },
    
    CloseDialogWindow:function(cmp,event,helper){
        //alert('CloseDialogWindow'); 
        cmp.set("v.closeDialog",'slds-hide'); 
        cmp.destroy();
    },
    RenderFilterData:function(cmp,event,helper){ 
       
       cmp.set("v.ResultData",''); 
       cmp.set("v.NoOfRecord",0);
       cmp.set("v.AllreadyQueryDataSet",'');
        
        var searchKey =cmp.get("v.searchKey");
		
        var PillsArray=[];
        /*var RevenueFilter=cmp.get("v.RevenueFilter");
        for(var i=0;i<RevenueFilter.length;i++){
            if(RevenueFilter[i].isSelected){
                PillsArray.push(RevenueFilter[i].Name);
            }
            
        }*/
        
        for(var i=0;i<cmp.find('chek_Box').length;i++){
                    //alert(cmp.find('chek_Box')[i].get('v.label'));
                   if(cmp.find('chek_Box')[i].get("v.value")){
                       
                       PillsArray.push(cmp.find('chek_Box')[i].get('v.label')); 
                   }
                    
        }
        
        if(searchKey !=''){
               
                if(PillsArray != ''){
                     //cmp.set("v.FilterAssistanceMap",filterAsistMap);
                     helper.SearchWithFilter(cmp,event,PillsArray,searchKey,cmp.get("v.SchFavIdList"));
                     cmp.set("v.PillsArray",PillsArray);  
                }
                else{  
                    helper.formPress(cmp,event,helper);
                    cmp.set("v.PillsArray",PillsArray); 
                }
            }
            else{
                if(PillsArray.length>0){
                    //cmp.set("v.FilterAssistanceMap",filterAsistMap);
                    helper.FetchFilterData(cmp,event,PillsArray,cmp.get("v.SchFavIdList"));
                    cmp.set("v.PillsArray",PillsArray);
                    }
                    else{
                        helper.doInit(cmp,event,helper);
                        cmp.set("v.PillsArray",PillsArray);
                    } 
            }
    
    },
    doInit:function(component,event,helper){
        debugger ;
        helper.doInit(component,event,helper);
        //alert("doInIt");
        component.set("v.clearSearch",'');
        component.set("v.searchKey",'');
        helper.isCatmOpp(component, event, helper);
        helper.Get_PMDM_Catogery(component,event);
        helper.getRenewalProducts(component);  
        //helper.getIndusryFilterValue(component,event);
        //var Temp=[];
        //var RevenueFilter=component.get("v.RevenueFilter");
        //for(var i=0;i<RevenueFilter.length;i++){
          //  Temp.push({Name:RevenueFilter[i],isSelected:false});
        //}   
        //component.set("v.RevenueFilter",Temp);
    },
    handleAddRemoveProduct:function(cmp,event,helper){ 
        //alert('handleAddRemoveProduct')
        var ResultData=cmp.get("v.ResultData");
        var FavandSchedule=[];
        var FavandScheduleId=[];
        var SchOnly=[];
        var SchOnlyId=[];
        var favOnly=[];
        var favOnlyId=[];
        var SchFavId_List=[];
        var FinalDataSet=[];
        var RemainigPrd=[];
        for(var i=0;i<ResultData.length;i++){
            //alert(ResultData[i].ProductName);
            //alert(ResultData[i].IsSchedule);
            if(ResultData[i].IsSchedule == true || ResultData[i].IsFav == true){
                
                FavandSchedule.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:ResultData[i].IsSchedule,IsFav:ResultData[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery, avail_Subscription:ResultData[i].avail_Subscription, availAsConnectedHWM:ResultData[i].availAsConnectedHWM});
            	FavandScheduleId.push(ResultData[i].ProductId);
            }
            else{
               
                RemainigPrd.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:ResultData[i].IsSchedule,IsFav:ResultData[i].IsFav,styleClass:"",IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery, avail_Subscription:ResultData[i].avail_Subscription, availAsConnectedHWM:ResultData[i].availAsConnectedHWM});
            }
        }
         //alert(FavandSchedule.length); 
         //alert(RemainigPrd.length);
         FinalDataSet=FinalDataSet.concat(FavandSchedule);
         FinalDataSet=FinalDataSet.concat(RemainigPrd);
         cmp.set("v.SchFavList",FavandSchedule);
         cmp.set("v.SchFavIdList",FavandScheduleId);
         cmp.set("v.ResultData",FinalDataSet);
         cmp.set("v.NoOfRecord",FinalDataSet.length);
    }, 
    BulkschProcess:function(cmp,event,helper){
        var searchKey =cmp.get("v.searchKey");
        var ResultData=cmp.get("v.ResultData");
        var TempResultDataId=[];
        var IsAllreadySchdeule=false;
        var isAnySubcriptionableProd = false ;
        var tempSelectedSubscriptionableList = [] ;
        var tempselectedNONSubcrionableProdList = [] ;
        var subsciptionArray = [] ;
        debugger ;
        for(var i=0;i<ResultData.length;i++){
            if(ResultData[i].IsCheckBoxSelected == true  && ResultData[i].IsSchedule == false){
                 // EBA_SF-2174 adding check in if for NCR Payment Processing by Stuti
                if(ResultData[i].avail_Subscription == true && !(cmp.get("v.subsOnlyProdNames").includes(ResultData[i].ProductName)== true || cmp.get("v.subsOnlyRevenueTypes").includes(ResultData[i].ServiceOfferCatogery)== true ? true:false)) {
                    isAnySubcriptionableProd = true ;
                    tempSelectedSubscriptionableList.push({
                        ProductId:ResultData[i].ProductId ,
                        ProductName:ResultData[i].ProductName ,
                        checkOLISubcription : false 
               		 });
                    
                } else {
                    tempselectedNONSubcrionableProdList.push({
                        ProductId:ResultData[i].ProductId ,
                        ProductName:ResultData[i].ProductName ,
                        checkOLISubcription : false 
                    }) ;
                    TempResultDataId.push(ResultData[i].ProductId);
                    subsciptionArray.push(false) ;
                    
                    
                }
                 //TempResultData.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:true,IsFav:ResultData[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery});
                 //TempResultDataId.push(ResultData[i].ProductId);   
            }
            else if(ResultData[i].IsCheckBoxSelected == true  && ResultData[i].IsSchedule == true)
            {
                IsAllreadySchdeule=true;
            }
        }
        
        cmp.set("v.confirmSubscriptionModal", isAnySubcriptionableProd ) ;
        cmp.set("v.selectedSubcrionableProdList", tempSelectedSubscriptionableList ) ;
        cmp.set("v.selectedNONSubcrionableProdList", tempselectedNONSubcrionableProdList )
        
        if(isAnySubcriptionableProd == false && TempResultDataId.length > 0  ){
            // TempResultDataId = tempselectedNONSubcrionableProdList
            if(cmp.get("v.TriggerScreenName") == 'ADD PRODUCT'){
                var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                  "ProductIds" : TempResultDataId ,
                  "HasSubsciption" : subsciptionArray
                });
                appEvent.fire();
                
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added To Schedule Successfully....",
                        "Category" : "Success",
                        "isShow" : "True"
                    }); 
                    FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully....",
        			"type":"success"
   			 		});
    				toastEvent.fire();

            		helper.doInit(cmp,event,helper);
                    //helper.Render_Schedule(cmp,event,helper);  
            }
                
            else{
                
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : TempResultDataId ,
                    "hasSubscription" : subsciptionArray
                });
                appEvent.fire();
                 
                
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Added To Schedule Successfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                }); 
                FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();

                helper.doInit(cmp,event,helper);
                //helper.Render_Schedule(cmp,event,helper);  
            }
             
        }
        
        else if(TempResultDataId.length <= 0 && tempSelectedSubscriptionableList.length <= 0 ) {
            
            if(IsAllreadySchdeule){
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Selected Product is Already Scheduled.",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire(); 
            } 
            else{
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "No product is selected,Please select the products from list.",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No product is selected,Please select the products from list.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
            }
        }
        
        
    },
	BulkFavProcess:function(cmp,event,helper){
        var ResultData=cmp.get("v.ResultData");
		var TempResultDataId=[];
        var IsAllreadySchdeule=false;
        var searchKey =cmp.get("v.searchKey");
        cmp.set("v.SelectAll",false);
        for(var i=0;i<ResultData.length;i++){
              
            if(ResultData[i].IsCheckBoxSelected == true  && ResultData[i].IsFav == false){
                 //TempResultData.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:true,IsFav:ResultData[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery});
                 TempResultDataId.push(ResultData[i].ProductId);   
            }
            else if(ResultData[i].IsCheckBoxSelected == true  && ResultData[i].IsFav == true)
            {
                IsAllreadySchdeule=true;
            }
        }
        
        
        if(TempResultDataId.length>0){
            
            var appfavEvent = $A.get("e.c:psaddfavEvent_PS");
            appfavEvent.setParams({
                "ProductIds" : TempResultDataId 
            });  
            appfavEvent.fire(); 
        
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Added to Favorites Successfully.",
                "Category" : "Success",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire(); 
            var PillsArray=cmp.get('v.PillsArray');
            //helper.doInit(cmp,event);
            if(PillsArray == ''){
                
                if(searchKey){
                    helper.formPress(cmp,event,helper);
                }
                
                else{
                    helper.doInit(cmp,event,helper);
                } 
            }
             
            
            else{
               var PillsArray=[]; 
               /*var RevenueFilter=cmp.get("v.RevenueFilter");
                for(var i=0;i<RevenueFilter.length;i++){
                    if(RevenueFilter[i].isSelected){
                        PillsArray.push(RevenueFilter[i].Name);
                    }
                    
                }*/
                
                for(var i=0;i<cmp.find('chek_Box').length;i++){
                    //alert(cmp.find('chek_Box')[i].get('v.label'));
                   if(cmp.find('chek_Box')[i].get("v.value")){
                       PillsArray.push(cmp.find('chek_Box')[i].get('v.label')); 
                   }
                    
               }
                
                if(searchKey){
                	//alert('1'); 
                    helper.SearchWithFilter(cmp,event,PillsArray,searchKey,cmp.get("v.SchFavIdList"));
                }
                else{
                    //cmp.set("v.FilterAssistanceMap",filterAsistMap);
                    //alert('2');
        			helper.FetchFilterData(cmp,event,PillsArray,cmp.get("v.SchFavIdList"));

                }
            }
            cmp.set("v.SeletedProductCount",parseInt(0));
            
        }
      else{
            if(IsAllreadySchdeule){
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Select Product Already Favourate ",
                "Category" : "Warning",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire();
         } 
         else{
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "No product is selected,Please select the products from list.",
                "Category" : "Warning",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire();*/
             //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No product is selected,Please select the products from list.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
        }
        }   
        
    },  
    AddToBundle:function(cmp,event,helper){
        var ResultData=cmp.get("v.ResultData");
        var renewablRevnTypes = cmp.get("v.renewablRevnTypes");
        var selectedprod = [];
        for(var i=0;i<ResultData.length;i++){
            if(ResultData[i].IsCheckBoxSelected == true ){
                
                //FavandSchedule.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:ResultData[i].IsSchedule,IsFav:true,styleClass:"hoverTable",IsCheckBoxSelected:false});
                selectedprod.push({Id:ResultData[i].ProductId,Name:ResultData[i].ProductName,SelectstatusForProduct : false,avail_Subscription:ResultData[i].avail_Subscription,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery,IsCheckBoxSelected:ResultData[i].IsCheckBoxSelected,renewablRevnTypes:renewablRevnTypes, availAsConnectedHWM:ResultData[i].availAsConnectedHWM});
            }
            
        }
        
        if(selectedprod.length>0){       
            helper.CreateAddProductToBundle(cmp,event,helper,selectedprod,cmp.get("v.OpportunityId"));            
        }
        
        else{
           /* var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "No product is selected,Please select the products from list.",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire(); */
            //Ajay-jul2021
            var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
       		 "title": "Warning!",
       		 "message": "No product is selected,Please select the products from list.",
        		"type":"warning"
   			 });
    		toastEvent.fire();
        }
    },
    RemoveFilterPills:function(cmp,event,helper){
        var index = event.currentTarget.dataset.rowIndex;
		//alert('Pankaj'+index);     
        var searchKey =cmp.get("v.searchKey"); 
        var filterAsistMap={};
		var RevenueFilter=cmp.get("v.RevenueFilter");
        var PillsArray=[];
        var RevenueFilterTemp=[];
        cmp.set("v.SeletedProductCount",parseInt(0));
       
        
        for(var i=0;i<cmp.get("v.PillsArray").length;i++){
            if(index != cmp.get("v.PillsArray")[i]){
                PillsArray.push(cmp.get("v.PillsArray")[i]);
            } 
        }
        cmp.set("v.PillsArray",PillsArray);
        
        /*for(var i=0;i<RevenueFilter.length;i++){
            var tempCheck=true;
            for(var j=0;j<PillsArray.length;j++){
                if(RevenueFilter[i].Name.toUpperCase() == PillsArray[j].toUpperCase()){
                    RevenueFilterTemp.push({Name:RevenueFilter[i].Name,isSelected:true});
                    tempCheck=false;
                } 
                
            }
            if(tempCheck){
                RevenueFilterTemp.push({Name:RevenueFilter[i].Name,isSelected:false});
            }
                        
        }*/
        
        for(var i=0;i<RevenueFilter.length;i++){
           
            if(index.toUpperCase() === RevenueFilter[i].Name.toUpperCase()){
                RevenueFilterTemp.push({Name:RevenueFilter[i].Name,isSelected:false});
            }
            else{
                 RevenueFilterTemp.push({Name:RevenueFilter[i].Name,isSelected: RevenueFilter[i].isSelected});
            }
        }
        
        cmp.set("v.RevenueFilter",RevenueFilterTemp);
        cmp.set("v.SelectAll",false);
       

        if(searchKey != ''){
            
            if(PillsArray != ''){
                //alert('1 and 2');
                //cmp.set("v.FilterAssistanceMap",filterAsistMap);
                helper.SearchWithFilter(cmp,event,PillsArray,searchKey,cmp.get("v.SchFavIdList"));
                //cmp.set("v.PillsArray",PillsArray); 
            }
            else{
                helper.formPress(cmp,event,helper);
                cmp.set("v.PillsArray",PillsArray); 
                //cmp.set("v.FilterAssistanceMap",filterAsistMap);
            }
        }
        
        else{
             
            if(PillsArray.length>0){
            //cmp.set("v.FilterAssistanceMap",filterAsistMap);
        	helper.FetchFilterData(cmp,event,PillsArray,cmp.get("v.SchFavIdList"));
            cmp.set("v.PillsArray",PillsArray);    
            }
            else{
                helper.doInit(cmp,event,helper);
                cmp.set("v.PillsArray",PillsArray);
                //cmp.set("v.FilterAssistanceMap",filterAsistMap);
            } 
        }
        
    },
    SelectAll:function(cmp,event,helper){
        //cmp.set("v.SeletedProductCount",parseInt("0"));
        var SeletedProductCount = cmp.get("v.SeletedProductCount");
        var ResultData=cmp.get("v.ResultData");
        var renewablRevnTypes = cmp.get("v.renewablRevnTypes");
        var ResultDataTeamp=[];
        var SelectAll=cmp.get("v.SelectAll");
        
        
        if(ResultData.length > 100 && SelectAll==true){
             var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "Bulk Favorite/Schedule Works only for 100 Products Please refine your search.",
                                "Category" : "Warning",
                                "isShow" : "True"
                            });
              FloatMsgEvent.fire();
           cmp.set("v.SelectAll",false);
            
           
            
        }
        else{
            if(SelectAll){
                cmp.set("v.SeletedProductCount",parseInt(0));
            }
              for(var i=0;i<ResultData.length;i++){
                  	
                  if(SelectAll){
                       
                       cmp.set("v.SeletedProductCount",parseInt(cmp.get("v.SeletedProductCount") + 1));
                  }
                  
                  else{
                      if(ResultData[i].IsCheckBoxSelected){
                         cmp.set("v.SeletedProductCount",parseInt(cmp.get("v.SeletedProductCount") - 1));   
                      }
                      
                  }
            	  ResultDataTeamp.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:ResultData[i].IsSchedule,IsFav:ResultData[i].IsFav,styleClass:ResultData[i].styleClass,IsCheckBoxSelected:SelectAll,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery , avail_Subscription:ResultData[i].avail_Subscription,renewablRevnTypes, availAsConnectedHWM: ResultData[i].availAsConnectedHWM});
           }
           if(parseInt(cmp.get("v.SeletedProductCount")) > 20){
                    cmp.set("v.DisableBulkProcess",true);
           }  
           else{
                   cmp.set("v.DisableBulkProcess",false);
           } 
         cmp.set("v.ResultData",ResultDataTeamp); 
         
                                        
        }
            
    },
    
    
    buldHandleAddProductsFirstPhase : function(cmp, event, helper) {         
            //alert('YOU Have product added ');
            //buldHandleAddProductsFirstPhase
            //
            var ResultData = cmp.get("v.ResultData");
        	var countSelectedProduct=0;
            for(var i=0;i<ResultData.length;i++){
            if(ResultData[i].IsCheckBoxSelected == true ){
                
               countSelectedProduct=parseInt(countSelectedProduct+1);
            }
            
        }
       
        if(parseInt(countSelectedProduct)>0){
             helper.buldHandleAddProductsFirstPhaseHlpe(cmp, event,helper);
        }
        else{
            		var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No product is selected,Please select the products from list.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
        }
            

    } ,
    
    addAllForSubscription : function(cmp, event, helper) {
        //debugger ;
        var tempList = cmp.get("v.selectedSubcrionableProdList") ;
        if(event.getSource().get("v.checked") == true) {
            for(var i=0; i <tempList.length ;i++ ) {
                tempList[i].checkOLISubcription = true ;
            }
        } else if(event.getSource().get("v.checked") == false) {
            for(var i=0; i <tempList.length ;i++ ) {
                tempList[i].checkOLISubcription = false ;
            }
        }
        
        cmp.set("v.selectedSubcrionableProdList" , tempList);
        
    } ,
    
    submitSubcriptionProds : function(cmp, event, helper) {
        //debugger;
        var subscriptionList = cmp.get("v.selectedSubcrionableProdList") ;
        var nonSubscriptionList = cmp.get("v.selectedNONSubcrionableProdList") ;
        var finalList = subscriptionList.concat(nonSubscriptionList);
        var tempProdIds = [];
        var tempSubscriptionVals = [], tempServLineItemTypes = [],  tempHWMMntcTypes =[], tempQtyTypes =[];
        var hasError = false;
      
        for(var i=0; i<finalList.length ; i++) {
            tempProdIds.push(finalList[i].ProductId) ;
            tempSubscriptionVals.push(finalList[i].checkOLISubcription);           
            tempServLineItemTypes.push(finalList[i].selectLineItemType);
            tempHWMMntcTypes.push(finalList[i].selectHWMMntcType);
            tempQtyTypes.push(finalList[i].qtyTyp);
            
            if((finalList[i].isServiceLineItem && $A.util.isEmpty(finalList[i].selectLineItemType)) 
               || (finalList[i].isAvlAsCnctHWM && $A.util.isEmpty(finalList[i].selectHWMMntcType))
              || (finalList[i].isQtyTypApplicable && $A.util.isEmpty(finalList[i].qtyTyp))) {
                hasError = true;
               	break; 
            }
        }
        //console.log(JSON.stringify(tempSubscriptionVals));
        //console.log(JSON.stringify(tempServLineItemTypes));
        if(hasError) {
        	
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please select Line Item Type for below Service Products",
                "Category" : "Error",
                "isShow" : "True"
            }); 
            FloatMsgEvent.fire(); */
            //Ajay-jul2021
             var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
       		 "title": "Error!",
       		 "message": "Please select Line Item Type or Maintenance Type or Qty Type for below Service Products",
        	"type":"error"
   			 });
    		toastEvent.fire();
        }
        else {
            if(cmp.get("v.TriggerScreenName") == 'ADD PRODUCT'){
                var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                    "ProductIds" : tempProdIds ,
                    "HasSubsciption" : tempSubscriptionVals,
                    "ServLineItemTypeArray" : tempServLineItemTypes,
					"HWMMntcTypeArray" : tempHWMMntcTypes,
                    "qtyTypeArray" :  tempQtyTypes                   
                });
                appEvent.fire();
                //cmp.set("v.SelectAll",false);  
                    
                    /* commented for opp line item type change
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added To Schedule Successfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    }); 
                    FloatMsgEvent.fire(); 
            		helper.doInit(cmp,event);*/
            }
                
            else{
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : tempProdIds ,
                    "hasSubscription" : tempSubscriptionVals,
                    "ServLineItemTypeArray" : tempServLineItemTypes,
                    "HWMMntcTypeArray" : tempHWMMntcTypes,
                    "qtyTypeArray" :  tempQtyTypes
                });
                appEvent.fire();
               
                /*commented for opp line item type change
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Added To Schedule Successfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                }); 
                FloatMsgEvent.fire();  
                helper.doInit(cmp,event); */
             }
            
            cmp.set("v.confirmSubscriptionModal", false) ;
            cmp.set("v.confirmServTypeSelModal", false) ;
            cmp.set("v.confirmHWMTypeModal", false) ;
            cmp.set("v.confirmQtyTypModal", false);
            var ResultData=cmp.get("v.ResultData");
            var ResultDataTeamp=[];
            var renewablRevnTypes = cmp.get("v.renewablRevnTypes");

            for(var i=0;i<ResultData.length;i++){
                ResultDataTeamp.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:ResultData[i].IsSchedule,IsFav:ResultData[i].IsFav,styleClass:ResultData[i].styleClass,IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery , avail_Subscription:ResultData[i].avail_Subscription,renewablRevnTypes, availAsConnectedHWM: ResultData[i].availAsConnectedHWM});
              
           }            
         cmp.set("v.ResultData",ResultDataTeamp);
         cmp.set("v.SelectAll",false);
         
            
        }
    } ,
    
    
    BulkschProcessThroughAdd:function(cmp,event,helper){
        var ResultData=cmp.get("v.ResultData");
        var TempResultDataId=[];
        var tempBooleanSubscribe  = [] ;
        var IsAllreadySchdeule=false;
        var isAnySubcriptionableProd = false ;
        for(var i=0;i<ResultData.length;i++){
            if(ResultData[i].IsCheckBoxSelected == true){
                 //TempResultData.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:true,IsFav:ResultData[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery});
                 TempResultDataId.push(ResultData[i].ProductId); 
                tempBooleanSubscribe.push(false) ;
                  
            }
            
        }
        
        if(TempResultDataId.length>0){
            if(cmp.get("v.TriggerScreenName") == 'ADD PRODUCT'){
                var appEvent = $A.get("e.c:ceEvent");
                appEvent.setParams({
                  "ProductIds" : TempResultDataId,
                   "HasSubsciption" : tempBooleanSubscribe
                });
                appEvent.fire();
                
                    /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Added To Schedule Successfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    }); 
                    FloatMsgEvent.fire(); */
                	//Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();

                    //cmp.set("v.SelectAll",false); 
            		helper.doInit(cmp,event,helper);
             
            }
                
            else{
                
                var appEvent = $A.get("e.c:InsertScheduleEvent");
                appEvent.setParams({
                    "ProductIds" : TempResultDataId ,
                    "hasSubscription" : tempBooleanSubscribe
                });
                appEvent.fire();
                
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Added To Schedule Successfully.",
                    "Category" : "Success",
                    "isShow" : "True"
                }); 
                FloatMsgEvent.fire();*/
                //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Added To Schedule Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();

                helper.doInit(cmp,event,helper);
            }
        }
        
        else{
            
            
                /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "No product is selected,Please select the products from list.",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();*/
            //Ajay-jul2021
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "No product is selected,Please select the products from list.",
        			"type":"warning"
   			 		});
    				toastEvent.fire();
        }  
    },
    OnSearchBarClear:function(cmp,event,helper){
        cmp.set("v.searchKey",'');
           
        var PillsArray=cmp.get("v.PillsArray");
        
        if(PillsArray.length == 0){
            helper.doInit(cmp,event,helper);  
        }
        else{
           helper.FetchFilterData(cmp,event,PillsArray,cmp.get("v.SchFavIdList"));
        }
        cmp.set("v.clearSearch",'');
    },
    refreshBundle:function(component,event,helper){
        var message = event.getParam("CallFromBundleforRefresh");
        
        if(message == 'call_from_child'){
            helper.getUserFavBundle(component);
            
        }   
         
        else{
           
			var ToggelBundleComponent = component.get("v.ToggelBundleComponent");
        	component.set("v.ToggelBundleComponent", ToggelBundleComponent == false ? true : false);            
        }

    },
    clearFilter:function(cmp,event,helper){
        var Temp=[];
        var PillsArray=[];
        var RevenueFilter=cmp.get("v.RevenueFilter");
        var searchKey=cmp.get("v.searchKey");
        var OpportunityId=cmp.get("v.OpportunityId");
        cmp.set("v.SeletedProductCount",parseInt(0)); 
        cmp.set("v.DisableBulkProcess",false);
        cmp.set("v.SelectAll",false);
        for(var i=0;i<RevenueFilter.length;i++){
            Temp.push({Name:RevenueFilter[i].Name,isSelected:false});
        }   
        cmp.set("v.RevenueFilter",Temp);
        cmp.set("v.PillsArray",PillsArray);
        cmp.set("v.OpportunityId",OpportunityId);
        
        if(searchKey){
            helper.formPress(cmp,event,helper);
        }
                
        else{
            helper.doInit(cmp,event,helper);
        }
    },
    RealTimeSearch : function(cmp,event,helper){
        
        //alert(cmp.find('chek_Box')[0].get("v.value")); 
        //alert(cmp.find('chek_Box')[0].get("v.label"));   
       const SeletedProductCount = cmp.get("v.SeletedProductCount"); 
       
        if(parseInt(SeletedProductCount)>0){ 
            cmp.set("v.PrevSelectConfrm",true);
        } 
        else{
            helper.RealTimeSearchhelper(cmp,event,helper);
        }
      
    },
    //Call by aura:waiting event  
    handleShowSpinner: function(component, event, helper) {
        component.set("v.isSpinner", true); 
    },
    
    //Call by aura:doneWaiting event 
    handleHideSpinner : function(component,event,helper){
        component.set("v.isSpinner", false);
    },
    SavePreviousProduct :function(component,event,helper){
	    helper.buldHandleAddProductsFirstPhaseHlpe(component,event,helper);                                              
    },
     CancleSavePreviousProduct:function(component,event,helper){
         component.set("v.PrevSelectConfrm",false);  
         component.set("v.SelectAll",false);
         component.set("v.SeletedProductCount",0);
         helper.RealTimeSearchhelper(component,event,helper);
     },
	CloseConfirmWindow:function(component,event,helper){
         
        component.set("v.PrevSelectConfrm",false); 
        
         /****by Stuti EBA-2175*****/
         //component.set("v.SelectAll",false); 
         //component.set("v.SeletedProductCount",parseInt(0));
         component.set("v.SeletedProductCount",component.get("v.SeletedProductCount"));
         /****by Stuti EBA-2175 ends*****/
        
         component.set("v.DisableBulkProcess",false);
         //helper.RealTimeSearchhelper(component,event,helper);
         
    },
    
    // added as a part of EBA 2467
    handleBundleClose : function(cmp,event,helper){
        var body = cmp.get("v.body");
        body.pop();
        cmp.set("v.body", body);        
    }
                                        
})