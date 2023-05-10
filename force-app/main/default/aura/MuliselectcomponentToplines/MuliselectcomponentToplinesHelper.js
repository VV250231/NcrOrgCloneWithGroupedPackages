({
	CreatePicklist : function(component, event, helper) {
		var action = component.get("c.getpickval_CompetitorValues"); 
        var inputsel = component.find("v.arrvals"); 
        var opts=[]; 
        action.setCallback(this, function(a) { 
           
                	//alert('fINAL'+a.getReturnValue()); 
            		var str = a.getReturnValue();
					var str_array = str.split(';');

				for(var i = 0; i < str_array.length; i++) {
   						// Trim the excess whitespace.
   						str_array[i] = str_array[i].replace(/^\s*/, "").replace(/\s*$/, "");
                       // Add additional code here, such as:
   						alert(str_array[i]); 
                    	opts.push({index: i ,value: str_array[i]}); 
						}
                
           
                 component.set("v.arrvals",opts);    
        });
        $A.enqueueAction(action);  
	},
    
    RightToLeft : function(component, event, helper) {
        var ss=component.get("v.arrvalsSelect");
        var avilablearry=component.get("v.arrvals"); 
        
        var selectvalue=event.target.innerHTML;
        
       
        var newarry=[];
        for(var j=0;j<avilablearry.length;j++){
            
            if(avilablearry[j].value === selectvalue)
            {
					  //avilablearry.splice(selectvalue,1);
                	  avilablearry.splice(j, 1);	 
                      
            }  
        }
        component.set("v.arrvals",avilablearry);
        
        var selectedopts=[];
        for(var i=0;i<ss.length;i++){
                if(ss[i].value !=  selectvalue){
                    selectedopts.push({index: i ,value : ss[i].value});
                    
                }	 
            }      
        selectedopts.push({index : parseInt(ss.length+1) ,value  : selectvalue});
        component.set("v.arrvalsSelect",selectedopts);   
        this.fireComponentEvent(component, event);
    },
    LeftToRight:function(component, event, helper){
       var rightarry=component.get("v.arrvalsSelect");
       var leftarry=component.get("v.arrvals"); 
       var selectedfromLeft = event.target.innerHTML;  
       var temparry1=[]; 
        if(leftarry.length >0)
        {
            for(var i=0 ; i<leftarry.length ; i++)
        	{
                
            	temparry1.push({index : i, value : leftarry[i].value});
                
            }
                
        }
        
       var i=0;
       do {
    		if(leftarry.length === 0 && temparry1.length === 0)
            {
            
        		temparry1.push({index : i, value : selectedfromLeft});
               
                //alert('i am colprate 2');
			}
           
            if(leftarry.length>0 )
           { 
               
               temparry1.push({index : parseInt(temparry1.length+1), value : selectedfromLeft});
               //alert('i am colprate 3');
        	   break;
               
           }
           i++;
		}
		while (i <leftarry.length);
        component.set("v.arrvals",temparry1);
        
        
        for(var j=0;j<rightarry.length;j++)
            {
                if(rightarry[j].value == selectedfromLeft)
                {
                    rightarry.splice(j, 1);
                }
            }
        component.set("v.arrvalsSelect",rightarry);
        this.fireComponentEvent(component, event);
    },
    fireComponentEvent : function(cmp, event) { 
        
		var parentName = cmp.get("v.arrvalsSelect");
		// Look up event by name, not by type
        var compEvents = cmp.getEvent("componentEventFired");
        compEvents.setParams({ "context" : parentName });
        compEvents.fire();
        },
    
    wrapperMultiValue: function(component, event, helper){
        var accrecid=component.get("v.AccountId");
        //alert('accountid>>>>'+accrecid); 
        var action = component.get("c.NewGetPicklistCompetetorsValue"); 
         action.setParams({ 
        	accId : accrecid     
    	}); 
        var rightarray=[];  
        var leftarray=[]; 
        action.setCallback(this, function(a) {
            if(a.getReturnValue() != null){
                
            
              for(var i=0;i<a.getReturnValue().length;i++){
                 
                 //alert('2'+a.getReturnValue()[i].ListValue); 
                if(a.getReturnValue()[i].Selecetd){
                    rightarray.push({index: i ,value: a.getReturnValue()[i].ListValue}); 
                }
                else{
                    leftarray.push({index: i ,value: a.getReturnValue()[i].ListValue});
                }
            } 
             
            component.set("v.arrvals",leftarray);
            component.set("v.arrvalsSelect",rightarray);
            } 
           // else{
               // alert('Account dose not have a Majors Product Matrix attached');  
           // }
        });
        $A.enqueueAction(action); 
    },
     
    Cancelcompetetorsection:function(component){
        
        document.getElementById("modalwindow").style.display = "None";
        document.getElementById("newcmpsection").style.display = "None";
         
        
      },
    
     setHwCompetetors : function(component, event, helper) {

        var action = component.get("c.addCompetetors"); 
        var comp = component.find("comp").get("v.value");	
           
              action.setParams({ "testvalue" : comp });	
  
        action.setCallback(this, function(response) {
            var state = response.getState();           
                if (state === "SUCCESS") 
                {  
                
                   this.wrapperMultiValue(component); 
                    component.set("v.testvalue",null); 
                } 
          
        } );
     
        $A.enqueueAction(action); 
    } ,
    
    
     saveHwCompetetors : function(component, event, helper) {
       
        
         var Selectedarray = component.get("v.arrvalsSelect");
         var accrecid=component.get("v.AccountId");
         var selectedvaluestring='';
         var i=0;
         do {
             if(i<=(Selectedarray.length-1))
             {
                 selectedvaluestring+=Selectedarray[i].value+';'; 
             }
             	i++;
			}
		while (i <Selectedarray.length);  
         
        var str = selectedvaluestring.substring(0, selectedvaluestring.length - 1);
        var action = component.get("c.saveCompetetors"); 
        var accrecid=component.get("v.AccountId"); 
         action.setParams({ 
                  accId : component.get("v.AccountId"),
                  rightvalues : str	

       });
         
        document.getElementById("modalwindow").style.display = "None";
        document.getElementById("newcmpsection").style.display = "None"; 
        //document.getElementById("spinnerdiv").style.display = "None";
      

        action.setCallback(this, function(response) {
           // alert('1');
            var state = response.getState();           
                if (state === "SUCCESS") 
                {  
                    document.getElementById("spinnerdiv").style.display = "None";
              		//alert('Refresh');
                    this.Cancelcompetetorsection(component);
                     //$A.get('e.force:refreshView').fire();	
                     //
                      var compEvent = component.getEvent("componentEventFired1");
                        compEvent.setParams({"v.myrecords" : compEvent});
                        compEvent.fire();
                        console.log('event fired' +compEvent);
                    $A.get('e.force:refreshView').fire();
 
                           
                } 
          
        } ); 
         //	document.getElementById("spinnerdiv").style.display = "block"; 
       
          $A.enqueueAction(action);  
    }  
});