({
    doinitHelper : function(component, event, helper) {
        component.set("v.showSpinner",true);
        /*var action = component.get("c.getstatusDashboardCount");
        action.setParams({ accountId : component.get("v.recordId") });
        var obj = {};
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state === 'SUCCESS'){
                console.log('response'+JSON.stringify(response.getReturnValue()));
                //component.set("v.populateData",response.getReturnValue());
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);*/
    },
    creatingPicklistHelper : function(component, event, helper) {        
        component.set("v.showSpinner",true);
        var action = component.get("c.getAccount");
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();   
                console.log(retResponse);
                console.log('response'+JSON.stringify(response.getReturnValue()));
                component.set('v.DataCollection',response.getReturnValue());
                //console.log('collection'+JSON.stringify(component.get('v.DataCollection')));
                var opts = [];
                var summerizeData;
                 var QuoteInProcess =[];
                 var OrdersSubmittedBOC =[];
                 var OrdersReturned =[];
                var NotBookedReasons=[];
                
                for( var i=0; i < retResponse.length; i++ ){
                    opts.push({
                        label: retResponse[i].AccountName,
                        value: retResponse[i].AccountId
                    });                     
                }
                if(retResponse.length>0){
                    //Prepare  summerizeData for dashboard
                    summerizeData= {
                        Awaiting_Approvals : retResponse[0].Awaiting_Approvals,
                        InProgress : retResponse[0].InProgress,
                        Config_Error:retResponse[0].Config_Error,
                        Import_Issue:retResponse[0].Import_Issue,
                        Incorrect_Submission:retResponse[0].Incorrect_Submission,
                        Missing_Documentations:retResponse[0].Missing_Documentations,
                        None_OrderFieldsNull:retResponse[0].None_OrderFieldsNull
                    };
                    
                    //Prepare  Reason list
                    for(var i=0; i<retResponse[0].NotBookedReasons.length;i++){
                        NotBookedReasons.push({
                            ReasonName: retResponse[0].NotBookedReasons[i].ReasonName,
                            NumberOfQuotes:   retResponse[0].NotBookedReasons[i].NumberOfQuotes
                        });
                    }
                   //Prepare  QuoteInProcess list
                    for(var i=0; i<retResponse[0].QuotesInProcess.length;i++){
                        QuoteInProcess.push({
                            QuoteNo: retResponse[0].QuotesInProcess[i].QuoteNo,
                            Owner:   retResponse[0].QuotesInProcess[i].Owner,
                            OpportunityNumber: retResponse[0].QuotesInProcess[i].OpportunityNumber,
                            OpportunityValue: retResponse[0].QuotesInProcess[i].OpportunityValue,
                            QuoteTotal: retResponse[0].QuotesInProcess[i].QuoteTotal,
                            DateModified: retResponse[0].QuotesInProcess[i].DateModified,
                            HW_SW_Status: retResponse[0].QuotesInProcess[i].HW_SW_Status,
                            Main_SupportStatus: retResponse[0].QuotesInProcess[i].Main_SupportStatus,
                            FinancialCallOff:retResponse[0].QuotesInProcess[i].FinancialCallOff
                        });
                    }
                    
                    //Prepare  OrdersSubmittedBOC list
                    for(var i=0; i<retResponse[0].OrderSubmittedToBOC.length;i++){
                        OrdersSubmittedBOC.push({
                            QuoteNo: retResponse[0].OrderSubmittedToBOC[i].QuoteNo,
                            Owner:   retResponse[0].OrderSubmittedToBOC[i].Owner,
                            OpportunityNumber: retResponse[0].OrderSubmittedToBOC[i].OpportunityNumber,
                            OpportunityValue: retResponse[0].OrderSubmittedToBOC[i].OpportunityValue,
                            QuoteTotal: retResponse[0].OrderSubmittedToBOC[i].QuoteTotal,
                            DateModified: retResponse[0].OrderSubmittedToBOC[i].DateModified,
                            Status: retResponse[0].OrderSubmittedToBOC[i].Status,
                            ActionOwner: retResponse[0].OrderSubmittedToBOC[i].ActionOwner,
                            PendingReason :retResponse[0].OrderSubmittedToBOC[i].PendingReason,
                            FinancialCallOff:retResponse[0].OrderSubmittedToBOC[i].FinancialCallOff
                        });
                    }
                    
                    //Prepare  OrderReturnedToSales list
                    for(var i=0; i<retResponse[0].OrderReturnedToSales.length;i++){
                        OrdersReturned.push({
                            QuoteNo: retResponse[0].OrderReturnedToSales[i].QuoteNo,
                            Owner:   retResponse[0].OrderReturnedToSales[i].Owner,
                            OpportunityNumber: retResponse[0].OrderReturnedToSales[i].OpportunityNumber,
                            OpportunityValue: retResponse[0].OrderReturnedToSales[i].OpportunityValue,
                            QuoteTotal: retResponse[0].OrderReturnedToSales[i].QuoteTotal,
                            DateModified: retResponse[0].OrderReturnedToSales[i].DateModified,
                            ReturnComment: retResponse[0].OrderReturnedToSales[i].ReturnComment,
                            ReturnReason: retResponse[0].OrderReturnedToSales[i].ReturnReason,
                            FinancialCallOff:retResponse[0].OrderReturnedToSales[i].FinancialCallOff
                        });
                    }
                }
                //console.log('QuoteInProcess'+JSON.stringify(QuoteInProcess));
                component.set('v.AccountOptions',opts);
                component.set('v.summerizeData',summerizeData);
                component.set('v.QuoteInProcess',QuoteInProcess);
                component.set('v.OrdersSubmittedBOC',OrdersSubmittedBOC);
                component.set('v.OrdersReturned',OrdersReturned);
                component.set('v.NotBookedReasons',NotBookedReasons);
               console.log('OrdersSubmittedBOC'+JSON.stringify(OrdersSubmittedBOC));
                component.set("v.showSpinner",false);
            }
            else{
                //console.log('Error');
                console.log('Fisrt log'+response.getError());
                var errors = response.getError();
                if(errors[0] && errors[0].message){// To show other type of exceptions
                    console.log('Second log'+errors[0].message);
                    var showToast = $A.get("e.force:showToast"); 
                        showToast.setParams({ 
                        'title' : 'Error!', 
                        'type' :   'error',
                        'message' : errors[0].message+'.Contact to Admin. '
                        }); 
                        showToast.fire();
                }
                if(errors[0] && errors[0].pageErrors) // To show DML exceptions
                     console.log('Third log'+ errors[0].pageErrors[0].message);
                     
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    onChangeAccountHelper : function(component, event, helper) {        
        component.set("v.showSpinner",true);
        console.log(component.find("mySelect").get("v.value"));
        var AccId = component.find("mySelect").get("v.value");
        var summerizeData;
        var QuoteInProcess =[];
        var OrdersSubmittedBOC =[];
        var OrdersReturned =[];
        var NotBookedReasons=[];
        
        for(var i=0;i<component.get('v.DataCollection').length;i++){
            if(AccId == component.get('v.DataCollection')[i].AccountId){
                //Prepare summerize data
               summerizeData= {
                        Awaiting_Approvals : component.get('v.DataCollection')[i].Awaiting_Approvals,
                        InProgress : component.get('v.DataCollection')[i].InProgress,
                        Config_Error:component.get('v.DataCollection')[i].Config_Error,
                        Import_Issue:component.get('v.DataCollection')[i].Import_Issue,
                        Incorrect_Submission:component.get('v.DataCollection')[i].Incorrect_Submission,
                        Missing_Documentations:component.get('v.DataCollection')[i].Missing_Documentations,
                        None_OrderFieldsNull:component.get('v.DataCollection')[i].None_OrderFieldsNull
               }; 
                
                //Prepare  Reason list
                    for(var j=0;j<component.get('v.DataCollection')[i].NotBookedReasons.length;j++){
                        NotBookedReasons.push({
                            ReasonName: component.get('v.DataCollection')[i].NotBookedReasons[j].ReasonName,
                            NumberOfQuotes:   component.get('v.DataCollection')[i].NotBookedReasons[j].NumberOfQuotes
                        });
                    }
                
                for(var j=0;j<component.get('v.DataCollection')[i].QuotesInProcess.length;j++){
                    //Prepare QuoteInProcess list   
                    QuoteInProcess.push({
                            QuoteNo: component.get('v.DataCollection')[i].QuotesInProcess[j].QuoteNo,
                            Owner:   component.get('v.DataCollection')[i].QuotesInProcess[j].Owner,
                            OpportunityNumber: component.get('v.DataCollection')[i].QuotesInProcess[j].OpportunityNumber,
                            OpportunityValue: component.get('v.DataCollection')[i].QuotesInProcess[j].OpportunityValue,
                            QuoteTotal: component.get('v.DataCollection')[i].QuotesInProcess[j].QuoteTotal,
                            DateModified: component.get('v.DataCollection')[i].QuotesInProcess[j].DateModified,
                            HW_SW_Status: component.get('v.DataCollection')[i].QuotesInProcess[j].HW_SW_Status,
                            Main_SupportStatus: component.get('v.DataCollection')[i].QuotesInProcess[j].Main_SupportStatus,
                            FinancialCallOff:component.get('v.DataCollection')[i].QuotesInProcess[j].FinancialCallOff
                        });    
                }
                
                //Prepare OrdersSubmittedBOC list
                for(var j=0;j<component.get('v.DataCollection')[i].OrderSubmittedToBOC.length;j++){
                      
                    OrdersSubmittedBOC.push({
                            QuoteNo: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].QuoteNo,
                            Owner:   component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].Owner,
                            OpportunityNumber: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].OpportunityNumber,
                            OpportunityValue: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].OpportunityValue,
                            QuoteTotal: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].QuoteTotal,
                            DateModified: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].DateModified,
                            Status: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].Status,
                            ActionOwner: component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].ActionOwner,
                            PendingReason :component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].PendingReason,
                            FinancialCallOff:component.get('v.DataCollection')[i].OrderSubmittedToBOC[j].FinancialCallOff
                        });   
                }
                
                //Prepare OrdersReturned list
                for(var j=0;j<component.get('v.DataCollection')[i].OrderReturnedToSales.length;j++){
                      
                    OrdersReturned.push({
                            QuoteNo: component.get('v.DataCollection')[i].OrderReturnedToSales[j].QuoteNo,
                            Owner:   component.get('v.DataCollection')[i].OrderReturnedToSales[j].Owner,
                            OpportunityNumber:component.get('v.DataCollection')[i].OrderReturnedToSales[j].OpportunityNumber,
                            OpportunityValue: component.get('v.DataCollection')[i].OrderReturnedToSales[j].OpportunityValue,
                            QuoteTotal: component.get('v.DataCollection')[i].OrderReturnedToSales[j].QuoteTotal,
                            DateModified: component.get('v.DataCollection')[i].OrderReturnedToSales[j].DateModified,
                            ReturnComment: component.get('v.DataCollection')[i].OrderReturnedToSales[j].ReturnComment,
                            ReturnReason: component.get('v.DataCollection')[i].OrderReturnedToSales[j].ReturnReason,
                            FinancialCallOff:component.get('v.DataCollection')[i].OrderReturnedToSales[j].FinancialCallOff
                        });  
                }
                
                
                
                component.set('v.summerizeData',summerizeData);
                component.set('v.QuoteInProcess',QuoteInProcess);
                component.set('v.OrdersSubmittedBOC',OrdersSubmittedBOC);
                component.set('v.OrdersReturned',OrdersReturned);
                 component.set('v.NotBookedReasons',NotBookedReasons);
                break;
            }
        }
        component.set("v.showSpinner",false);
        
    }
    
})