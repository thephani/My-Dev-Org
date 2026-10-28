public class contactExtension {
    private final Contact c; //User sobject

    //initializes the private member variable u by     using the getRecord method from the standard controller
    public contactExtension(ApexPages.StandardController stdController) {
        this.c = (Contact) stdController.getRecord();
    }

    //builds a picklist of account names based on their account id
    public List < selectOption > getaccts() {
        List < selectOption > options = new List < selectOption > ();
        //new list for holding all of the picklist options
        options.add(new selectOption('', '- None -'));
        //add the first option of '- None -' in case the user doesn't        want to select a value or in        case no values are        returned from query below
        string st = '                         Test';
        for (Account account: [SELECT Id, Name FROM Account]) {
            //query for Account records 
            options.add(new selectOption(account.id, account.Name));
            //for all records found - add them to the picklist options
        }
        return options; //return the picklist options
    }
}