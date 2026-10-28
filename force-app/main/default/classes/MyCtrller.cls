public class MyCtrller {
    public List<String> listOfAddresses {get; set;}

    public MyCtrller() {
       listOfAddresses = new List<String>();
       listOfAddresses.add('2001 Gemini St, Houston, TX');
       listOfAddresses.add('210 E Huron St, Ann Arbor');
       listOfAddresses.add('45th Park Ave, New York');
    }
  }