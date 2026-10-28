public virtual class CheckingAccount {
    private String ownerName;
    private double balance;
    public String accountType;
    
    public CheckingAccount(String ownerName, double balance) {
        this.accountType = 'Checking';
        this.ownerName = ownerName;
        this.balance = balance;
    }
    
    public void transfer(CheckingAccount destinationAccount, double amount) {
        if(balance >= amount){
            destinationAccount.deposit(amount); // deposit
            balance -= amount;// debit
        } else {
            system.debug('Not Sufficient Funds in Checking Account');
        }
    }
    
    public void debit(double amount){
        if (amount < 0) {
            system.debug('Amount Should be .');
        }
    }
    
    public void deposit(double amount) {
        if (amount < 0) {
            system.debug('Cannot deposit a negative amount');
            //throw new IllegalArgumentException("Cannot deposit a negative amount");
        }
        this.balance += amount;
    }
    
    public virtual void withdraw(double amount) {
        if (amount < 0) {
            system.debug('Cannot withdraw a negative amount');
            //throw new IllegalArgumentException("Cannot withdraw a negative amount");
        }
        this.balance -= amount;
    }
    
    public String getOwnerName() {
        return this.ownerName;
    }
    
    public double getBalance() {
        return this.balance;
    }
    
    public virtual string getaccountType(){
        return this.accountType;
    }
}