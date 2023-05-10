({
    showToast : function(type, title, message, duration, mode) {
        console.log('flow toast msg helper');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "duration": duration,
            "mode": mode,
        });
        toastEvent.fire();
    }
})