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
        
        if(!component.find("Last_Name").get("v.value"))
        {
            component.find("Last_Name").set("v.errors",[{message:"Please Enter Last Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Last_Name").set("v.errors", null);
        }
        
        
        
        if(!component.find("First_Name").get("v.value"))
        {
            component.find("First_Name").set("v.errors",[{message:"Please Enter First Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("First_Name").set("v.errors",null);
        }
        
        if(!component.find("Email_Address").get("v.value"))
        {
            component.find("Email_Address").set("v.errors",[{message:"Please Enter Email Address: "}]);
            submitREcord = false ;
        }
        else if(!component.find("Email_Address").get("v.value").match(emailRegex))
        {
            component.find("Email_Address").set("v.errors",[{message:"Please Enter Email in correct format: "}]);
            submitREcord = false ;
        }
            else{
                component.find("Email_Address").set("v.errors",null);
            }
        
        if(!component.find("City").get("v.value"))
        {
            component.find("City").set("v.errors",[{message:"Please Enter City: "}]);
            submitREcord = false ;
        }
        else{
            component.find("City").set("v.errors",null);
        }
        
        return submitREcord;
    }
})