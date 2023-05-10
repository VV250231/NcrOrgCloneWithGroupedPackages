({
	doInit : function(component, event, helper) {
		var initialObject=helper.getInitialObject();
        component.set('v.userSelections',initialObject);
        var days=['--None--', 'SUN','MON','TUE','WED','THU','FRI','SAT'];
        var date=['--None--','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22',
                  '23','24','25','26','27','28','29','30','31'];
        component.set('v.days',days);
        component.set('v.date',date);
        
	},
    submit : function(component, event, helper) {
        console.log('here');
        helper.submitHandler(component,event);
        
    },

    checkSchedule:function(component, event, helper) {
        helper.checkScheduleHandler(component,event);
    }, 
    
    handleTimeChange:function(component) {
        var Week='';
        var cron='';
        var dateNumber='';
        var currentCronAsString='';
        // Return today's date and time
        var currentTime = new Date();
        var day = currentTime.getDate(); // Date
        var month = currentTime.getMonth() + 1; // returns the month (from 0 to 11)
        var year = currentTime.getFullYear(); 
        var freq=  component.find("selectPicklist").get("v.value");
        let time= component.get('v.userSelections').time;
        
       component.set('v.frequency',freq);
        
        if(freq=='Other')
        cron =  component.find("cron").get("v.value");
        if(freq=='Weekly')
        Week =  component.find("selectWeek").get("v.value");
        if(freq=='Monthly')
        dateNumber = component.find("selectDay").get("v.value");
        
         component.set('v.week',Week);
         component.set('v.day',dateNumber);
        
        if(time !=null && time!=undefined && time !=''){
            let [hour, minute, seconds] = time.split(":");
            if(freq=='None')
               //0 15 10 * * ? -->	Fire at 10:15 AM every day
                currentCronAsString = `0 ${minute} ${hour} ${day} ${month} ? ${year}`;
            
            else if(freq=='Daily')
               //0 15 10 * * ? -->	Fire at 10:15 AM every day
               currentCronAsString = `0 ${minute} ${hour} * * ?`;
           else if(freq=='Weekly')
                //0 15 10 ? * MON	Fire at 10:15 AM every Monday
               currentCronAsString = `0 ${minute} ${hour} ? * ${Week}`;
            else if(freq=='Monthly')
               // 0 15 10 15 * ? --> Fire at 10:15 AM on the 15th day of every month
                currentCronAsString = `0 ${minute} ${hour} ${dateNumber} * ?`; 
            else if(freq=='Other')
            currentCronAsString=cron;   
            component.set('v.cronExpression',currentCronAsString);
        }
        
         //alert('CronDate: '+ freq + ' '+ Week+ ' ' +dateNumber+' '+ time);
         //alert('currentCronAsString: '+ component.get('v.cronExpression'));
   },

})