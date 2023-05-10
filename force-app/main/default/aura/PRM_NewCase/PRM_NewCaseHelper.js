({
	isValidate : function(component, event, helper)
    {
        var numberRegex = /^\d*\.?\d*$/;
        var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
    	var submitREcord = true ; 
        //alert(component.find("selectCountryCode").get("v.value"));
       
        if(component.find("Category").get("v.value") == '-- None --')
        {
            //component.find("Category").set("v.errors",[{message:"Please Select Category: "}]);
            component.set("v.isCategoryError" , true);
            submitREcord = false ;
        }
        else{
            //component.find("Category").set("v.errors", null);
            component.set("v.isCategoryError" , false);
        }
        
        return submitREcord;
    }
})