public class GenericTimeDifferenceApexClass {
    public static StringIntegerWrapper duration_between_two_date_times(DateTime start_date_time, DateTime end_date_time) {
        StringIntegerWrapper wrapperObj = new StringIntegerWrapper();
        Integer start_year_as_int = start_date_time.year(); //grab the start year
        Integer start_day_as_int = start_date_time.dayOfYear(); //grab the start day
        Integer start_hour_as_int = start_date_time.hour(); //grab the start hour
        Integer start_minute_as_int = start_date_time.minute(); //grab the start minute
        Integer start_second_as_int = start_date_time.second(); //grab the start second
        Integer start_in_seconds = (start_year_as_int * 31556926) + (start_day_as_int * 86400) + (start_hour_as_int * 3600) + (start_minute_as_int * 60) + (start_second_as_int * 1); //convert the start date to a value in seconds
        //there are 31556926 seconds in one year and that is why we are mutiplying the start_year_as_int value by 31556926 > this same logic applies to the days, hours & minutes logic which is why there are weird multipliers in that line of code
        Integer end_year_as_int = end_date_time.year(); //grab the end year
        Integer end_day_as_int = end_date_time.dayOfYear(); //grab the end day
        Integer end_hour_as_int = end_date_time.hour(); //grab the end hour
        Integer end_minute_as_int = end_date_time.minute(); //grab the end minute
        Integer end_second_as_int = end_date_time.second(); //grab the end second
        Integer end_in_seconds = (end_year_as_int * 31556926) + (end_day_as_int * 86400) + (end_hour_as_int * 3600) + (end_minute_as_int * 60) + (end_second_as_int * 1); //convert the end date to a value in seconds
        Integer total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
        Integer year_result = math.mod(math.floor(total_duration_in_seconds/31556926).intValue(),10000000); //number of years
        Integer day_result = math.mod(math.floor(total_duration_in_seconds/86400).intValue(),365); //number of days
        Integer hour_result = math.mod(math.floor(total_duration_in_seconds/3600).intValue(),24); //number of hours
        Integer minute_result = math.mod(math.floor(total_duration_in_seconds/60).intValue(),60); //number of minutes
        Integer second_result = math.mod(math.floor(total_duration_in_seconds/1).intValue(),60); //number of seconds
        Integer Corrected_result;
        Integer Corrected_Result_seconds;
        if(day_result>0){
            Corrected_result = day_result * 24 + hour_result;
        }
        else{
            Corrected_result  = hour_result;
        }
        if(day_result>0){
            Corrected_Result_seconds = ((day_result * 24 + hour_result) * 60 * 60 + minute_result *60 + second_result);
        }
        else{
            Corrected_Result_seconds  = (hour_result * 60 * 60 + minute_result *60 + second_result);
        }
        
        String return_string;
        if(minute_result>9 && second_result > 9){
            wrapperObj.TimeHoueAndMinute = (String.valueOf(Corrected_result)+':'+ String.valueOf(minute_result));
            wrapperObj.TimeHourMinuteSeconds = (String.valueOf(Corrected_result)+':'+ String.valueOf(minute_result) +':'+ String.valueOf(second_result)); 
            wrapperObj.sumoOfMinuteHourInSecond = Corrected_Result_seconds;
        }
        else if(minute_result>9 && second_result <9){
            wrapperObj.TimeHoueAndMinute = (String.valueOf(Corrected_result)+':'+ String.valueOf(minute_result));
            wrapperObj.TimeHourMinuteSeconds = (String.valueOf(Corrected_result)+':'+ String.valueOf(minute_result) +':0'+ String.valueOf(second_result)); 
            wrapperObj.sumoOfMinuteHourInSecond = Corrected_Result_seconds;
            
        }else if(minute_result <9 && second_result >9){
            wrapperObj.TimeHoueAndMinute = (String.valueOf(Corrected_result)+':0'+ String.valueOf(minute_result));
            wrapperObj.TimeHourMinuteSeconds = (String.valueOf(Corrected_result)+':0'+ String.valueOf(minute_result) +':'+String.valueOf(second_result)); 
            wrapperObj.sumoOfMinuteHourInSecond = Corrected_Result_seconds;
            
        }
        else{
            wrapperObj.TimeHoueAndMinute = (String.valueOf(Corrected_result)+':0'+ String.valueOf(minute_result));
            wrapperObj.TimeHourMinuteSeconds = (String.valueOf(Corrected_result)+':0'+ String.valueOf(minute_result) +':0'+String.valueOf(second_result));
            wrapperObj.sumoOfMinuteHourInSecond = Corrected_Result_seconds;
        }
        return wrapperObj; //pass back the final string
    }
    public class StringIntegerWrapper{
        public String TimeHoueAndMinute;
        public Integer sumoOfMinuteHourInSecond;
        public String TimeHourMinuteSeconds;
    }
}