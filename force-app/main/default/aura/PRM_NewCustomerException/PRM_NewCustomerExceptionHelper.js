({
	isValidate : function(component, event, helper)
    {
        var numberRegex = /^\d*\.?\d*$/;
         var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
    	var submitREcord = true ; 
        //alert(component.find("Partner_Name").get("v.value"));
       
        
       	if(!component.find("Customer_Name").get("v.value"))
        {
            component.find("Customer_Name").set("v.errors",[{message:"Please Select End Customer: "}]);
            component.set("v.isLookupError", true);
            submitREcord = false ;
        }
        else{
            component.find("Customer_Name").set("v.errors", null);
            component.set("v.isLookupError", false);
        }
        
        
         if(!component.find("Primary_Contact_Name").get("v.value"))
        {
            component.find("Primary_Contact_Name").set("v.errors",[{message:"Please Enter End Customer Primary Contact: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Primary_Contact_Name").set("v.errors",null);
        }
        
        if(!component.find("Primary_Solution").get("v.value"))
        {
            component.find("Primary_Solution").set("v.errors",[{message:"Please Enter Primary Solution/Offer Portfolio: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Primary_Solution").set("v.errors",null);
        }
        
        if(!component.find("Opportunity_Value").get("v.value"))
        {
            component.find("Opportunity_Value").set("v.errors",[{message:"Please Enter Opportunity Value/Amount: "}]);
            submitREcord = false ;
        }
       else if(!component.find("Opportunity_Value").get("v.value").match(numberRegex))
        {
                    component.find("Opportunity_Value").set("v.errors",[{message:"Please Enter Opportunity Value/Amount in correct format: "}]);
                    submitREcord = false ;
        }
        else{
            component.find("Opportunity_Value").set("v.errors",null);
        }
        
         if(!component.find("Expected_Close_Date").get("v.value"))
        {
            component.find("Expected_Close_Date").set("v.errors",[{message:"Please Enter Expected Close Date/Expected Book Date: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Expected_Close_Date").set("v.errors",null);
        }
        
         if(!component.find("Primary_Competitor").get("v.value"))
        {
            component.find("Primary_Competitor").set("v.errors",[{message:"Please Enter Primary Competitor: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Primary_Competitor").set("v.errors",null);
        }
        
        return submitREcord;
    }
})