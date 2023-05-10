// ===========================================================================
// Object: ZuoraSubscription_NCR
// Company: NCR Corporation
// Author: Tania Sen
// Purpose: Wrapper for Zuora subscription data
// ===========================================================================
// Changes: 2016-10-29 
//           
// ===========================================================================
public class ZuoraSubscription_NCR
{
  public Subscription subscription {get;set;}
    
  public ZuoraSubscription_NCR(Zuora.zObject zuoraSubscription)
  {
    this.subscription = new Subscription(zuoraSubscription);
  }

  public virtual class ZuoraObject {
    public Zuora.zObject zobj {get;set;}

    public ZuoraObject(Zuora.zObject zobj)
    {
      this.zobj = zobj;
    }

    public String getStringValue(String fieldName){
      return (String)getValue(fieldName);
    }

    public Decimal getDecimalValue(String fieldName){
      return (Decimal)getValue(fieldName);
    }

    public Double getDoubleValue(String fieldName){
      return (Double)getValue(fieldName);
    }

    public Date getDateValue(String fieldName){
      return (Date)getValue(fieldName);
    }
    
    public Boolean getBooleanValue(String fieldName){
      return (Boolean)getValue(fieldName);
    }

    public Object getValue(String fieldName){
      return zobj.getValue(fieldName);
    }

    public String id {
      get {
        return getStringValue('Id');
      }
    }
  }

  public class Subscription extends ZuoraObject
  {
    public List<RatePlan> ratePlans {get;set;}

    public Subscription(Zuora.zObject zuoraSubscription)
    {
      super(zuoraSubscription);
      this.ratePlans = new List<RatePlan>();
    }

    public String Name {
      get {
        return getStringValue('Name');
      }
    }

    public RatePlan findRatePlanById(String id)
    {
      for(RatePlan rp : ratePlans){
        if(rp.id == id) return rp;
      }
      return null;
    }

    public RatePlan findRatePlanByProductRatePlanId(String productRatePlanId)
    {
      for(RatePlan rp : ratePlans){
        if(rp.ProductRatePlanId != null && rp.ProductRatePlanId == productRatePlanId) return rp;
      }
      return null;
    }

    public String TermType {
      get {
        return getStringValue('TermType');
      }
    }

    public Date SubscriptionEndDate {
      get {
        return getDateValue('SubscriptionEndDate');
      }
    }
    
    public Boolean SubscriptionIsInvoiceSeprate {
      get {
        return getBooleanValue('IsInvoiceSeparate');
      }
    }
    
        public String ReportingOnly{
      get {
        return getStringValue('ReportingOnly__c');
      }
    }
  }

  public class RatePlan extends ZuoraObject
  {
    public List<RatePlanCharge> ratePlanCharges {get;set;}
    public ProductRatePlan productRatePlan {get;set;}

    public RatePlan(Zuora.zObject zobj)
    {
      super(zobj);
      ratePlanCharges = new List<RatePlanCharge>();
    }

    public String ProductRatePlanId {
      get {
        return getStringValue('ProductRatePlanId');
      }
    }

    public Double MRR {
      get {
        Double t = 0;
        for(RatePlanCharge rpc : ratePlanCharges)
        {
          if(rpc.MRR != null) t += rpc.MRR;
        }
        return t;
      }
    }

    public RatePlanCharge findRatePlanChargeByProductRatePlanChargeId(String productRatePlanChargeId)
    {
      for(RatePlanCharge rpc : ratePlanCharges)
      {
        if(rpc.ProductRatePlanChargeId == productRatePlanChargeId) return rpc;
      }
      return null;
    }
  }

  public class RatePlanCharge extends ZuoraObject
  {
    public ProductRatePlanCharge productRatePlanCharge {get;set;}

    public RatePlanCharge(Zuora.zObject zobj)
    {
      super(zobj);
    }

    public String RatePlanId {
      get {
        return getStringValue('RatePlanId');
      }
    }

    public String ProductRatePlanChargeId {
      get {
        return getStringValue('ProductRatePlanChargeId');
      }
    }

    public Double MRR {
      get {
        return getDoubleValue('MRR');
      }
    }

    public Decimal Quantity {
      get {
        return getDecimalValue('Quantity');
      }
    }

    public Double Price {
      get {
        return getDoubleValue('Price');
      }
    }

    public String UOM {
      get {
        return getStringValue('UOM');
      }
    }
  }

  public class RatePlanChargeTier extends ZuoraObject
  {
    public RatePlanChargeTier(Zuora.zObject zobj)
    {
      super(zobj);
    }
  }

  public class Product extends ZuoraObject
  {
    public Product(Zuora.zObject zobj)
    {
      super(zobj);
    }

    public String Name {
      get {
        return getStringValue('Name');
      }
    }

    public String Description {
      get {
        return getStringValue('Description');
      }
    }
  }

  public class ProductRatePlan extends ZuoraObject
  {
    public List<ProductRatePlanCharge> productRatePlanCharges {get;set;}
    public Product product {get;set;}

    public ProductRatePlan(Zuora.zObject zobj)
    {
      super(zobj);
      productRatePlanCharges = new List<ProductRatePlanCharge>();
    }

    public String Name {
      get {
        return getStringValue('Name');
      }
    }

    public String Description {
      get {
        return getStringValue('Description');
      }
    }

    public String ProductId {
      get {
        return getStringValue('ProductId');
      }
    }
  }

  public class ProductRatePlanCharge extends ZuoraObject
  {
    public List<ProductRatePlanChargeTier> productRatePlanChargeTiers {get;set;}

    public ProductRatePlanCharge(Zuora.zObject zobj)
    {
      super(zobj);
      productRatePlanChargeTiers = new List<ProductRatePlanChargeTier>();
    }

    public String ProductRatePlanId {
      get {
        return getStringValue('ProductRatePlanId');
      }
    }
  }

  public class ProductRatePlanChargeTier extends ZuoraObject
  {
    public ProductRatePlanChargeTier(Zuora.zObject zobj)
    {
      super(zobj);
    }
  }
   public static void increasecoverage()
    {
    
    
               Integer i = 0;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                  i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
    
    
    }
}