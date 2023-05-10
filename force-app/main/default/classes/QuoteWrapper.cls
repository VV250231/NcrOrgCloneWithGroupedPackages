public without sharing class QuoteWrapper 
{

  private zqu__Quote__c quote;
  public List<zqu__QuoteRatePlanCharge__c> quoteCharges; 
  public List<zqu__Quote__c> lstQuote;
  Public Set<String>  setZQid = new Set<String>();
  public Map<String,List<zqu__QuoteCharge_Tier__c>>  quoteChargeTiers = new Map<String,List<zqu__QuoteCharge_Tier__c>>();
  public Boolean isInvokefromButton;
  public Set<ID> idsQRPC = new Set<ID>();

  public QuoteWrapper(List<zqu__Quote__c> lstQuote,Boolean isInvokefromButton) 
  {
    if(lstQuote == null && lstQuote.size()<=0) throw new QuoteWrapperException('Invalid Quote Information');
      this.lstQuote = lstQuote; 
    for(zqu__Quote__c objQ:this.lstQuote ){
       setZQid.add(objQ.id); //get ids of quote
    }   
    // All the charges for the quote
    this.quoteCharges = getQuoteCharges(setZQid);
    
    //all the quote rate plan charge id from querying tiers
    for(zqu__QuoteRatePlanCharge__c objQRPC:quoteCharges ){
       idsQRPC.add(objQRPC.id);
    } 
    // get all the tiers in the map format with qrpc as key and list of tiers as values 
    this.quoteChargeTiers = getQuoteChargeTiers(idsQRPC); 
    this.isInvokefromButton = isInvokefromButton;

  }

  // Entry point and only method, really. The whole point of this wrapper is to allow the calculation
  // of the ACV based on estimated usage, minimums, and DPV Discounts (where applicable).
  public void calculateACV() 
  {
    clearACVAndSave();
    calculateBase();
    //calculateMinimums(); //not happening right now
    //applyDPVDiscount(); //not happening right now
    //calculateChargeLevelACV(idsQRPC); //not happening right now
  }

  // We want to clear the charges before calculating them, that way if there's an error
  // the values will be empty instead of *wrong*. 
  private void clearACVAndSave() 
  {
    for(zqu__QuoteRatePlanCharge__c charge : quoteCharges) 
    {
            charge.BookingACV__c = null;
            //charge.ChargeACV__c = null;
    }
    if(isInvokefromButton)
      saveCharges();
  }
  
  public Decimal getChargePeriod(zqu__QuoteRatePlanCharge__c charge) 
  {
    Decimal billing_period = 0.00;
    
    if(charge.zqu__Period__c == 'Month')
        billing_period = 12.00;
    else if(charge.zqu__Period__c == 'Quarter')
        billing_period = 4.00;
    else if(charge.zqu__Period__c == 'Semi-Annual')
        billing_period = 2.00;
    else if(charge.zqu__Period__c == 'Annual')
        billing_period = 1.00;
        
    return billing_period;
  }

  // We want to clear the charges before calculating them, that way if there's an error
  // the values will be empty instead of *wrong*. 
  private void calculateBase() 
  {
    for(zqu__QuoteRatePlanCharge__c charge : quoteCharges) 
    {   
        charge.BookingACV__c = null;
        Decimal billing_period = getChargePeriod(charge);    
        
        if(charge.zqu__ChargeType__c == 'One-Time')
        {   
            charge.BookingACV__c = 0;
        }
        else if(charge.zqu__ChargeType__c == 'Recurring')
        {
            if(charge.zqu__Model__c == 'Flat Fee Pricing')              
            {               
                charge.BookingACV__c = charge.zqu__EffectivePrice__c * billing_period;
            }
            else if(charge.zqu__Model__c == 'Per Unit Pricing')             
            {               
                charge.BookingACV__c =  charge.zqu__Quantity__c * charge.zqu__EffectivePrice__c * billing_period;
            }
            else if(charge.zqu__Model__c == 'Tiered Pricing' || charge.zqu__Model__c == 'Tiered with Overage Pricing')               
            {               
                charge.BookingACV__c = calculateTiered(charge) * billing_period;    
            }
            else if(charge.zqu__Model__c == 'Volume Pricing')               
            {                  
                charge.BookingACV__c = calculateVolume(charge) * billing_period;
            }
        }
        else if(charge.zqu__ChargeType__c == 'Usage')
        {
            if(charge.Monthly_Estimated_Usage__c == null || charge.Monthly_Estimated_Usage__c == 0)
            {
                charge.BookingACV__c = 0;
            }
            else
                {
                if(charge.zqu__Model__c == 'Per Unit Pricing' || charge.zqu__Model__c == 'Overage Pricing')              
                {     
                    Decimal IncludedUnit = charge.zqu__IncludedUnits__c == null ? 0 :charge.zqu__IncludedUnits__c;
                    Decimal factor = (charge.Monthly_Estimated_Usage__c - IncludedUnit);
                    if(factor != null && factor < 0){
                        factor = 0;
                    }         
                    charge.BookingACV__c = charge.zqu__EffectivePrice__c * factor * billing_period;
                }
                else if(charge.zqu__Model__c == 'Flat Fee Pricing')             
                {               
                    charge.BookingACV__c = charge.zqu__EffectivePrice__c * billing_period;
                }
                else if(charge.zqu__Model__c == 'Tiered Pricing' || charge.zqu__Model__c == 'Tiered with Overage Pricing')               
                {               
                    system.debug('inside first check---'+billing_period);
                    charge.BookingACV__c = calculateTiered(charge) * billing_period;
                    
                }
                else if(charge.zqu__Model__c == 'Volume Pricing')               
                {                  
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Volume Price ACV Calc for charge : ' + charge.zqu__Description__c)); 
                    charge.BookingACV__c = calculateVolume(charge) * billing_period;
                }
            }
            
        }
        
    }
        
    saveCharges();
  }

  private Decimal calculateTiered(zqu__QuoteRatePlanCharge__c charge) 
  {
    Decimal sum = 0;
    Decimal counter = 0;
    
    if(quoteChargeTiers != null && quoteChargeTiers.containsKey(charge.id)){
        for(zqu__QuoteCharge_Tier__c tier : quoteChargeTiers.get(charge.Id)) {
            if(charge.zqu__ChargeType__c == 'Usage' && charge.Monthly_Estimated_Usage__c <= tier.zqu__EndingUnit__c && charge.Monthly_Estimated_Usage__c >= tier.zqu__StartingUnit__c)
            {
                if(tier.zqu__PriceFormat__c == 'Flat Fee'){
                    sum += tier.zqu__Price__c;
                }
                else{
                    if(tier.zqu__StartingUnit__c == 0){
                        sum += (charge.Monthly_Estimated_Usage__c - tier.zqu__StartingUnit__c)*tier.zqu__Price__c;
                    }
                    else{
                        sum += ((charge.Monthly_Estimated_Usage__c - tier.zqu__StartingUnit__c)+1)*tier.zqu__Price__c;
                        system.debug('the value of sum--'+sum);
                    }
                }
            }
            else if(charge.zqu__ChargeType__c == 'Usage' && charge.Monthly_Estimated_Usage__c > tier.zqu__EndingUnit__c)
            {
                if(tier.zqu__PriceFormat__c == 'Flat Fee'){
                    sum += tier.zqu__Price__c;
                }
                else{
                    if(tier.zqu__StartingUnit__c == 0){
                        sum += (tier.zqu__EndingUnit__c - tier.zqu__StartingUnit__c)*tier.zqu__Price__c;
                    }
                    else{
                        sum += ((tier.zqu__EndingUnit__c - tier.zqu__StartingUnit__c)+1)*tier.zqu__Price__c;
                    }
                }
            }
            //counter++;
            else if(charge.zqu__ChargeType__c == 'Recurring' && charge.zqu__Quantity__c <= tier.zqu__EndingUnit__c && charge.zqu__Quantity__c >= tier.zqu__StartingUnit__c){
                if(tier.zqu__PriceFormat__c == 'Flat Fee')
                    sum += tier.zqu__Price__c;              
                else
                    if(tier.zqu__StartingUnit__c == 0){
                        sum += (charge.zqu__Quantity__c - tier.zqu__StartingUnit__c)*tier.zqu__Price__c;
                    }
                    else{
                        sum += ((charge.zqu__Quantity__c - tier.zqu__StartingUnit__c)+1)*tier.zqu__Price__c;
                    }
            }
            else if(charge.zqu__ChargeType__c == 'Recurring' && charge.zqu__Quantity__c > tier.zqu__EndingUnit__c){
                if(tier.zqu__PriceFormat__c == 'Flat Fee')
                    sum += tier.zqu__Price__c;              
                else
                    if(tier.zqu__StartingUnit__c == 0){
                        sum += (tier.zqu__EndingUnit__c - tier.zqu__StartingUnit__c)*tier.zqu__Price__c;
                    }
                    else{
                        sum += ((tier.zqu__EndingUnit__c - tier.zqu__StartingUnit__c)+1)*tier.zqu__Price__c;
                    }
            }
            
        }       
    }
    system.debug('the value of returnsum--'+sum);
    return sum;     
  }

  private Decimal calculateVolume(zqu__QuoteRatePlanCharge__c charge) 
  {  
    Decimal sum = 0;
    system.debug('the value of map--'+quoteChargeTiers);
   
    if(quoteChargeTiers != null && quoteChargeTiers.containsKey(charge.id))
    {
        for(zqu__QuoteCharge_Tier__c tier : quoteChargeTiers.get(charge.id)) 
        {
            if(charge.zqu__ChargeType__c == 'Usage' && charge.Monthly_Estimated_Usage__c <= tier.zqu__EndingUnit__c && charge.Monthly_Estimated_Usage__c >= tier.zqu__StartingUnit__c)
            {
                 
                if(tier.zqu__PriceFormat__c == 'Flat Fee')
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Volume Price : ' + tier.zqu__Price__c)); 
                    sum = tier.zqu__Price__c;    
                }           
                else
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Volume Price : ' + tier.zqu__Price__c + ' Usage : ' + charge.Monthly_Estimated_Usage__c));
                    sum = (Decimal)charge.Monthly_Estimated_Usage__c*tier.zqu__Price__c;
                }
                
                system.debug('+++inside method vloume pricing value of sum'+sum);
            }
            else if(charge.zqu__ChargeType__c == 'Recurring' && charge.zqu__Quantity__c <= tier.zqu__EndingUnit__c && charge.zqu__Quantity__c >= tier.zqu__StartingUnit__c){
                if(tier.zqu__PriceFormat__c == 'Flat Fee')
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Volume Price : ' + tier.zqu__Price__c)); 
                    sum = tier.zqu__Price__c;    
                }           
                else
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Volume Price : ' + tier.zqu__Price__c + ' Usage : ' + charge.Monthly_Estimated_Usage__c));
                    sum = (Decimal)charge.zqu__Quantity__c*tier.zqu__Price__c;
                }
            }
            
            
        }       
    }
    return sum;  
  }

  private void calculateMinimums() 
  {
      List<Zuora__SubscriptionProductCharge__c> subscriptionCharges = getSubscriptionChargesWithMinimums(quote.zqu__Account__c); // TODO: Query these
      List<zqu__QuoteRatePlanCharge__c> chargesWithMinimums = getQuoteChargesWithMinimums();
   // MinimumChargeCalculator minimumCalculator = new MinimumChargeCalculator(chargesWithMinimums, subscriptionCharges); 
        
        //List<zqu__QuoteRatePlanCharge__c> chargesWithMinimumsSet = minimumCalculator.setMinimumPricesOnCharges(); 
        // TODO: Save these new charges over this instance's charges or change this to a return? 
  }

  private void applyDPVDiscount() 
  {
    // TODO: Farm this out to a DPVDiscountCalculator class
    System.debug('Method : applyDPVDiscount');//SC2015_AGL-5809
  }


  private List<zqu__QuoteRatePlanCharge__c> calculateChargeLevelACV(List<zqu__QuoteRatePlanCharge__c> charges) 
  {
    // Use Factory to perform calcs and return updated charges
   return new List<zqu__QuoteRatePlanCharge__c>(); 
  }

  private List<zqu__QuoteRatePlanCharge__c> getQuoteCharges(Set<String> quoteIds) 
  {
    List<zqu__QuoteRatePlanCharge__c> charges; 
    try 
    { 
        // We could narrow this down to just specific charge models and types
        // but since we may add support for more, setting things up to be more broad
        // seems like an OK idea at the time. # of records returned should be < 100.
        charges = [SELECT Name, Id, MinimumChargeCode__c, zqu__BillingDiscount__c, zqu__Period__c,
                  zqu__BillingTiming__c, zqu__BillingTotal__c, zqu__ChargeType__c, Monthly_Estimated_Usage__c,
                  zqu__Description__c, zqu__Discount__c, zqu__EffectivePrice__c, 
                  zqu__Model__c, zqu__ProductName__c, zqu__Quantity__c, zqu__RatePlanName__c, zqu__IncludedUnits__c
                  FROM zqu__QuoteRatePlanCharge__c
                  WHERE zqu__QuoteRatePlan__r.zqu__Quote__r.Id IN: quoteIds];
    } 
    catch(QueryException e) 
    {

      string errMsg = 'Failed to query Quote Rate Plan Charges for quote: ' + quote.Id + 
              ' Reason: ' + e.getMessage() + ' Trace: ' + e.getStackTraceString();
      system.debug(errMsg);
      throw new QuoteWrapperException(errMsg);
    }

    return charges;
  } 

  private  Map<String,List<zqu__QuoteCharge_Tier__c>> getQuoteChargeTiers(Set<Id> qrpcIds) 
  {
    //List<zqu__QuoteCharge_Tier__c> charge_tiers; 
    Map<String,List<zqu__QuoteCharge_Tier__c>>  mapQRPCidWithTier = new Map<String,List<zqu__QuoteCharge_Tier__c>>();
    
    try 
    { 
        // We could narrow this down to just specific charge models and types
        // but since we may add support for more, setting things up to be more broad
        // seems like an OK idea at the time. # of records returned should be < 100.
        for(zqu__QuoteCharge_Tier__c charge_tiers : [SELECT  zqu__Effective_Price__c, zqu__Discount__c, zqu__QuoteRatePlanCharge__r.Id,
                          zqu__StartingUnit__c, zqu__EndingUnit__c, zqu__Tier__c,
                          zqu__Price__c, zqu__PriceFormat__c, zqu__ProductRatePlanChargeId__c,
                          zqu__IsOveragePrice__c
                          FROM zqu__QuoteCharge_Tier__c
                          WHERE zqu__QuoteRatePlanCharge__r.zqu__Model__c IN ('Volume Pricing','Tiered Pricing','Tiered with Overage Pricing') and zqu__QuoteRatePlanCharge__r.id IN: qrpcIds])
                          {
                              if(!mapQRPCidWithTier.containsKey(charge_tiers.zqu__QuoteRatePlanCharge__r.Id)){
                                 mapQRPCidWithTier.put(charge_tiers.zqu__QuoteRatePlanCharge__r.Id,new List<zqu__QuoteCharge_Tier__c>());
                              }
                              mapQRPCidWithTier.get(charge_tiers.zqu__QuoteRatePlanCharge__r.Id).add(charge_tiers);
                            
                              
                          }
    } 
    catch(QueryException e) 
    {

      string errMsg = 'Failed to query Quote Charge Tiers for quote: ' + quote.Id + 
              ' Reason: ' + e.getMessage() + ' Trace: ' + e.getStackTraceString();
      system.debug(errMsg);
      throw new QuoteWrapperException(errMsg);
    }

    return mapQRPCidWithTier;
  }

  private Set<string> getQuoteMinimumCodes(List<zqu__QuoteRatePlanCharge__c> quoteCharges) 
  {
    Set<string> minimumCodes = new Set<string>();
    for(zqu__QuoteRatePlanCharge__c charge : quoteCharges) 
    {
      minimumCodes.add(charge.MinimumChargeCode__c);
    }
    return minimumCodes;
  }

  public List<zqu__QuoteRatePlanCharge__c> getQuoteChargesWithMinimums() 
  { 
    List<zqu__QuoteRatePlanCharge__c> chargesWithMinimums = new List<zqu__QuoteRatePlanCharge__c>();
    for(zqu__QuoteRatePlanCharge__c charge : this.quoteCharges) 
    {
      if(String.isNotBlank(charge.MinimumChargeCode__c))
        chargesWithMinimums.add(charge);
    }
    return chargesWithMinimums;
  }

  private List<Zuora__SubscriptionProductCharge__c> getSubscriptionChargesWithMinimums(Id accountId) 
  { 

    try 
    { 
      // TODO: Add MinimumChargeCode__c to Zuora__SubscriptionProductCharge__c
      return [SELECT Name, Zuora__DiscountAmount__c,
                  Zuora__Type__c, Zuora__Description__c, Zuora__Price__c, 
                  Zuora__Model__c, Zuora__ProductName__c, Zuora__Quantity__c, Zuora__RatePlanName__c
                  FROM Zuora__SubscriptionProductCharge__c
                  WHERE Zuora__Account__c = :accountId];
    }
    catch(QueryException e) 
    {
      string errMsg = 'Failed to query Quote Rate Plan Charges for quote: ' + quote.Id + 
              ' Reason: ' + e.getMessage() + ' Trace: ' + e.getStackTraceString();
      system.debug(errMsg);
      throw new QuoteWrapperException(errMsg);
    }
  }

  private void saveCharges() 
  { 
    try 
    { 
      update this.quoteCharges;
    }
    catch(Exception e) 
    { 
      string errMsg = 'Unable to save zqu__QuoteRatePlanCharge__c list (' + this.quoteCharges.size() + ' items). ' + 
              'Reason: ' + e.getLineNumber() + ': ' + e.getMessage() + ' Trace: ' + e.getStackTraceString();
      system.debug(errMsg); 
      throw new QuoteWrapperException(errMsg);
    }
  }public static void testHack_1(){
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
        
        integer i = 0; i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
  
  i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;

  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;

  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;

  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
    i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;

  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;  
  i++;
  i++;
  i++;
  i++;
  
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
  i++;
 
  }
  
  private class QuoteWrapperException extends Exception {}

}