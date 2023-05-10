public class FilterUtil {

    public String evalEqualFilter(OppListViewController.FieldFilterWrapper filter){
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' =\''  + filter.selectedValue + '\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {
            String pklstVals ='';
            
            for(String a : filter.selectedOptions) {
                pklstVals += '\''  + a +  '\',';  
            }
            pklstVals = pklstVals.substring(0,pklstVals.length()-1);
            
            dynamicQuery = filter.fieldName + ' IN (' + pklstVals  +')';       
        } else if((filter.fieldType == Schema.DisplayType.Date.name()) || (filter.fieldType == Schema.DisplayType.Currency.name())) {
            dynamicQuery = filter.fieldName + ' ='  + filter.selectedValue; 
              
        } 
        return dynamicQuery;     
    }
    
    
    public String evalNotEqualFilter(OppListViewController.FieldFilterWrapper filter){
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' != \''  + filter.selectedValue + '\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {
            String pklstVals ='';
            
            for(String a : filter.selectedOptions) {
                pklstVals += '\''  + a +  '\',';  
            }
            pklstVals = pklstVals.substring(0,pklstVals.length()-1);
            
            dynamicQuery  = filter.fieldName + ' NOT IN (' + pklstVals  +')';       
        } else if((filter.fieldType == Schema.DisplayType.Date.name()) || (filter.fieldType == Schema.DisplayType.Currency.name())) {
            dynamicQuery = filter.fieldName + ' !='  + filter.selectedValue;  
              
        } 
        return dynamicQuery;     
    }
    
    
    
    public String evalLessThanFilter(OppListViewController.FieldFilterWrapper filter){
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' < \''  + filter.selectedValue + '\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += filter.fieldName + ' < \''  + a +  '\' AND ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length()-4);      
        } else if((filter.fieldType == Schema.DisplayType.Date.name()) || (filter.fieldType == Schema.DisplayType.Currency.name())) {  
            dynamicQuery = filter.fieldName + ' < '  + filter.selectedValue;   
              
        } 
        return dynamicQuery;     
    }
    
    public String evalGreaterThanFilter(OppListViewController.FieldFilterWrapper filter) {
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' > \''  + filter.selectedValue + '\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += filter.fieldName + ' > \''  + a +  '\' AND ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length()-4);      
        } else if((filter.fieldType == Schema.DisplayType.Date.name()) || (filter.fieldType == Schema.DisplayType.Currency.name())) {
            dynamicQuery = filter.fieldName + ' > '  + filter.selectedValue;   
              
        } 
        return dynamicQuery;     
    }
    
    public String evalLessOREqualFilter(OppListViewController.FieldFilterWrapper filter) {
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery =  filter.fieldName + ' <= \''  + filter.selectedValue + '\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += filter.fieldName + ' <= \''  + a +  '\' AND ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length()-4);      
        }
        else if((filter.fieldType == Schema.DisplayType.Date.name()) || (filter.fieldType == Schema.DisplayType.Currency.name())) {
           dynamicQuery = filter.fieldName + ' <= '  + filter.selectedValue;   
              
        } 
        return dynamicQuery;     
    }
    
    public String evalGreaterOREqualFilter(OppListViewController.FieldFilterWrapper filter) {
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' >= \''  + filter.selectedValue + '\'';   
        
        }  else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += filter.fieldName + ' >= \''  + a +  '\' AND ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length()-4);      
        } else if((filter.fieldType == Schema.DisplayType.Date.name()) || (filter.fieldType == Schema.DisplayType.Currency.name())) {
           dynamicQuery = filter.fieldName + ' >= '  + filter.selectedValue;      
        } 
        return dynamicQuery;     
    }
    
     public String evalContainsFilter(OppListViewController.FieldFilterWrapper filter) {
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' LIKE \'%'  + filter.selectedValue + '%\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            dynamicQuery  =  '( ';
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += filter.fieldName + ' LIKE \'%'  + a +  '%\' OR ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length()-3) + ')';      
        }
        return dynamicQuery;     
    }
    
    
    public String evalNotContainsFilter(OppListViewController.FieldFilterWrapper filter) {
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery =  '(NOT ' + filter.fieldName + ' LIKE \'%'  + filter.selectedValue + '%\')';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += '(NOT ' + filter.fieldName + ' LIKE \'%'  + a +  '%\') AND ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length() - 4) ;      
        } 
        return dynamicQuery;     
    }
    
    public String evalStartsWithFilter(OppListViewController.FieldFilterWrapper filter) {
        String dynamicQuery = '';
        
        if (filter.fieldType == Schema.DisplayType.String.name()) {
            dynamicQuery = filter.fieldName + ' LIKE \''  + filter.selectedValue + '%\'';   
        
        } else if(filter.fieldType == Schema.DisplayType.Picklist.name()) {          
            dynamicQuery  =  '( ';
            
            for(String a : filter.selectedOptions) {
                dynamicQuery += filter.fieldName + ' LIKE \''  + a +  '%\' OR ';  
            }
            dynamicQuery = dynamicQuery.substring(0,dynamicQuery.length()-3) + ')';      
        }
        return dynamicQuery;     
    }
}