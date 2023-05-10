/****************************************************************************************************************
*   ClassName :   LeadTriggerVariableClass
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1617     30 Nov 2021     Kapil Bhati         Removed Marketo user hardcoded Id 
****************************************************************************************************************/
public class LeadTriggerVariableClass {
    public static String LeadSourceValue ='Sales-HOS-Restaurant Data';
    public static String LeadSource_Sales_HOS_RestaurantData = LeadSourceValue.replaceAll( '\\s+', '');
    public static String LeadSourceValue_Sales ='Sales-HOS-Fab Five';
    public static String LeadSource_Sales_HOS_FabFive = LeadSourceValue_Sales.replaceAll('\\s+', '');
  //public static String marketoUserID='0050g000006HruFAAS';
    public static String marketoUserID= System.Label.Marketo_Us;  //EBA_SF-1617 Removed hardcoded Id - Modified by Kapil Bhati 
    public static String pManaged='Partner Managed';
    public static String uState='UNITED STATES';
	public static String Hosp='Hospitality';
}