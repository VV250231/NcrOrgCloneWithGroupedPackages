({
    doInit : function(component, event, helper) {
        debugger ;
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            for (i = 0; i < sURLVariables.length; i++) { 
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };
        
        var orderId = getUrlParameter('c__orderId');
        var accountName = getUrlParameter('c__acctN');
        var orderNum = getUrlParameter('c__orderNbr');
        
        component.set("v.accountName", accountName);
        component.set("v.originalOrderNbr", orderNum);
        component.set("v.orderId", orderId);
        
            
        
       
        component.set("v.showSpinner" , true) ;
        
        component.set("v.columns" , [   
            { label : 'Ordered Item' , fieldName : 'Ordered_Item__c' , type: 'text' , initialWidth : 150} ,   
            { label : 'Product Description' , fieldName : 'Product_Description__c', type: 'Text Area', initialWidth : 255 } ,			
            { label : 'SERIAL NUMBER' , fieldName : 'SERIAL_NUMBER__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Arrival Date' , fieldName : 'PROMISE_DATE__c' , type: 'date-local' , initialWidth : 100} ,
            { label : 'Requested Date' , fieldName : 'Request_Date__c' , type: 'date-local' , initialWidth : 150} ,
            { label : 'Line Status' , fieldName : 'Line_Status__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Quantity' , fieldName : 'Quantity__c' , type: 'number' , initialWidth : 150, cellAttributes: { alignment: 'left' }} ,
            { label : 'Qty Shipped' , fieldName : 'Qty_Shipped__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Qty Cancelled' , fieldName : 'Qty_Cancelled__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Order Source' , fieldName : 'Order_Source__c	' , type: 'text' , initialWidth : 150} ,
            { label : 'Order Source Reference' , fieldName : 'Order_Source_Reference__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Cust PO Line Number' , fieldName : 'Cust_PO_Line_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Cust Product Desc' , fieldName : 'Cust_Product_Desc__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Line Number' , fieldName : 'Line_Number__c' , type: 'number' , initialWidth : 150, cellAttributes: { alignment: 'left' }},
            { label : 'Unit Selling Price' , fieldName : 'Unit_Selling_Price__c' , type :'currency' ,initialWidth : 150, cellAttributes: { alignment: 'left' },typeAttributes: { currencyCode : 'USD' , maximumFractionDigits : 2 }} ,
            { label : 'Tax Amount' , fieldName : 'Tax_Amount__c' , type :'currency' ,initialWidth : 150, cellAttributes: { alignment: 'left' },typeAttributes: { currencyCode : 'USD' , maximumFractionDigits : 2 }} ,
            { label : 'Extended Price' , fieldName : 'Extended_Price__c' , type :'currency' ,initialWidth : 150, cellAttributes: { alignment: 'left' },typeAttributes: { currencyCode : 'USD' , maximumFractionDigits : 2 }} ,
            { label : 'SW Key End Date' , fieldName : 'SW_Key_End_Date__c' , type: 'date' , initialWidth : 150} ,  
            { label : 'Carrier Name' , fieldName : 'Carrier_Name__c' , type: 'text' , initialWidth : 150} ,
            { label : 'EMS Airway Shipment Number' , fieldName : 'EMS_Airway_Shipment_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'EMS Shipment Number' , fieldName : 'EMS_Shipment_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Additional Tracking Info' , fieldName : 'Additional_Tracking_Info__c' , type: 'Text Area' , initialWidth : 255} ,
            { label : 'Freight Forwarder' , fieldName : 'Freight_Forwarder__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Package Number High' , fieldName : 'Package_Number_High__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Package Number Low' , fieldName : 'Package_Number_Low__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Partial Invoice Flag' , fieldName : 'Partial_Invoice_Flag__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Pro Number' , fieldName : 'Pro_Number__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Deliver To Contact' , fieldName : 'Deliver_To_Contact__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Deliver To Location' , fieldName : 'Deliver_To_Location__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Delivery Status' , fieldName : 'Delivery_Status__c' , type: 'text' , initialWidth : 150} ,
            { label : 'PS Project Number' , fieldName : 'PS_Project_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Shipping Date' , fieldName : 'Shipping_Date__c' , type: 'date' , initialWidth : 100} ,
            { label : 'Intermediate Ship To' , fieldName : 'Intermediate_Ship_To__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Shipping Method' , fieldName : 'Shipping_Method__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Ship To' , fieldName : 'Ship_To__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Ship To Address1' , fieldName : 'Ship_To_Address1__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address2' , fieldName : 'Ship_To_Address2__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address3' , fieldName : 'Ship_To_Address3__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address4' , fieldName : 'Ship_To_Address4__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address5' , fieldName : 'Ship_To_Address5__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Contact' , fieldName : 'Ship_To_Contact__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Ship To Customer' , fieldName : 'Ship_To_Customer__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Bill To' , fieldName : 'Bill_To__c' , type: 'Phone', initialWidth : 255 } ,
            { label : 'Bill To Address1' , fieldName : 'Bill_To_Address1__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address2' , fieldName : 'Bill_To_Address2__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address3' , fieldName : 'Bill_To_Address3__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address4' , fieldName : 'Bill_To_Address4__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address5' , fieldName : 'Bill_To_Address5__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Contact' , fieldName : 'Bill_To_Contact__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Bill To Customer' , fieldName : 'Bill_To_Customer__c' , type: 'text' , initialWidth : 150} ,
        ]) ;
        
        /*component.set("v.columns" , [               
            { label : 'Shipping Date' , fieldName : 'Shipping_Date__c' , type: 'date-local' , initialWidth : 100} ,
            { label : 'Additional Tracking Info' , fieldName : 'Additional_Tracking_Info__c' , type: 'Text Area' , initialWidth : 255} ,
            
            { label : 'PROMISE DATE' , fieldName : 'PROMISE_DATE__c' , type: 'date-local' , initialWidth : 100} ,
             
            { label : 'Bill To' , fieldName : 'Bill_To__c' , type: 'Phone', initialWidth : 255 } ,
            { label : 'Bill To Address1' , fieldName : 'Bill_To_Address1__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address2' , fieldName : 'Bill_To_Address2__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address3' , fieldName : 'Bill_To_Address3__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address4' , fieldName : 'Bill_To_Address4__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Address5' , fieldName : 'Bill_To_Address5__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Bill To Contact' , fieldName : 'Bill_To_Contact__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Bill To Customer' , fieldName : 'Bill_To_Customer__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Cust PO Line Number' , fieldName : 'Cust_PO_Line_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Cust Product Desc' , fieldName : 'Cust_Product_Desc__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Deliver To Contact' , fieldName : 'Deliver_To_Contact__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Deliver To Location' , fieldName : 'Deliver_To_Location__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Delivery Status' , fieldName : 'Delivery_Status__c' , type: 'text' , initialWidth : 150} ,
            { label : 'EMS Airway Shipment Number' , fieldName : 'EMS_Airway_Shipment_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'EMS Shipment Number' , fieldName : 'EMS_Shipment_Number__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Extended Price' , fieldName : 'Extended_Price__c' , type :'currency' ,initialWidth : 150, cellAttributes: { alignment: 'left' }, typeAttributes: { currencyCode : 'USD' , maximumFractionDigits : 2 }} ,
            { label : 'Carrier Name' , fieldName : 'Carrier_Name__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Freight Forwarder' , fieldName : 'Freight_Forwarder__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Intermediate Ship To' , fieldName : 'Intermediate_Ship_To__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Line Number' , fieldName : 'Line_Number__c' , type: 'number' , initialWidth : 150, cellAttributes: { alignment: 'left' }},
            { label : 'Line Status' , fieldName : 'Line_Status__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Order Source' , fieldName : 'Order_Source__c	' , type: 'text' , initialWidth : 150} ,
            { label : 'Order Source Reference' , fieldName : 'Order_Source_Reference__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Package Number High' , fieldName : 'Package_Number_High__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Package Number Low' , fieldName : 'Package_Number_Low__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Partial Invoice Flag' , fieldName : 'Partial_Invoice_Flag__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Pro Number' , fieldName : 'Pro_Number__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Product Description' , fieldName : 'Product_Description__c', type: 'Text Area', initialWidth : 255 } ,
            { label : 'Ordered Item' , fieldName : 'Ordered_Item__c' , type: 'text' , initialWidth : 150} ,
            { label : 'PS Project Number' , fieldName : 'PS_Project_Number__c' , type: 'text' , initialWidth : 150} ,
           { label : 'Unit Selling Price' , fieldName : 'Unit_Selling_Price__c' , type: 'currency' , initialWidth : 150, typeAttributes: { currencyCode : 'USD' , maximumFractionDigits : 2 },  cellAttributes: { alignment: 'left' }} ,
             { label : 'Tax Amount' , fieldName : 'Tax_Amount__c' , type: 'currency' , initialWidth : 150,typeAttributes: { currencyCode : 'USD' , maximumFractionDigits : 2 },  cellAttributes: { alignment: 'left' }} , 
             
            { label : 'Quantity' , fieldName : 'Quantity__c' , type: 'number' , initialWidth : 150, cellAttributes: { alignment: 'left' }},
            { label : 'Qty Cancelled' , fieldName : 'Qty_Cancelled__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Qty Shipped' , fieldName : 'Qty_Shipped__c' , type: 'number' , initialWidth : 150} ,
            { label : 'Request Date' , fieldName : 'Request_Date__c' , type: 'date-local' , initialWidth : 150} ,
            { label : 'SERIAL NUMBER' , fieldName : 'SERIAL_NUMBER__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Shipping Method' , fieldName : 'Shipping_Method__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Ship To' , fieldName : 'Ship_To__c' , type: 'text' , initialWidth : 150} ,
            { label : 'Ship To Address1' , fieldName : 'Ship_To_Address1__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address2' , fieldName : 'Ship_To_Address2__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address3' , fieldName : 'Ship_To_Address3__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address4' , fieldName : 'Ship_To_Address4__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Address5' , fieldName : 'Ship_To_Address5__c' , type: 'Text Area' , initialWidth : 250} ,
            { label : 'Ship To Contact' , fieldName : 'Ship_To_Contact__c' , type: 'phone' , initialWidth : 150} ,
            { label : 'Ship To Customer' , fieldName : 'Ship_To_Customer__c' , type: 'text' , initialWidth : 150} ,
            { label : 'SW Key End Date' , fieldName : 'SW_Key_End_Date__c' , type: 'date-local' , initialWidth : 150} ,            
        ]) ;*/
            
            console.log('Columns : '+JSON.stringify(component.get("v.columns")));    
            
            debugger ;
             component.set("v.showSpinner" , true) ;
       		 var action1 = component.get("c.deleteLines");
            action1.setParams({'orderId': orderId});
            action1.setCallback(this, function(response){
                var state = response.getState() ;
                var resp = response.getReturnValue() ;
                if(state == 'SUCCESS') {
                    console.log(JSON.stringify(resp));        
                   // component.set("v.data" , resp) ;
                   // component.set("v.currentList" , resp);
                }
               // console.log("Data : "+JSON.stringify(component.get("v.data")));
               // component.set("v.showSpinner" , false) ;
            }) ;
            $A.enqueueAction(action1) ;
            component.set("v.showSpinner" , true) ;
       		 var action2 = component.get("c.serviceLines");
            action2.setParams({'orderId': orderId});
            action2.setCallback(this, function(response){
                var state = response.getState() ;
                var resp = response.getReturnValue() ;
                if(state == 'SUCCESS') {
                    console.log(JSON.stringify(resp));        
                   // component.set("v.data" , resp) ;
                   // component.set("v.currentList" , resp);
                }
               // console.log("Data : "+JSON.stringify(component.get("v.data")));
                component.set("v.showSpinner" , false) ;
            }) ;
            $A.enqueueAction(action2) ;
            component.set("v.showSpinner" , true) ;
            var action = component.get("c.getERPOrderLineDetail");
            action.setParams({'orderId': orderId});
            action.setCallback(this, function(response){
                var state = response.getState() ;
                var resp = response.getReturnValue() ;
                if(state == 'SUCCESS') {
                    console.log(JSON.stringify(resp)); 
            		if(resp.length>0){
                    	component.set("v.data" , resp) ;
            			helper.setPaginationList(component);
                    	component.set("v.currentList" , resp);
            		}
                }
                console.log("Data : "+JSON.stringify(component.get("v.data")));
                component.set("v.showSpinner" , false) ;
            }) ;
            
            $A.enqueueAction(action) ;
   },
            
   handleSearchOrderLinesByBillToCustomer : function(component, event, helper){         
            var searchTextVal = component.get("v.searchText");
            var orderId = component.get("v.orderId");
            
            /*if(searchTextVal) {
                var action = component.get("c.searchOrderLinesByBillToCustomer");
                action.setParams({searchStr : searchTextVal, orderId : orderId});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state == 'SUCCESS'){
                        var resp  = response.getReturnValue() ;
                        if(resp != null && resp.length > 0){
                        	component.set("v.data" , resp) ;                 
                        } 
                    }
              }) ;
              $A.enqueueAction(action);
            } 
            else {
            	component.set("v.data" , component.get("v.currentList"));
            }*/
       },
    //pagination method start
    navigation: function(component, event, helper) {
        helper.pagination(component,event);   
    },
    goToPage:function (component, event, helper){
       helper.jumpToPage(component);
        
    }
    //pagination method end
 	
 })