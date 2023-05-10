public class PartnerAccountInlineAttachmentController 
{
	public List<NoteAndAttachmentDetail> lstNoteAndAttachmentDetail {get;set;}
	
    public PartnerAccountInlineAttachmentController(ApexPages.StandardController stdController) 
    {
    	lstNoteAndAttachmentDetail = new List<NoteAndAttachmentDetail>();
       	List<Attachment> lstAttachment = [Select Id, Name, CreatedDate, CreatedBy.Name from Attachment where ParentId =: stdController.getId()];
       
       	for(Attachment objAttachment : lstAttachment)
       	{
       		lstNoteAndAttachmentDetail.add(new NoteAndAttachmentDetail(objAttachment.Id, objAttachment.Name, objAttachment.CreatedDate,	
       																	objAttachment.CreatedBy.Name, 'Attachment'));
       	}
       	
       	List<Note> lstNote = [Select Id, Title, CreatedDate, CreatedBy.Name from Note where ParentId =: stdController.getId()];
       
       	for(Note objNote : lstNote)
       	{
       		lstNoteAndAttachmentDetail.add(new NoteAndAttachmentDetail(objNote.Id, objNote.Title, objNote.CreatedDate,	
       																	objNote.CreatedBy.Name, 'Note'));
       	}
    }
    
    @AuraEnabled
    public static List<NoteAndAttachmentDetail> getPartnerAccountAttachment(String accId) 
    {
        System.debug('=======================accId==========='+accId);
    	List<NoteAndAttachmentDetail> lstNoteAndAttachmentDetail = new List<NoteAndAttachmentDetail>();
       	List<Attachment> lstAttachment = [Select Id, Name, CreatedDate, CreatedBy.Name from Attachment where ParentId =: accId];
       
       	for(Attachment objAttachment : lstAttachment)
       	{
       		lstNoteAndAttachmentDetail.add(new NoteAndAttachmentDetail(objAttachment.Id, objAttachment.Name, objAttachment.CreatedDate,	
       																	objAttachment.CreatedBy.Name, 'Attachment'));
       	}
       	
        System.debug('=======================lstNoteAndAttachmentDetail==========='+lstNoteAndAttachmentDetail);
       	/*List<Note> lstNote = [Select Id, Title, CreatedDate, CreatedBy.Name from Note where ParentId =: accId];
       
       	for(Note objNote : lstNote)
       	{
       		lstNoteAndAttachmentDetail.add(new NoteAndAttachmentDetail(objNote.Id, objNote.Title, objNote.CreatedDate,	
       																	objNote.CreatedBy.Name, 'Note'));
       	}*/       	
       	return lstNoteAndAttachmentDetail;
    }
    
    
    
    public class NoteAndAttachmentDetail
    {
    	@AuraEnabled
    	public Id recordId {get;set;}
    	
    	@AuraEnabled
    	public String name {get;set;}
    	
    	@AuraEnabled
    	public Datetime createdDateTime {get;set;}
    	
    	@AuraEnabled
    	public String createdByName {get;set;}
    	
    	@AuraEnabled
    	public String valueType {get;set;}
    	
    	public NoteAndAttachmentDetail(Id recordId, String Name, Datetime createdDateTime, String createdByName, String valueType)
    	{
    		this.recordId = recordId;
    		this.name = name;
    		this.createdDateTime = createdDateTime;
    		this.createdByName = createdByName;
    		this.valueType = valueType;
    	}
    }
}