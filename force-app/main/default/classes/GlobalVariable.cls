public class GlobalVariable {
    static String GblPrcBkmdtId = NCR_PriceBook__mdt.getInstance('Global')?.PriceBook_Id__c;
    static String StaticGblPrcBkmdtId = NSCCommonInfoUtil.getIdOf('GblPricebookId');
    static String CPQPrcBkmdtId = NCR_PriceBook__mdt.getInstance('CPQ_Price_Book')?.PriceBook_Id__c;
    static String cpqPBId = System.Label.CPQ_PriceBook_Id;
    public static String pricebookId = GblPrcBkmdtId != NULL ? GblPrcBkmdtId : StaticGblPrcBkmdtId; //sandbox=01sS00000008cajIAA, sandbox:cert=01s7000000030GM, prod=01s7000000030GM
  //public static String CPQPricebookId = CPQPrcBkmdtId != NULL ? CPQPrcBkmdtId : '01s4u000000mR4JAAU';
    public static String CPQPricebookId = CPQPrcBkmdtId != NULL ? CPQPrcBkmdtId : cpqPBId;
  //  public static Id testProductSearchExtensionsOpptyID='0067000000GqMxhAAF'; //sandbox=006S0000002fmqU, production=0067000000Gq35n / 0067000000GqMxhAAF / 0067000000Gq35n
  //  public static Id testProductScheduleExtensionsOpptyID='0067000000GqMxhAAF'; //sandbox=006S0000002fmqU, production=0067000000Gq35n / 0067000000GqMxhAAF / 0067000000Gq35n
    public static String PricebookEntryId = 'PRICEBOOKENTRYID';     
    public static String no = 'N';
    public static String yes = 'Y';
    public static String catHW = 'HW';
    public static String catSW = 'SW';
    public static String catPS = 'PS';
    public static String catCS = 'CS';
    public static String catTS = 'TS';                              
    public static Integer noOfYears = 20;
    public static Integer maxDisplay = 6;                                   
    public static Date unhandledQtyDate = Date.newInstance(3000, 1,1);
    public static Date OLIBeforeSKO = Date.newInstance(2016, 12,21);
    public static Date OLIAfterSKO = Date.newInstance(2016, 12,22);
}