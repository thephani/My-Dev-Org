public class AcumenBank {    
    public static void main() {
        
        system.debug('Welcome to Acumen Bank!');        
        CheckingAccount michaelsCheckingAccount = new CheckingAccount('Michael', 5000);        
        CheckingAccount gobsAccount = new CheckingAccount('Gob', 2000);        
        system.debug('Open Accounts:');        
        printAccountDetails( michaelsCheckingAccount);        
        michaelsCheckingAccount = new SavingAccount('Michael', 12000);
        printAccountDetails( michaelsCheckingAccount);
        michaelsCheckingAccount.getAccountType();
        michaelsCheckingAccount.withdraw(1000);
                
        printAccountDetails( gobsAccount);        
        
        system.debug('Making transfer of $1000...');
        try {
            // sleep logic
            Integer start = System.Now().millisecond();
            //while(System.Now().millisecond()< start+500){}
        } catch (Exception ex) {
            system.debug('Unable to make transfer');
        }
        
        michaelsCheckingAccount.transfer(gobsAccount, 1000);
        
        system.debug('Updated Account Details:');
        
        printAccountDetails( michaelsCheckingAccount);
        
        printAccountDetails( gobsAccount);
        
        // sample code for savings account implementation
        /*
// Initialize new savings account with initial balance of $30,000 and 0.89% interest
SavingsAccount acesSavingsAccount = new SavingsAccount('Ace', 30000, .0089);

SavingsAccount garysSavingsAccount = new SavingsAccount('Gary', 10000, .0056);

acesSavingsAccount.transfer(garysSavingsAccount, 5000);
// apply 2 years of interest to the savings accounts
acesSavingsAccount.applyInterest(2);
garysSavingsAccount.applyInterest(2);
*/
    }
    
    private static void printAccountDetails(CheckingAccount account) {
        system.debug(  account.getAccountType()+' Account for '+ account.getOwnerName()+ ' has Balance: '+account.getBalance());
    }
}