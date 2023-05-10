({
	loadAccount: function(component) { 
        
		var action = component.get("c.getAccount");    
        action.setParams({   
        Accountid : component.get("v.AccountId")  
    });
        document.getElementById("spinnerdiv").style.display = "None"; 
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {
            
             document.getElementById("spinnerdiv").style.display = "None";
             component.set("v.account", a.getReturnValue()); 
             $A.get('e.force:refreshView').fire();
        } 
            else if (a.getState() === "ERROR") { 
            $A.log("Errors", a.getError());
                
        }
            
    });
    document.getElementById("spinnerdiv").style.display = "block";
    $A.enqueueAction(action);
     },
    getpicklistvalue: function(component){ 
        var Industryvalue=component.find("Industryvalue");
          
        var selectedIndustry = component.get("{!v.account}");
           
        var action = component.get("c.getpickval");
        var inputsel = component.find("InputSelectDynamic"); 
        var opts=[];
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputsel.set("v.options", opts);

        });     
        $A.enqueueAction(action); 
        },
     
    updateAccount:function(component)
    { 
       
        var action = component.get("c.saveAccount");    
        var account = component.get("v.account");
        action.setParams({"acc": account});
        action.setCallback(this, function(a) {   
        console.log('SAVED.');  
        document.getElementById("spinnerdiv").style.display = "None";     
            
            if(a.getState()==="SUCCESS"){
                
               document.getElementById("spinnerdiv").style.display = "None";
               component.set("v.RevenueWindowEditAccess", 'WindowRevenueNotAccess');
                
            }    
               
        } );
        document.getElementById("spinnerdiv").style.display = "block";
        $A.enqueueAction(action); 
        console.log('save:end'); 
        
       
        
         
     }, 
    showModal:function(component){
        
       
        component.set("v.RevenueWindowEditAccess", 'WindowRevenueNotAccess');
        
    },
    showEditAccountModal:function(component){
        
        
        var action = component.get("c.ShowHodeEditWindowRevenue");
        action.setCallback(this, function(response){ 
        var state = response.getState();
           
        if (state === "SUCCESS") {
            component.set("v.RevenueWindowEditAccess", response.getReturnValue());  
         } 
      });   
      
       $A.enqueueAction(action);  
    },
    getUserProfile:function(component){
        
        var action = component.get("c.getUserProfile"); 
        action.setParams({ 
        Accountid : component.get("v.AccountId")           
		});
        
    	action.setCallback(this, function(response){  
        var state = response.getState();
        var buttoncheck=response.getReturnValue();   
        if (state === "SUCCESS") { 
            component.set("v.ProfileName", response.getReturnValue()); 
            
            if(buttoncheck ==='ButtonAccess')
            {
                
                document.getElementById("EditButtonidentifier1").style.display = "block"; 
            }
            this.loadAccount(component);  
            
             
         } 
            
         else if (a.getState() === "ERROR") { 
            $A.log("Errors", a.getError());
                
        }   
      });   
       
       $A.enqueueAction(action);
   },
    
    getMyObjects: function(component){
                        
       var action = component.get("c.getAcountCompetetors"); 
                     action.setParams({ 
            Accountid : component.get("v.AccountId")
                         
       });	
            
       action.setCallback(this, function(response){
        var state = response.getState();           
                if (state === "SUCCESS") 
                {
            component.set("v.myrecords", response.getReturnValue());
            this.loadAccount(component);
               $A.get('e.force:refreshView').fire();	
            
       			}
        
    });
    $A.enqueueAction(action);
 },
    
    showEditCompetetors:function(component){
     
        
        document.getElementById("modalwindow").style.display = "block";
        document.getElementById("newcmpsection").style.display = "block"; 
        
     
      },
    
    getMyObjectspurchased: function(component){
                        
       var action = component.get("c.getAcountPurchasedlist"); 
                     action.setParams({ 
            Accountid : component.get("v.AccountId")
                         
       });	
           
       action.setCallback(this, function(response){
        var state = response.getState();           
                if (state === "SUCCESS") 
                {
            component.set("v.myrecords1", response.getReturnValue());
            this.loadAccount(component);
               $A.get('e.force:refreshView').fire();	
                          
       			}
        
    });
    $A.enqueueAction(action);
 },
    
       getMyObjectsNotSold: function(component){
                        
       var action = component.get("c.getAcountNotSoldlist"); 
                     action.setParams({ 
            Accountid : component.get("v.AccountId")
                         
       });	
           
       action.setCallback(this, function(response){
        var state = response.getState();           
                if (state === "SUCCESS") 
                {
            component.set("v.myrecords2", response.getReturnValue());
            this.loadAccount(component);
               $A.get('e.force:refreshView').fire();	
                          
       			}
        
    });
    $A.enqueueAction(action);
 },
   
    
    showEditNotSoldvalues:function(component){
           
        document.getElementById("modalwindow1").style.display = "block";
        document.getElementById("newcmpsection1").style.display = "block"; 
        

      },
    
    Cancelcompetetorsection:function(component){
        
        document.getElementById("modalwindow").style.display = "None";
        document.getElementById("newcmpsection").style.display = "None";
         
        
      },
    
    saveHwCompetetors:function(component){
        
        document.getElementById("modalwindow").style.display = "None";
        document.getElementById("newcmpsection").style.display = "None";
         
        
      },
    
    getOppProducts: function(component){
                        
       var action = component.get("c.getOpportunityProducts"); 
                     action.setParams({ 
            Accountid : component.get("v.AccountId")
                         
       });	
            
       action.setCallback(this, function(response){
        var state = response.getState();           
                if (state === "SUCCESS") 
                {
            component.set("v.oppprodrecords", response.getReturnValue());
			console.log('#####' +response.getReturnValue());
            this.loadAccount(component);
            
       			}
        
    });
    $A.enqueueAction(action);
 },

    getClosedProducts: function(component){
                        
       var action = component.get("c.getOpportunityClosedProducts"); 
                     action.setParams({ 
            Accountid : component.get("v.AccountId")
                         
       });	
            
       action.setCallback(this, function(response){
        var state = response.getState();           
                if (state === "SUCCESS") 
                {
            component.set("v.oppprodclosedrecords", response.getReturnValue());
			console.log('#####' +response.getReturnValue());
            this.loadAccount(component);
            
       			}
        
    });
    $A.enqueueAction(action);
 },
    
    handleComponentEventFired:function(event){          
           this.getMyObjects(event);         
      },
    
    handleComponentEventFired1:function(event){          
           this.getMyObjectsNotSold(event); 
           this.getMyObjectspurchased(event);         
      },
    getAccountLabel:function(component, event, helper){
       
        var action = component.get("c.getLabelofAccount");
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") 
            {
                 
                //console.log(JSON.stringify(response.getReturnValue()));
                component.set('v.myMapAccountLabel',response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
		        
    }  
    
     
})