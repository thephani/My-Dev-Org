public class upsertExample {


    public void upsertExample() {
    Opportunity opp = [SELECT Id, Name, AccountId, 
                              (SELECT Id, PricebookEntry.Product2Id, PricebookEntry.Name 
                               FROM OpportunityLineItems)
                       FROM Opportunity 
                       WHERE HasOpportunityLineItem = true 
                       LIMIT 1]; 

    Asset[] assets = new Asset[]{}; 

    // Create an asset for each line item on the opportunity
    for (OpportunityLineItem lineItem:opp.OpportunityLineItems) {

        //This code populates the line item Id, AccountId, and Product2Id for each asset
        Asset asset = new Asset(Name = lineItem.PricebookEntry.Name,
                                Line_Item_ID__c = lineItem.Id,
                                AccountId = opp.AccountId,
                                Product2Id = lineItem.PricebookEntry.Product2Id);

        assets.add(asset);
    }
 
    try {
        upsert assets Line_Item_ID__c;  // This line upserts the assets list with
                                        // the Line_Item_Id__c field specified as the 
                                        // Asset field that should be used for matching
                                        // the record that should be upserted. 
    } catch (DmlException e) {
        System.debug(e.getMessage());
    }
}

}