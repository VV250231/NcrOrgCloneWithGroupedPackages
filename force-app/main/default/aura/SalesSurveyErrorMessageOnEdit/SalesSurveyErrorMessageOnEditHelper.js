({
    openAlert: function(cmp, event) {
        this.LightningAlert.open({
            //message: 'Sales Survey can only be edit using Edit Sales Survey Button',
            message: 'You can not edit this record Using Edit Button',
            theme: 'Warning',
            label: 'Warning!',
        }).then(function() {
            console.log('alert is closed');
        });
    }
});