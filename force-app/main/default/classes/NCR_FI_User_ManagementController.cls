public class NCR_FI_User_ManagementController{
    public Blob contentFile { get; set; }
    public String nameFile { get; set; }
    public Integer rowCount { get; set; }
    public Integer colCount { get; set; }
    public Map<String,User> mapUsr {get; set;}
    public List<User> usrlst {get; set;}
    public List<wrapper> lstwrp {get; set;}
   
    public void Results()
    {
        lstwrp = new List<Wrapper>();
        List<List<String>> parsedCSV = new List<List<String>>();

        rowCount = 0;
        colCount = 0;
        Set<String> strst = new Set<String>();
        if (contentFile != null)
        {
            String fileString = contentFile.toString();
            parsedCSV = parseCSV(fileString, False);
            rowCount = parsedCSV.size();
            for (List<String> row : parsedCSV)
            {
                if (row.size() > colCount)
                {
                    colCount = row.size();
                }
               //for(String str :row){
                  strst.add(row[1]); 
               //} 
            }
        }
       
        mapUsr = new Map<String,User>();
        usrlst = [Select id,name,username,isActive,Email,FederationIdentifier from User where FederationIdentifier in:strst];
        System.debug('+++++usrlst+++'+usrlst);
        for(User obj:usrlst){
            mapUsr.put(obj.FederationIdentifier,obj);
        }
        for(String str:strst){
         wrapper wrp = new wrapper();
         wrp.str = str;
         if(mapUsr.containsKey(str)){
             wrp.usr = mapUsr.get(str);
         }
         lstwrp.add(wrp);
        }
       
       // return parsedCSV;
    }
    public Void saveUserDetails(){
        List<User> usrlst = new List<User>();
        for(wrapper wrp:lstwrp){
             if(wrp.usr.id !=null){
                 usrlst.add(wrp.usr);
             }
        }
        if(usrlst.size()>0 && usrlst != null){
            update usrlst;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'User Detail was updated Successfully.Thank you!'));
       }
    }
    public Pagereference CreatePDF()
     {
      pagereference pr = new pagereference('/apex/FinalReport1');
      pr.setredirect(true);

      return pr;
     }
     
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders)
     {
     
        List<List<String>>  allFields = new List<List<String>>();
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        contents = contents.replaceAll('""','DBLQT');
        List<String> lines = new List<String>();
        try
        {
          lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
        }
        catch (System.ListException e)
        {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line: lines)
        {
           if (line.replaceAll(',','').trim().length() == 0) break;
            List<String> fields = line.split(','); 
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields)
            {
                if (field.startsWith('"') && field.endsWith('"'))
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
                else if (field.startsWith('"'))
                {
                    makeCompositeField = true;
                    compositeField = field;
                }
                else if (field.endsWith('"'))
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                }
                else if (makeCompositeField)
                {
                    compositeField +=  ',' + field;
                }
                else
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
         
           allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;      
     }
     
   public Class wrapper{
   
       public String str{get; set;}
       public User usr {get;set;}
      public wrapper(){
       this.usr = new User();
      }
   }
     
}