/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class that covers Hospitality Apex code constants values for quick deployment validation
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-07-19
* @modified
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-07-19
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
private class HSRConstantsTest {
    @IsTest
    static void codeCoverage() {
        System.assertNotEquals(null, HSRConstants.ACCOUNT_RT_SITE);
        System.assertNotEquals(null, HSRConstants.ACCOUNT_RT_CUSTOMER);
        System.assertNotEquals(null, HSRConstants.ACCOUNT_RT_PARTNER);
        System.assertNotEquals(null, HSRConstants.ACCOUNT_RT_ENTERPRISE);
        System.assertNotEquals(null, HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS);
        System.assertNotEquals(null, HSRConstants.CONTACT_ACR_STATUS_ERROR);
        System.assertNotEquals(null, HSRConstants.CONTACT_ACR_STATUS_COMPLETE);
        System.assertNotEquals(null, HSRConstants.ASSET_RT_ASSET);
        System.assertNotEquals(null, HSRConstants.ASSET_RT_SERIALIZED_ASSET);
        System.assertNotEquals(null, HSRConstants.ACR_DEFAULT_ROLES);
        System.assertNotEquals(null, HSRConstants.ASYNC_JOB_IN_PROGRESS_STATUS);
        System.assertNotEquals(null, HSRConstants.ASYNC_JOB_JOB_TYPE_BATCH);
        System.assertNotEquals(null, HSRConstants.ASYNC_JOB_JOB_TYPE_QUEUEABLE);
        System.assertNotEquals(null, HSRConstants.HW_DISPATCH_OUTBOUND_WO_USER_ID);
        System.assertNotEquals(null, HSRConstants.HW_DISPATCH_OUTBOUND_WO_SOURCE_SYSTEM);
        System.assertNotEquals(null, HSRConstants.HW_DISPATCH_OUTBOUND_WO_DEFAULT_SITE_SHORT_NAME);
        System.assertNotEquals(null, HSRConstants.HW_DISPATCH_OUTBOUND_WO_DEFAULT_BRAND);
        System.assertNotEquals(null, HSRConstants.HW_DISPATCH_OUTBOUND_REQUEST_TYPE);
        System.assertNotEquals(null, HSRConstants.HW_DISPATCH_OUTBOUND_DEFAULT_PRIORITY_TYPE);
    }
}