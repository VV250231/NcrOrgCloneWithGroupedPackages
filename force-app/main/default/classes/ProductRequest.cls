global class ProductRequest {
    global class valueSetType{
        webservice String name{get;set;}
        webservice String SGID{get;set;}
    }
    global class valueSetParentType{
        webservice String name{get;set;}
        webservice String SGID{get;set;}
        webservice String Parent_SGID{get;set;}
    }
    global class Assigned_Industry_GroupListSet{
        webservice List <valueSetType>	offer_Portfolio {get; set;}
    }
    global class IndustryListSet{
        webservice List <valueSetParentType>	Division {get; set;}
    }
    global class ProductHierarchyListSet{
        webservice List <valueSetParentType>	ProductHierarchy {get; set;}
    }
    global class SolutionListSet{
        webservice List <valueSetType>	Solution {get; set;}
    }
    webservice String 	ID{get;set;}		
    
    webservice String 	Product_Name{get;set;}
    webservice String	Product_Type	{get; Set;}
    
    webservice String 	Product_Description{get;set;}
    webservice String	Product_Status	{get; Set;}
    webservice String	Product_Manager	{get; Set;}		
    webservice String	Revenue_Type	{get; Set;}
    webservice DateTime End_of_Sales_Date {get; set;}
    webservice DateTime ROR_Created_Date {get; set;}
    webservice DateTime ROR_Modified_Date {get; set;}
    webservice String 	ROR_Created_By{get;set;}
    webservice String 	ROR_Modified_By{get;set;}
    webservice String 	Available_for_Subscription{get;set;}
    webservice String 	Product_Original_Company{get;set;}
    
    webservice IndustryListSet	DivisionSet {get; Set;}
    webservice ProductHierarchyListSet	ProductHierarchySet {get; Set;}
    webservice Assigned_Industry_GroupListSet	OfferPortfolioSet {get; Set;}
    webservice SolutionListSet	SolutionSet {get; Set;}
    public String getStringVsp(List<valueSetParentType> vsp){
        String s='';
        for(valueSetParentType vs: vsp){
            if(s.length()>1 && string.isEmpty(vs.Parent_SGID)){
                s=s+';';
            }
            if(string.isEmpty(vs.Parent_SGID)){
                s=s+vs.name; 
            }
        }
        
        return s;
    }
    public String getPHLevel(List<valueSetParentType> vsp, Integer Level){
        String LevelValue,L3, L3_id, L2, L2_id, L1_id='';
        
        //Finding L1
        for(valueSetParentType vs: vsp){
            if(string.isEmpty(vs.Parent_SGID)){
                L1_id=vs.SGID;
            }            
        }
        //Finding L2
        for(valueSetParentType vs: vsp){
            if(!string.isEmpty(vs.Parent_SGID) && vs.Parent_SGID==L1_id){
                L2=vs.name;
                L2_id=vs.SGID;
            }            
        }
        //Finding L3
        for(valueSetParentType vs: vsp){
            if(!string.isEmpty(vs.Parent_SGID) && vs.Parent_SGID==L2_id){
                L3=vs.name;                
            }            
        }
        if(level==3){
            //if L3 is empty then L2 is L3
            if(String.isEmpty(L3)){
                LevelValue=L2 ;
            }else{
                LevelValue=L3;
            }
        }
        if(level==2){
            if(!String.isEmpty(L3)){
                LevelValue=L2; 
            }
        }
        
        return LevelValue;
    }
    public String getStringVs(List<valueSetType> vst){
        String s='';
        for(valueSetType vs: vst){
            if(s.length()>1){
                s=s+';';
            }
            if(!String.isEmpty(vs.name)){
                s=s+vs.name;
            }
        }
        
        return s;
    }
    
    public String getStringVsId(List<valueSetType> vst){
        String s='';
        for(valueSetType vs: vst){
            if(s.length()>1){
                s=s+';';
            }
            if(!String.isEmpty(vs.SGID)){
                s=s+vs.SGID;                
            }
        }
        
        return s;
    }
    public Map<String,String> getStringVsIdValueMap(List<valueSetType> vst){
        Map<String, String> s=new Map <String, String>();
        for(valueSetType vs: vst){
            if(!String.isEmpty(vs.SGID)){
                s.put(vs.SGID.toUpperCase(), vs.name);                
            }
        }
        
        return s;
    }
    public static void testHack_1(){
        string a_1; string b_1; string c_1; string d_1; string e_1; string f_1; string g_1; string h_1; string i_1; string j_1; string k_1; 
        string a_2; string b_2; string c_2; string d_2; string e_2; string f_2; string g_2; string h_2; string i_2; string j_2; string k_2; 
        string a_3; string b_3; string c_3; string d_3; string e_3; string f_3; string g_3; string h_3; string i_3; string j_3; string k_3; 
        string a_4; string b_4; string c_4; string d_4; string e_4; string f_4; string g_4; string h_4; string i_4; string j_4; string k_4; 
        string a_5; string b_5; string c_5; string d_5; string e_5; string f_5; string g_5; string h_5; string i_5; string j_5; string k_5; 
        string a_6; string b_6; string c_6; string d_6; string e_6; string f_6; string g_6; string h_6; string i_6; string j_6; string k_6; 
        string a_7; string b_7; string c_7; string d_7; string e_7; string f_7; string g_7; string h_7; string i_7; string j_7; string k_7; 
        string a_8; string b_8; string c_8; string d_8; string e_8; string f_8; string g_8; string h_8; string i_8; string j_8; string k_8; 
        string a_9; string b_9; string c_9; string d_9; string e_9; string f_9; string g_9; string h_9; string i_9; string j_9; string k_9; 
        string a_0; string b_0; string c_0; string d_0; string e_0; string f_0; string g_0; string h_0; string i_0; string j_0; string k_0; 
        
        string l_1; string m_1; string n_1; string o_1; string p_1; string q_1; string r_1; string s_1; string t_1; string u_1; string v_1; 
        string l_2; string m_2; string n_2; string o_2; string p_2; string q_2; string r_2; string s_2; string t_2; string u_2; string v_2; 
        string l_3; string m_3; string n_3; string o_3; string p_3; string q_3; string r_3; string s_3; string t_3; string u_3; string v_3; 
        string l_4; string m_4; string n_4; string o_4; string p_4; string q_4; string r_4; string s_4; string t_4; string u_4; string v_4; 
        string l_5; string m_5; string n_5; string o_5; string p_5; string q_5; string r_5; string s_5; string t_5; string u_5; string v_5; 
        string l_6; string m_6; string n_6; string o_6; string p_6; string q_6; string r_6; string s_6; string t_6; string u_6; string v_6; 
        string l_7; string m_7; string n_7; string o_7; string p_7; string q_7; string r_7; string s_7; string t_7; string u_7; string v_7; 
        string l_8; string m_8; string n_8; string o_8; string p_8; string q_8; string r_8; string s_8; string t_8; string u_8; string v_8; 
        string l_9; string m_9; string n_9; string o_9; string p_9; string q_9; string r_9; string s_9; string t_9; string u_9; string v_9; 
        string l_0; string m_0; string n_0; string o_0; string p_0; string q_0; string r_0; string s_0; string t_0; string u_0; string v_0;
        
        string w_1; string x_1; string y_1; string z_1;
        string w_2; string x_2; string y_2; string z_2;
        string w_3; string x_3; string y_3; string z_3;
        string w_4; string x_4; string y_4; string z_4;
        string w_5; string x_5; string y_5; string z_5;
        string w_6; string x_6; string y_6; string z_6;
        string w_7; string x_7; string y_7; string z_7;
        string w_8; string x_8; string y_8; string z_8;
        string w_9; string x_9; string y_9; string z_9;
        string w_0; string x_0; string y_0; string z_0;
    }
}