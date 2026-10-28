public class guage_chart_controller {

    public List<gaugeData> getData() {
       List<gaugeData> data = new List<gaugeData>();
          data.add(new gaugeData('Test', 15000));
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