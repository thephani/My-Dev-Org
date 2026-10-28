global class batchClass implements Database.Batchable<sObject>
{
    
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        for ( Account a : scope)
        {
            a.Phone='123';
        }
        update scope;
    }  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name,Phone FROM Account ';
        return Database.getQueryLocator(query);
    }
    
    
}