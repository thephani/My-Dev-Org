public class email_Ext {

    public email_Ext(ApexPages.StandardController controller) {

    }
    public List<EmailMessage> getEmails(){
        return [SELECT Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, 
                ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, 
                ReplyToEmailMessageId 
                FROM EmailMessage where ParentId = '50090000002jc2GAAQ' ORDER By CreatedDate DESC];
    }

}