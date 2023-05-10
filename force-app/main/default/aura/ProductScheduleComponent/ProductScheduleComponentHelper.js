({
    ToggleCollapseHandler : function(component, event, helper) {  
        //var idx = event.currentTarget.parentNode.id;

        var m = event.currentTarget.id; 
         
        var existingSrc = document.getElementById(m).src;  
        var opts=[];
        var object=[]; 
        var inputScheduleValue = component.get("v.scheduleValue");
        for(var k=0;k<inputScheduleValue[m].Duration.length;k++){ 
            
            if(inputScheduleValue[m].Duration[k].selected === true){
                //console.log(inputScheduleValue[i].Duration[k].value);
                //var Selected_month=parseInt(inputScheduleValue[m].Duration[k].value.substr(0,inputScheduleValue[m].Duration[k].value.indexOf(' '))); 
                opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : true});  
            }
            else{
                opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : false}); 
            }
        }
        if(inputScheduleValue[m].collapse === false){ 
            
            object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:inputScheduleValue[m].UnschldQty,Duration:opts,collapse:true,listofOppSchedule:[]};  
            //console.log(object[m]);	       
        }
        else{
            
            object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:inputScheduleValue[m].UnschldQty,Duration:opts,collapse:false,listofOppSchedule:[]}; 
        }
        //console.log(JSON.stringify(inputScheduleValue[m].listofOppSchedule[0])+'$$');
        for(var i=0;i<inputScheduleValue[m].listofOppSchedule.length;i++){ 
            //Custom Month code Start//
                        var CustomMonth=[];
            			
                        for(var mon=0;mon<inputScheduleValue[m].listofOppSchedule[i].Month.length;mon++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[i].Month[mon].selected){
                               CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[i].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[i].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[i].Month[mon].selected}); 
                            }
                            else  
                            CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[i].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[i].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[i].Month[mon].selected});
                        	
                            
                        }
                        //Custom Month code End//
                        
            			//Custom Year Code Start//
                        var CustomYear=[];
						for(var YearCounter=0;YearCounter<inputScheduleValue[m].listofOppSchedule[i].Year.length;YearCounter++){
                             
                            if(inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].selected){
                               CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].selected}); 
                            }
                            else  
                            CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].selected});
                        	
                            
                        }
						//Custom Year Code End//
            object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
            //console.log('##'+inputScheduleValue[m].listofOppSchedule[i].olis.monthYear+'Q: '+inputScheduleValue[m].listofOppSchedule[i].olis.Quantity);
        }  
        inputScheduleValue.splice(m,1,object[m]); 
        
        component.set("v.scheduleValue",inputScheduleValue);     
    },
    passRecordIdHelper: function(component, event ,helper){
        // alert('HurrayOppName' +event.getParam("passRecordName"));
        
        //component.set("v.abcId", event.getParam("passRecordId"));
        var counter;
        var object=[];  
        var newtotalvalue1=[];
        var action = component.get("c.ScheduleCalculateWrapper "); 
        action.setParams({      
            OppotunityId :component.get("v.abcId"),
            CallFromPreviousSchedule:"False"      
        }); 
        action.setCallback(this, function(a) {
            
            if (a.getState() === "SUCCESS") {
                var k;
                for(var i=0;i<a.getReturnValue().length;i++){ 
                    var unschedulequantity=0;
                    var denominator = Math.pow(10, 0);
                    //Set EDD
                    var newunitprice=parseInt(a.getReturnValue()[i].OpportunityLineItem.UnitPrice);
                    var newtotalvalue=parseInt(a.getReturnValue()[i].OpportunityLineItem.TotalPrice);
                    //Added by Saritha
                    
                    // newtotalvalue1.Push(inputScheduleValue1[i].ProductName);
                    //console.log('values' +newtotalvalue1);
                    var rounded_number = Math.round(newunitprice * denominator)/denominator;
                    var rounded_number2= Math.round(newtotalvalue * denominator)/denominator;
                    //alert('>>'+a.getReturnValue()[i].OpportunityLineItem.Unscheduled_Quantity__c);
                    if(parseInt(a.getReturnValue()[i].OpportunityLineItem.Unscheduled_Quantity__c) > 0){
                        unschedulequantity=a.getReturnValue()[i].OpportunityLineItem.Unscheduled_Quantity__c;
                    }
                    else {
                        unschedulequantity=0;
                    }
                    var opts=[]; 
                    //var Durationselected=a.getReturnValue()[i].OpportunityLineItem.Duration__c;
                    for(var k=0;k< a.getReturnValue()[i].optionsWrap.length;k++){
                        if(a.getReturnValue()[i].optionsWrap[k] === '----'){
                            
                            opts.push({ label: a.getReturnValue()[i].optionsWrap[k], value:  a.getReturnValue()[i].optionsWrap[k] ,selected : true}); 
                        }
                        else {
                            
                            opts.push({ label: a.getReturnValue()[i].optionsWrap[k], value:  a.getReturnValue()[i].optionsWrap[k] ,selected : false}); 
                        }
                        
                    }
                    
                    object[i]={Id:a.getReturnValue()[i].OpportunityLineItem.Id,UnitPrice:rounded_number,Quantity:a.getReturnValue()[i].OpportunityLineItem.Quantity,TotalPrice:rounded_number2,counter:i,ProductName:a.getReturnValue()[i].NameofProduct,UnschldQty:unschedulequantity,Duration:opts,collapse:false,listofOppSchedule:[]};
                    
                    for(var j=0;j<a.getReturnValue()[i].listofOppSchedule.length;j++){ 
                        k=j;  
                        //console.log(a.getReturnValue()[i].listofOppSchedule[k].olis.ScheduleDate+'##fget');
                        var CustomMonth=[]; 
                        CustomMonth.push({ label: 'Jan', value:  '1' ,selected : true});
                        CustomMonth.push({ label: 'Feb', value:  '2' ,selected : false});
                        CustomMonth.push({ label: 'Mar', value:  '3' ,selected : false});
                        CustomMonth.push({ label: 'Apr', value:  '4' ,selected : false});
                        CustomMonth.push({ label: 'May', value:  '5' ,selected : false});
                        CustomMonth.push({ label: 'Jun',value: '6' ,selected : false});
                        CustomMonth.push({ label: 'Jul',value: '7' ,selected : false});
                        CustomMonth.push({ label: 'Aug', value:  '8' ,selected : false});
                        CustomMonth.push({ label: 'Sep', value:  '9' ,selected : false});
                        CustomMonth.push({ label: 'Oct', value:  '10' ,selected : false});
                        CustomMonth.push({ label: 'Nov', value:  '11' ,selected : false});
                        CustomMonth.push({ label: 'Dec', value:  '12' ,selected : false});
                        //Custom Month code End//
                        //Custom Year Code Start//
                        var CustomYear=[];
                        var end = new Date().getFullYear(); 
                            CustomYear.push({label:'---',value:'---',selected:false});
                        	CustomYear.push({label:'2013',value:'2013',selected:false});
                            CustomYear.push({label:'2014',value:'2014',selected:false});
                            CustomYear.push({label:'2015',value:'2015',selected:false});
                            CustomYear.push({label:'2016',value:'2016',selected:false}); 
                            CustomYear.push({label:'2017',value:'2017',selected:false}); 
                            CustomYear.push({label:'2018',value:'2018',selected:false});
                            CustomYear.push({label:'2019',value:'2019',selected:false});
                            CustomYear.push({label:'2020',value:'2020',selected:false});
                            CustomYear.push({label:'2021',value:'2021',selected:false});
                            CustomYear.push({label:'2022',value:'2022',selected:false});
                        	CustomYear.push({label:'2023',value:'2023',selected:false});
                        	CustomYear.push({label:'2024',value:'2024',selected:false});
                        	CustomYear.push({label:'2025',value:'2025',selected:false});
                        	CustomYear.push({label:'2026',value:'2026',selected:false});
                        	CustomYear.push({label:'2027',value:'2027',selected:false});
                        	CustomYear.push({label:'2028',value:'2028',selected:false});
                        	CustomYear.push({label:'2029',value:'2029',selected:false});
                        	CustomYear.push({label:'2030',value:'2030',selected:false});
						//Custom Year Code End//
                        object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:a.getReturnValue()[i].listofOppSchedule[k].olis.ScheduleDate,Quantity:a.getReturnValue()[i].listofOppSchedule[k].olis.Quantity,Type:'Quantity',Id:a.getReturnValue()[i].listofOppSchedule[k].olis.Id});
                        //console.log(object[i].listofOppSchedule[j].ScheduleDate+'@@'+a.getReturnValue()[i].listofOppSchedule[k].olis.Quantity);
                    } 
                    
                }  
                
            } 
            else if(a.getState() === "ERROR") {
                
                var errors = a.getError();
                if (errors){
                    
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message +'Reload Page');
                    }
                } else {
                    //console.log("Unknown error");
                    //alert('4'); 
                }
            }
                else 
                { 
                    alert('Error'+a.getReturnValue());
                }  
            
            component.set("v.ShowHideSchedulerSpinner",false);
            component.set("v.scheduleValue",object);
            
        }); 
        $A.enqueueAction(action);
    },
    RecalculateQuantity2helper:function(component, event ,helper){
        //alert('firemethod');
        var m=component.get("v.IndentifierClint");
        var inputScheduleValue = component.get("v.scheduleValue");
        var object=[];
        var opts=[];
        var sumofbreakdown=0;
        var UnsynkQunatity=0;
        //calculation for unitprice and totalprice	
        var denominator = Math.pow(10, 0);
        
        if(inputScheduleValue[m].UnitPrice==null){
           // alert('enterr');
            inputScheduleValue[m].UnitPrice=0;
        }
        
        
        var finalTotalPrice=Math.round((inputScheduleValue[m].UnitPrice*inputScheduleValue[m].Quantity) * denominator)/denominator;
        //calculation for unitprice and totalprice End
         
        for(var l=0;l<inputScheduleValue[m].Duration.length;l++){
            if(inputScheduleValue[m].Duration[l].selected === true){
                opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : true});  
            }
            else{
                opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : false}); 
            }
        }
        //object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,Duration:opts,listofOppSchedule:[]};  
        //alert('Hi'+inputScheduleValue[i].listofOppSchedule.length);  
        for(var j=0;j<inputScheduleValue[m].listofOppSchedule.length; j++){
            //alert('Quantity'+inputScheduleValue[i].listofOppSchedule[j].Quantity);
            
            sumofbreakdown=parseInt(sumofbreakdown)+parseInt(inputScheduleValue[m].listofOppSchedule[j].Quantity);
            //alert('Sum'+sumofbreakdown); 
            
        } 
        if(inputScheduleValue[m].Quantity>sumofbreakdown){
            UnsynkQunatity=parseInt(inputScheduleValue[m].Quantity)-parseInt(sumofbreakdown);
            object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:finalTotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:UnsynkQunatity,Duration:opts,collapse:inputScheduleValue[m].collapse,listofOppSchedule:[]};
        }
        else{
            object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:sumofbreakdown,TotalPrice:finalTotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:UnsynkQunatity,Duration:opts,collapse:inputScheduleValue[m].collapse,listofOppSchedule:[]};
        }  
        for(var k=0;k<inputScheduleValue[m].listofOppSchedule.length; k++){
           //Custom Month code Start//
                        var CustomMonth=[];
            			
                        for(var mon=0;mon<inputScheduleValue[m].listofOppSchedule[k].Month.length;mon++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[k].Month[mon].selected){
                               CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[k].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[k].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Month[mon].selected}); 
                            }
                            else  
                            CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[k].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[k].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Month[mon].selected});
                        	
                            
                        }
                        //Custom Month code End//
                        
            			//Custom Year Code Start//
                        var CustomYear=[];
						for(var YearCounter=0;YearCounter<inputScheduleValue[m].listofOppSchedule[k].Year.length;YearCounter++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].selected){
                               CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].selected}); 
                            }
                            else  
                            CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].selected});
                        }
						//Custom Year Code End//
           
            //alert(inputScheduleValue[i].listofOppSchedule[k].Quantity);
            if(inputScheduleValue[m].listofOppSchedule.length>k){ 
                //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[k].Id});
            }
            else{
                object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
            }
        }
        
        inputScheduleValue.splice(m,1,object[m]); 
        component.set("v.scheduleValue",inputScheduleValue);
        
    },
    handlesInsertSchApplicationEvent : function(component,event,helper){
        //alert('enterhandler' + event.getParam("ProductIds"));
        //alert('recid' +component.get("v.abcId"));
        var action = component.get("c.removeSchedule");
        action.setParams({ "SelectedProductid": event.getParam("ProductIds"),
                          "recordId":component.get("v.abcId")
                         });
        action.setCallback(this, function(a) {
            //alert(a.getState());
            if(a.getState() === "SUCCESS"){ 
                //alert("calling load method");
                helper.reloadSchedulerUI(component, event ,helper);
            }
        });
        $A.enqueueAction(action);
    },
    handlesDeleteSchApplicationEvent : function(component,event,helper){
        //alert('1');
        var action = component.get("c.InsertOpportunityLineItemPS");
        if(event.getParam("ProductIds") != ''){
            action.setParams({ "Product_Selected_From_Favorite_Section": event.getParam("ProductIds"),
                          "Oppid":component.get("v.abcId")
                         });
        action.setCallback(this, function(a) {
            
            if(a.getState() === "SUCCESS"){
                //alert('3');
                helper.reloadSchedulerUI(component, event ,helper);
                //alert('4');
            }
        });
        $A.enqueueAction(action);
        }
        else{
            alert('please select a product'); 
        }
    },
    reloadSchedulerUI: function(component, event ,helper){
        helper.passRecordIdHelper(component, event ,helper); 
        var eventForScheduled = $A.get("e.c:ReloadUI");
                    
        eventForScheduled.fire();
        
    }, 
    saveSchedulerHelper:function(component, event ,helper){
        //component.set("v.ShowHideSchedulerSpinner",true);
        //Optimization Work start
        //alert('Enter in save');
        var currentTarger1=event.currentTarget.id;
        var value1=currentTarger1.indexOf("_");
        var value2=currentTarger1.length;
        var montharray=[];
        var m=parseInt(currentTarger1.substring(parseInt(value1)+1,value2));
        //End
        
        var selected_Month;
        var inputScheduleValue = component.get("v.scheduleValue");
        var testJson = '{"OpportunityLineItem": [';
        for(var i=m; i<=m; i++){
            for(var k=0;k<inputScheduleValue[i].Duration.length;k++){
                if(inputScheduleValue[i].Duration[k].selected === true){
                    selected_Month=inputScheduleValue[i].Duration[k].value;
                    //alert('selected_Month'+selected_Month);
                }
            }
            testJson += '{';
            testJson += '"Id"'+ ':"' +inputScheduleValue[i].Id+'",'; 
            testJson += '"Quantity"' + ":"+inputScheduleValue[i].Quantity+",";
            testJson += '"UnitPrice"' + ":"+inputScheduleValue[i].UnitPrice+",";
            testJson += '"TotalPrice"' + ":"+inputScheduleValue[i].TotalPrice+",";
            testJson += '"ProductName"' + ":"+ '"' +encodeURI(inputScheduleValue[i].ProductName)+'"' + ",";
            testJson += '"UnschldQty"' + ":"+ '"' +inputScheduleValue[i].UnschldQty+'"' + ",";
            testJson += '"counter"' + ":" + '"' + inputScheduleValue[i].counter + '"'+",";
            //@Ajay not required to be saved
            //testJson += '"Duration"' + ":" + '"' + selected_Month + '"'+","; 
            
            testJson += '"OpportunityLineItemSchedule": ['; 
            
            for(var j=0;j<inputScheduleValue[i].listofOppSchedule.length;j++){
                //alert('Schedule Date'+inputScheduleValue[i].listofOppSchedule[j].ScheduleDate);
                var month;
                var year;
                for(var mon=0;mon<inputScheduleValue[i].listofOppSchedule[j].Month.length;mon++){
                    if(inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected){
                       month=parseInt(inputScheduleValue[i].listofOppSchedule[j].Month[mon].value); 
                    }
                }
                
                for(var YearCounter=0;YearCounter<inputScheduleValue[i].listofOppSchedule[j].Year.length;YearCounter++){
                    if(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected){
                        year=parseInt(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value);
                    }
                }
                var scheduleaDate = year+'-'+month+'-'+1;
                testJson+='{'
                if((inputScheduleValue[i].listofOppSchedule[j].Quantity))
                testJson += '"Quantity"' + ":"+inputScheduleValue[i].listofOppSchedule[j].Quantity+",";
                testJson += '"Id"'+ ':"' +inputScheduleValue[i].listofOppSchedule[j].Id+'",';	
                testJson += '"Type"' + ":"+ '"' +inputScheduleValue[i].listofOppSchedule[j].Type+'",';
                testJson += '"ScheduleDate"' + ":"+ '"' +scheduleaDate+'"';
                
                if( j === inputScheduleValue[i].listofOppSchedule.length - 1){ 
                    testJson += '}'; 
                }		else{
                    testJson += '},';      
                }
                
            } 
            
            testJson += ']';
            if( i == m - 1){ 
                testJson += '}';
            }else{
                testJson += '}';      
            } 
        }
        testJson += ']}';
        //console.log(testJson);
        var action = component.get("c.SaveManegeSchedule"); 
        action.setParams({      
            JsonString : testJson      
        }); 
        
        //Added by Saritha
        //helper.SaveScheduleValidations(component, event, helper);
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
               if(a.getReturnValue() === "SUCCESS"){
                   /*  var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Product Schedule Updated Succesfully.",
                        "Category" : "Success",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();*/
                   toastEvent.setParams({
       		 		"title": "Success!",
       		 		"message": "Product Schedule Updated Successfully.",
        			"type":"success"
   			 		});
    				toastEvent.fire();
                }else{
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                        FloatMsgEvent.setParams({
                         "Msg" : a.getReturnValue(),
                         "Category" : "Error",
                         "isShow" : "True"
                        });
                     FloatMsgEvent.fire();
                }
            }
            else{ 
                // alert(error);
            }
            //component.set("v.ShowHideSchedulerSpinner",false);
        });
        //this.passRecordIdHelper(component, event ,helper);
        
        $A.enqueueAction(action); 
     },
    handleApplicationEventhelper :function(component, event, helper){
        // component.set("v.ShowHideSchedulerSpinner",true);
        
        var selected_Month;
        var inputScheduleValue = component.get("v.scheduleValue");
        var testJson = '{"OpportunityLineItem": [';
        for(var i=0; i<inputScheduleValue.length; i++){
            for(var k=0;k<inputScheduleValue[i].Duration.length;k++){
                if(inputScheduleValue[i].Duration[k].selected === true){
                    selected_Month=inputScheduleValue[i].Duration[k].value;
                    //alert('selected_Month'+selected_Month);
                }
            }
            testJson += '{';
            testJson += '"Id"'+ ':"' +inputScheduleValue[i].Id+'",'; 
            testJson += '"Quantity"' + ":"+inputScheduleValue[i].Quantity+",";
            testJson += '"UnitPrice"' + ":"+inputScheduleValue[i].UnitPrice+",";
            testJson += '"TotalPrice"' + ":"+inputScheduleValue[i].TotalPrice+",";
            testJson += '"ProductName"' + ":"+ '"' +encodeURI(inputScheduleValue[i].ProductName)+'"' + ",";
            testJson += '"UnschldQty"' + ":"+ '"' +inputScheduleValue[i].UnschldQty+'"' + ",";
            testJson += '"counter"' + ":" + '"' + inputScheduleValue[i].counter + '"'+",";
            testJson += '"Duration"' + ":" + '"' + selected_Month + '"'+","; 
            
            testJson += '"OpportunityLineItemSchedule": ['; 
            
            for(var j=0;j<inputScheduleValue[i].listofOppSchedule.length;j++){
                var month;
                var year;
                for(var mon=0;mon<inputScheduleValue[i].listofOppSchedule[j].Month.length;mon++){
                    if(inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected){
                       month=parseInt(inputScheduleValue[i].listofOppSchedule[j].Month[mon].value); 
                    }
                }
                
                for(var YearCounter=0;YearCounter<inputScheduleValue[i].listofOppSchedule[j].Year.length;YearCounter++){
                    if(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected){
                        year=parseInt(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value);
                    }
                }
                var scheduleaDate = year+'-'+month+'-'+1;
                testJson+='{'
                if((inputScheduleValue[i].listofOppSchedule[j].Quantity))
                testJson += '"Quantity"' + ":"+inputScheduleValue[i].listofOppSchedule[j].Quantity+",";
                testJson += '"Id"'+ ':"' +inputScheduleValue[i].listofOppSchedule[j].Id+'",';	
                testJson += '"Type"' + ":"+ '"' +inputScheduleValue[i].listofOppSchedule[j].Type+'",';
                testJson += '"ScheduleDate"' + ":"+ '"' +scheduleaDate+'"';
                
                if( j === inputScheduleValue[i].listofOppSchedule.length - 1){ 
                    testJson += '}'; 
                }		else{
                    testJson += '},';      
                }
                
            } 
            
            testJson += ']';
            if( i == inputScheduleValue.length - 1){ 
                testJson += '}';
            }else{
                testJson += '},';      
            } 
        }
        testJson += ']}';
        //console.log(testJson);
        var action = component.get("c.SubmitManegeSchedule"); 
        action.setParams({      
            JsonStringSubmit : testJson      
        }); 
        //Added by Saritha
        //helper.SaveScheduleValidations(component, event, helper);
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Product Schedule Updated Succesfully.",
                    "Category" : "Success",
                    "isShow" : "True" 
                });
                FloatMsgEvent.fire(); 
                var validateAmtPSComp = $A.get("e.c:EventToValidateMsg");
            		validateAmtPSComp.setParams({
                "postSubmit" : "postSubmit"});
            	validateAmtPSComp.fire();
                
            }
            else{ 
                // alert(error);
            }
            //component.set("v.ShowHideSchedulerSpinner",false);
        });
        $A.enqueueAction(action); 
    } ,
    DeleteOLI : function(component, event ,helper){
   
        var action = component.get("c.DeleteOli");
            action.setParams({ ProductId : component.get("v.ProductIdForDelete")
                                    });
            action.setCallback(this, function(a) {
                if(action.getState() ==='SUCCESS'){
                    if(a.getReturnValue()==='SUCCESS'){
                        helper.passRecordIdHelper(component, event ,helper);
                        var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                        FloatMsgEvent.setParams({
                            "Msg" : "Product deleted Succesfully.",
                            "Category" : "Success",
                            "isShow" : "True"
                        });
                        FloatMsgEvent.fire(); 
                    }
                }
            });
            $A.enqueueAction(action); 
    },
    CancelCopyWindow :function(component, event, helper){
       component.set("v.ShowHideCopyModel",false);
    },
     ValidateMonthYearNull : function(component,event,helper){ 
         
					 var object=[];
						var ValidateMonthYear;
						var inputScheduleValue = component.get("v.scheduleValue");
                        for(var i=0 ; i<inputScheduleValue.length ; i++){
                            var opts=[];
                        for(var d=0;d<inputScheduleValue[i].Duration.length;d++){                
                                if(inputScheduleValue[i].Duration[d].selected === true){
                                    opts.push({ label: inputScheduleValue[i].Duration[d].label, value:  inputScheduleValue[i].Duration[d].value ,selected : true});  
                                }
                                 
                                else{
                                    opts.push({ label: inputScheduleValue[i].Duration[d].label, value:  inputScheduleValue[i].Duration[d].value ,selected : false}); 
                                }
						} 
                        
                        object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,UnscheduleFinder:false,Duration:opts,collapse:true,listofOppSchedule:[]}; 		
                        //month1=parseInt(datevalue.getMonth() + 1);
                        //year1=parseInt(datevalue.getFullYear());
                        //Added to check month year Null
						
                         var isMonthYearNeedToCheck=true;
                            for(var j=0; j < inputScheduleValue[i].listofOppSchedule.length; j++){
                                var ss=false;
                                var FirstDate =inputScheduleValue[i].listofOppSchedule[j].ScheduleDate;
                        		//alert(FirstDate);    
                        		var FirstDateArray=(FirstDate.split("-"));
                                //Custom Month code Start//
                        var CustomMonth=[];
            			var month1;
                        for(var mon=0;mon<inputScheduleValue[i].listofOppSchedule[j].Month.length;mon++){
                            
                            if(inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected){
                               CustomMonth.push({ label: inputScheduleValue[i].listofOppSchedule[j].Month[mon].label, value:  inputScheduleValue[i].listofOppSchedule[j].Month[mon].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected}); 
								month1=parseInt(inputScheduleValue[i].listofOppSchedule[j].Month[mon].value);
							}	
                            else  
                            CustomMonth.push({ label: inputScheduleValue[i].listofOppSchedule[j].Month[mon].label, value:  inputScheduleValue[i].listofOppSchedule[j].Month[mon].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected});
                        	
                            
                        }
                        //Custom Month code End//
                        
            			//Custom Year Code Start//
                        var CustomYear=[];
						var year1;
						for(var YearCounter=0;YearCounter<inputScheduleValue[i].listofOppSchedule[j].Year.length;YearCounter++){
                            
                            if(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected){
                               CustomYear.push({ label: inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected}); 
							   year1=inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value;
							}
                            else  
                            CustomYear.push({ label: inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected});
                        	
                            
                        }
						//Custom Year Code End//
                        		var ConvertedFirstDate = new Date(year1, month1, 1);
                            	var Firstmonth=parseInt(ConvertedFirstDate.getMonth() + 1);
                        		var Firstyear=parseInt(ConvertedFirstDate.getFullYear());
                                 
                                 var ScheduleQty = parseInt(inputScheduleValue[i].listofOppSchedule[j].Quantity);
                                if((isNaN(year1) || isNaN(month1)) && ScheduleQty>0){
                                        ss=true;
										ValidateMonthYear = 'NotValidate';
                               			object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});
                        		}
							    else{
									object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});
								}
                            }    
                            
                       }
					   if(ValidateMonthYear === 'NotValidate'){
						  
                        component.set("v.scheduleValue",object);
                           
					   }
                    else{
                        return true;
                    }
			},
    ManageQuantityScheduleHelper:function(component,event,helper){
        if(event.getSource().get("v.value") == '' || event.getSource().get("v.value")== 0){
           event.getSource().set("v.value",1); 
        } 
        
        else
        {
        var inputScheduleValue = component.get("v.scheduleValue");
        var m=component.get("v.IndentifierClint");
        var object=[]; 
        var opts=[]; 
            if(inputScheduleValue[m].Quantity != '' || inputScheduleValue[m].UnitPrice != ''){
                
                var denominator = Math.pow(10, 0);
                var NewTotalPrice=parseInt(inputScheduleValue[m].Quantity)*parseInt(inputScheduleValue[m].UnitPrice);
                var NewTotalPrice=Math.round(NewTotalPrice * denominator)/denominator;
               
                for(var k=0;k<inputScheduleValue[m].Duration.length;k++){ 
                    
                    if(inputScheduleValue[m].Duration[k].selected === true){
                        //console.log(inputScheduleValue[i].Duration[k].value);
                        //console.log(inputScheduleValue[m].Duration[k])
                        if(inputScheduleValue[m].Duration[k].value=='----'){
                            opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : true});    
                        }
                        else if(inputScheduleValue[m].Duration[k].value=='Custom'){
                            component.set("v.ShowCustomDuration",true);
                            //document.getElementById('greyOutBackground').style.display='block';
                        }else{
                            //Selected_month=parseInt(inputScheduleValue[m].Duration[k].value.substr(0,inputScheduleValue[m].Duration[k].value.indexOf(' '))); 
                            opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : true});  
                            
                        }
                    }
                    else{
                        opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : false}); 
                    }
                }
                
                    //Calculate Unschedule Quantity//
                    var sumOfUnschedule=0;
                    for(var j=0;j<inputScheduleValue[m].listofOppSchedule.length; j++){
                        sumOfUnschedule=parseInt(sumOfUnschedule)+parseInt(inputScheduleValue[m].listofOppSchedule[j].Quantity);
                    } 
                	//End Of Calculation//

                if(parseInt(sumOfUnschedule)< parseInt(inputScheduleValue[m].Quantity)){
                    var unScheduleQuantity=parseInt(inputScheduleValue[m].Quantity)-parseInt(sumOfUnschedule);
                	
                    object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:NewTotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:unScheduleQuantity,TheCheck:false,EditMode:true,collapse:true,Duration:opts,listofOppSchedule:[]};    
                
                }
                else{
                    
                    object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:NewTotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:0,TheCheck:false,EditMode:true,collapse:true,Duration:opts,listofOppSchedule:[]};   
                }
                
                
                for(var k=0;k<inputScheduleValue[m].listofOppSchedule.length; k++){
                    //alert(inputScheduleValue[i].listofOppSchedule[k].Quantity);
                    //Custom Month code Start//
                        var CustomMonth=[];
            			
                        for(var mon=0;mon<inputScheduleValue[m].listofOppSchedule[k].Month.length;mon++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[k].Month[mon].selected){
                               CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[k].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[k].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Month[mon].selected}); 
                            }
                            else  
                            CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[k].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[k].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Month[mon].selected});
                        	
                            
                        }
                        //Custom Month code End//
                        
            			//Custom Year Code Start//
                        var CustomYear=[];
						for(var YearCounter=0;YearCounter<inputScheduleValue[m].listofOppSchedule[k].Year.length;YearCounter++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].selected){
                               CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].selected}); 
                            }
                            else  
                            CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[k].Year[YearCounter].selected});
                        	
                            
                        }
						//Custom Year Code End//
                    
                    if(inputScheduleValue[m].listofOppSchedule.length>k){ 
                        //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[k].Id});
                    }
                    else{
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                    }
                    
        	}
                
                inputScheduleValue.splice(m,1,object[m]);
                component.set("v.scheduleValue",inputScheduleValue);	
            }
        	else{
                   
            	    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Required field mising", 
                        "Category" : "Warning",
                        "isShow" : "True"
                    }); 
                    FloatMsgEvent.fire(); 
                    
        	}
        } 
        
    }
    
})