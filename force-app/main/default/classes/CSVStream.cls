public class CSVStream {
    public static Boolean isTest;
    public static String strEmailAddr;
    public static String strOut;
    public static Boolean restRequested;
    public String strEmail{get;set;}
    public String strRptname{get;set;}
    
   public CSVStream () {
       strOut = '';        
   }
  
   /* getCSVStream property retrun csv string for requersted report
   */
   public String getCSVStream() {
        restRequested = System.isFuture() || System.isScheduled();
        executeRpt();
        return strOut;
   }
  
   /* executeRpt method retrun csv string for requersted report
   */
    public void executeRpt() {
        String requestURL = '/' + strRptname + '?export=1&xf=csv&enc=x-SJIS_0213'; 
       
        
        if(Test.isRunningTest()){
            strOut = 'test';
        } else {
            Blob blobreport =  new PageReference(requestURL).getContent();          
            strOut = blobToString(blobreport , 'x-SJIS_0213');
        }
    }    
    public String blobToString(Blob input, String inCharset) {
        String hex = EncodingUtil.convertToHex(input);        
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;        
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);       
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
 
}