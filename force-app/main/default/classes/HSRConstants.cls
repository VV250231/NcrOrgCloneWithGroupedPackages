/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Static final variables related to Hospitality Service Cloud logic
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-07-15
* @modified       2022-07-15
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-07-15
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public inherited sharing class HSRConstants {

    public static final String ACCOUNT_RT_SITE = 'Site';
    public static final String ACCOUNT_RT_CUSTOMER = 'Customer';
    public static final String ACCOUNT_RT_PARTNER = 'Partner';
    public static final String ACCOUNT_RT_ENTERPRISE = 'Enterprise';

    public static final String CONTACT_ACR_STATUS_TO_PROCESS = 'To Process';
    public static final String CONTACT_ACR_STATUS_ERROR = 'Error';
    public static final String CONTACT_ACR_STATUS_COMPLETE = 'Complete';

    public static final String ASSET_RT_ASSET = 'Asset';
    public static final String ASSET_RT_SERIALIZED_ASSET = 'Serialized_Asset';

    public static final String ACR_DEFAULT_ROLES = 'MyNCR User';

    public static final List<String> ASYNC_JOB_IN_PROGRESS_STATUS = new List<String>{
            'Holding', 'Queued', 'Preparing', 'Processing'
    };
    public static final List<String> ASYNC_JOB_JOB_TYPE_BATCH = new List<String>{
            'BatchApex', 'BatchApexWorker'
    };
    public static final List<String> ASYNC_JOB_JOB_TYPE_QUEUEABLE = new List<String>{
            'Queueable'
    };

    // ---- INT-06 Dispatch outbound integration util ----
    public static final String HW_DISPATCH_OUTBOUND_WO_USER_ID = 'SCHSR';
    public static final String HW_DISPATCH_OUTBOUND_WO_SOURCE_SYSTEM = 'SCHSR';
    public static final String HW_DISPATCH_OUTBOUND_WO_DEFAULT_SITE_SHORT_NAME = 'NA';
    public static final String HW_DISPATCH_OUTBOUND_WO_DEFAULT_BRAND = 'NA';

    public static final String HW_DISPATCH_OUTBOUND_REQUEST_TYPE = 'Outbound to ES';

    public static final Integer HW_DISPATCH_OUTBOUND_DEFAULT_PRIORITY_TYPE = 4;

}