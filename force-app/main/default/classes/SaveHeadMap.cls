public class SaveHeadMap {
    
    public string strImageBlob {get;set;}
    
    Public SaveHeadMap(ApexPages.StandardController controller){
     	System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    
    /*
    Public SaveHeadMap(){
        
    }*/
    
    Public PageReference SaveHirarchyImage(){ 
       
        try{
            if(ApexPages.currentPage().getParameters().get('id') != '' && ApexPages.currentPage().getParameters().get('id') != null){
            system.debug('Before Query');
            List<Attachment> AttachList = [Select id,name from Attachment where ParentId = :ApexPages.currentPage().getParameters().get('id') and Name  like '%HeatMap%'];
            system.debug('Aftre Query'+AttachList);   
            if(AttachList.size()>0){
                    delete AttachList;  
            }   
                
            
                
            Attachment myAttachment  = new Attachment();
            system.debug('<><><><><>'+strImageBlob.replaceFirst('data:image/png;base64,',''));
            myAttachment.Body = EncodingUtil.base64Decode(strImageBlob.replaceFirst('data:image/png;base64,',''));
            myAttachment.Name = 'HeatMap';
            myAttachment.ParentId = ApexPages.currentPage().getParameters().get('id');
            myAttachment.contentType = 'Executive_Briefing.png';    
            system.debug('myAttachment'+myAttachment); 
            insert myAttachment;
            }    
            system.debug('Redirect to another page'); 
            
           
        }       
        
        catch(Exception e){
            system.debug('<><><><><><>'+e);
        }

        //return new PageReference('/apex/ExecutiveBriefingPDFNew?id='+ ApexPages.currentPage().getParameters().get('id')) ; 
        PageReference pageRef = new PageReference('/apex/ExecutiveBriefingPDFNew?id='+ApexPages.currentPage().getParameters().get('id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
}