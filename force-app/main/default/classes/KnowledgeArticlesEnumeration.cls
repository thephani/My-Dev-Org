global class KnowledgeArticlesEnumeration implements Schedulable, database.Batchable < sobject > {
    
    List<Rebate__kav> rebateExpiredList = new List<Rebate__kav>();  
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
                
        system.debug('in query locator');
        
        // Gets all Rebate(Knowledge article Type Name)
                
        return Database.getQueryLocator([SELECT Title, Summary, OwnerId,Expiration_Date__c FROM Rebate__kav WHERE PublishStatus = 'Online' 
        AND Language = 'en_US' AND LastPublishedDate = LAST_N_DAYS: 180]);
        
    }
    
    global void execute(SchedulableContext sc) {
        
        // this is responsible for scheduling Apex Class
        
        KnowledgeArticlesEnumeration obj = new KnowledgeArticlesEnumeration();
        database.executebatch(obj, 200);
    }
    
    global void execute(Database.BatchableContext BC, List < sObject > articles) {
        
        // this calls enumerate Articles methods where it checks it condition
        enumerateArticles(articles);
    }
    
    global void finish(Database.BatchableContext BC) {      
        system.debug('Batch Load has been Successfully Finished');
    }

    // This method is responsible for checking conditions of 10 days and 2 days 
    
    public void enumerateArticles(List<sObject> articleList){  
              
        List<string> recipients = new List<string>();
        string emailSubject,htmlBody='<h2>Please respond to this</h2><br/><br/>';           
        
        recipients.add('phani.cse29@gmail.com');
        recipients.add('tkolla@gmail.com');       
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();             
        mail.setSaveAsActivity(false);
        mail.setToAddresses(recipients);
        mail.setBccSender(false);               
        
        for (Rebate__kav ka: (List < Rebate__kav > ) articleList) {
             
            Integer days = Date.today().daysBetween(ka.Expiration_Date__c);                             
            if(days == 10){  
                emailSubject = 'Knowledge Article Expiration Date - 10 Days';  // Setting Subject for email            
                htmlBody += URL.getSalesforceBaseUrl().toExternalForm()+'/'+ka.Id;    // adding article detail link to email body
                mail.setSubject(emailSubject);        
                mail.setHtmlBody(htmlBody);       
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     
            } else if(days == 2){
                emailSubject = 'Knowledge Article Expiration Date - 2 Days'; // Setting Subject for email
                htmlBody += URL.getSalesforceBaseUrl().toExternalForm()+'/'+ka.Id;  // adding article detail link to email body
                mail.setSubject(emailSubject);        
                mail.setHtmlBody(htmlBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }            
        }
    }
}