trigger VenuTaskNewFile2 on ContentVersion (before insert) {
    String standarUserProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'].Id;
    
    // SELECT Id, Title, FROM ContentDocument WHERE CreatedDate = TODAY
    // file name
    
    // get contentDocument Ids from Content Version because this will help for both New document or new version
    Map<string, ContentVersion> cv_map = new Map<string, ContentVersion>();
    for(ContentVersion cv: Trigger.New){
        // A brand-new document has no ContentDocumentId until after insert.
        if (cv.ContentDocumentId != null) {
            cv_map.put(cv.ContentDocumentId, cv);
        }
    }
    
    // get account id from given contentdocumentIds
    Map<string, ContentVersion> acc_cdl_map = new Map<String, ContentVersion>();
    if (!cv_map.isEmpty()) {
    for(ContentDocumentLink cdl: [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: cv_map.keySet()]){
        string tempId = cdl.LinkedEntityId;
        if(tempId.startsWith('001')){
            acc_cdl_map.put(cdl.LinkedEntityId, cv_map.get(cdl.ContentDocumentId));         
        }
    }
    
    }

    system.debug('ADDED accounts '+acc_cdl_map.keySet());
    
    // check account owner and profile
    Map<Id, Account> acc_user_map = new Map<Id, Account>();
    for(Account acc: [SELECT Id, Name, OwnerId, Owner.Email, Owner.Name FROM Account WHERE Id IN:acc_cdl_map.keySet() AND Owner.ProfileId =: standarUserProfileId]){
        // no need to check whether owner is user or not because queues doesnt have profile that will be filtered above
        acc_user_map.put(acc.Id, acc);
    }
    
    for(Account acc: acc_user_map.values()){
        string userName = acc.Owner.Name;
        string userId = acc.OwnerId;
        string userEmail = acc.Owner.Email;
        
        string fileName = acc_cdl_map.get(acc.Id).Title;
        string link = 'salesforce base url/'+acc_cdl_map.get(acc.Id).Id;
        system.debug('I will fire an email now');
        system.debug('====with following info=======');
        system.debug('Name: '+username+ ' UserId: '+userId+' Username: '+userEmail+' FileName:  '+fileName+' Link: '+link);
    }
    
    
}
