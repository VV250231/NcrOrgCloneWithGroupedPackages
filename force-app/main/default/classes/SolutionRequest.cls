global class SolutionRequest {
    
    global class valueSetParentType{
        webservice String name{get;set;}
        webservice String SGID{get;set;}
        webservice String Parent_SGID{get;set;}
    }
    
    global class SolutionListSet{
        webservice List <valueSetParentType>	Solution {get; set;}
    }
    
    webservice String 	Offer_Type{get;set;}
    webservice String 	Offer_Status{get;set;}
    webservice SolutionListSet	SolutionSet {get; Set;}
    
    public Map<String, String> getSolMap(List<valueSetParentType> vsp){
        String L3='';
        Map<String, String> solMap=new Map<String, String>();

        //Finding L3 (Top)
        for(valueSetParentType vs: vsp){
            if(vs.Parent_SGID==null || string.isEmpty(vs.Parent_SGID) || vs.Parent_SGID.toUpperCase()=='SOLUTION HIERARCHY'){
                L3=vs.SGID;
            }            
        }
        //Finding L2
        for(valueSetParentType vs: vsp){
            if(vs.Parent_SGID==L3){
                solMap.put('id', vs.SGID);
                solMap.put('name', vs.name);
            }            
        }
        
        return solMap;
    }
   

}