public class NewPurchase_Ext {

    public Opportunity opp {get; set;}
    @TestVisible
    public List < oppLineItem_Wrapper > prodList1 {get; set;}
    public Id pb2Id {get; set;}   
    public List<SelectOption> pbOptions {get; set;}
        
    Account acc; Id accId;

    public NewPurchase_Ext(ApexPages.StandardController sc) {

        pbOptions = new List<SelectOption>();
        prodList1 = new List<oppLineItem_Wrapper>();

        for(Pricebook2 pbe: [SELECT Id, Name, IsActive FROM Pricebook2 where IsActive = true]){
            pbOptions.add(new SelectOption(pbe.Id, pbe.Name));
        }    
        accId = sc.getId(); 

    }
    
    public void getProds(){
        prodList1.clear();
        for (PricebookEntry pbe: [SELECT Id, Name, Pricebook2Id, Product2Id, ProductCode, UnitPrice, IsActive FROM PricebookEntry where Pricebook2id = :pb2Id AND IsActive = TRUE]) {
            prodList1.add(new oppLineItem_Wrapper( pbe.Id, pbe.ProductCode, 0,pbe.UnitPrice));
        }                
       
    }

    public PageReference saveRecord() {
    
        acc = [SELECT Id, Name FROM Account WHERE Id = : accId];
        opp = new Opportunity();
        //opp.RecordTypeId = '01228000000HHjj'; // Simple RecordTypeId passed
        opp.Name = acc.Name + ' - Opp';
        opp.CloseDate = system.today();
        opp.StageName = 'Processing';
        //opp.ForecastCategoryName = 'Commit';
        opp.AccountId = accId;
        
        List < OpportunityLineItem > insert_list = new List < OpportunityLineItem > ();        
        insert opp;
        
        for(oppLineItem_Wrapper item: prodList1){
            if(item.QUantity > 0 ){
               insert_list.add(new OpportunityLineItem(OpportunityId = opp.Id, priceBookEntryId = item.PriceBookEntryId, Quantity = item.Quantity, UnitPrice = item.Price));
            }
        }      

        if (insert_list.size() > 0) {
            insert insert_list;
        }        
        return new PageReference('/' + opp.Id);
    }
     
    @TestVisible
    public class oppLineItem_Wrapper{
        public Id PriceBookEntryId {get; set;}
        public string productCode {get; set;}
        public Integer Quantity {get; set;}
        public Decimal Price {get; set;}
        
        public oppLineItem_Wrapper(Id PriceBookEntryId, string productCode, Integer Quantity, Decimal Price){
            this.PriceBookEntryId = PriceBookEntryId;
            this.productCode = productCode;
            this.Quantity = Quantity;
            this.Price = Price;
        }
    }
}