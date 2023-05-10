({
    isValidate : function(component, event, helper)
    {
        var numberRegex = /^\d*\.?\d*$/;
        component.set("v.isExpenseError", false);
        component.set("v.isExpenseNumberValidationError", false);
        
    	var submitREcord = true ; 
        if(!component.find("Activity_Name").get("v.value"))
        {
            component.find("Activity_Name").set("v.errors",[{message:"Please Enter Activity Name (max 72 characters): "}]);
            submitREcord = false ;
        }
        else{
            component.find("Activity_Name").set("v.errors",null);
        }
        
        if(component.get("v.activityValue") == '---None---')
        {
            component.find("selectActivity").set("v.errors",[{message:"Please select Activity Type: "}]);
            submitREcord = false ;
        }
        else{
            component.find("selectActivity").set("v.errors", null);
        }
        
        if(!component.find("Activity_Description").get("v.value"))
        {
            component.find("Activity_Description").set("v.errors",[{message:"Please Enter Activity Description: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Activity_Description").set("v.errors",null);
        }
        
        
        if(!component.find("Activity_Date").get("v.value"))
        {
            component.find("Activity_Date").set("v.errors",[{message:"Please Select Activity Start Date: "}]);
            submitREcord = false ;
        }
        else
        {
            var date1 = new Date();
            var date2 = new Date(component.find("Activity_Date").get("v.value"));
            var timeDiff = Math.abs(date2.getTime() - date1.getTime());
            var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
            if(date2 < date1)
            {
                component.find("Activity_Date").set("v.errors",[{message:"Activity start date must be greater than Today, Please select a valid Start Date:"}]);
        		submitREcord = false ;
            }
            else if(diffDays <= 30)
            {
                component.find("Activity_Date").set("v.errors",[{message:"Activity start date must be greater than 30 days, Please select a valid Start Date:"}]);
				submitREcord = false ;            
            }
            else
               component.find("Activity_Date").set("v.errors",null);
        }
        
        if(!component.find("End_Date").get("v.value"))
        {
            component.find("End_Date").set("v.errors",[{message:"Please Select Activity End Date: "}]);
            submitREcord = false ;
        }
        else
        {
            var date1 = new Date(component.find("End_Date").get("v.value"));
            var date2 = new Date(component.find("Activity_Date").get("v.value"));
            
            if(date1 < date2)
            {
                component.find("End_Date").set("v.errors",[{message:"Activity End date must be greater than Start Date, Please select a valid Start Date:"}]);
            	submitREcord = false ;
            }
            else   
            	component.find("End_Date").set("v.errors",null);
        }
        
        if(component.get("v.activityValue") != '---None---')
        {
            if(component.find("selectActivity").get("v.value") == 'Event - Roadshow') 
            {
                //alert(component.find("selectActivity").get("v.value")+'---------'+component.find("Number_of_Leads").get("v.value"));
                //alert(component.find("Number_of_Leads").get("v.value").match(numberRegex));
                
                if((!component.find("Number_of_Leads").get("v.value")))
                { 
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Leads").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Event - Tradeshow')
            {
               
                if((!component.find("Number_of_Leads").get("v.value")))
                { 
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Leads").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Event - Seminar')
            {
                //component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                
                if((!component.find("Number_of_Attendees").get("v.value")))
                { 
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Attendees").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Attendees").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Event - EBC Visit' )
            {
                if((!component.find("Number_of_Attendees").get("v.value"))){
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Attendees").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Attendees").set("v.errors",null);
                }
                
                if(!component.find("Estimated_Revenue").get("v.value")){
                    component.find("Estimated_Revenue").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Estimated_Revenue").get("v.value").match(numberRegex))
                {
                    component.find("Estimated_Revenue").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Estimated_Revenue").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'E-marketing - Email' )
            {
                if((!component.find("Estimated_Open_Emails").get("v.value"))){
                    component.find("Estimated_Open_Emails").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Estimated_Open_Emails").get("v.value").match(numberRegex))
                {
                    component.find("Estimated_Open_Emails").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Estimated_Open_Emails").set("v.errors",null);
                }
                
                if((!component.find("Number_of_Leads").get("v.value"))){
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Leads").set("v.errors",null);
                }
                
                if((!component.find("Number_of_Emails_Sent").get("v.value"))){
                    component.find("Number_of_Emails_Sent").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Emails_Sent").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Emails_Sent").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Emails_Sent").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'E-marketing - Microsite')
            {
                //component.find("Number_of_Unique_Site_Visitors").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Number_of_Unique_Site_Visitors").get("v.value")))
                { 
                    component.find("Number_of_Unique_Site_Visitors").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Unique_Site_Visitors").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Unique_Site_Visitors").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Unique_Site_Visitors").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'E-marketing - Webinar')
            {
                //component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Number_of_Attendees").get("v.value")))
                { 
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Attendees").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Attendees").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'E-marketing - Social Media')
            {
                //component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Number_of_Leads").get("v.value")))
                { 
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Leads").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'E-marketing - Video')
            {
                //component.find("Number_of_Unique_Views").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Number_of_Unique_Views").get("v.value")))
                { 
                    component.find("Number_of_Unique_Views").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Unique_Views").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Unique_Views").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Unique_Views").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'E-marketing - Endorsed Outsourced Mktg')
            {
                //component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Number_of_Leads").get("v.value")))
                { 
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Leads").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Print - Collateral' )
            {
                if(!component.find("Number_of_Copies").get("v.value"))
                {
                    component.find("Number_of_Copies").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Copies").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Copies").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Copies").set("v.errors",null);
                }
                
            }
            else if(component.find("selectActivity").get("v.value") == 'Print - Brochure' )
            {
                //component.find("Number_of_Copies").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Number_of_Copies").get("v.value")))
                { 
                    component.find("Number_of_Copies").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Copies").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Copies").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Copies").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Print - Publication' )
            {
                //component.find("Circulation").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Circulation").get("v.value")))
                { 
                    component.find("Circulation").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Circulation").get("v.value").match(numberRegex))
                {
                    component.find("Circulation").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Circulation").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Print - Direct Mail' )
            {
                if((!component.find("Estimated_Number_of_Responses").get("v.value")) ){
                    component.find("Estimated_Number_of_Responses").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Estimated_Number_of_Responses").get("v.value").match(numberRegex))
                {
                    component.find("Estimated_Number_of_Responses").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Estimated_Number_of_Responses").set("v.errors",null);
                }
               
                if((!component.find("Number_of_Contacts").get("v.value"))){
                    component.find("Number_of_Contacts").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Contacts").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Contacts").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Contacts").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Print - White Paper')
            {
                //component.find("Circulation").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Circulation").get("v.value")))
                { 
                    component.find("Circulation").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Circulation").get("v.value").match(numberRegex))
                {
                    component.find("Circulation").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Circulation").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Sales Program - Funded Head Count')
            {
                //component.find("Annual_Sales_Quota").set("v.errors",[{message:"Please Enter value: "}]);
                //submitREcord = false ;
                if((!component.find("Annual_Sales_Quota").get("v.value")))
                { 
                    component.find("Annual_Sales_Quota").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Annual_Sales_Quota").get("v.value").match(numberRegex))
                {
                    component.find("Annual_Sales_Quota").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Annual_Sales_Quota").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Sales Program - Incentive')
            {
                if((!component.find("Number_of_Sales").get("v.value"))){
                    component.find("Number_of_Sales").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Sales").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Sales").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Sales").set("v.errors",null);
                }
                if((!component.find("Estimated_Revenue").get("v.value"))){
                    component.find("Estimated_Revenue").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Estimated_Revenue").get("v.value").match(numberRegex))
                {
                    component.find("Estimated_Revenue").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Estimated_Revenue").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Sales Program - Telesales')
            {
                if((!component.find("Number_of_Sales").get("v.value"))){
                    component.find("Number_of_Sales").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Sales").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Sales").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Sales").set("v.errors",null);
                }
                
                if((!component.find("Number_of_Calls").get("v.value"))){
                    component.find("Number_of_Calls").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Calls").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Calls").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Calls").set("v.errors",null);
                }
            }
            else if(component.find("selectActivity").get("v.value") == 'Sales Program - Telemarketing' )
            {
                if((!component.find("Number_of_Calls").get("v.value"))){
                  component.find("Number_of_Calls").set("v.errors",[{message:"Please Enter Serial Number: "}]);
                  submitREcord = false ;
                }
                else if(!component.find("Number_of_Calls").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Calls").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Calls").set("v.errors",null);
                }
                
                if((!component.find("Number_of_Leads").get("v.value"))){
                  component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter Serial Number: "}]);
                  submitREcord = false ;
                }
                else if(!component.find("Number_of_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Leads").set("v.errors",null);
                }
            } 
            else if(component.find("selectActivity").get("v.value") == 'Sales Program - Sales Training' )
            {
                //component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter Description: "}]);
                //submitREcord = false 
                if((!component.find("Number_of_Attendees").get("v.value")))
                { 
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                }
                else if(!component.find("Number_of_Attendees").get("v.value").match(numberRegex))
                {
                    component.find("Number_of_Attendees").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                }
                else
                {
                     component.find("Number_of_Attendees").set("v.errors",null);
                }
            }
        }
        
        /* Start Validate Expense Table*/ 
        
        var RowItemList = component.get("v.requestExpenseList");
        for (var indexVar = 0; indexVar < RowItemList.length; indexVar++) 
        {
            if($A.util.isEmpty(RowItemList[indexVar].Actvity__c) || $A.util.isEmpty(RowItemList[indexVar].Estimated_Cost__c))
            {
                submitREcord = false ;
                component.set("v.isExpenseError", true);
            }
            
            if(!$A.util.isEmpty(RowItemList[indexVar].Estimated_Cost__c))
            {
                if(!RowItemList[indexVar].Estimated_Cost__c.match(numberRegex))
      			{
                    submitREcord = false ;
                	component.set("v.isExpenseNumberValidationError", true);
                }
            }
        }
		
        /* End Validate Expense Table */
        return submitREcord;
	},
	saveRequest: function(component, event, helper) 
    {
    	var action = component.get("c.saveMDFDetail"); 
        action.setParams({ "lstExpense" : component.get("v.requestExpenseList"), 
                          "objRequest" : component.get("v.request"), 
                          "strActivity" : component.find("selectActivity").get("v.value"), 
                          "strVendors" : component.find("selectVendor").get("v.value")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue()}).fire();
                component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue(),"backFrom" : "New"}).fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                //alert(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
		$A.enqueueAction(action);   
    },
	createObjectData: function(component, event) {
        // get the requestExpenseList from component and add(push) New Object to List  
        var RowItemList = component.get("v.requestExpenseList");
        
        RowItemList.push({
            'sobjectType': 'MDF_Expense_Detail__c',
            'Actvity__c': '',
            'Estimated_Cost__c': ''
        });
        // set the updated list to attribute (requestExpenseList) again    
        component.set("v.requestExpenseList", RowItemList);
         
        component.set("v.expenseListSize", RowItemList.length);
    },
    
    clearAllErrorMessages : function(component, event)
    {
       	if(component.get("v.activityValue") == 'Event - Roadshow')
        {
            component.find("Number_of_Leads").set("v.errors",null);
            component.find("Number_of_Leads").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Event - Tradeshow')
        {
            component.find("Number_of_Leads").set("v.errors",null);
			component.find("Number_of_Leads").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Event - Seminar' )
        {
            component.find("Number_of_Attendees").set("v.errors",null);
			component.find("Number_of_Attendees").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Event - EBC Visit' )
        {
            component.find("Number_of_Attendees").set("v.errors",null);
            component.find("Estimated_Revenue").set("v.errors",null);
			
			component.find("Number_of_Attendees").set("v.value",null);
            component.find("Estimated_Revenue").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'E-marketing - Email' )
        {
            component.find("Estimated_Open_Emails").set("v.errors",null);
            component.find("Number_of_Leads").set("v.errors",null);
            component.find("Number_of_Emails_Sent").set("v.errors",null);
			
			component.find("Estimated_Open_Emails").set("v.value",null);
            component.find("Number_of_Leads").set("v.value",null);
            component.find("Number_of_Emails_Sent").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'E-marketing - Microsite')
        {
            component.find("Number_of_Unique_Site_Visitors").set("v.errors",null);
			component.find("Number_of_Unique_Site_Visitors").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'E-marketing - Webinar')
        {
            component.find("Number_of_Attendees").set("v.errors",null);
			component.find("Number_of_Attendees").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'E-marketing - Social Media')
        {
            component.find("Number_of_Leads").set("v.errors",null);
			component.find("Number_of_Leads").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'E-marketing - Video' )
        {
            component.find("Number_of_Unique_Views").set("v.errors",null);
			component.find("Number_of_Unique_Views").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'E-marketing - Endorsed Outsourced Mktg')
        {
            component.find("Number_of_Leads").set("v.errors",null);
			component.find("Number_of_Leads").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Print - Collateral')
        {
            component.find("Number_of_Copies").set("v.errors",null);
			
			component.find("Number_of_Copies").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Print - Brochure')
        {
            component.find("Number_of_Copies").set("v.errors",null);
			 component.find("Number_of_Copies").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Print - Publication' )
        {
            component.find("Circulation").set("v.errors",null);
			
			component.find("Circulation").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Print - Direct Mail' )
        {
            component.find("Estimated_Number_of_Responses").set("v.errors",null);
            component.find("Number_of_Contacts").set("v.errors",null);
			
			 component.find("Estimated_Number_of_Responses").set("v.value",null);
            component.find("Number_of_Contacts").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Print - White Paper')
        {
            component.find("Circulation").set("v.errors",null);
			 component.find("Circulation").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Sales Program - Funded Head Count' )
        {
            component.find("Annual_Sales_Quota").set("v.errors",null);
			component.find("Annual_Sales_Quota").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Sales Program - Incentive')
        {
            component.find("Number_of_Sales").set("v.errors",null);
            component.find("Estimated_Revenue").set("v.errors",null);
			
			component.find("Number_of_Sales").set("v.value",null);
            component.find("Estimated_Revenue").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Sales Program - Telesales')
        {
            component.find("Number_of_Sales").set("v.errors",null);
            component.find("Number_of_Calls").set("v.errors",null);
			
			 component.find("Number_of_Sales").set("v.value",null);
            component.find("Number_of_Calls").set("v.value",null);
        }
        else if(component.get("v.activityValue") == 'Sales Program - Telemarketing' )
        {
            component.find("Number_of_Calls").set("v.errors",null);
            component.find("Number_of_Leads").set("v.errors",null);
			
			component.find("Number_of_Calls").set("v.value",null);
            component.find("Number_of_Leads").set("v.value",null);
        } 
        else if(component.get("v.activityValue") == 'Sales Program - Sales Training' )
        {
            component.find("Number_of_Attendees").set("v.errors",null);
			component.find("Number_of_Attendees").set("v.value",null)
        }

    }
})