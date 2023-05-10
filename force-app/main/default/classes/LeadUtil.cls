/****************************************************************************************************************
* Author        :   Ajay Dixit    
* Description   :   This class will hold several methods helpful in mainly LEAD triggers
****************************************************************************************************************/


public class LeadUtil {
    
    // private variable referencing the class
    private static LeadUtil instance = null;
    private  set<id> namerQueueUserSet = new set<id>();
    private  set<id> sdlQueueUserSet = new set<id>();
    private  set<id> emeaUserSet = new set<id>();
    

    // The constructor is private 
    private LeadUtil() {
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    
    // a static method that returns the instance of the record type
    public static LeadUtil getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null) instance = new LeadUtil();
        return instance;
    }
    /****************************************************************************************************************
    * Author        :   Ajay Dixit
   	* Param			:	
    * Return        :   Set of Ids
    * Description   :   returns set<id> containing user Ids of Namer Queue/Group
    ****************************************************************************************************************/
	
    public Set<Id> getNamerQueueUser() {
        if(namerQueueUserSet.isEmpty()){            
            namerQueueUserSet=NSCCommonInfoUtil.getInstance().getQueueUsers('NAMER_Queue','Queue');
        }		
        return namerQueueUserSet; //return the map
    }
    /****************************************************************************************************************
    * Author        :   Ajay Dixit
   	* Param			:	
    * Return        :   Set of Ids
    * Description   :   returns set<id> containing user Ids of SDL Queue/Group
    ****************************************************************************************************************/
	
    public Set<Id> getSDLQueueUser() {
        if(sdlQueueUserSet.isEmpty()){            
            sdlQueueUserSet=NSCCommonInfoUtil.getInstance().getQueueUsers('SDL_Team','Regular');
        }		
        return sdlQueueUserSet; //return the map
    }
    /****************************************************************************************************************
    * Author        :   Ajay Dixit
   	* Param			:	
    * Return        :   Set of Ids 
    * Description   :   returns set<id> containing user Ids of EMEA Queue/Group
    ****************************************************************************************************************/
	
    public Set<Id> getEMEAUser() {
        if(emeaUserSet.isEmpty()){            
            emeaUserSet=NSCCommonInfoUtil.getInstance().getQueueUsers('EMEA',null);
        }		
        return emeaUserSet; //return the map
    }
    
    
}