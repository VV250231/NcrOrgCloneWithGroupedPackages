({
	getInitialObject : function() 
    {
        var initialObj={
            batchSize: 200,
            recordLimit: 200,
            objectName : '',
            condition : '',
            systemLevel : true,
            deleteUnshared : false,
            partialDelete : true,
            isSchedule : true,
            time : '',
            freq: '',
        };
        return initialObj;
	},

    checkScheduleHandler: function(component,event)
    { 
        var userSelections=component.get('v.userSelections');

        if(userSelections.isSchedule)
        {
           component.set("v.notSchedule",true);
           component.set("v.Schedule",false);   
        }
        else{
        component.set("v.notSchedule",false);
           component.set("v.Schedule",true);   
        }
    },

    submitHandler : function(component,event)
    {
        var userSelections=component.get('v.userSelections'); 
        if(this.isFieldBlank(userSelections.objectName))
        {
            this.showToast('Error','Please provide an Object Name','error');
            return;   
        }
        if(this.isFieldBlank(userSelections.batchSize))
        {
            this.showToast('Error','Batch Size cannot be blank','error');
            return;
        }
        if(userSelections.batchSize>2000 || userSelections.batchSize<1)
        {
            this.showToast('Error','Batch size should be between 1 and 2000','error');
            return;
        }
        
        /*if(this.isFieldBlank(userSelections.condition))
        {
            this.showToast('Error','Please Enter Wher condition','error');
            return;
        } */
        
        if(component.get('v.frequency')=='Weekly' && ((component.get('v.week')=='--None--') || component.get('v.week')==''
           ||component.get('v.week')==undefined))
        {

            this.showToast('Error','Please Select a Week','error');
            return;
        }
        if(component.get('v.frequency')=='Monthly' && ((component.get('v.day')=='--None--') || component.get('v.day')==''
           ||component.get('v.day')==undefined))
        {
            this.showToast('Error','Please Select a Date','error');
            return;
        }
        
        if(this.isFieldBlank(userSelections.time) && userSelections.isSchedule && component.get('v.frequency')!='Other')
        {
            this.showToast('Error','Time cannot be blank','error');
            return;
        }
        
        if(this.isFieldBlank(userSelections.time) && userSelections.isSchedule && component.get('v.frequency')=='Other')
        {
            this.showToast('Error','Cron expression cannot be blank','error');
            return;
        }

        console.log('Here 1 '+JSON.stringify(component.get('v.userSelections')));
        var action=component.get('c.executeDeletion');
        console.log('Here 2'+JSON.stringify(component.get('v.userSelections')));
        action.setParams({'userInput': JSON.stringify(component.get('v.userSelections')),
           				 'cronExp': component.get('v.cronExpression'),
                         });
        console.log('Here '+JSON.stringify(userSelections));
        console.log('cronExp '+component.get('v.cronExpression'));
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS")
            {
                var resp=response.getReturnValue();
                if(resp=="SUCCESS")
                {
                    this.showToast('Initiated','The Deletion of records has been initiated','success');
                }
                else
                {
                    this.showToast('Error',resp,'error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    isFieldBlank:function(val)
    {
        if($A.util.isUndefinedOrNull(val))
            return true;
        if($A.util.isEmpty(val))
            return true;
        return false;
        
    },
    showToast : function(title,message,type) 
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    }
})