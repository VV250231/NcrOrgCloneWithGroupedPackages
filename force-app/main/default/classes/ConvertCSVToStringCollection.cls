public with sharing class ConvertCSVToStringCollection {
    public Static List<String> executeFromApex(String requests){
        String csvString = requests.replaceAll('[\\n\\t ]', ',');
        List<String> CommaSepatedListOfString = new List<String>();  
        for(String s : csvString.split(',')){
                
                if(String.isNotBlank(s)){
                    CommaSepatedListOfString.add(s);
                }
        }
        
        return CommaSepatedListOfString;
    }
    
}