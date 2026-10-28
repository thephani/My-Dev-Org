public class paginationDataTable_controller {

    public paginationDataTable_controller() {

    }

    public List < ApexPage > getAccounts() {
        //return [SELECT Id, Name, Phone, Industry, OwnerId, Owner.Name FROM Account];
        return [SELECT Name, Id, ApiVersion, MasterLabel, Description, CreatedById, CreatedBy.Name FROM ApexPage];
    }
}