public class SavingAccount extends CheckingAccount{
    
    public SavingAccount(string owner, Double balance){        
        super(owner, balance);        
    }
    
    public override void withdraw(double amount) {
    	system.debug('Cannot Withdraw money in CheckingAccount');
    }
    
    public override string getaccountType(){
        return 'Saving';
    }

}