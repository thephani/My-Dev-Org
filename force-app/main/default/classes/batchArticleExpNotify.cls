global class batchArticleExpNotify implements Database.Batchable < sObject > {

    global string query;

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT ArticleNumber,ArticleType,CreatedBy.email,KnowledgeArticleId,Title,UrlName FROM KnowledgeArticleVersion where PublishStatus = \'Online\' and Language = \'en_US\'';
        system.debug('Test1');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List < sObject > articles) {
        system.debug('Test2');
        Map < String, KnowledgeArticleVersion > knowledgearticleversiondata = new Map < String, KnowledgeArticleVersion > ();
        Map < String, List < Sobject >> knowledgearticlemap = new Map < String, List < Sobject >> ();
        Set < String > articletype = new Set < String > ();
        Map < string, Set < String >> articletypetoarticles = new Map < string, Set < String >> ();
        List < Messaging.SingleEmailMessage > emailmessages = new List < Messaging.SingleEmailMessage > ();

        for (Sobject obj: database.query(query)) {

            KnowledgeArticleVersion kav = (KnowledgeArticleVersion) obj;
            String s = kav.ArticleType;
            String artnumber = kav.Articlenumber;
            articletype.add(s);
            knowledgearticleversiondata.put(artnumber, kav);

            if (articletypetoarticles.containsKey(s)) {
                Set < String > existingids = articletypetoarticles.get(s);
                existingids.add(artnumber);
                articletypetoarticles.put(s, existingids);
            } else {
                Set < String > articleIds = new Set < String > ();
                articleIds.add((String) kav.get('ArticleNumber'));
                articletypetoarticles.put(s, articleIds);
            }
        }
        
        system.debug('@@@'+knowledgearticleversiondata.keyset());
        system.debug('@@@'+articletypetoarticles.keyset());        

        List < String > temparticletypes = new List < String > ();
        Map < String, Knowledgearticleversion > validrecordsForUpdate = new Map < String, Knowledgearticleversion > ();
        temparticletypes.addAll(articletype);
        for (String s: temparticletypes) { // this block will execute only number of articletypes times
            Date dt = Date.today();
            Set < String > ids = articletypetoarticles.get(s);
            System.debug('the value of ids' + ids);
            string idstring = '(';
            for (String idv: ids) {
                idstring = idstring + ',' + '\'' + idv + '\'';
            }
            idstring = idstring.replace('(,', '(');
            idstring = idstring + ')';
            String query1 = 'Select Id,ArticleNumber,Expiration_Date__c, Data_Source_Link__c from ' + s + ' where ArticleNumber IN ' + idstring + ' and PublishStatus = \'online\' and Language = \'en_US\' and Expiration_Date__c <=' + dt.year() + '-' + ((dt.month() < 10) ? '0' + dt.month() : dt.month() + '') + '-' + ((dt.day() < 10) ? '0' + dt.day() : dt.day() + '');

            knowledgearticlemap.put(s, (List < Sobject > ) database.query(query1));

        }
        Messaging.SingleEmailMessage mail;
        try {
            for (String s: knowledgearticlemap.keySet()) {
                for (Sobject sob: (List < Sobject > ) knowledgearticlemap.get(s)) {
                    String mailbody = '<html><body>Dear Employee,<br><br>Article:{title} has expired as of {expiration} <br><br>As a result, the article has been moved to the “drafts” folder.  You can either re-publish the article and create a new expiration date, or you will need to make any necessary updates to the article within the SharePoint site.  The article can be accessed directly using the URL below:<br>{Link} <br><br>Thanks for your support!';
                    KnowledgeArticleVersion kavrec = knowledgearticleversiondata.get((string) sob.get('ArticleNumber'));
                    String artid = kavrec.KnowledgeArticleId;
                    KbManagement.PublishingService.editOnlineArticle(artid, false);
                    validrecordsForUpdate.put((string) sob.get('ArticleNumber'), kavrec);
                    mail = new Messaging.SingleEmailMessage();
                    mail.setUseSignature(false);
                    mail.setToAddresses(new String[] {
                        knowledgearticleversiondata.get((string) sob.get('ArticleNumber')).createdBy.email
                    });
                    mail.setSubject('Article: ' + knowledgearticleversiondata.get((string) sob.get('ArticleNumber')).Title + ' is expired');
                    String title = knowledgearticleversiondata.get((string) sob.get('ArticleNumber')).Title;
                    String datasourceurl = String.valueOf(sob.get('Data_Source_Link__c'));
                    String expirationdate = String.valueOf(sob.get('Expiration_Date__c'));
                    mailbody = mailbody.replace('{title}', title);
                    mailbody = mailbody.replace('{Link}', datasourceurl);
                    mailbody = mailbody.replace('{expiration}', expirationdate);
                    mail.setHtmlBody(mailbody);
                    emailmessages.add(mail);
                }
                List < Messaging.SendEmailResult > results = Messaging.sendEmail(emailmessages);
            }
        } catch (Exception ex) {
            //ExceptionUtility.logException('batchArticleExpNotify', null, ex.getMessage() + ' ::: ' + ex.getStackTraceString());
            system.debug('Error: '+ex);
        }
    }
    global void finish(Database.BatchableContext BC) {

    }

}