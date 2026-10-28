public class lead_pipeline_controller {

    public List<Lead> getStage1(){
        return [SELECT Id, Name, Email, status FROM Lead WHERE Status = 'Open - Not Contacted'];
    }

    public List<Lead> getStage2(){
        return [SELECT Id, Name, Email, status FROM Lead WHERE Status = 'Working - Contacted'];
    }    
    
    //write more mehtods like above only change is wher status = 'status' 
}