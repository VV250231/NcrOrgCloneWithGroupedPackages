({
    getRenewalProducts: function(cmp){
       
        var getSettingsAction = cmp.get("c.getRnwableProds");
     /***** Stuti-1595 *****/
        getSettingsAction.setParams({'OppId': cmp.get("v.OpportunityId")});
        /***** Stuti-1595 Ends *****/
            getSettingsAction.setCallback(this, function(response) {
                if (cmp.isValid() && response !== null && response.getState() == 'SUCCESS') {                   
                    cmp.set("v.renewablRevnTypes" ,response.getReturnValue().RnwablRevTypes); 
                    
                    if(!$A.util.isEmpty(response.getReturnValue().OppLineItemTypes)) {
                        var OppLineItemTypes = response.getReturnValue().OppLineItemTypes;
                        var lineItemTypeMap = [];
                        for(var key in OppLineItemTypes){
                            lineItemTypeMap.push({key: key, value: OppLineItemTypes[key]});
                        }
                        cmp.set("v.oppLineItemTypeMap", lineItemTypeMap);
                    }                    
                    console.log('getSubsProduct success');
                    
                    if(!$A.util.isEmpty(response.getReturnValue().HWMMntTypes)) {                        
                    	cmp.set("v.HWMMntcTypes" ,response.getReturnValue().HWMMntTypes); 
                    }
                    //adding qtyTypes CSI 304 by Stuti
                    if(!$A.util.isEmpty(response.getReturnValue().qtyTypes)) {                        
                    	var qtyTypeResp = response.getReturnValue().qtyTypes;
                        var qtyTypeMap = [];
                        for(var key in qtyTypeResp){
                            qtyTypeMap.push({key: key, value: qtyTypeResp[key]});
                        }              
                        cmp.set("v.qtyTypeMap", qtyTypeMap);
                    }
                    
                    /***** EBA_SF-2174 adding check for NCR Payment Processing by Stuti*****/
                    cmp.set("v.subsOnlyProdNames" ,response.getReturnValue().ProductNames);
                	cmp.set("v.subsOnlyRevenueTypes" ,response.getReturnValue().RevenueTypes);
                    /***** EBA_SF-2174 ends*****/
                    
                }           
            });
            $A.enqueueAction(getSettingsAction);
	},
    FetchFilterData : function(cmp,event,PillsArray,SchFavListId) {
       
		var OpportunityId=cmp.get("v.OpportunityId");
        var action = cmp.get("c.getFilterResult");
            action.setStorable();
            action.setParams({
                "FilterString": PillsArray,
                "SchFavListId": SchFavListId,
                "OppId": OpportunityId
               
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                        
                        var ResultData=[];
                        var AllreadyQueryDataSet=[];
                        for(var i=0;i<response.getReturnValue().length;i++){ 
                            ResultData.push({ProductId:response.getReturnValue()[i].Id,ProductName:response.getReturnValue()[i].Name,IsSchedule:false,IsFav:false,IsCheckBoxSelected:false,ServiceOfferCatogery:response.getReturnValue()[i].Service_Offer_Category__c,LeadTime_Wks:response.getReturnValue()[i].LEAD_TIME_WKS__c, availAsConnectedHWM:response.getReturnValue()[i].Available_as_Connected_HWM__c}); 
                            AllreadyQueryDataSet.push(response.getReturnValue()[i].Id);
                        }
                         
                        //console.log(cmp.get("v.SchFavList"));
                        
                        var PillsWithFilter=[];
                        var PillsWithOutFilter=[];
                        //({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery});    
                        for(var i=0;i<PillsArray.length;i++){
                            
                            for(var j=0;j<cmp.get("v.SchFavList").length;j++){
                                
                                if(PillsArray[i] == cmp.get("v.SchFavList")[j].ServiceOfferCatogery){ 
                                   
                                   PillsWithFilter.push({ProductId:cmp.get("v.SchFavList")[j].ProductId,ProductName:cmp.get("v.SchFavList")[j].ProductName,IsSchedule:cmp.get("v.SchFavList")[j].IsSchedule,IsFav:cmp.get("v.SchFavList")[j].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:cmp.get("v.SchFavList")[j].IsCheckBoxSelected,ServiceOfferCatogery:cmp.get("v.SchFavList")[j].ServiceOfferCatogery,LeadTime_Wks:cmp.get("v.SchFavList")[j].LeadTime_Wks});
                                }
                                
                                if(PillsArray[i] != cmp.get("v.SchFavList")[j].ServiceOfferCatogery){
                                    
                                   PillsWithOutFilter.push({ProductId:cmp.get("v.SchFavList")[j].ProductId,ProductName:cmp.get("v.SchFavList")[j].ProductName,IsSchedule:cmp.get("v.SchFavList")[j].IsSchedule,IsFav:cmp.get("v.SchFavList")[j].IsFav,styleClass:"",IsCheckBoxSelected:cmp.get("v.SchFavList")[j].IsCheckBoxSelected,ServiceOfferCatogery:cmp.get("v.SchFavList")[j].ServiceOfferCatogery,LeadTime_Wks:cmp.get("v.SchFavList")[j].LeadTime_Wks});  
                                }
                            }

                        }
                        
                       
                        //cmp.set('v.SchFavList',);
                        PillsWithFilter.concat(PillsWithOutFilter);
                        
                        //console.log(PillsWithFilter);
                        
                        cmp.set("v.ResultData",PillsWithFilter.concat(ResultData)); 
                        cmp.set("v.AllreadyQueryDataSet",cmp.get("v.SchFavIdList").concat(AllreadyQueryDataSet));
                        cmp.set("v.NoOfRecord",cmp.get("v.ResultData").length);
                        cmp.set("v.PillsArray",PillsArray);
                    }
                 
                  
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
	},
    doInit:function(cmp,event,helper){
        cmp.set("v.SeletedProductCount",parseInt(0));
        var action = cmp.get("c.getFirstChunk");
        // action.setStorable();
        action.setParams({
                "OpportunityId": cmp.get("v.OpportunityId")    
            });
        
            action.setCallback(this, function (response) {
                var state = response.getState();
                
                    if(cmp.isValid() && state === "SUCCESS") { 
                        var ResultData=[];
                        var AllreadyQueryDataSet=[];
                        var FavandSchedule=[];
                        var FavandScheduleId=[];
                        var SchOnly=[];
                        var SchOnlyId=[];
                        var favOnly=[];
                        var favOnlyId=[];
                        var SchFavId_List=[];
                        var FinalDataSet=[];
                        for(var i=0;i<response.getReturnValue().length;i++){
                            
                            if(response.getReturnValue()[i].IsSchedule == true && response.getReturnValue()[i].IsFav == true){
                                FavandSchedule.push({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery,LeadTime_Wks:response.getReturnValue()[i].LeadTime_Wks, avail_Subscription:response.getReturnValue()[i].availForSubscription, availAsConnectedHWM:response.getReturnValue()[i].avlAsCnctdHWM }); 
                                FavandScheduleId.push(response.getReturnValue()[i].ProductId);
                            }
                            
                            else if(response.getReturnValue()[i].IsSchedule == true){
                                SchOnly.push({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery,LeadTime_Wks:response.getReturnValue()[i].LeadTime_Wks , avail_Subscription:response.getReturnValue()[i].availForSubscription, availAsConnectedHWM:response.getReturnValue()[i].avlAsCnctdHWM }); 
                            	SchOnlyId.push(response.getReturnValue()[i].ProductId);
                            }
                            
                            else if(response.getReturnValue()[i].IsFav == true){
                                 favOnly.push({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery,LeadTime_Wks:response.getReturnValue()[i].LeadTime_Wks , avail_Subscription:response.getReturnValue()[i].availForSubscription, availAsConnectedHWM:response.getReturnValue()[i].avlAsCnctdHWM });    
                            	 favOnlyId.push(response.getReturnValue()[i].ProductId);
                            }
                            
                            else{
                                  ResultData.push({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery,LeadTime_Wks:response.getReturnValue()[i].LeadTime_Wks, avail_Subscription:response.getReturnValue()[i].availForSubscription, availAsConnectedHWM:response.getReturnValue()[i].avlAsCnctdHWM });   
                                }
                            //ResultData.push({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav}); 
                            AllreadyQueryDataSet.push(response.getReturnValue()[i].ProductId);
                            
                        }
                        FinalDataSet=FinalDataSet.concat(FavandSchedule);
                        FinalDataSet=FinalDataSet.concat(favOnly);
                        FinalDataSet=FinalDataSet.concat(SchOnly);
                        
                        
                        SchFavId_List=SchFavId_List.concat(FavandScheduleId);
                        SchFavId_List=SchFavId_List.concat(favOnlyId);
                        SchFavId_List=SchFavId_List.concat(SchOnlyId);
                        
                        cmp.set("v.SchFavList",FinalDataSet);
                        cmp.set("v.SchFavIdList",SchFavId_List);
                        FinalDataSet=FinalDataSet.concat(ResultData);
                        
                        cmp.set("v.ResultData",FinalDataSet);
                        var PillsArray= cmp.get("v.PillsArray");                    
                        if(PillsArray.length>0){  
                            var act = cmp.get("c.RenderFilterData") ;
                            act.setParams({
                                cmp : cmp ,
                                event : event ,
                                helper : helper
                            });
                            $A.enqueueAction( act) ;
                        }					
                        
                        cmp.set("v.NoOfRecord",AllreadyQueryDataSet.length);
                        cmp.set("v.AllreadyQueryDataSet",AllreadyQueryDataSet);
                        cmp.set("v.SelectAll",false); // EBA-SF-1141
                      
                        
                    }
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
           
        
	},
    
    
    getNextPage:function(cmp,event){
        var action = cmp.get("c.GetNextPage"); 
            action.setStorable();
            action.setParams({
                    "ProductId": cmp.get("v.AllreadyQueryDataSet"),
                  	"OppId": cmp.get("v.OpportunityId")
                   
                });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                        var ResultData=[];
                        var AllreadyQueryDataSet=[];
                        for(var i=0;i<response.getReturnValue().length;i++){
                            //alert(response.getReturnValue()[i].Id);
                            ResultData.push({ProductId:response.getReturnValue()[i].Id,ProductName:response.getReturnValue()[i].Name,IsSchedule:false,IsFav:false,IsCheckBoxSelected:false,ServiceOfferCatogery:response.getReturnValue()[i].Service_Offer_Category__c,LeadTime_Wks:response.getReturnValue()[i].LEAD_TIME_WKS__c , avail_Subscription:response.getReturnValue()[i].Available_for_Subscription__c, availAsConnectedHWM:response.getReturnValue()[i].Available_as_Connected_HWM__c }); 
                        	AllreadyQueryDataSet.push(response.getReturnValue()[i].Id);
                        }
                        
                    }
                cmp.set("v.ResultData",cmp.get("v.ResultData").concat(ResultData));
                cmp.set("v.AllreadyQueryDataSet",cmp.get("v.AllreadyQueryDataSet").concat(AllreadyQueryDataSet)); 
                cmp.set("v.NoOfRecord",cmp.get("v.AllreadyQueryDataSet").length);
                
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
    },
    getNextPageForFilter:function(cmp,event,ProductId,PillsArray){
        var action = cmp.get("c.getNextPageFor_Filter");
            action.setStorable();
            action.setParams({
                "ProductId": ProductId,
                "FilterString":PillsArray,
                "OppId": cmp.get("v.OpportunityId")
               
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                        var ResultData=[];
                        var AllreadyQueryDataSet=[]; 
                        for(var i=0;i<response.getReturnValue().length;i++){
                            //alert(response.getReturnValue()[i].Id);
                            ResultData.push({ProductId:response.getReturnValue()[i].Id,ProductName:response.getReturnValue()[i].Name,IsSchedule:false,IsFav:false,ServiceOfferCatogery:response.getReturnValue()[i].Pmdm_Product_Category__c,IsCheckBoxSelected:false,ServiceOfferCatogery:response.getReturnValue()[i].Service_Offer_Category__c,LeadTime_Wks:response.getReturnValue()[i].LEAD_TIME_WKS__c , avail_Subscription:response.getReturnValue()[i].Available_for_Subscription__c, availAsConnectedHWM:response.getReturnValue()[i].Available_as_Connected_HWM__c}); 
                        	AllreadyQueryDataSet.push(response.getReturnValue()[i].Id);
                        }
                         
                    }
                cmp.set("v.ResultData",cmp.get("v.ResultData").concat(ResultData));
                cmp.set("v.AllreadyQueryDataSet",cmp.get("v.AllreadyQueryDataSet").concat(AllreadyQueryDataSet)); 
                cmp.set("v.NoOfRecord",cmp.get("v.AllreadyQueryDataSet").length);
                
                  
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
    },
    getNextPageForQueryString:function(cmp,event,ProductId,searchKey){
        
        var action = cmp.get("c.getNextPageFor_SearchString");
            action.setStorable();
            action.setParams({
                "ProductId": ProductId,
                "searchKey":searchKey,
                "OppId": cmp.get("v.OpportunityId")
               
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                        var ResultData=[];
                        var AllreadyQueryDataSet=[]; 
                        for(var i=0;i<response.getReturnValue().length;i++){
                            //alert(response.getReturnValue()[i].Id);
                            ResultData.push({ProductId:response.getReturnValue()[i].Id,ProductName:response.getReturnValue()[i].Name,IsSchedule:false,IsFav:false,ServiceOfferCatogery:response.getReturnValue()[i].Service_Offer_Category__c,IsCheckBoxSelected:false,LeadTime_Wks:response.getReturnValue()[i].LEAD_TIME_WKS__c, avail_Subscription:response.getReturnValue()[i].Available_for_Subscription__c, availAsConnectedHWM:response.getReturnValue()[i].Available_as_Connected_HWM__c }); 
                        	AllreadyQueryDataSet.push(response.getReturnValue()[i].Id);
                        }
                         
                    }
                cmp.set("v.ResultData",cmp.get("v.ResultData").concat(ResultData));
                cmp.set("v.AllreadyQueryDataSet",cmp.get("v.AllreadyQueryDataSet").concat(AllreadyQueryDataSet)); 
                cmp.set("v.NoOfRecord",cmp.get("v.ResultData").length);

           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
    },
    CreateAddProductToBundle:function(component,event,helper,Obj,Oppid){
        $A.createComponent(
            "c:AddProductToBundle",
            {
                "SelectedProductForBundle": Obj,
                "OpportunityId":component.get("v.favOppId"),
                "isCommunityUser":component.get("v.isCommunityUser"),	
                "IPTPartnerCommunityUrl":component.get("v.IPTPartnerCommunityUrl"),
                "renewablRevnTypes":component.get("v.renewablRevnTypes"),
                "oppLineItemTypeMap":component.get("v.oppLineItemTypeMap"),
                "TriggerScreenName":component.get("v.TriggerScreenName"),
                "OpportunityId":Oppid,
                "HWMMntcTypes": component.get("v.HWMMntcTypes"),
                "qtyTypeMap" : component.get("v.qtyTypeMap"),  //CSI 304 QTY TYPE ENHANCEMENT by Stuti
                "isCatm" : component.get("v.isCatm"),
                "subsOnlyProdNames" : component.get("v.subsOnlyProdNames"), //EBA-2174
                "subsOnlyRevenueTypes" : component.get("v.subsOnlyRevenueTypes") //EBA-2174
            
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
        
    },
    formPress:function(cmp,event,helper){
                    
			var action = cmp.get("c.getProductList");
            action.setStorable();
            action.setParams({
                "searchKey": cmp.get("v.searchKey"),
                "SchFavListId" : cmp.get("v.SchFavListId"),
                "OppId" : cmp.get("v.OpportunityId")
               
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                  if(cmp.isValid() && state === "SUCCESS") {
                        
                        var ResultData=[];
                        var AllreadyQueryDataSet=[];
                        for(var i=0;i<response.getReturnValue().length;i++){
                            
                            ResultData.push({ProductId:response.getReturnValue()[i].Id,ProductName:response.getReturnValue()[i].Name,IsSchedule:false,IsFav:false,IsCheckBoxSelected:false,ServiceOfferCatogery:response.getReturnValue()[i].Service_Offer_Category__c,LeadTime_Wks:response.getReturnValue()[i].LEAD_TIME_WKS__c, avail_Subscription:response.getReturnValue()[i].Available_for_Subscription__c,  availAsConnectedHWM:response.getReturnValue()[i].Available_as_Connected_HWM__c}); 
                            AllreadyQueryDataSet.push(response.getReturnValue()[i].Id);
                        }
                        
                        //cmp.set("v.ResultData",cmp.get("v.SchFavList").concat(ResultData)); 
                        
						var PillsWithFilter=[];
                        var PillsWithOutFilter=[];
                        var PillsArray = cmp.get("v.PillsArray");
                        //({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery});    
                        for(var i=0;i<cmp.get("v.PillsArray").length;i++){
                            
                            for(var j=0;j<cmp.get("v.SchFavList").length;j++){
                                
                                if(PillsArray[i] == cmp.get("v.SchFavList")[j].ServiceOfferCatogery){ 
                                   
                                   PillsWithFilter.push({ProductId:cmp.get("v.SchFavList")[j].ProductId,ProductName:cmp.get("v.SchFavList")[j].ProductName,IsSchedule:cmp.get("v.SchFavList")[j].IsSchedule,IsFav:cmp.get("v.SchFavList")[j].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:cmp.get("v.SchFavList")[j].IsCheckBoxSelected,ServiceOfferCatogery:cmp.get("v.SchFavList")[j].ServiceOfferCatogery,LeadTime_Wks:cmp.get("v.SchFavList")[j].LeadTime_Wks});
                                }
                                
                                if(PillsArray[i] != cmp.get("v.SchFavList")[j].ServiceOfferCatogery){
                                    
                                   PillsWithOutFilter.push({ProductId:cmp.get("v.SchFavList")[j].ProductId,ProductName:cmp.get("v.SchFavList")[j].ProductName,IsSchedule:cmp.get("v.SchFavList")[j].IsSchedule,IsFav:cmp.get("v.SchFavList")[j].IsFav,styleClass:"",IsCheckBoxSelected:cmp.get("v.SchFavList")[j].IsCheckBoxSelected,ServiceOfferCatogery:cmp.get("v.SchFavList")[j].ServiceOfferCatogery,LeadTime_Wks:cmp.get("v.SchFavList")[j].LeadTime_Wks});  
                                }
                            }

                        }
                        
                       
                        //cmp.set('v.SchFavList',);
                        PillsWithFilter.concat(PillsWithOutFilter);
                        
                        //console.log(PillsWithFilter);
                        
                        cmp.set("v.ResultData",PillsWithFilter.concat(ResultData));                       
                      
                        cmp.set("v.AllreadyQueryDataSet",cmp.get("v.SchFavIdList").concat(AllreadyQueryDataSet));
                        cmp.set("v.NoOfRecord",cmp.get("v.ResultData").length);
                        cmp.set("v.PillsArray",cmp.get("v.PillsArray"));
                        
                    }
                  
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
    },
    SearchWithFilter:function(cmp,event,FilterString,searchKey,SchFavListId){
        var action = cmp.get("c.SearchWithFilter");
            action.setStorable();
            action.setParams({
                "FilterString": FilterString,
                "searchKey":searchKey,
                "SchFavListId": SchFavListId,
                "OppId": cmp.get("v.OpportunityId")
               
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                        
                        var ResultData=[];
                        var AllreadyQueryDataSet=[];
                        for(var i=0;i<response.getReturnValue().length;i++){
                            
                            ResultData.push({ProductId:response.getReturnValue()[i].Id,ProductName:response.getReturnValue()[i].Name,IsSchedule:false,IsFav:false,IsCheckBoxSelected:false,ServiceOfferCatogery:response.getReturnValue()[i].Service_Offer_Category__c,LeadTime_Wks:response.getReturnValue()[i].LEAD_TIME_WKS__c, avail_Subscription:response.getReturnValue()[i].Available_for_Subscription__c, availAsConnectedHWM:response.getReturnValue()[i].Available_as_Connected_HWM__c}); 
                            AllreadyQueryDataSet.push(response.getReturnValue()[i].Id);
                        }
                        
                        //cmp.set("v.ResultData",cmp.get("v.SchFavList").concat(ResultData)); 
                        
                        var PillsWithFilter=[];
                        var PillsWithOutFilter=[];
                        var PillsArray = cmp.get("v.PillsArray");
                        //({ProductId:response.getReturnValue()[i].ProductId,ProductName:response.getReturnValue()[i].ProductName,IsSchedule:response.getReturnValue()[i].IsSchedule,IsFav:response.getReturnValue()[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:response.getReturnValue()[i].IsCheckBoxSelected,ServiceOfferCatogery:response.getReturnValue()[i].ServiceOfferCatogery});    
                        for(var i=0;i<cmp.get("v.PillsArray").length;i++){
                            
                            for(var j=0;j<cmp.get("v.SchFavList").length;j++){
                                
                                if(PillsArray[i] == cmp.get("v.SchFavList")[j].ServiceOfferCatogery){ 
                                   
                                   PillsWithFilter.push({ProductId:cmp.get("v.SchFavList")[j].ProductId,ProductName:cmp.get("v.SchFavList")[j].ProductName,IsSchedule:cmp.get("v.SchFavList")[j].IsSchedule,IsFav:cmp.get("v.SchFavList")[j].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:cmp.get("v.SchFavList")[j].IsCheckBoxSelected,ServiceOfferCatogery:cmp.get("v.SchFavList")[j].ServiceOfferCatogery,LeadTime_Wks:cmp.get("v.SchFavList")[j].LeadTime_Wks});
                                }
                                
                                if(PillsArray[i] != cmp.get("v.SchFavList")[j].ServiceOfferCatogery){
                                    
                                   PillsWithOutFilter.push({ProductId:cmp.get("v.SchFavList")[j].ProductId,ProductName:cmp.get("v.SchFavList")[j].ProductName,IsSchedule:cmp.get("v.SchFavList")[j].IsSchedule,IsFav:cmp.get("v.SchFavList")[j].IsFav,styleClass:"",IsCheckBoxSelected:cmp.get("v.SchFavList")[j].IsCheckBoxSelected,ServiceOfferCatogery:cmp.get("v.SchFavList")[j].ServiceOfferCatogery,LeadTime_Wks:cmp.get("v.SchFavList")[j].LeadTime_Wks});  
                                }
                            }

                        }
                        
                       
                        //cmp.set('v.SchFavList',);
                        PillsWithFilter.concat(PillsWithOutFilter);
                        
                        //console.log(PillsWithFilter);
                        
                        cmp.set("v.ResultData",PillsWithFilter.concat(ResultData)); 
                        
                        
                        cmp.set("v.AllreadyQueryDataSet",cmp.get("v.SchFavIdList").concat(AllreadyQueryDataSet));
                        //cmp.set("v.NoOfRecord",cmp.get("v.ResultData").length);
                        //cmp.set("v.PillsArray",PillsArray);
                    }
                 
                  
           });
           $A.getCallback(function() {
               $A.enqueueAction(action); 
           })(); 
    },
    Render_Schedule:function(cmp,event,helper){
            var searchKey =cmp.get("v.searchKey");        
            var PillsArray=cmp.get('v.PillsArray');
            if(PillsArray == ''){
                
                if(searchKey){
                    helper.formPress(cmp,event,helper);
                }
                
                else{
                    helper.doInit(cmp,event,helper);
                }
            }
             
            
            else{
                
                if(searchKey){
                	//alert('1'); 
                    helper.SearchWithFilter(cmp,event,PillsArray,searchKey,cmp.get("v.SchFavIdList"));
                }
                else{
                    helper.FetchFilterData(cmp,event,PillsArray,cmp.get("v.SchFavIdList"));
                }
            }
    },
    Get_PMDM_Catogery : function(component, event){
    	
    	var Temp=[];
        var action = component.get('c.get_PMDM_Product_Catoget'); 
        action.setParams({'OppId': component.get("v.OpportunityId")});
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                //component.set('v.sObjList', a.getReturnValue());
                for(var i=0;i<a.getReturnValue().length;i++){
                    //alert(a.getReturnValue()[i].Pmdm_Product_Category__c);
                    Temp.push({Name:a.getReturnValue()[i].Service_Offer_Category__c,isSelected:false});
                }
                component.set("v.RevenueFilter",Temp);
            }
            
        });
        $A.enqueueAction(action);    
   },
    getIndusryFilterValue :function(component,event){ 
        var Temp=[];
        var action = component.get('c.getIndusryFilterValue'); 
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state 
            if(state == 'SUCCESS') {
                //component.set('v.sObjList', a.getReturnValue());
                for(var i=0;i<a.getReturnValue().length;i++){
                    //alert(a.getReturnValue()[i].Pmdm_Product_Category__c);
                    Temp.push({Name:a.getReturnValue()[i].Industry__c,isSelected:false});
                }
                component.set("v.IndustryFilter",Temp);
            }
            
        });
        $A.enqueueAction(action); 
    },
    buldHandleAddProductsFirstPhaseHlpe: function(cmp, event, helper){
    	 var ResultData=cmp.get("v.ResultData");
         var TempResultDataId=[];
            var IsAllreadySchdeule=false;
            var isAnySubcriptionableProd = false,isAnyServiceProd = false, isAnyConnectedHWMProd = false, tempRcrd, confirmSubMdlHdr, isAnyQtyTypeProd=false/*CSI-304 by Stuti*/ ;
            var tempSelectedSubscriptionableList = [] ;
            var tempselectedNONSubcrionableProdList = [] ;
        debugger;
        /*CSI-304 by Stuti*/
        if(cmp.get("v.isCatm")){
            isAnyQtyTypeProd = true;
        }
            //console.log('Result data '+ JSON.stringify(ResultData));
            for(var i=0;i<ResultData.length;i++){
                //console.debug(' Diwakar '+ResultData[i].avail_Subscription);
                /*if(ResultData[i].IsCheckBoxSelected == true && ResultData[i].avail_Subscription == true){  below if condition add  by Diwakar*/
                
                if(ResultData[i].IsCheckBoxSelected == true && ResultData[i].avail_Subscription == true && ResultData[i].ServiceOfferCatogery != 'Cloud' && (!(cmp.get("v.isCatm"))) && !(cmp.get("v.subsOnlyProdNames").includes(ResultData[i].ProductName)== true || cmp.get("v.subsOnlyRevenueTypes").includes(ResultData[i].ServiceOfferCatogery)== true ? true:false)){ // EBA_SF-2174 adding check in if for NCR Payment Processing by Stuti
                     //TempResultData.push({ProductId:ResultData[i].ProductId,ProductName:ResultData[i].ProductName,IsSchedule:true,IsFav:ResultData[i].IsFav,styleClass:"hoverTable",IsCheckBoxSelected:false,ServiceOfferCatogery:ResultData[i].ServiceOfferCatogery});
                    tempRcrd = {ProductId:ResultData[i].ProductId,
                                ProductName:ResultData[i].ProductName,
                                checkOLISubcription : false,
                                isServiceLineItem : false,
                                selectLineItemType : '',
                                isAvlAsCnctHWM : false,	
                                selectHWMMntcType : '',
                                isQtyTypApplicable : false,
                                qtyTyp : ''};
                    
                    if(!cmp.get("v.isCatm")){
                        if (!$A.util.isEmpty(cmp.get("v.renewablRevnTypes")) && !$A.util.isEmpty(ResultData[i].ServiceOfferCatogery) && cmp.get("v.renewablRevnTypes").includes(ResultData[i].ServiceOfferCatogery)) {
                        	isAnyServiceProd = true;
                        	tempRcrd.isServiceLineItem = true;     
                    	} 
                    }
                    if(!cmp.get("v.isCatm")){
                    	if(ResultData[i].availAsConnectedHWM == true) {
                        	isAnyConnectedHWMProd = true;  
                        	tempRcrd.isAvlAsCnctHWM = true;    
                    }
                }
                if(cmp.get("v.isCatm")){
                    tempRcrd.isQtyTypApplicable = true;
                }
                    tempSelectedSubscriptionableList.push(tempRcrd);
         
                    isAnySubcriptionableProd = true;
                    
                }  else if(ResultData[i].IsCheckBoxSelected == true) {
                   tempRcrd = {ProductId:ResultData[i].ProductId ,
                                  ProductName:ResultData[i].ProductName,
                                  checkOLISubcription : false,
                                  isServiceLineItem : false,
                                  selectLineItemType : '',
                               	  isAvlAsCnctHWM : false,
                                  selectHWMMntcType : '',
                               	  isQtyTypApplicable : false,
                                  qtyTyp : ''
                                 };                
                    
                    if(!cmp.get("v.isCatm")){
                    if (cmp.get("v.renewablRevnTypes").includes(ResultData[i].ServiceOfferCatogery)) {
                        isAnyServiceProd = true;
                        tempRcrd.isServiceLineItem = true;     
                    }}
                        
                    if(!cmp.get("v.isCatm")){
                   if(ResultData[i].availAsConnectedHWM == true) {
                        isAnyConnectedHWMProd = true;     
                        tempRcrd.isAvlAsCnctHWM = true;  
                   }
                    }
                    if(cmp.get("v.isCatm")){
                        tempRcrd.isQtyTypApplicable = true;
                    }
                   
                   tempselectedNONSubcrionableProdList.push(tempRcrd);
                }   
            }
            
            cmp.set("v.confirmSubscriptionModal", isAnySubcriptionableProd );
            cmp.set("v.confirmServTypeSelModal", isAnyServiceProd) ;
            cmp.set("v.confirmHWMTypeModal", isAnyConnectedHWMProd) ;
            cmp.set("v.selectedSubcrionableProdList", tempSelectedSubscriptionableList );
            cmp.set("v.selectedNONSubcrionableProdList", tempselectedNONSubcrionableProdList); 
            cmp.set("v.confirmQtyTypModal", isAnyQtyTypeProd);
            
            if(isAnySubcriptionableProd == false && isAnyServiceProd == false && isAnyConnectedHWMProd == false && isAnyQtyTypeProd == false) {
                var act = cmp.get("c.BulkschProcessThroughAdd") ;
                act.setParams({
                    cmp : cmp ,
                    event : event ,
                    helper : helper
                });
                $A.enqueueAction( act) ;
                
            } else {
                if (isAnySubcriptionableProd == true && (isAnyServiceProd == true || isAnyConnectedHWMProd == true || isAnyQtyTypeProd == true)) {
                    confirmSubMdlHdr = "Please select product(s) to be added as a subscription and update other fields.";       
                } else if (isAnySubcriptionableProd == true) {
                    confirmSubMdlHdr = "Please select product(s) to be added as a subscription.";         
                } else if (isAnyServiceProd == true || isAnyConnectedHWMProd == true || isAnyQtyTypeProd == true) {
                    confirmSubMdlHdr = "Please update below fields of product(s)."; //"Please update the line item type of product(s).         
                }
                cmp.set("v.confirmSubModalHeader", confirmSubMdlHdr); 	
            }
        cmp.set("v.PrevSelectConfrm",false);
        cmp.set("v.SeletedProductCount",parseInt(0));
        cmp.set("v.DisableBulkProcess",false);
        
        this.RealTimeSearchhelper(cmp,event,helper);
       
	},
    RealTimeSearchhelper : function(cmp,event,helper) {
           const ResultData = cmp.get("v.ResultData"); 
           cmp.set("v.NoOfRecord",0);
           cmp.set("v.AllreadyQueryDataSet",'');
           var searchKey =cmp.get("v.searchKey");
           var PillsArray=[]; 
            
           for(var i=0;i<cmp.find('chek_Box').length;i++){
                //alert(cmp.find('chek_Box')[i].get('v.label'));
               if(cmp.find('chek_Box')[i].get("v.value")){
                   PillsArray.push(cmp.find('chek_Box')[i].get('v.label')); 
               }
                
           }
            
           if(searchKey !=''){
                   
                    if(PillsArray != ''){
                            helper.SearchWithFilter(cmp,event,PillsArray,searchKey,cmp.get("v.SchFavIdList"));
                            cmp.set("v.PillsArray",PillsArray);   
                    }
                    else{  
                        this.formPress(cmp,event,helper);
                        cmp.set("v.PillsArray",PillsArray); 
                    }
                }
                else{
                    if(PillsArray.length>0){
                        //cmp.set("v.FilterAssistanceMap",filterAsistMap);
                        this.FetchFilterData(cmp,event,PillsArray,cmp.get("v.SchFavIdList"));
                        cmp.set("v.PillsArray",PillsArray);
                        }
                        else{
                            this.doInit(cmp,event,helper);
                            cmp.set("v.PillsArray",PillsArray);
                        } 
                } 
            
            
            cmp.set("v.PillsArray",PillsArray);
    },
    formPresshlpr:function(cmp,event,helper){
    	var index = event.currentTarget.dataset.rowIndex;
        var PillsArray=cmp.get('v.PillsArray');
        var searchKey =cmp.get("v.searchKey");
        
        if(event.keyCode === 13) {
             //alert('Search Called');
            cmp.set("v.clearSearch",'close');
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
            
        }
        
        else if(index == 'ButtonPress'){
             cmp.set("v.clearSearch",'close');
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
          
            
        }
	},
             isCatmOpp : function(component, event, helper) {
		 var action = component.get("c.getOpportunity");
        action.setParams({ 
        OppId :component.get("v.OpportunityId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if(state === "SUCCESS") {  
                component.set("v.isCatm",response.getReturnValue());
                console.log('Test JSon'+JSON.stringify(response.getReturnValue()));
            }
     else if(state === "ERROR") {
                
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message) {
                       alert("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    alert('4');
                }
            }
                else{
                    alert('>>>>'+'Please reload the page.');
                }
             //component.set("v.ShowHideSpinner",false);
             
        });     
        $A.enqueueAction(action);
        
                
	}
})