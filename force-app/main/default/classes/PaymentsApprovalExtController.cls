public with sharing class PaymentsApprovalExtController {
	private Id payApprovalId;
	public PaymentsApprovalExtController(ApexPages.StandardController stdController) {
		payApprovalId = stdController.getId();
	}
	public PageReference onSubmit() {
		if (payApprovalId != null) {
			SBAA.ApprovalAPI.submit(payApprovalId, SBAA__Approval__c.qtc_PaymentsApproval__c);
		}
		return new PageReference('/' + payApprovalId);
	}
	public PageReference onRecall() {
		if (payApprovalId != null) {
			SBAA.ApprovalAPI.recall(payApprovalId, SBAA__Approval__c.qtc_PaymentsApproval__c);
		}
		return new PageReference('/' + payApprovalId);
	}

}