({
    invoke : function(component, event, helper) {
        var type = component.get("v.type").toLowerCase(); //force user entered attribute to all lowercase
        var title = component.get("v.title");
        var message = component.get("v.messageText");
        var duration = component.get("v.duration")+"000"; //convert duration value from seconds to milliseconds
        var mode = component.get("v.mode").toLowerCase(); //force user entered attribute to all lowercase
        helper.showToast(type, title, message, duration, mode);
    }
})