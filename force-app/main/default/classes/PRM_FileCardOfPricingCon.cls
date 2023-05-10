public class PRM_FileCardOfPricingCon {
    
    @AuraEnabled
    public static List<priceBookWrapper> fetchPriceList() {
        List<PriceBookWrapper> prcLst;
        List<User> usrLst = [SELECT Id, AccountId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        if (! usrLst.isEmpty()) {
            prcLst = getPriceList(usrLst[0].AccountId);
        }
        return prcLst;        
    }
    
    @AuraEnabled
    public static List<PriceBookWrapper> getPriceList(String accountId) {
        
        String prtnrType,prtnrLvl,prtnrCtryCode,prtnrRgn;
        Boolean dstbtrExcptn;
        Set<String> prtnrIndtrs = new Set<String>();
        List<PriceBookWrapper> priceWrpLst = new List<PriceBookWrapper>();
        
        
        List<Account> actLst = [SELECT Id, Account_Country_Code__c, Partner_Type__c, Partner_Program_Level__c, 
                                Partner_Industry__c, Account_Region__c, Region__c, ISO_Country_Code__c, Distributor__c, Direct_Partner__c
                                FROM Account WHERE Id =: accountId];
        //Removed distributor_exception__c from select query due to EBA_SF-688

        
        if (! actLst.isEmpty()) {
            Account act = actLst[0];
            prtnrType = act.Partner_Type__c;
           // dstbtrExcptn = act.Distributor_Exception__c;
           // commented due to EBA_SF-688
            prtnrLvl = act.Partner_Program_Level__c;
            prtnrCtryCode = act.ISO_Country_Code__c;
            
            if (act.Partner_Industry__c != null)
                prtnrIndtrs.addAll(act.Partner_Industry__c.split(';'));
            
            // Determine Partner Region
            List<Country_Code__mdt> ctryCode_RgnLst = new List<Country_Code__mdt>();
            ctryCode_RgnLst = [SELECT DeveloperName, Region__c, MasterLabel FROM Country_Code__mdt WHERE DeveloperName =: actLst[0].ISO_Country_Code__c];
            if (! ctryCode_RgnLst.isEmpty())
                prtnrRgn = ctryCode_RgnLst[0].Region__c;
            else
                prtnrRgn = act.Account_Region__c;
            
            // get price list based on country + partner type + patner level + partner region + partner industry.
            // Note : Turkey has pricing modal based on product name.
            Map<String,PriceBookWrapper> indToPrcLstMap = new Map<String,PriceBookWrapper>(); // indstryToPriceLstMap
            if (prtnrCtryCode != 'TR') {
                if(prtnrIndtrs.size() > 0) {
                    for (String str: prtnrIndtrs) {
                        indToPrcLstMap.put(str, new PriceBookWrapper(prtnrRgn,str,prtnrCtryCode,act.Direct_Partner__c));
                    } 
                }
                
                // Find in case of Namer what type of partner he is either direct or indirect
                Boolean isDirect = false;
                if(prtnrRgn == 'NAMER') {
                    isDirect = (act.Distributor__c != null && act.Distributor__c.split(';').size() == 1 && act.Distributor__c.split(';').contains('NCR (direct purchase from NCR)')) ? true : false;
                }
                
                List<Channel_Price_Book__c> priceLst = new List<Channel_Price_Book__c>();
                if (prtnrType == 'Distributor' || dstbtrExcptn == true ) {
                    priceLst = [SELECT Id, Partner_Type__c, Channel_Program_Level__r.Name, Industry__c, Old_Value__c, New_Value__c, CurrencyIsoCode 
                                FROM Channel_Price_Book__c WHERE Industry__c IN: prtnrIndtrs and Region__c =: prtnrRgn
                                ORDER BY Channel_Program_Level__r.Rank ASC];
                    
                } else {
                    priceLst = [SELECT Id, Partner_Type__c, Channel_Program_Level__r.Name, Industry__c, Old_Value__c, New_Value__c, CurrencyIsoCode 
                                FROM Channel_Price_Book__c WHERE Industry__c IN: prtnrIndtrs and  Partner_Type__c != 'Distributor' and Region__c =: prtnrRgn
                                ORDER BY Channel_Program_Level__r.Rank ASC];
                }
                
                for(Channel_Price_Book__c cpb : priceLst) {
                    if (prtnrType == 'Distributor' || dstbtrExcptn == true ) {indToPrcLstMap.get(cpb.Industry__c).priceList.add(cpb);
                    } else if (prtnrRgn != 'NAMER' && prtnrRgn != 'NAMER CFI'  && prtnrRgn != 'NAMER MAJORS'  && cpb.Channel_Program_Level__r.Name == act.Partner_Program_Level__c) {indToPrcLstMap.get(cpb.Industry__c).priceList.add(cpb);
                    } else if ((prtnrRgn == 'NAMER' || prtnrRgn == 'NAMER CFI' || prtnrRgn == 'NAMER MAJORS') && cpb.Industry__c != 'Financial') {
                        if (cpb.Channel_Program_Level__r.Name == act.Partner_Program_Level__c)
                            indToPrcLstMap.get(cpb.Industry__c).priceList.add(cpb);
                    } else if ((prtnrRgn == 'NAMER' || prtnrRgn == 'NAMER CFI' || prtnrRgn == 'NAMER MAJORS') && cpb.Industry__c == 'Financial') {
                        if (prtnrType == 'Distributor' ) {
                            indToPrcLstMap.get(cpb.Industry__c).priceList.add(cpb);
                        } else if (act.Direct_Partner__c && cpb.Partner_Type__c == 'Direct Partner') {indToPrcLstMap.get(cpb.Industry__c).priceList.add(cpb);
                        } else if (act.Direct_Partner__c == false && cpb.Partner_Type__c == 'Indirect Partner') { indToPrcLstMap.get(cpb.Industry__c).priceList.add(cpb);}
                    }
                    
                }               
                
                if (indToPrcLstMap.values().size() > 0) {
                    priceWrpLst.addAll(indToPrcLstMap.values());
                }
            } else {
                // Turkey has priceing model based on products.
                List<Channel_Price_Book_Turkey__c> turkeyPrcLst = new List<Channel_Price_Book_Turkey__c>();
                turkeyPrcLst = [SELECT Id, Name, Product_Group__c, PID__c, Old_Discount__c, New_Discount__c FROM Channel_Price_Book_Turkey__c];
                PriceBookWrapper obj = new PriceBookWrapper(prtnrCtryCode);
                obj.trukeyPriceList = turkeyPrcLst;
                priceWrpLst.add(obj);
            }
            
            
        }
        
        return priceWrpLst;
        
    }
    
    public class PriceBookWrapper {
        
        @AuraEnabled public String partnerRegion;
        @AuraEnabled public String industry;
        @AuraEnabled public String partnerCountryCode;
        @AuraEnabled public Boolean directPartner;
        @AuraEnabled public List<Channel_Price_Book__c> priceList = new List<Channel_Price_Book__c>();
        @AuraEnabled public List<Channel_Price_Book_Turkey__c> trukeyPriceList = new List<Channel_Price_Book_Turkey__c>();
        public PriceBookWrapper(String ptnrRegion, String industry, String partnerCountryCode, Boolean directPartner) {
            this.partnerRegion = partnerRegion;
            this.industry = industry;
            this.partnerCountryCode = partnerCountryCode;
            this.directPartner = directPartner;
        }
        
        public PriceBookWrapper(String partnerCountryCode) {
            this.partnerCountryCode = partnerCountryCode;
        }
    }
}