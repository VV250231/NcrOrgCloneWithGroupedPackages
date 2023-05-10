/*************************************************************************************************
* ClassName     :   ReportsToEmailController
* Author        :   Kapil Bhati 
* Email Id      :   kb250441@ncr.com  
* Description   :   Controller for reportToEmail vf component. Used to send filter report based on account mcn value.
* Version       :   Initial
* Story Number  :   EBA_SF-2153
# Modification History.: 
Story No#         Date            DevName                Description

*************************************************************************************************/
global without sharing class  ReportsToEmailController {
    public  Id rptId { get; set; } // Here we will get the report Id from the VF Component
    public  transient  Reports.ReportResults results{get; set;} // It will hold the entire data of a report
    public  Id con {get;set;}
    public  List<String> colList = new  List<String>();
    public  Map<Integer,List<String>> rowList = new  Map<Integer,List<String>>();
    
    
    
    
    /*********************
// Method Name : getReportResult
// Description : Here we will get the data of a report and send to the VF Component
/********************/
    public string getReportResult() {
        String htmlBody;
        List<Email_Recipient__c> etList = [select id,Direct_MCN__c,Indirect_MCN__c,Reporting_Filter__c,Direct_FUA__c,Indirect_FUA__c from Email_Recipient__c where id =:con ORDER BY Createddate DESC  limit 1];
        if(etList.size()>0){
            
            // Get the report metadata
            Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(rptId);
            Reports.ReportMetadata reportMd = describe.getReportMetadata();
            
            // Fetching report Format
            reports.ReportFormat reportFormat = reportMd.getreportFormat();
            
            // Get Report Filter Logic
            String reportFilterLogic = reportMd.getReportBooleanFilter();
            
            // Fetching all existing report filter
            List<Reports.ReportFilter> filterListExisting = reportMd.getReportFilters();
            
            
            
            if(etList[0].Reporting_Filter__c=='Direct MCN'){
                //Master Customer Number Filter
                Reports.ReportFilter rfm = new Reports.ReportFilter();
                rfm.setColumn('Case.Account.Master_Customer_Number__c');
                rfm.setFilterType('fieldValue');
                rfm.setOperator('contains');
                rfm.setValue(etList[0].Direct_MCN__c);
                filterListExisting.add(rfm);
            }
            else if(etList[0].Reporting_Filter__c=='Indirect MCN'){
                //Master Customer Number Filter
                Reports.ReportFilter rfm = new Reports.ReportFilter();
                rfm.setColumn('Case.Account.Master_Customer_Number__c');
                rfm.setFilterType('fieldValue');
                rfm.setOperator('contains');
                rfm.setValue(etList[0].Indirect_MCN__c);
                filterListExisting.add(rfm);  
            }
            else if(etList[0].Reporting_Filter__c=='Direct FUA'){
                // Site Number Filter
                Reports.ReportFilter rfs = new Reports.ReportFilter();
                rfs.setColumn('Case.Site_Id__c.Site_Number__c');
                rfs.setFilterType('fieldValue');
                rfs.setOperator('contains');
                rfs.setValue(etList[0].Direct_FUA__c);
                filterListExisting.add(rfs);
                
            }
            else if(etList[0].Reporting_Filter__c=='Indirect FUA'){
                // Site Number Filter
                Reports.ReportFilter rfs = new Reports.ReportFilter();
                rfs.setColumn('Case.Site_Id__c.Site_Number__c');
                rfs.setFilterType('fieldValue');
                rfs.setOperator('contains');
                rfs.setValue(etList[0].Indirect_FUA__c);
                filterListExisting.add(rfs);
                
            }
            else if(etList[0].Reporting_Filter__c=='All FUA'){
                // Site Number Filter
                Reports.ReportFilter rfs = new Reports.ReportFilter();
                rfs.setColumn('Case.Site_Id__c.Site_Number__c');
                rfs.setFilterType('fieldValue');
                rfs.setOperator('contains');
                rfs.setValue(etList[0].Direct_FUA__c+','+etList[0].Indirect_FUA__c);
                filterListExisting.add(rfs);
                
            }
            else{
                //Master Customer Number Filter
                Reports.ReportFilter rfm = new Reports.ReportFilter();
                rfm.setColumn('Case.Account.Master_Customer_Number__c');
                rfm.setFilterType('fieldValue');
                rfm.setOperator('contains');
                rfm.setValue(etList[0].Direct_MCN__c+ ','+ etList[0].Indirect_MCN__c);
                filterListExisting.add(rfm);  
            }
            
            //Adding new filters to thr report metadata
            reportMd.setReportFilters(filterListExisting);
            
            // Updating report filter logic
            if(reportFilterLogic!=null){
                integer filterCount = filterListExisting.size();
                String reportFilterLogicNew = '(' + reportFilterLogic + ')'+' AND '+String.valueOf(filterCount);
                 reportMd.setReportBooleanFilter(reportFilterLogicNew);
            }
            
            // Here it will run the report with that report ID and adding the report data into results
            results = Reports.ReportManager.runReport(rptId,reportMd,true); 
            
            Reports.ReportFactWithDetails factDetails;
            List<Reports.ReportDetailRow>  rowDt = new  List<Reports.ReportDetailRow>();
            Map<string,List<Reports.ReportDetailRow>> rowDTMap = new Map<string,List<Reports.ReportDetailRow>>();
            
            //If report is Tabular
            if(String.valueof(reportFormat)=='TABULAR'){
                //get the map of the column names to their name and label
                Map<String, Reports.DetailColumn> detailColumnMap = results.getreportExtendedMetadata().getDetailColumnInfo();
                for (Reports.DetailColumn detailColumn: detailColumnMap.values()) {
                    colList.add(detailColumn.getLabel());
                }
                // Get the fact map from the report results
                factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
                rowDt = factDetails.getRows();
                integer count =0;
                for(Reports.ReportDetailRow rowObj:rowDt){
                    count = count +1;
                    for(Reports.ReportDataCell data:rowObj.getdataCells()){
                        if(rowList.get(count)!=null){
                            rowList.get(count).add(data.getlabel());
                        }
                        else{
                            rowList.put(count,new list<string>{data.getlabel()});  
                        }
                    }
                }
                htmlBody = getTableBody();
            }
            else if(String.valueof(reportFormat)=='SUMMARY'){
                
                //get the map of the column names to their name and label
                Map<String, Reports.DetailColumn> detailColumnMap = results.getreportExtendedMetadata().getDetailColumnInfo();
                for (Reports.DetailColumn detailColumn: detailColumnMap.values()) {
                    colList.add(detailColumn.getLabel());
                }
                
                // Get the first down-grouping in the report
                Reports.Dimension dim = results.getGroupingsDown();
                List<Reports.GroupingValue> groupingValList = dim.getGroupings();
                List<String> factMapKeyList = new List<String>();
                for(Reports.GroupingValue groupingVal:groupingValList){
                    factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(groupingVal.getKey() + '!T');
                    rowDTMap.put(groupingVal.getKey(),factDetails.getRows());
                }
                
                integer count =0;
                for(List<Reports.ReportDetailRow> rowObjList:rowDTMap.values()){
                    for(Reports.ReportDetailRow rowObj:rowObjList){
                        count = count +1;
                        for(Reports.ReportDataCell data:rowObj.getdataCells()){
                            if(rowList.get(count)!=null){
                                rowList.get(count).add(data.getlabel());
                            }
                            else{
                                rowList.put(count,new list<string>{data.getlabel()});  
                            }
                        }
                    }
                }
                htmlBody =  getTableBody();
            }
            
        }
        else{
            return null;  
        }
        return htmlBody;
    }
    
    
   
    
    // Create report table using report data
    public  string getTableBody(){
        string csvBody;
        List<string> sRows = new List<string>();
        string rows;
        //iterate over list and output columns/data into table rows...
        for(List<string> singleRow : rowList.values()){
            for(string cell:singleRow){
                if(sRows.size()==(singleRow.size()-1)){
                    sRows.add('"'+ cell + '"'); 
                    if(rows!=null)
                        rows = rows +'"'+ cell + '"';
                    else
                        rows = '"'+ cell + '"';
                    
                } 
                else{
                    sRows.add('"'+ cell + '",');
                    if(rows!=null)
                        rows = rows +'"'+ cell + '",';
                    else
                        rows ='"'+ cell + '",';
                    
                }
            }
            rows = rows+ '\n';
            
        }
        
        if(rows!=null)
            csvBody = string.join(colList,',') + '\n' +rows;
        else
            csvBody = string.join(colList,',');
        
        return csvBody;
        
    }
}