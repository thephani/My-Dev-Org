@isTest(SeeAllData=true)
public class myCoolTypeAheadTest {
  static testMethod void testMyCoolTypeAheadCont(){
    myCoolTypeAheadCont ctrl = new myCoolTypeAheadCont();
    List<String> results = myCoolTypeAheadCont.querySuggestions('Account', 'Name', 'united');
    
  }
}