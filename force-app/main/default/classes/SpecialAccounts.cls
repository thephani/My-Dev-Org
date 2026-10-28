global class SpecialAccounts {

  global class AccountInfo {
     webService String AcctName;
     webService Integer AcctNumber;
  }

  webService static Account createAccount(AccountInfo info) {
    Account acct = new Account();
    acct.Name = info.AcctName;
    acct.AccountNumber = String.valueOf(info.AcctNumber);
    insert acct;
    return acct;
  }

  testMethod static void testAccountCreate() {
    AccountInfo info = new AccountInfo();
    info.AcctName = 'Manoj Cheenath';
    info.AcctNumber = 12345;
    Account acct = SpecialAccounts.createAccount(info);
    System.assert(acct != null);
  }
}