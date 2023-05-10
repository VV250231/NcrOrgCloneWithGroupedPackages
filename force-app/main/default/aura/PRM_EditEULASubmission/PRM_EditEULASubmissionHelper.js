({
	getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
    
    isValidate : function(component, event, helper)
    {
        var numberRegex = /^\d*\.?\d*$/;
         var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
    	var submitREcord = true ; 
        //alert(component.find("Partner_Name").get("v.value"));
        
        
         if(!component.find("Customer_Name").get("v.value"))
        {
            component.find("Customer_Name").set("v.errors",[{message:"Please Enter Customer Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Customer_Name").set("v.errors",null);
        }
        
        if(!component.find("Solution_Name_or_Identifying_PID").get("v.value"))
        {
            component.find("Solution_Name_or_Identifying_PID").set("v.errors",[{message:"Please Enter Solution Name or Identifying PID: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Solution_Name_or_Identifying_PID").set("v.errors",null);
        }
        
         if(component.find("Country").get("v.value") == '-- None --')
        {
            //component.find("Class").set("v.errors",[{message:"Please Select Country: "}]);
            component.set("v.isCountryError" , true);
            submitREcord = false ;
        }
        else{
            //component.find("Class").set("v.errors", null);
            component.set("v.isCountryError" , false);
        }
        
         if(!component.find("Date_of_Agreement").get("v.value"))
        {
            component.find("Date_of_Agreement").set("v.errors",[{message:"Please Select Date of Agreement: "}]);
            submitREcord = false ;
        }
        else
        {
           
               component.find("Date_of_Agreement").set("v.errors",null);
        }
        
        if(!component.find("End_Date_of_Agreement").get("v.value"))
        {
            component.find("End_Date_of_Agreement").set("v.errors",[{message:"Please Select End Date of Agreement: "}]);
            submitREcord = false ;
        }
        else
        {
            var date1 = new Date(component.find("End_Date_of_Agreement").get("v.value"));
            var date2 = new Date(component.find("Date_of_Agreement").get("v.value"));
            
            if(date1 < date2)
            {
                component.find("End_Date_of_Agreement").set("v.errors",[{message:"End Date of Agreement must be greater than Date of Agreement, Please select a valid Date:"}]);
            	submitREcord = false ;
            }
            else   
            	component.find("End_Date_of_Agreement").set("v.errors",null);
        }
        
       
        
 /*        if(!component.find("End_Date_of_Agreement").get("v.value"))
        {
            component.find("End_Date_of_Agreement").set("v.errors",[{message:"Please Enter End Date of Agreement: "}]);
            submitREcord = false ;
        }
        else{
            component.find("End_Date_of_Agreement").set("v.errors",null);
        } */
        
         if(!component.find("Address").get("v.value"))
        {
            component.find("Address").set("v.errors",[{message:"Please Enter Address: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Address").set("v.errors",null);
        }
        
  /*       if(!component.find("Date_of_Agreement").get("v.value"))
        {
            component.find("Date_of_Agreement").set("v.errors",[{message:"Please Enter Date of Agreement: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Date_of_Agreement").set("v.errors",null);
        } */
        
        
        return submitREcord;
    }
})