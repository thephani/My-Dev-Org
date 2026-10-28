public class guageController {
    public String acctId {get;set;}

    public guageController (ApexPages.StandardController controller){
        acctId = controller.getRecord().Id;
    }

    public List<gaugeData> getData() {
          Integer TotalOpptys = 0;
          Integer TotalAmount = 0;
          Integer thisMonth = date.Today().month();

          AggregateResult ClosedWonOpptys = [select SUM(Amount) totalRevenue, CALENDAR_MONTH(CloseDate) theMonth, COUNT(Name) numOpps
                                   from Opportunity
                                   where AccountId =: acctId
                                   and StageName = 'Closed Won'
                                   and CALENDAR_MONTH(CloseDate) =: thisMonth
                                   GROUP BY CALENDAR_MONTH(CloseDate) LIMIT 1];

          List<gaugeData> data = new List<gaugeData>();
          data.add(new gaugeData(Integer.valueOf(ClosedWonOpptys.get('numOpps')) + ' Opptys', Integer.valueOf(ClosedWonOpptys.get('totalRevenue'))));
                    return data;
     }

    public class gaugeData {
        public String name { get; set; }
        public Integer size { get; set; }

        public gaugeData(String name, Integer data) {
            this.name = name;
            this.size = data;
        }
    }
}