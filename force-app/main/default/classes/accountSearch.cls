public class accountSearch {

    public String SearchTerm4 { get; set; }

    public String SearchTerm3 { get; set; }

    public String SearchTerm2 { get; set; }

    List<Account> accounts { get; set; }
    private String Soql { get; set; }   
    public String searchTerm { get; set; }

    private accountSearch(){
    }
    
    public Void Search() {  
         Soql = 'SELECT Name,Phone FROM Account WHERE Name like \'' + searchTerm + '%\'';   
         system.debug('Phani'+searchTerm);                   
    }
    
    public List<Account> getAccounts() {
        try{        
            accounts = Database.query(Soql);
            return accounts;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please Enter Search Terms' ));
            return null;           
        }    
    }

}