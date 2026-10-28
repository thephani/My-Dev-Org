public class GetAccountContacts {

    private List<Account> accounts { get; set; } 
    
    public List<Account> getAccounts() {
        accounts = [Select Account.Name, Id, (Select Id, AccountId, Name,Title,Phone,Department From Account.Contacts)FROM Account LIMIT 5];
        return accounts;
    }  
    
    public List<Account> getAccConCases(){
        return [select id, Name, (select id, Name from Account.Contacts), (select id, ContactId, CaseNumber from Cases) from account LIMIT 10];
    }                

}