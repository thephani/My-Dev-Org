public class importDataFromCSVController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<account> acclist{get;set;}
    public importDataFromCSVController(){
        csvFileLines = new String[]{};
            acclist = New List<Account>(); 
    }
    
    public void importCSVFile(){
        try{
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            for(Integer i=1;i<csvFileLines.size();i++){
                Account accObj = new Account() ;
                string[] csvRecordData = csvFileLines[i].split(',');
                accObj.name = csvRecordData[0] ;             
                accObj.accountnumber = csvRecordData[1];
                accObj.Type = csvRecordData[2];
                accObj.AccountSource = csvRecordData[3];   
                accObj.Industry = csvRecordData[4];                                                                             
                acclist.add(accObj);   
            }
            //insert acclist;
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
    }
}