({
	isValidate : function(component, event, helper)
    {
         var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
    	var submitREcord = true ; 
        //alert(component.find("Partner_Name").get("v.value"));
        /*if(!component.find("Partner_Name").get("v.value"))
        {
            component.find("Partner_Name").set("v.errors",[{message:"Please Enter Partner Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Partner_Name").set("v.errors",null);
        }*/
        
       if(!component.find("First_Name").get("v.value"))
        {
            component.find("First_Name").set("v.errors",[{message:"Please Enter First Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("First_Name").set("v.errors", null);
        }
        
         if(!component.find("Last_Name").get("v.value"))
        {
            component.find("Last_Name").set("v.errors",[{message:"Please Enter Last Name: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Last_Name").set("v.errors",null);
        }
        
        if(!component.find("Partner_Contact_s_Title_or_Position").get("v.value"))
        {
            component.find("Partner_Contact_s_Title_or_Position").set("v.errors",[{message:"Please Enter Partner Contact's Title or Position: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Partner_Contact_s_Title_or_Position").set("v.errors",null);
        }
        
        /*if(!component.find("Partner_Contact_s_Email_Address").get("v.value"))
        {
            component.find("Partner_Contact_s_Email_Address").set("v.errors",[{message:"Please Enter Partner Contact's Email Address: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Partner_Contact_s_Email_Address").set("v.errors",null);
        }*/
        
        if((!component.find("Partner_Contact_s_Email_Address").get("v.value")))
        { 
            component.find("Partner_Contact_s_Email_Address").set("v.errors",[{message:"Please Enter Partner Contact's Email Address: "}]);
            submitREcord = false ;
        }
        else if(!component.find("Partner_Contact_s_Email_Address").get("v.value").match(emailRegex))
        {
            component.find("Partner_Contact_s_Email_Address").set("v.errors",[{message:"Please Enter valid Email: "}]);
            submitREcord = false ;
        }
        else
        {
            component.find("Partner_Contact_s_Email_Address").set("v.errors",null);
        }
        
         if(!component.find("Country_the_Partner_is_located_in").get("v.value"))
        {
            component.find("Country_the_Partner_is_located_in").set("v.errors",[{message:"Please Enter Country the Partner is located in: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Country_the_Partner_is_located_in").set("v.errors",null);
        }
        
         if(!component.find("Industries_partner_focuses_on").get("v.value"))
        {
            component.find("Industries_partner_focuses_on").set("v.errors",[{message:"Please Enter Industry or Industries Partner focuses on: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Industries_partner_focuses_on").set("v.errors",null);
        }
        
        if(!component.find("Company_s_Significant_Win").get("v.value"))
        {
            component.find("Company_s_Significant_Win").set("v.errors",[{message:"Please Enter Company's Significant Win: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Company_s_Significant_Win").set("v.errors",null);
        }
        
        if(!component.find("Why_was_the_win_significant").get("v.value"))
        {
            component.find("Why_was_the_win_significant").set("v.errors",[{message:"Please Enter Why was the win significant: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Why_was_the_win_significant").set("v.errors",null);
        }  
        
        if(!component.find("Size_of_the_deal_and_competed_with").get("v.value"))
        {
            component.find("Size_of_the_deal_and_competed_with").set("v.errors",[{message:"Please Enter Size of the deal and competed with: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Size_of_the_deal_and_competed_with").set("v.errors",null);
        }  
        
         if(component.get("v.ObjPartnerSpotlight.Story_on_NCR_Partner_Comm_Social_Media__c") != 'Yes' &&
          component.get("v.ObjPartnerSpotlight.Story_on_NCR_Partner_Comm_Social_Media__c") != 'No')
        {
            component.set("v.isSocialMediaError", true);
            submitREcord = false ;
        }
        else{
            component.set("v.isSocialMediaError", false);
        }

        return submitREcord;
    }
})