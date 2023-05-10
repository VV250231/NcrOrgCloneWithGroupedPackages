/*
##################################################################################################
# Class Name............................:fromJSON.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class fromJSON{
    public cls_OpportunityLineItem[] OpportunityLineItem;
    public class cls_OpportunityLineItem {
        public String Id;   //00k54000003CsctAAC
        public Integer Quantity;        //2
        public Decimal UnitPrice;      //0
        public Decimal TotalPrice;    //0
        public Decimal TotalTCVPrice;
        public Decimal TotalACVPrice;
        public boolean isSubscriptioned;
        public Integer NumberOfTerms;
        public Decimal OneTimeFee;
        public Decimal MonthlyFee;
        public String RevenueType;
        public String ProductName;   //Do Not Touch This Opportunity 2186-Compact Cash Drawer
        public String UnschldQty;   //1
        public String counter;     //0
        public String Duration;
        public String ScheduleDate;   //to take first schedule date
        public String OpportunityId;
        public String isPackage;
        public String isCompanion;
        public Integer NumberOfLicense;
        public Integer NumberOfSites;
        public String MasterLineId;
        public String qtyTyp; //part of story 2072 - by Stuti
        public Boolean isCATMProduct; //Addeds channge for story CSI-365 - Products: One Time Revenue 
        public cls_OpportunityLineItemSchedule[] OpportunityLineItemSchedule;
    }
    public class cls_OpportunityLineItemSchedule {
        public Integer Quantity;    //1
        public String Type;   //Quantity
        public String Id;
        public String ScheduleDate;
        
    }
    public static fromJSON parse(String json){
        return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
    }
}