public class MailUtilities {
	
	public static Boolean isValidEmailAddress(String emailAddress){
        if(emailAddress != null && emailAddress.trim() != null && emailAddress.trim().length() > 0){
            String[] split = emailAddress.split('@');
            if(split != null && split.size() == 2){
	            split = split[1].split('\\.');
	            if(split != null && split.size() >= 2){
	                return true;
	            }
            }
        }
        return false;
    }	
	
	public static void sendEmailWithStandardAttachments(List<String> recipients,String emailSubject,String body,Boolean useHTML,List<Id> attachmentIDs) {
        List<Attachment> stdAttachments = [SELECT id, name, body FROM Attachment WHERE Id IN:attachmentIDs];
        sendEmailWithStandardAttachments(recipients, emailSubject, body, useHTML, stdAttachments);
    }
    
    public static void sendEmailWithStandardAttachments(List<String> recipients,String emailSubject,String body,Boolean useHTML,List<Attachment> stdAttachments) {
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        
        for(Attachment attachment : stdAttachments) {
            Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
            fileAttachment.setFileName(attachment.Name);
            fileAttachment.setBody(attachment.Body);
            fileAttachments.add(fileAttachment);
        }
        sendMail(recipients, emailSubject, body, useHTML, fileAttachments);
    }
     
    public static void sendTextEmail(List<String> recipients,String emailSubject,String textBody) { 
        sendMail(recipients, emailSubject, textBody, false, null);
    }
    
    public static void sendHTMLEmail(List<String> recipients,String emailSubject,String htmlBody) { 
        sendMail(recipients, emailSubject, htmlBody, true, null);
    }
	
	private static void sendMail(List<String> recipients,String emailSubject,String body,Boolean useHTML,List<Messaging.EmailFileAttachment> fileAttachments) {
		
		if(recipients == null) return;
        if(recipients.size() == 0) return;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();             
        mail.setSaveAsActivity(false);
        mail.setToAddresses(recipients);
        mail.setSubject(emailSubject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        if (useHTML) {
            mail.setHtmlBody(body);
        } else {
            mail.setPlainTextBody(body);
        }
        // Specify FileAttachments
        if(fileAttachments != null && fileAttachments.size() > 0) {
            mail.setFileAttachments(fileAttachments);
        }
        // Sends mail here
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		
	}	
}