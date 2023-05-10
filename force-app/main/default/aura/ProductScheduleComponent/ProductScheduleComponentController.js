({
    doInit : function(component, event, helper){
        var scheduleRemoveoppName=[];
        var inputScheduleValue1 = component.get("v.scheduleValue");
        
    },
    handleSubmitRefreshComp : function(component, event, helper){
        helper.passRecordIdHelper(component, event, helper);
    },
    passRecordId : function(component, event, helper){
        component.set("v.LabelExpandCollapse", "/resource/ExpandAll/svg/fullscreen.svg");
        component.set("v.abcId", event.getParam("passRecordId")); 
        helper.passRecordIdHelper(component, event, helper);
    }, 
    DeleteProduct : function(component, event, helper){
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        var inputScheduleValue = component.get("v.scheduleValue");
        component.set("v.ShowHideBeforeDelete",true);
        component.set("v.ProductIdForDelete",inputScheduleValue[idd].Id);
        
    },
    CancelDelete : function(component, event, helper){
        component.set("v.ShowHideBeforeDelete",false);
    },
    ProceedDelete : function(component, event, helper){
        component.set("v.ShowHideBeforeDelete",false);
        helper.DeleteOLI(component, event, helper);
    },
    URLExpandAll : function(component, event, helper){
         
        var counter;
        var object=[];  
        var inputScheduleValue = component.get("v.scheduleValue"); 
                var k; 
                for(var i=0;i<inputScheduleValue.length;i++){ 
                    var opts=[]; 
                    for(var k=0;k< inputScheduleValue[i].Duration.length;k++){
                        if(inputScheduleValue[i].Duration[k].selected === true){
                            
                            opts.push({ label: inputScheduleValue[i].Duration[k].label, value:  inputScheduleValue[i].Duration[k].value ,selected : true}); 
                        }
                        else {
                            
                            opts.push({ label: inputScheduleValue[i].Duration[k].label, value:  inputScheduleValue[i].Duration[k].value ,selected : false}); 
                        }                      
                    }
                    //if(component.get("v.LabelExpandCollapse").includes("fullscreen")){
                    if(component.get("v.LabelExpandCollapse").indexOf("fullscreen") != -1 ){
						object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,Duration:opts,collapse:true,listofOppSchedule:[]};
					}
                    else{
						object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,Duration:opts,collapse:false,listofOppSchedule:[]};
					}
                    for(var j=0;j<inputScheduleValue[i].listofOppSchedule.length;j++){ 
                        k=j;  
                        //Custom Month code Start//
                        var CustomMonth=[];
            			
                        for(var mon=0;mon<inputScheduleValue[i].listofOppSchedule[j].Month.length;mon++){
                            
                            if(inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected){
                               CustomMonth.push({ label: inputScheduleValue[i].listofOppSchedule[j].Month[mon].label, value:  inputScheduleValue[i].listofOppSchedule[j].Month[mon].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected}); 
                            }
                            else  
                            CustomMonth.push({ label: inputScheduleValue[i].listofOppSchedule[j].Month[mon].label, value:  inputScheduleValue[i].listofOppSchedule[j].Month[mon].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Month[mon].selected});
                        	
                            
                        }
                        //Custom Month code End//
                        
            			//Custom Year Code Start//
                        var CustomYear=[];
						for(var YearCounter=0;YearCounter<inputScheduleValue[i].listofOppSchedule[j].Year.length;YearCounter++){
                            
                            if(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected){
                               CustomYear.push({ label: inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected}); 
                            }
                            else  
                            CustomYear.push({ label: inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected});
                        	
                            
                        }
						//Custom Year Code End//
                        object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[i].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[k].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[k].Id});                         
                    }   
                }
               //if(component.get("v.LabelExpandCollapse").includes("fullscreen")){
               if(component.get("v.LabelExpandCollapse").indexOf("fullscreen") != -1 ){
                   component.set("v.LabelExpandCollapse", "/resource/ExpandAll/svg/collapseAll.svg");
                }else{
                   component.set("v.LabelExpandCollapse", "/resource/ExpandAll/svg/fullscreen.svg");
                }
            component.set("v.scheduleValue",object);
    },
    AddScheduleItem:function(component, event, helper){
        
        var object=[];
        var targetclicked=event.currentTarget.id;
        var inputScheduleValue = component.get("v.scheduleValue");
        var addElement=(inputScheduleValue[targetclicked].listofOppSchedule.length/3);
        //console.log( ':::BEFORE IF:::' );
        object.push({ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});
        var denominator = Math.pow(10, 0);  
        var value1=addElement.toString().indexOf(".");
        var value2=addElement.toString().length; 
        var lengthofschedule=parseInt(inputScheduleValue[targetclicked].listofOppSchedule.length);
        // console.log(addElement.toString().substring(value1,value2));
        var rounded_number = Math.round(addElement.toString().substring(value1,value2) * denominator)/denominator;
        if(addElement.toString().substring(value1,value2) == '0' &&  rounded_number == '0')
        { 
            //console.log('case 1 : no element');
            object.push({counterBreakDown:lengthofschedule+1,ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});
            object.push({counterBreakDown:lengthofschedule+2,ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});
        }
        else{
            
            if(addElement.toString().substring(value1,value2) != '0' &&  rounded_number == '0'){
                // console.log("Case 2");
                object.push({counterBreakDown:lengthofschedule+1,ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});
            }
            else if(addElement.toString().substring(value1,value2) == rounded_number){
                // console.log('Case 3');
                object.push({counterBreakDown:lengthofschedule+1,ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});
                object.push({counterBreakDown:lengthofschedule+2,ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});
            } 
        }
        // console.log('lenght of object array'+object.length);
        var NewObject=[];
        for(var i=0; i<object.length; i++){
			 //Custom Month code Start//
                        var CustomMonth=[];
            			CustomMonth.push({ label: '---', value:  '---' ,selected : true});
                        CustomMonth.push({ label: 'Jan', value:  '1' ,selected : false});
                        CustomMonth.push({ label: 'Feb', value:  '2' ,selected : false});
                        CustomMonth.push({ label: 'Mar', value:  '3' ,selected : false});
                        CustomMonth.push({ label: 'Apr', value:  '4' ,selected : false});
                        CustomMonth.push({ label: 'May', value:  '5' ,selected : false});
                        CustomMonth.push({ label: 'Jun', value:  '6' ,selected : false});
                        CustomMonth.push({ label: 'Jul', value:  '7' ,selected : false});
                        CustomMonth.push({ label: 'Aug', value:  '8' ,selected : false});
                        CustomMonth.push({ label: 'Sep', value:  '9' ,selected : false});
                        CustomMonth.push({ label: 'oct', value:  '10' ,selected : false});
                        CustomMonth.push({ label: 'Nov', value:  '11' ,selected : false});
            			CustomMonth.push({ label: 'Dec', value:  '10' ,selected : false});
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
			NewObject.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:object[i].lengthofschedule,ScheduleDate:'',Quantity:0,Type:'Quantity',Id:''});			
            lengthofschedule=parseInt(lengthofschedule+1); 
            inputScheduleValue[targetclicked].listofOppSchedule.splice(lengthofschedule,0,NewObject[i]);
        }       
        
        component.set("v.scheduleValue",inputScheduleValue);
        
    },
    ToggleCollapse : function(component, event, helper) { 
        helper.ToggleCollapseHandler(component, event);
    },
    ManageSchedule : function(component, event, helper){
        // alert('Manage');
        var s=component.get("v.EDD").split("-");
        var d=new Date(component.get("v.EDD"));        
        var eddMon=d.getMonth();
        var eddYr=d.getFullYear();
        var eddDay=s[2];
        				//Custom Month code Start//
                        var CustomMonth1=[];
        				CustomMonth1.push({ label: '---', value:  '---' ,selected : false});
                        CustomMonth1.push({ label: 'Jan', value:  '1' ,selected : false});
                        CustomMonth1.push({ label: 'Feb', value:  '2' ,selected : false});
                        CustomMonth1.push({ label: 'Mar', value:  '3' ,selected : false});
                        CustomMonth1.push({ label: 'Apr', value:  '4' ,selected : false});
                        CustomMonth1.push({ label: 'May', value:  '5' ,selected : false});
                        CustomMonth1.push({ label: 'Jun', value:  '6' ,selected : false});
                        CustomMonth1.push({ label: 'Jul', value:  '7' ,selected : false});
                        CustomMonth1.push({ label: 'Aug', value:  '8' ,selected : false});
                        CustomMonth1.push({ label: 'Sep', value:  '9' ,selected : false});
                        CustomMonth1.push({ label: 'Oct', value:  '10' ,selected : false});
                        CustomMonth1.push({ label: 'Nov', value:  '11' ,selected : false});
                        CustomMonth1.push({ label: 'Dec', value:  '12' ,selected : false});
                        //Custom Month code End//
                        
                        //Custom Year Code Start//
                        var CustomYear1=[];
                        
                            CustomYear1.push({label:'---',value:'---',selected:false});
                        	CustomYear1.push({label:'2013',value:'2013',selected:false});
                            CustomYear1.push({label:'2014',value:'2014',selected:false});
                            CustomYear1.push({label:'2015',value:'2015',selected:false});
                            CustomYear1.push({label:'2016',value:'2016',selected:false}); 
                            CustomYear1.push({label:'2017',value:'2017',selected:false}); 
                            CustomYear1.push({label:'2018',value:'2018',selected:false});
                            CustomYear1.push({label:'2019',value:'2019',selected:false});
                            CustomYear1.push({label:'2020',value:'2020',selected:false});
                            CustomYear1.push({label:'2021',value:'2021',selected:false});
                            CustomYear1.push({label:'2022',value:'2022',selected:false});
                        	CustomYear1.push({label:'2023',value:'2023',selected:false});
                        	CustomYear1.push({label:'2024',value:'2024',selected:false});
                        	CustomYear1.push({label:'2025',value:'2025',selected:false});
                        	CustomYear1.push({label:'2026',value:'2026',selected:false});
                        	CustomYear1.push({label:'2027',value:'2027',selected:false});
                        	CustomYear1.push({label:'2028',value:'2028',selected:false});
                        	CustomYear1.push({label:'2029',value:'2029',selected:false});
                        	CustomYear1.push({label:'2030',value:'2030',selected:false});
						//Custom Year Code End//  
                        
        var inputScheduleValue = component.get("v.scheduleValue");
        var m=component.get("v.IndentifierClint");
         
        var object=[];
        var counter=0;
        var opts=[];
		var Selected_month=0;
        // console.log('##'+component.get("v.ShowCustomDuration"))
        if(!component.get("v.ShowCustomDuration")){
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
                        Selected_month=parseInt(inputScheduleValue[m].Duration[k].value.substr(0,inputScheduleValue[m].Duration[k].value.indexOf(' '))); 
                        opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : true});  
                        
                    }
                }
                else{
                    opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : false}); 
                }
            }
        }
        //console.log('##1'+component.get("v.ShowCustomDuration"))
        
        // does calculation only when custom Duration popup is off
        if(!component.get("v.ShowCustomDuration") && Selected_month>0){
            
            var denominator = Math.pow(10, 0);
            var NewToatlProce=parseInt(inputScheduleValue[m].Quantity)*parseInt(inputScheduleValue[m].UnitPrice);
            var NewToatlProce=Math.round(NewToatlProce * denominator)/denominator;
            
            object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:NewToatlProce,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:0,Duration:opts,collapse:true,listofOppSchedule:[]}; 
            
            // Breakdown logic Start here
            
            var remain=parseInt(inputScheduleValue[m].Quantity);
            var partsLeft=Selected_month;
            for(var j=0;j<partsLeft; j++){ 
                //alert('Length of Breakdown'+j+'--'+inputScheduleValue[i].listofOppSchedule.length);
                var size=Math.floor((remain + partsLeft - j - 1) / (partsLeft - j));
                var EDD = component.get("v.EDD");
        		var EDDDateArry=(EDD.split("-"));
                
            	var datevalueEDD = new Date(EDDDateArry[0], EDDDateArry[1] - 1, 1);
                datevalueEDD.setMonth(datevalueEDD.getMonth() + j); 
				var scDate=datevalueEDD.getFullYear() + "-" + (datevalueEDD.getMonth()+1) + "-" + 1;
                
                //Custom Month code Start//
                		var CustomMonth=[];
                        for(var h=0;h<CustomMonth1.length;h++){
                            if(parseInt(CustomMonth1[h].value) === parseInt(datevalueEDD.getMonth()+1))
                            CustomMonth.push({ label: CustomMonth1[h].label, value:  CustomMonth1[h].value,selected:true});      
                            else
                            CustomMonth.push({ label: CustomMonth1[h].label, value:  CustomMonth1[h].value,selected:false});     
                        }
                                        
                        //Custom Month code End//
                        //Custom Year Code Start//
                        	var CustomYear=[];
                			for(var k=0;k<CustomYear1.length;k++){
                                //alert(CustomYear1[k].value);
								if(parseInt(datevalueEDD.getFullYear())===parseInt(CustomYear1[k].value))
									CustomYear.push({label:CustomYear1[k].label,value:CustomYear1[k].value,selected:true}); 
								else
									CustomYear.push({label:CustomYear1[k].label,value:CustomYear1[k].value,selected:false});	
							}
                        	//CustomYear.push({label:datevalueEDD.getFullYear(),value:datevalueEDD.getFullYear(),selected:true}); 
						//Custom Year Code End//                
                
                if(inputScheduleValue[m].listofOppSchedule.length>j){ 
                    //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                    
                    object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:j,ScheduleDate:scDate,Quantity:size,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});
                }
                
                else{
                    object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:j,ScheduleDate:scDate,Quantity:size,Type:'Quantity',Id:''});
                }                       
                
                remain =remain-size; 
                
            }
            //BreakDown logic end
            
            //console.log(object[m]);  
            //console.log(inputScheduleValue[m].splice(m,0,object[m])); 
            inputScheduleValue.splice(m,1,object[m]);
            
            component.set("v.scheduleValue",inputScheduleValue);
        }
        
    },
    SaveSchedule : function(component, event, helper){
        
        var currentTarger=event.currentTarget.id;
        var value1=currentTarger.indexOf("_");
        var value2=currentTarger.length;
        var m=parseInt(currentTarger.substring(parseInt(value1)+1,value2));
        var inputScheduleValue = component.get("v.scheduleValue");
        var object=[]; 
        var opts=[];
        var unschqtyvalidate=false;
        var EDD = component.get("v.EDD");
        var EDDDateArry=(EDD.split("-"));
        var datevalueEDD = new Date(EDDDateArry[0], EDDDateArry[1] - 1, EDDDateArry[2]);
        var month=parseInt(datevalueEDD.getMonth() + 1);
        var year=parseInt(datevalueEDD.getFullYear());
        
        for(var l=0;l<inputScheduleValue[m].Duration.length;l++){
            if(inputScheduleValue[m].Duration[l].selected === true){
                opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : true});  
            }
            else{
                opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : false}); 
            }
        }
        
        object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,UnscheduleFinder:false,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:inputScheduleValue[m].UnschldQty,Duration:opts,collapse:true,listofOppSchedule:[]}; 	
        
        var validateEdd='Validated';
        var sumOfSchedule=0;
		var scheduleValidate='Validate';
        for (var j = 0; j < inputScheduleValue[m].listofOppSchedule.length; j++) 
        {
            var eddvalidate=false;
            var date1 =inputScheduleValue[m].listofOppSchedule[j].ScheduleDate;
            var arrdate1=(date1.split("-"));
            
            var month1;
            var year1;
			sumOfSchedule+=parseInt(inputScheduleValue[m].listofOppSchedule[j].Quantity);
            //Custom Month code Start//
                        var CustomMonth=[];
                        
                        for(var mon=0;mon<inputScheduleValue[m].listofOppSchedule[j].Month.length;mon++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[j].Month[mon].selected){
                               month1=parseInt(inputScheduleValue[m].listofOppSchedule[j].Month[mon].value); 
                               CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[j].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[j].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[j].Month[mon].selected}); 
                            }
                            else  
                               CustomMonth.push({ label: inputScheduleValue[m].listofOppSchedule[j].Month[mon].label, value:  inputScheduleValue[m].listofOppSchedule[j].Month[mon].value ,selected : inputScheduleValue[m].listofOppSchedule[j].Month[mon].selected});
                            
                            
                        }
                        //Custom Month code End//
                        
                        //Custom Year Code Start//
                        var CustomYear=[];
                        for(var YearCounter=0;YearCounter<inputScheduleValue[m].listofOppSchedule[j].Year.length;YearCounter++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].selected){
                                year1=parseInt(inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].value);     
                                CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].selected}); 
                            }
                            else  
                                CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].selected});
                            
                            
                        }
                        //Custom Year Code End//
                        var datevalue = new Date(year1, month1, 1);
            /* if(year1 < year)
                         { 
                            validateEdd = 'EDDNOTVALIDATED';
							eddvalidate=true;
                       		object[m].listofOppSchedule.push({validate:eddvalidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[m].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});	
								
                         }	
                         
                        else if(year1 == year && month1 <=  month  ){
                            validateEdd = 'EDDNOTVALIDATED';
							eddvalidate=true;
                       		object[m].listofOppSchedule.push({validate:eddvalidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[m].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});	
                        }*/
						
            
			
            if(parseInt(sumOfSchedule) >parseInt(inputScheduleValue[m].Quantity)){
                object[m].listofOppSchedule.push({validate:true,counterBreakDown:j,ScheduleDate:inputScheduleValue[m].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});	
            }
            
            else if((parseInt(year1) <= parseInt(year)) && (!(component.get("v.ProfileName") === '00e70000000x3egAAA'))){
                 if(parseInt(month1) < parseInt(month))
                            { 
                                validateEdd = 'EDDNOTVALIDATED';
                                eddvalidate=true;
                                object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:eddvalidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[m].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});    
                            }
                            else{
                                    object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:eddvalidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[m].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});   
                                }
            }
            
            else{
                object[m].listofOppSchedule.push({validate:eddvalidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[m].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});	
            }
        }
        
        if(parseInt(sumOfSchedule) > parseInt(inputScheduleValue[m].Quantity)){
			 
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "The sum of Sub Quantity cannot be greater than the Total Quantity. Please make the adjustments and save again.",
                "Category" : "Error",
                "isShow" : "True" 
            });
            FloatMsgEvent.fire();
		}
		else
		{
         if(validateEdd == 'EDDNOTVALIDATED'){
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "All Schedule month should not be less than the Expected Delivery Start Date, Correct the highlighted dates and then SAVE",
                "Category" : "Error",
                "isShow" : "True" 
            });
            FloatMsgEvent.fire();
            
            inputScheduleValue.splice(m,1,object[m]);
            component.set("v.scheduleValue",inputScheduleValue);
        }
        
        else if(validateEdd == 'Validated'){
            object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:inputScheduleValue[m].UnschldQty,Duration:opts,collapse:true,listofOppSchedule:[]}; 	
            var validateCheck='Validated';
            var ValidateMonthYear ;
            var isMonthYearNeedToCheck=true;
            for (var i = 0; i < inputScheduleValue[m].listofOppSchedule.length; i++) 
            {
                var ss=false;
                var date1 =inputScheduleValue[m].listofOppSchedule[i].ScheduleDate;
                var arrdate1=(date1.split("-"));
                var datevalue = new Date(arrdate1[0], arrdate1[1] - 1, arrdate1[2]);
                var month1;
                var year1;
                //Custom Month code Start//
                        var CustomMonth=[];
                        
                        for(var mon=0;mon<inputScheduleValue[m].listofOppSchedule[i].Month.length;mon++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[i].Month[mon].selected){
                                
                               month1=parseInt(inputScheduleValue[m].listofOppSchedule[i].Month[mon].value);    
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
                                year1=parseInt(inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].value);
                            }
                            else  
                            CustomYear.push({ label: inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].label, value:  inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].value ,selected : inputScheduleValue[m].listofOppSchedule[i].Year[YearCounter].selected});
                            
                        }
                        //Custom Year Code End// 
                
                for (var j = 0; j < inputScheduleValue[m].listofOppSchedule.length; j++) 
                {
                    var month2;
                    var year2;	
                    if (parseInt(i) != parseInt(j)) 
                    {
                        
                        
                            for(var mon=0;mon<inputScheduleValue[m].listofOppSchedule[j].Month.length;mon++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[j].Month[mon].selected){
                              
                               month2=parseInt(inputScheduleValue[m].listofOppSchedule[j].Month[mon].value); 

                            }

                            
                        }
                        //Custom Month code End//
                        
            			//Custom Year Code Start//
                       
						for(var YearCounter=0;YearCounter<inputScheduleValue[m].listofOppSchedule[j].Year.length;YearCounter++){
                            
                            if(inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].selected){
                               year2=inputScheduleValue[m].listofOppSchedule[j].Year[YearCounter].value; 
                            }
                        }
                        
						
						//Custom Year Code End/		
                           var datevalue = new Date(year1, month1, 1);
							var datevalue2 = new Date(year2, month2, 1);
                            
                            
                            /*if(month1 == month2 && year1 == year2) 
                                            {
                                                //alert(inputScheduleValue[m].listofOppSchedule[i].counterBreakDown);
                                                validateCheck='NotValidated'; // means there are duplicate values
                                                //object[m].listofOppSchedule.push({validate:false,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
                                                var cc=i;
                                                ss=true;   
                                            }*/	
                            if(datevalue.getTime() == datevalue2.getTime()){
                                
                                validateCheck='NotValidated'; 
                                var cc=i;
                                ss=true;
                            }
                            
                        
                    }
                }
                
                if(ss === true){
                    isMonthYearNeedToCheck = false;
                    object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
                }
                else{
                    var ScheduleQty = parseInt(inputScheduleValue[m].listofOppSchedule[i].Quantity);
                    if(ScheduleQty>0  ){
                        if((isNaN(year1) || isNaN(month1)) && (isMonthYearNeedToCheck)){
                             ValidateMonthYear = 'NotValidate';
						     ss=true;
                            object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
                        }
                        else{
                            object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
                        }
                    }
                    else{
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
                    }
                    //object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:i,ScheduleDate:inputScheduleValue[m].listofOppSchedule[i].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[i].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[i].Id});
                }
                
               // if(inputScheduleValue[m].UnschldQty>0){
                  //  unschqtyvalidate=true;
                    
               // }
                
            }
            
            
            if(validateCheck == 'NotValidated'){ 
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Schedule month for a product should not be same. Correct the highlighted dates to be unique and then SAVE.",
                    "Category" : "Error",
                    "isShow" : "True"  
                }); 
                FloatMsgEvent.fire();
                inputScheduleValue.splice(m,1,object[m]);
                component.set("v.scheduleValue",inputScheduleValue);
                
            }
            else if(ValidateMonthYear === 'NotValidate'){
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Please select the valid Month and Year of the highlighted schedule.",
                    "Category" : "Error",
                    "isShow" : "True"  
                }); 
                FloatMsgEvent.fire();
                inputScheduleValue.splice(m,1,object[m]);
                component.set("v.scheduleValue",inputScheduleValue);
            }
            else{
                
               
                inputScheduleValue.splice(m,1,object[m]);
                 
                    if(inputScheduleValue[m].UnschldQty>0){
                        inputScheduleValue[m].UnscheduleFinder=true;
                        unschqtyvalidate=true;
                        
                        
                    }else{
                        inputScheduleValue[m].UnscheduleFinder=false;
                    }
               
                if(unschqtyvalidate==true){
                    //Added by Saritha
                    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "You have unscheduled quantity in topline. Please see highlighted ones.",
                        "Category" : "Warning", 
                        "isShow" : "True" 
                    }); 
                    FloatMsgEvent.fire();
                }
                component.set("v.scheduleValue",inputScheduleValue);
                helper.saveSchedulerHelper(component, event, helper);
            }
            
        }
        
    }
},
    
    SaveScheduleValidations : function(component, event, helper){
        var action =component.get("c.SaveScheduleValidations");
        action.setParams({      
            productScheduleList : component.get("v.scheduleValue")      
        }); 
        //alert('hey');
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                // alert('Enter Validation Method');  
                
            }
            else{ 
                // alert(error);
            }
            // component.set("v.ShowHideSchedulerSpinner",false);
        });
        $A.enqueueAction(action); 
    },
    
    RecalculateQuantity : function(component, event, helper){
        var m=component.get("v.IndentifierClint");
        var inputScheduleValue = component.get("v.scheduleValue");
        var object=[]; 
        var sumofbreakdown=0;
        var UnsynkQunatity=0; 
        var counterForBreakDownQuantity=0;
        var denominator = Math.pow(10, 0);
        for(var i=0 ;i<inputScheduleValue[m].listofOppSchedule.length; i++ ){
				 
				 if(inputScheduleValue[m].listofOppSchedule[i].Quantity === null || inputScheduleValue[m].listofOppSchedule[i].Quantity === ''){
					 counterForBreakDownQuantity=counterForBreakDownQuantity+1;
                     
				 } 
                
					 
			}
           
           if(counterForBreakDownQuantity > 0){
              alert('BreakDown Quantity Can not be blank');
                
                var opts=[];
                var finalUnitPrice=Math.round((parseInt(inputScheduleValue[m].TotalPrice)/inputScheduleValue[m].Quantity) * denominator)/denominator;
                for(var l=0;l<inputScheduleValue[m].Duration.length;l++){
                        if(inputScheduleValue[m].Duration[l].selected === true){
                            opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : true});  
                        }
                        else{
                            opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : false}); 
                        }
        		}
                
                for(var j=0;j<inputScheduleValue[m].listofOppSchedule.length; j++){
                   if(inputScheduleValue[m].listofOppSchedule[j].Quantity === null || inputScheduleValue[m].listofOppSchedule[j].Quantity === ''){ 
                 	sumofbreakdown=parseInt(sumofbreakdown)+parseInt(0);
                 	} 
                    else{
                      sumofbreakdown=parseInt(sumofbreakdown)+parseInt(inputScheduleValue[m].listofOppSchedule[j].Quantity);  
                    } 
                }
                
                 if(inputScheduleValue[m].Quantity>sumofbreakdown){ 
            		UnsynkQunatity=parseInt(inputScheduleValue[m].Quantity)-parseInt(sumofbreakdown);
                     
            		object[m]={Id:inputScheduleValue[m].Id,UnitPrice:finalUnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:UnsynkQunatity,TheCheck:false,Duration:opts,collapse:inputScheduleValue[m].collapse,EditMode:inputScheduleValue[m].EditMode,listofOppSchedule:[]};
        		 }
                else{
                    object[m]={Id:inputScheduleValue[m].Id,UnitPrice:finalUnitPrice,Quantity:sumofbreakdown,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:UnsynkQunatity,Duration:opts,TheCheck:false,collapse:inputScheduleValue[m].collapse,EditMode:inputScheduleValue[m].EditMode,listofOppSchedule:[]};
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
                    if(inputScheduleValue[m].listofOppSchedule[k].Quantity === null || inputScheduleValue[m].listofOppSchedule[k].Quantity === ''){ 
                        //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:0,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[k].Id});
                    }
                    else{
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                    }
        	    }
                
                inputScheduleValue.splice(m,1,object[m]);
                component.set("v.scheduleValue",inputScheduleValue);   

           }
           
           else{   
                 object=[];
                 var opts=[];
                 var finalUnitPrice=Math.round((parseInt(inputScheduleValue[m].TotalPrice)/inputScheduleValue[m].Quantity) * denominator)/denominator;
				 
                for(var l=0;l<inputScheduleValue[m].Duration.length;l++){
                        if(inputScheduleValue[m].Duration[l].selected === true){
                            opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : true});  
                        }
                        else{
                            opts.push({ label: inputScheduleValue[m].Duration[l].label, value:  inputScheduleValue[m].Duration[l].value ,selected : false}); 
                        }
        		} 
                
                for(var j=0;j<inputScheduleValue[m].listofOppSchedule.length; j++){
                 sumofbreakdown=parseInt(sumofbreakdown)+parseInt(inputScheduleValue[m].listofOppSchedule[j].Quantity);
                 }
               
                  //alert('sumofbreakdown'+sumofbreakdown);
                 if(inputScheduleValue[m].Quantity>sumofbreakdown){ 
            		UnsynkQunatity=parseInt(inputScheduleValue[m].Quantity)-parseInt(sumofbreakdown);
                     //alert('UnsynkQunatity'+UnsynkQunatity);
            		object[m]={Id:inputScheduleValue[m].Id,UnitPrice:finalUnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:UnsynkQunatity,TheCheck:false,Duration:opts,collapse:inputScheduleValue[m].collapse,EditMode:inputScheduleValue[m].EditMode,listofOppSchedule:[]};
        		 }
                else{
                    object[m]={Id:inputScheduleValue[m].Id,UnitPrice:finalUnitPrice,Quantity:sumofbreakdown,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:UnsynkQunatity,Duration:opts,TheCheck:false,collapse:inputScheduleValue[m].collapse,EditMode:inputScheduleValue[m].EditMode,listofOppSchedule:[]};
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
                      if(inputScheduleValue[m].listofOppSchedule[k].Quantity === null || inputScheduleValue[m].listofOppSchedule[k].Quantity === ''){ 
                        //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:0,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[k].Id});
                    }
                    else{
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                    } 
        	    }
                 
                inputScheduleValue.splice(m,1,object[m]);
       		    component.set("v.scheduleValue",inputScheduleValue); 
                helper.RecalculateQuantity2helper(component, event, helper);
			} 
    },
    RecalculateQuantity2 : function(component, event, helper){
        helper.RecalculateQuantity2helper(component, event, helper);
    },
    
    CaptureIdentifier : function(component, event, helper){
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        //console.log('CaptureIdentifier'+idd);
        component.set("v.IndentifierClint",idd);  
    },
    CopyBreakDown :function(component, event, helper){
        //component.set("v.SchedulerSectionSelectAll",true); 
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        //alert('click on Index '+ idd);  
        var inputScheduleValue = component.get("v.scheduleValue");
        var object=[];
        for(var i=0; i<inputScheduleValue.length;i++){
            var opts=[]; 
            for(var l=0;l<inputScheduleValue[i].Duration.length;l++){
                if(inputScheduleValue[i].Duration[l].selected === true){
                    opts.push({ label: inputScheduleValue[i].Duration[l].label, value:  inputScheduleValue[i].Duration[l].value ,selected : true});  
                }
                else{
                    opts.push({ label: inputScheduleValue[i].Duration[l].label, value:  inputScheduleValue[i].Duration[l].value ,selected : false}); 
                }
            } 
            if(parseInt(idd) == parseInt(i))
            {
                object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,TheCheck:false,Duration:opts,collapse:inputScheduleValue[i].collapse,EditMode:inputScheduleValue[i].EditMode,hideIndex:true,copycheckbox:false,listofOppSchedule:[]}; 
            }
            else
            {
                object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,TheCheck:false,Duration:opts,collapse:inputScheduleValue[i].collapse,EditMode:inputScheduleValue[i].EditMode,hideIndex:false,copycheckbox:false,listofOppSchedule:[]}; 
            } 
            for(var k=0;k<inputScheduleValue[i].listofOppSchedule.length; k++){
                //Custom Month code Start//
                        var CustomMonth=[]; 
                		CustomMonth.push({ label: '---', value:  '---',selected : true});
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
                object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[i].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                
            }
            
        }	        
        component.set("v.ShowHideCopyModel",true); 
        component.set("v.CopyPasteAttribute",object);
        component.set("v.IndentifierCopyElementforHide",idd);
        
        
        var finalvalueofprevious = $A.get("e.c:getPreviousValue");
        finalvalueofprevious.setParams({ 
            "RrquestForPreviousData" : 'Request From Scheuler' 
        });
        finalvalueofprevious.fire();
         
    },
    PasteBreakDown : function(component, event, helper){
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        //var idd='123Prvs';
        var inputScheduleValue = component.get("v.scheduleValue");
        var copyIndex=component.get("v.IndentifierCopyElementforHide");

        if(idd.indexOf('Prvs')>0)
        {  
            var opts=[];
            var object=[];
            
            var pasteIndex=idd.substr(0, idd.indexOf('Prvs'));
            for(var k=0;k<inputScheduleValue[copyIndex].Duration.length;k++){ 
                
                if(inputScheduleValue[copyIndex].Duration[k].selected === true){
                    
                    opts.push({ label: inputScheduleValue[copyIndex].Duration[k].label, value:  inputScheduleValue[copyIndex].Duration[k].value ,selected : true});  
                } 
                else{
                    opts.push({ label: inputScheduleValue[copyIndex].Duration[k].label, value:  inputScheduleValue[copyIndex].Duration[k].value ,selected : false}); 
                } 
            }
            
            object[0]={Id:inputScheduleValue[copyIndex].Id,UnitPrice:inputScheduleValue[copyIndex].UnitPrice,Quantity:inputScheduleValue[copyIndex].Quantity,TotalPrice:inputScheduleValue[copyIndex].TotalPrice,counter:pasteIndex,ProductName:inputScheduleValue[copyIndex].ProductName,UnschldQty:inputScheduleValue[copyIndex].Quantity,Duration:opts,collapse:true,listofOppSchedule:[]};
            
            for(var i=0;i<inputScheduleValue[copyIndex].listofOppSchedule.length;i++){
                
               //Custom Month code Start//
                        var CustomMonth=[];
            			var m=copyIndex;
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
                object[0].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:i,ScheduleDate:inputScheduleValue[copyIndex].listofOppSchedule[i].ScheduleDate,Quantity:0,Type:'Quantity',Id:inputScheduleValue[copyIndex].listofOppSchedule[i].Id});
                
            }
            
            var EventForPreviousScheduler = $A.get("e.c:PasteDataTopreviousSchedule");
            EventForPreviousScheduler.setParams({ 
                "PasteData" : object[0], 
                "Index" : pasteIndex
            });
            EventForPreviousScheduler.fire();
            component.set("v.ShowHideCopyModel",false);
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Copy Is Completed Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
        
        else
        {
            var opts=[];
            var object=[];
            
            var pasteIndex=idd; 
            
            for(var k=0;k<inputScheduleValue[copyIndex].Duration.length;k++){ 
                
                if(inputScheduleValue[copyIndex].Duration[k].selected === true){
                    
                    opts.push({ label: inputScheduleValue[copyIndex].Duration[k].label, value:  inputScheduleValue[copyIndex].Duration[k].value ,selected : true});  
                } 
                else{
                    opts.push({ label: inputScheduleValue[copyIndex].Duration[k].label, value:  inputScheduleValue[copyIndex].Duration[k].value ,selected : false}); 
                } 
            }
            
            object[copyIndex]={Id:inputScheduleValue[pasteIndex].Id,UnitPrice:inputScheduleValue[pasteIndex].UnitPrice,Quantity:inputScheduleValue[pasteIndex].Quantity,TotalPrice:inputScheduleValue[pasteIndex].TotalPrice,counter:pasteIndex,ProductName:inputScheduleValue[pasteIndex].ProductName,UnschldQty:inputScheduleValue[pasteIndex].Quantity,Duration:opts,collapse:true,listofOppSchedule:[]};
            
            for(var i=0;i<inputScheduleValue[copyIndex].listofOppSchedule.length;i++){
                
                //Custom Month code Start//
                        var CustomMonth=[]; 
                		CustomMonth.push({ label: '---', value:  '---' ,selected : true});
                        CustomMonth.push({ label: 'Jan', value:  '1' ,selected : false});
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
                object[copyIndex].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:i,ScheduleDate:inputScheduleValue[copyIndex].listofOppSchedule[i].ScheduleDate,Quantity:0,Type:'Quantity',Id:inputScheduleValue[copyIndex].listofOppSchedule[i].Id});
                 
            }
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Copy Is Completed Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            
            component.set("v.ShowHideCopyModel",false);
            
            inputScheduleValue.splice(pasteIndex,1,object[copyIndex]);  
            component.set("v.scheduleValue",inputScheduleValue);
            component.set("v.ShowHideCopyModel",false);	
        }
        
    },
    handlesInsertSchApplicationEvent :function(component, event, helper){
        helper.handlesInsertSchApplicationEvent(component, event, helper)
        
    },
    handlesDeleteSchApplicationEvent :function(component, event, helper){
        helper.handlesDeleteSchApplicationEvent(component, event, helper)
        
    },
    
    cancelDuration :function(component, event, helper){
        component.set("v.ShowCustomDuration",false);
        
    },
    setDuration :function(component, event, helper){
        var inputCmp = component.find("inputCmp");
        var value = inputCmp.get("v.value");
        // console.log(value);
        var selected = component.find("customDuration").get("v.value");
        //console.log(selected);  

						var CustomMonth=[];
                    	CustomMonth.push({ label: '---', value:  '---' ,selected : true});
                        CustomMonth.push({ label: 'Jan', value:  '1' ,selected : false});
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
                    //Custom Month code Start//



		
        if (isNaN(value)) {
            inputCmp.set("v.errors", [{message:"Input not a number: " + value}]);
        } else {
            if(selected=='Years'){
                // alert('here');
                value=(parseInt(value)*12);
                component.set("v.CustomMonth",(parseInt(value)*12).toString());
            }
            component.set("v.CustomMonth",value.toString());                
            //alert(parseInt(value));
            if(parseInt(value)>100){
                inputCmp.set("v.errors", [{message:"Schedules are more than 100 Months: " + value}]); 
            }else{
                // alert('else');
                //copied
                var s=component.get("v.EDD").split("-");
                var d=new Date(component.get("v.EDD"));        
                var eddMon=d.getMonth();
                var eddYr=d.getFullYear();
                var eddDay=s[2];
                
                
                //var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                //"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                //             ];
                var m=component.get("v.IndentifierClint");
                var inputScheduleValue = component.get("v.scheduleValue");
                var object=[]; 
                var sumofbreakdown=0;
                var UnsynkQunatity=0; 
                var opts=[];
                for(var k=0;k<inputScheduleValue[m].Duration.length;k++){                
                    if(inputScheduleValue[m].Duration[k].selected === '----'){
                        opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : true});  
                    }
                    
                    else{
                        opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : false}); 
                    }
                }
                
                var denominator = Math.pow(10, 0);
                var NewToatlProce=parseInt(inputScheduleValue[m].Quantity)*parseInt(inputScheduleValue[m].UnitPrice);
                var NewToatlProce=Math.round(NewToatlProce * denominator)/denominator;
                
                object[m]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:NewToatlProce,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:0,Duration:opts,collapse:inputScheduleValue[m].collapse,listofOppSchedule:[]}; 
                
                // Breakdown logic Start here
                
                var remain=parseInt(inputScheduleValue[m].Quantity);
                var partsLeft=parseInt(component.get("v.CustomMonth"));
                for(var j=0;j<partsLeft; j++){ 
                    //alert('Length of Breakdown'+j+'--'+inputScheduleValue[i].listofOppSchedule.length);
                var size=Math.floor((remain + partsLeft - j - 1) / (partsLeft - j));
                var EDD = component.get("v.EDD");
        		var EDDDateArry=(EDD.split("-"));
                
            	var datevalueEDD = new Date(EDDDateArry[0], EDDDateArry[1] - 1, 1);
                datevalueEDD.setMonth(datevalueEDD.getMonth() + j); 
				var scDate=datevalueEDD.getFullYear() + "-" + (datevalueEDD.getMonth()+1) + "-" + 1;  
                
                		var CustomMonth1=[];
                        for(var h=0;h<CustomMonth.length;h++){
                            
                           
                            if(parseInt(CustomMonth[h].value) === parseInt(datevalueEDD.getMonth()+1))
                            CustomMonth1.push({ label: CustomMonth[h].label, value:  CustomMonth[h].value,selected:true});      
                            else
                            CustomMonth1.push({ label: CustomMonth[h].label, value:  CustomMonth[h].value,selected:false});     
                        }
                                        
                        //Custom Month code End//
                        //Custom Year Code Start//
                        	var CustomYear1=[];
                			for(var k=0;k<CustomYear.length;k++){
                                //alert(CustomYear1[k].value);
								if(parseInt(datevalueEDD.getFullYear())===parseInt(CustomYear[k].value))
									CustomYear1.push({label:CustomYear[k].label,value:CustomYear[k].value,selected:true}); 
								else
									CustomYear1.push({label:CustomYear[k].label,value:CustomYear[k].value,selected:false});	
							}
                        	//CustomYear.push({label:datevalueEDD.getFullYear(),value:datevalueEDD.getFullYear(),selected:true}); 
						//Custom Year Code End//   
					
					
					
                    if(inputScheduleValue[m].listofOppSchedule.length>j){ 
                        //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                        object[m].listofOppSchedule.push({Month:CustomMonth1,Year:CustomYear1,counterBreakDown:j,ScheduleDate:scDate,Quantity:size,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[j].Id});
                    }
                    
                    else{
                        object[m].listofOppSchedule.push({Month:CustomMonth1,Year:CustomYear1,counterBreakDown:j,ScheduleDate:scDate,Quantity:size,Type:'Quantity',Id:''});
                    }                       
                    
                    remain =remain-size; 
                    
                }
                //BreakDown logic end
                
                // console.log(object[m]);  
                //console.log(inputScheduleValue[m].splice(m,0,object[m])); 
                inputScheduleValue.splice(m,1,object[m]);
                component.set("v.ShowCustomDuration",false);
                
                component.set("v.scheduleValue",inputScheduleValue);
                //copy ended
            }                
            // console.log('%%'+component.get("v.CustomMonth"));
        }     
    },
    handleApplicationEvent:function(component, event, helper){
         
						var inputScheduleValue = component.get("v.scheduleValue");
        				var EDD = component.get("v.EDD");
                        var EDDDateArry=(EDD.split("-"));
        				//array 0 will be year 
                       //array 1 will be month
                      //array 2 will be date
                        var datevalueEDD = new Date(EDDDateArry[0], EDDDateArry[1] - 1, EDDDateArry[2]);
						var month=parseInt(datevalueEDD.getMonth() + 1);
                        var year=parseInt(datevalueEDD.getFullYear());
        
            var ExpectedStartDateValidate=false;
            var UnscheduleValidate=false;
			var ScheduleSumValidate=false;
			
            var counter=0;
            var object=[];
            for(var i=0;i<inputScheduleValue.length;i++){
                var opts=[];
				var ScheduleSum=0
                
                for(var l=0;l<inputScheduleValue[i].listofOppSchedule.length;l++){
                    ScheduleSum+=parseInt(inputScheduleValue[i].listofOppSchedule[l].Quantity);
                }
                
                
                for(var d=0;d<inputScheduleValue[i].Duration.length;d++){                
                    if(inputScheduleValue[i].Duration[d].selected === true){
                        opts.push({ label: inputScheduleValue[i].Duration[d].label, value:  inputScheduleValue[i].Duration[d].value ,selected : true});  
                    }
                    
                    else{
                        opts.push({ label: inputScheduleValue[i].Duration[d].label, value:  inputScheduleValue[i].Duration[d].value ,selected : false}); 
                    }  
				}
                //console.log('For index::'+i);
                //console.log('For index i lenght of shdedule'+inputScheduleValue[i].listofOppSchedule.length);
                if(ScheduleSum > inputScheduleValue[i].Quantity){
					object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnscheduleFinder:false,UnschldQty:inputScheduleValue[i].UnschldQty,Duration:opts,collapse:true,ValidateQuantity:true,listofOppSchedule:[]}; 		
				}
                else{
					object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnscheduleFinder:false,UnschldQty:inputScheduleValue[i].UnschldQty,Duration:opts,collapse:true,ValidateQuantity:false,listofOppSchedule:[]}; 		
				}
                
                
                for(var j=0;j<inputScheduleValue[i].listofOppSchedule.length;j++){
                     var Firstdate =inputScheduleValue[i].listofOppSchedule[j].ScheduleDate;
                     
                     //console.log('Firstdate'+Firstdate);
                      //array 0 will be year 
                      //array 1 will be month
                      //array 2 will be date
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
							   year1=parseInt(inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value);	
							}
                            else  
                            CustomYear.push({ label: inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].label, value:  inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].value ,selected : inputScheduleValue[i].listofOppSchedule[j].Year[YearCounter].selected});
                        	
                            
                         }
						//Custom Year Code End//
                     var ArrayFirstDate=(Firstdate.split("-"));
                      var ConvertedFirstDate = new Date(year1, month1, 1);
                     var firstyear =ConvertedFirstDate.getFullYear();
                     var firstmonth=ConvertedFirstDate.getMonth() + 1;

                        if((parseInt(year1) <= parseInt(year)) && (!(component.get("v.ProfileName") === '00e70000000x3egAAA'))){
                            if(parseInt(month1) < parseInt(month))
                            { 
                                ExpectedStartDateValidate=true;
                           		counter=counter+1; 
                           		object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ExpectedStartDateValidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});	 
                            }
                            else{
                                ExpectedStartDateValidate=false;
                        		object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ExpectedStartDateValidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});	 
                            }
                        }
                    
                    	else{
                        ExpectedStartDateValidate=false;
                        object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ExpectedStartDateValidate,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});	 
                    	}
					 						 	                    
                }
				if(ScheduleSum > inputScheduleValue[i].Quantity){
							ScheduleSumValidate=true;
                            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "The sum of Sub Quantity cannot be greater than the Total Quantity. Please make the adjustments and save again.",
                                "Category" : "Error",
                                "isShow" : "True" 
                            });
                            FloatMsgEvent.fire();
							//object[i].listofOppSchedule.push({validate:true,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});	 
							
                	}
            }
                    
					
					if(ScheduleSumValidate){
						console.log(object);	
						 component.set("v.scheduleValue",object);
					}
					else
					{
					if(counter > 0){
                        //alert('>>>'+'Not Validated');
                        //fire sync event
                        var FireSyncEvent = $A.get("e.c:SyncEvent");
                        FireSyncEvent.setParams({
                        "SchedulerCollection" : object,
                        "MsgFromScheduler" : "true"
                    	});
                    	FireSyncEvent.fire(); 
                        component.set("v.scheduleValue",object);
                    }
        			else if(counter == 0){
                        //alert('>>>>'+'validated');
                        //component.set("v.scheduleValue",object);
                        //alert('counter'+counter); 
                        object=[];
                        var counterForSameDate=0;
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
                                for (var k = 0; k < inputScheduleValue[i].listofOppSchedule.length; k++) 
                                 { 
                                     var month2;
									 var year2;
                                     if(j != k){
                                         var SecondDate =inputScheduleValue[i].listofOppSchedule[k].ScheduleDate;
                                         var SecondDateArray=(SecondDate.split("-"));
                                         for(var mon=0;mon<inputScheduleValue[i].listofOppSchedule[k].Month.length;mon++){
											 if(inputScheduleValue[i].listofOppSchedule[k].Month[mon].selected){
												 month2=inputScheduleValue[i].listofOppSchedule[k].Month[mon].value;
											 }
										 }
										 
										 for(var YearCounter=0;YearCounter<inputScheduleValue[i].listofOppSchedule[k].Year.length;YearCounter++){
											 if(inputScheduleValue[i].listofOppSchedule[k].Year[YearCounter].selected){
												 year2=parseInt(inputScheduleValue[i].listofOppSchedule[k].Year[YearCounter].value);
											 }
										 }
                                         var ConvertedSecondDate = new Date(year2, month2, 1);
                                         var Secondmonth=parseInt(ConvertedSecondDate.getMonth() + 1);
                                         var Secondyear=parseInt(ConvertedSecondDate.getFullYear());
                                             /*if(Firstmonth == Secondmonth && Firstyear == Secondyear){
                                                 counterForSameDate=counterForSameDate+1; 
                                                 ss=true;
                                             }*/
                                             if(ConvertedFirstDate.getTime() === ConvertedSecondDate.getTime()){
                                                 counterForSameDate=counterForSameDate+1; 
                                                 ss=true;
                                             }
                                     }    
                                 } 
                                
                                if(ss === true){
                               			object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});
                        		}
							    else{
							   			object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,validate:ss,counterBreakDown:j,ScheduleDate:inputScheduleValue[i].listofOppSchedule[j].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[j].Quantity,Type:'Quantity',Id:inputScheduleValue[i].listofOppSchedule[j].Id});
								}
                            }    
                            
                       }
                        
                        if(counterForSameDate > 0){
                            //alert('Same Date Validation fail');
                            //fire sync event
                        var FireSyncEvent = $A.get("e.c:SyncEvent");
                             FireSyncEvent.setParams({
                                  "SchedulerCollection" : object,
                                  "MsgFromScheduler" : "true"
                    	     });
                    	FireSyncEvent.fire(); 
                        component.set("v.scheduleValue",object);
                            
                        }
                        
                        else
						{
                            if(!helper.ValidateMonthYearNull(component,event,helper)){
                                
                                var FireSyncEvent = $A.get("e.c:SyncEvent");
                                 FireSyncEvent.setParams({
                                  "SchedulerCollection" : object,
                                  "MsgFromScheduler" : "true"
                    	         });
                    	       FireSyncEvent.fire(); 
                            }
                            else{
                                for(var l=0;l<object.length;l++){
									if(object[l].UnschldQty>0){
										object[l].UnscheduleFinder=true;
										UnscheduleValidate=true;  
									}else{
										object[l].UnscheduleFinder=false;
									}
								 }
                
								if(UnscheduleValidate==true){
									var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
									FloatMsgEvent.setParams({
										"Msg" : "You have unscheduled quantity in topline. Please see highlighted ones.",
										"Category" : "Warning",
										"isShow" : "True"
									});
									FloatMsgEvent.fire(); 
									
								}
                              component.set("v.scheduleValue",object); 
                            //Fire Sync event
							   var FireSyncEvent = $A.get("e.c:SyncEvent");
								 FireSyncEvent.setParams({
									  "SchedulerCollection" : object,
									  "MsgFromScheduler" : "SUCCESS"
								 });
							   FireSyncEvent.fire(); 
                            }	 
                           //helper.handleApplicationEventhelper(component, event, helper);
                             
                        }
                  }
			}
	
      }, 
    
    updateDate:function(component, event, helper){
        
        component.set("v.EDD", event.getParam("EDSD"));
    },
    validateScheduleDate: function(component, event, helper){
        //alert('>>>');
    },
    CancelCopyWindow: function(component, event, helper){
        helper.CancelCopyWindow(component, event, helper);
    },
   
    ManageQuantitySchedule : function(component, event, helper){
        
        helper.ManageQuantityScheduleHelper(component,event,helper);
    },
    OpenCopyPasteWindo:function(component,event){
        var inputScheduleValue = event.getParam("PreviousData");
        var object=[];
        for(var i=0; i<inputScheduleValue.length;i++){
            var opts=[]; 
            for(var l=0;l<inputScheduleValue[i].Duration.length;l++){
                if(inputScheduleValue[i].Duration[l].selected === true){
                    opts.push({ label: inputScheduleValue[i].Duration[l].label, value:  inputScheduleValue[i].Duration[l].value ,selected : true});  
                }
                else{
                    opts.push({ label: inputScheduleValue[i].Duration[l].label, value:  inputScheduleValue[i].Duration[l].value ,selected : false}); 
                }
            } 
            
            
            object[i]={Id:inputScheduleValue[i].Id,UnitPrice:inputScheduleValue[i].UnitPrice,Quantity:inputScheduleValue[i].Quantity,TotalPrice:inputScheduleValue[i].TotalPrice,counter:i,ProductName:inputScheduleValue[i].ProductName,UnschldQty:inputScheduleValue[i].UnschldQty,TheCheck:false,Duration:opts,collapse:inputScheduleValue[i].collapse,EditMode:inputScheduleValue[i].EditMode,hideIndex:false,copycheckbox:false,listofOppSchedule:[]}; 
            
            for(var k=0;k<inputScheduleValue[i].listofOppSchedule.length; k++){
                //Custom Month code Start//
                        var CustomMonth=[]; 
                        CustomMonth.push({ label: 'Jan', value:  '1' ,selected : true});
                        CustomMonth.push({ label: 'Feb', value:  '2' ,selected : false});
                        CustomMonth.push({ label: 'Mar', value:  '3' ,selected : false});
                        CustomMonth.push({ label: 'Apr', value:  '4' ,selected : false});
                        CustomMonth.push({ label: 'May', value:  '5' ,selected : false});
                        CustomMonth.push({ label: 'Jun', value: '6' ,selected : false});
                        CustomMonth.push({ label: 'Jul', value: '7' ,selected : false});
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
                object[i].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[i].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[i].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                
            } 
            
        }	        
        
        component.set("v.CopyPasteAttributePrevious",object);
        component.set("v.PreviousSelectAll",false);  
        component.set("v.SchedulerSelectAll",false);   
         
    },
    TatalAddjustment:function(component,event,helper){ 
        
        
        var inputScheduleValue = component.get("v.scheduleValue");
        var m=component.get("v.IndentifierClint");
        var object=[];   
        var opts=[]; 
		console.log(inputScheduleValue[m].TotalPrice);
        if(inputScheduleValue[m].TotalPrice == null){
            inputScheduleValue[m].TotalPrice=0;
        }
        if(inputScheduleValue[m].Quantity != '' || inputScheduleValue[m].UnitPrice != ''){
                 
            var denominator = Math.pow(10, 0);
                var NewUnitPrice=parseInt(inputScheduleValue[m].TotalPrice)/parseInt(inputScheduleValue[m].Quantity);
                var NewUnitPrice=Math.round(NewUnitPrice * denominator)/denominator;
                
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
                object[m]={Id:inputScheduleValue[m].Id,UnitPrice:NewUnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:0,TheCheck:false,EditMode:true,collapse:true,Duration:opts,listofOppSchedule:[]};   
                
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
                             CustomYear.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                        	
                            
                        }
						//Custom Year Code End//
                    if(inputScheduleValue[m].listofOppSchedule.length>k){ 
                        //alert('j breakdown'+inputScheduleValue[i].listofOppSchedule[j].Id);
                        object[m].listofOppSchedule.push({Month:CustomMonth,Year:CustomYear,counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:inputScheduleValue[m].listofOppSchedule[k].Id});
                    }
                    else{
                        object[m].listofOppSchedule.push({counterBreakDown:k,ScheduleDate:inputScheduleValue[m].listofOppSchedule[k].ScheduleDate,Quantity:inputScheduleValue[m].listofOppSchedule[k].Quantity,Type:'Quantity',Id:''});
                    }
        	}
                inputScheduleValue.splice(m,1,object[m]);
                component.set("v.scheduleValue",inputScheduleValue);	
            }
        	else{
                   console.log('console 2');
            	    var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "Required field mising",
                        "Category" : "Warning",
                        "isShow" : "True"
                    }); 
                    FloatMsgEvent.fire(); 
        	}
            
          
    },
    sentDateformScheduler:function(component,event){
       var finalvalueofscheduler = $A.get("e.c:SentSchedulerValue");
        finalvalueofscheduler.setParams({ 
            "SchedulerData" : component.get("v.scheduleValue")  
            });
        	finalvalueofscheduler.fire();
    },
    HandlerPasteEvent:function(component,event){
        var index=[];
        
        var object=[]; 
        index=event.getParam("Index");
        var SchedulerData=event.getParam("PasteData");
        var inputScheduleValue = component.get("v.scheduleValue");
        for(var i=0;i<index.length;i++){ 
        	var m=index[i];
            var opts=[];
            for(var k=0;k< inputScheduleValue[m].Duration.length;k++){
                
                        if(inputScheduleValue[m].Duration[k].selected === true){
                            
                            opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : true}); 
                        }
                        else {
                            
                            opts.push({ label: inputScheduleValue[m].Duration[k].label, value:  inputScheduleValue[m].Duration[k].value ,selected : false}); 
                        }                      
            }
            
            
           object[i]={Id:inputScheduleValue[m].Id,UnitPrice:inputScheduleValue[m].UnitPrice,Quantity:inputScheduleValue[m].Quantity,TotalPrice:inputScheduleValue[m].TotalPrice,counter:m,ProductName:inputScheduleValue[m].ProductName,UnschldQty:inputScheduleValue[m].Quantity,Duration:opts,collapse:true,EditMode:inputScheduleValue[m].EditMode,listofOppSchedule:[]}; 
           console.log(SchedulerData);
           for(var j=0;j<SchedulerData.listofOppSchedule.length;j++){
                 //Custom Month code Start//
                       
                        var CustomMonth=[];
                		CustomMonth.push({ label: '---', value:  '---' ,selected : true});
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
                object[i].listofOppSchedule.push({Month:SchedulerData.listofOppSchedule[j].Month,Year:SchedulerData.listofOppSchedule[j].Year,counterBreakDown:j,ScheduleDate:SchedulerData.listofOppSchedule[j].ScheduleDate,Quantity:0,Type:'Quantity',Id:SchedulerData.listofOppSchedule[j].Id});
                
            } 
            inputScheduleValue.splice(m,1,object[i]);
        }
           
            component.set("v.ShowHideCopyModel",false);
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Product Copy Is Completed Succesfully.",
                "Category" : "Success",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
            component.set("v.scheduleValue",inputScheduleValue);              
    },
    getProfileId : function(component,event,helper){
      component.set("v.ProfileName",event.getParam("ProfileName"));
    },
    Getfocus:function(component,event,helper){
         
         var currentTarger=event.currentTarget.id;
         event.currentTarget.focus(); 
         
    }, 
    Losefocus:function(component,event,helper){
        var currentTarger=event.currentTarget.id;
         event.currentTarget.blur(); 
    }, 
    collectCopyPasteIndex:function(component,event,helper){
        
        var schedulerObjectArray=component.get("v.CopyPasteAttribute");
        var previousSchedulerObjectArray=component.get("v.CopyPasteAttributePrevious");
        var idx = event.currentTarget;
        var idd=idx.dataset.ids;
        var copyfromIndex=component.get("v.IndentifierCopyElementforHide");   
        var IndexArrayofScheduler=[];
        var IndexArrayofPreviousScheduler=[];
        var object=[];
        var opts=[];
        var CustomMonth=[];
        var CustomYear=[];
        var inputScheduleValue = component.get("v.scheduleValue");
        
        
            for(var i=0;i<schedulerObjectArray.length;i++)
            {	 
                 
                if((parseInt(component.get("v.IndentifierCopyElementforHide")) != parseInt(i)) && (schedulerObjectArray[i].copycheckbox === true)){
                  
                   IndexArrayofScheduler.push(i);
                }
                
            }
            
          for(var j=0;j<previousSchedulerObjectArray.length;j++) 
           {
               
               if(previousSchedulerObjectArray[j].copycheckbox === true){
                 IndexArrayofPreviousScheduler.push(j);     
               } 
            	 
           }
           //console.log(IndexArrayofScheduler); 
           //console.log(IndexArrayofPreviousScheduler);
           object[0]={Id:inputScheduleValue[copyfromIndex].Id,UnitPrice:inputScheduleValue[copyfromIndex].UnitPrice,Quantity:inputScheduleValue[copyfromIndex].Quantity,TotalPrice:inputScheduleValue[copyfromIndex].TotalPrice,counter:idd,ProductName:inputScheduleValue[copyfromIndex].ProductName,UnschldQty:inputScheduleValue[copyfromIndex].Quantity,Duration:inputScheduleValue[copyfromIndex].Duration,collapse:true,listofOppSchedule:[]};
           
           for(var k=0;k<inputScheduleValue[copyfromIndex].listofOppSchedule.length;k++){
               
              object[0].listofOppSchedule.push({Month:inputScheduleValue[copyfromIndex].listofOppSchedule[k].Month,Year:inputScheduleValue[copyfromIndex].listofOppSchedule[k].Year,counterBreakDown:k,ScheduleDate:inputScheduleValue[copyfromIndex].listofOppSchedule[k].ScheduleDate,Quantity:0,Type:'Quantity',Id:inputScheduleValue[copyfromIndex].listofOppSchedule[k].Id});  
           }
        
           if(IndexArrayofPreviousScheduler.length > 0 ){
           
                var EventForPreviousScheduler = $A.get("e.c:PasteDataTopreviousSchedule");
            	EventForPreviousScheduler.setParams({ 
                        "PasteData" : object[0], 
                        "Index" : IndexArrayofPreviousScheduler
            	});
            	EventForPreviousScheduler.fire();
            }
            
        
            //Copy paste functionality
            var object1=[];   
            if(IndexArrayofScheduler.length > 0){
                
                for(var l=0;l<IndexArrayofScheduler.length;l++){
                    var m=IndexArrayofScheduler[l];
                    inputScheduleValue[m].collapse=true;    
                    inputScheduleValue[m].listofOppSchedule= object[0].listofOppSchedule;
                    
                } 
            } 
         		
         component.set("v.scheduleValue",inputScheduleValue); 
         component.set("v.ShowHideCopyModel",false);   
    },
    SelectAllCheckBox:function(component,event,helper){
       
        var schedulerObjectArray=component.get("v.CopyPasteAttribute");
        if(component.find("SchedulerSection").get("v.value"))
        {
           for(i=0;i<schedulerObjectArray.length;i++){ 
            schedulerObjectArray[i].copycheckbox=true;  
            
        	} 
        }
        else
        {	
			for(i=0;i<schedulerObjectArray.length;i++){ 
            schedulerObjectArray[i].copycheckbox=false;  
            
        	}
			               
        }
        component.set("v.CopyPasteAttribute",schedulerObjectArray);

         var PreviousschedulerObjectArray=component.get("v.CopyPasteAttributePrevious");
            if(component.find("PreviousSchedulerSection").get("v.value"))
            {
               for(i=0;i<PreviousschedulerObjectArray.length;i++){ 
                PreviousschedulerObjectArray[i].copycheckbox=true;  
                
                } 
            }
            else
            {	
                for(i=0;i<PreviousschedulerObjectArray.length;i++){ 
                PreviousschedulerObjectArray[i].copycheckbox=false;  
                
                }
                             
            }
          
          component.set("v.CopyPasteAttributePrevious",PreviousschedulerObjectArray);
           
    }
    
})