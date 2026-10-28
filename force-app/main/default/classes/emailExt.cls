public class emailExt{

    /*
    
    Email Status codes
    0 - New 
    1 - Read
    2 - Replied
    3 - Sent
    4 - Forwarded
    5 - Draft
    
    */
    
    public String shower {get; set;}
    public string searchTerm {get; set;}
    public List<EmailMessage> emails {get; set;}
    public Id caseId;
    public Map<Id, string> mailMsgs = new Map<Id, string>();
    public List<Id> sRetIds = new List<Id>();
    
    public emailExt(ApexPages.StandardController sc){
        searchTerm = '';
        shower = 'All Emails';    
        caseId = ApexPages.currentPage().getParameters().get('Id');
        //caseId = '500F000000M8AOJ';
        //emails.clear();
        emails = [SELECT Id, ParentId, ActivityId, TextBody, HtmlBody, Subject, Incoming, Status, MessageDate                 
                FROM EmailMessage where ParentId = :caseId ORDER By CreatedDate DESC];
        for(EmailMEssage m: emails)
            mailMsgs.put(m.Id, m.TextBody);
    }
    
    public void search(){
        emails.clear();
        sRetIds.clear();
        for(Id i: mailMsgs.KeySet()){
            string body = mailMsgs.get(i);
            body = body.toLowerCase();            
            if(body.contains(searchTerm.toLowerCase())){
                sRetIds.add(i);
            }
        }
        
        emails = [SELECT Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, 
                ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, 
                ReplyToEmailMessageId 
                FROM EmailMessage where ParentId =: caseId AND Id IN :sRetIds ORDER By CreatedDate DESC];
                
                shower = 'Search Mails';
        
        system.debug('sizeeeee: '+emails.size());
                //searchTerm = null;
    }
    
    public PageReference reset(){
        emails.clear();
        emails = [SELECT Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, 
                ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, 
                ReplyToEmailMessageId 
                FROM EmailMessage where ParentId = :caseId ORDER By CreatedDate DESC];
        shower = 'All Emails';
        searchTerm = '';
        return new PageReference('/apex/emailPage');
    }
    
    public void sMails(){
        emails.clear();
        emails = [SELECT Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, 
                ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, 
                ReplyToEmailMessageId 
                FROM EmailMessage where ParentId = :caseId AND Incoming = false ORDER By CreatedDate DESC];
        shower = 'Sent Emails';
    }
    
    public void rMails(){
        emails.clear();
        emails = [SELECT Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, 
                ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, 
                ReplyToEmailMessageId 
                FROM EmailMessage where ParentId = :caseId AND Incoming = true ORDER By CreatedDate DESC];
        shower = 'Received Emails';
    }

}