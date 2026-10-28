@IsTest
private class TriggerLifecycleTest {
    @IsTest
    static void accountFilesKeepLinksAcrossVersions() {
        Account account = new Account(Name = 'File lifecycle account');
        insert account;
        ContentVersion first = new ContentVersion(Title = 'Coverage document',
            PathOnClient = 'coverage.txt', VersionData = Blob.valueOf('First version'),
            FirstPublishLocationId = account.Id);
        Test.startTest();
        insert first;
        first = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :first.Id];
        ContentVersion second = new ContentVersion(Title = 'Coverage document revised',
            PathOnClient = 'coverage.txt', VersionData = Blob.valueOf('Second version'),
            ContentDocumentId = first.ContentDocumentId);
        insert second;
        Test.stopTest();
        ContentVersion saved = [SELECT IsLatest, VersionNumber, ContentDocumentId FROM ContentVersion WHERE Id = :second.Id];
        System.assertEquals(true, saved.IsLatest);
        System.assertEquals('2', saved.VersionNumber);
        System.assertEquals(first.ContentDocumentId, saved.ContentDocumentId);
        System.assertEquals(1, [SELECT count() FROM ContentDocumentLink
            WHERE ContentDocumentId = :first.ContentDocumentId AND LinkedEntityId = :account.Id],
            'Adding a version must preserve the original account link');
    }

    @IsTest
    static void eventsKeepTheirContactAssociations() {
        Contact contact = new Contact(LastName = 'Activity coverage contact');
        insert contact;
        Datetime starts = System.now().addDays(1);
        List<Event> events = new List<Event>{
            new Event(Subject = 'Contact meeting', WhoId = contact.Id, StartDateTime = starts, EndDateTime = starts.addHours(1)),
            new Event(Subject = 'Unrelated meeting', StartDateTime = starts, EndDateTime = starts.addHours(1))
        };
        Test.startTest();
        insert events;
        Test.stopTest();
        System.assertEquals(contact.Id, [SELECT WhoId FROM Event WHERE Id = :events[0].Id].WhoId);
        System.assertEquals(null, [SELECT WhoId FROM Event WHERE Id = :events[1].Id].WhoId);
        System.assertEquals('Activity coverage contact', [SELECT LastName FROM Contact WHERE Id = :contact.Id].LastName);
    }

    @IsTest
    static void candidateChangesArePreserved() {
        Candidate__c candidate = new Candidate__c(City__c = 'Seattle');
        Test.startTest();
        insert candidate;
        candidate.City__c = 'Portland';
        update candidate;
        Test.stopTest();
        System.assertEquals('Portland', [SELECT City__c FROM Candidate__c WHERE Id = :candidate.Id].City__c);
    }

    @IsTest
    static void positionsSupportTheFullRecordLifecycle() {
        Position__c position = new Position__c(Name = 'Coverage role');
        Test.startTest();
        insert position;
        position.Name = 'Updated coverage role';
        update position;
        delete position;
        System.assertEquals(true, [SELECT IsDeleted FROM Position__c WHERE Id = :position.Id ALL ROWS].IsDeleted);
        undelete position;
        Test.stopTest();
        System.assertEquals('Updated coverage role', [SELECT Name FROM Position__c WHERE Id = :position.Id].Name);
    }

    @IsTest
    static void lineItemChangesRefreshTheOpportunityProductList() {
        Account account = new Account(Name = 'Product coverage account');
        insert account;
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);
        Product2 product = new Product2(Name = 'Coverage racket', ProductCode = 'COV-RACKET', IsActive = true);
        insert product;
        PricebookEntry price = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id,
                                                  UnitPrice = 25, IsActive = true);
        insert price;
        String stage = [SELECT MasterLabel FROM OpportunityStage WHERE IsActive = true AND IsClosed = false ORDER BY SortOrder LIMIT 1].MasterLabel;
        Opportunity opportunity = new Opportunity(Name = 'Product coverage sale', AccountId = account.Id,
            StageName = stage, CloseDate = Date.today().addDays(30), Pricebook2Id = pricebookId);
        insert opportunity;
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId = opportunity.Id,
            PricebookEntryId = price.Id, Quantity = 2, UnitPrice = 25);
        Test.startTest();
        insert item;
        System.assertEquals('Coverage racket,', [SELECT Latest_Added_Product__c FROM Opportunity WHERE Id = :opportunity.Id].Latest_Added_Product__c);
        item.Quantity = 3;
        update new OpportunityLineItem(Id = item.Id, Quantity = 3);
        Test.stopTest();
        Opportunity saved = [SELECT Latest_Added_Product__c, Amount FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Coverage racket,', saved.Latest_Added_Product__c, 'Updating quantity must retain a single product name');
        System.assertEquals(75, saved.Amount);
    }
}
