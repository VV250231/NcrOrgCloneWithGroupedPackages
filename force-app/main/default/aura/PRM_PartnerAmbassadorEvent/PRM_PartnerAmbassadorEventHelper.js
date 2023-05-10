({
	isValidate : function(component, event, helper)
    {
         var emailRegex = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/;
    	var submitREcord = true ; 
        //alert(component.find("Partner_Name").get("v.value"));
       /* if(!component.find("Partner_Name").get("v.value"))
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
        
        if(!component.find("Sponsored_Activity_Name_and_Event_Leader").get("v.value"))
        {
            component.find("Sponsored_Activity_Name_and_Event_Leader").set("v.errors",[{message:"Please Enter Sponsored Activity Name and Event Leader: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Sponsored_Activity_Name_and_Event_Leader").set("v.errors",null);
        }
        
        if(!component.find("Date_Location_and_No_of_Event_Attendees").get("v.value"))
        {
            component.find("Date_Location_and_No_of_Event_Attendees").set("v.errors",[{message:"Please Enter Date Location and No of Event Attendees: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Date_Location_and_No_of_Event_Attendees").set("v.errors",null);
        }  
       
        if(!component.find("Metrics_Results").get("v.value"))
        {
            component.find("Metrics_Results").set("v.errors",[{message:"Please Enter Metrics Results: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Metrics_Results").set("v.errors",null);
        }
        
        if(!component.find("What_was_the_Impact_of_this_Event").get("v.value"))
        {
            component.find("What_was_the_Impact_of_this_Event").set("v.errors",[{message:"Please Enter What was the Impact of this Event: "}]);
            submitREcord = false ;
        }
        else{
            component.find("What_was_the_Impact_of_this_Event").set("v.errors",null);
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