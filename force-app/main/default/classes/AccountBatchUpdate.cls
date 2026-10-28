global class AccountBatchUpdate implements Database.Batchable<SObject> {
    
    // Start method - returns the scope of records to process
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Description FROM Account WHERE Description = null'
        );
    }
    
    // Execute method - processes each batch
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for (Account acc : scope) {
            acc.Description = 'Updated by Batch Apex';
        }
        update scope;
    }
    
    // Finish method - used for post-processing or logging
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Apex Completed');
    }
}