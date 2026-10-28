public class DynamicPage {
   public DynamicPage(ApexPages.StandardController controller) {}
   public Account acc {get;set;}
     
   public List < String > threeFieldList {
      get {
         if (threeFieldList == null) {
            threeFieldList = new List < String > ();
            threeFieldList.add('Industry');
            threeFieldList.add('AnnualRevenue');
            threeFieldList.add('BillingCity');
         }
         return threeFieldList;
      }
      private set;
   }
}