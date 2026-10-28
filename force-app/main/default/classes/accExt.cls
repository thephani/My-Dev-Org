public class accExt {

    public accExt() {}

    public accExt(ApexPages.StandardController controller) {}
    
    public List<Account> getAccounts(){
        return [SELECT Id, Name, Rating FROM Account];
    }

}