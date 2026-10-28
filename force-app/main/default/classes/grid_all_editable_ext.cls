public class grid_all_editable_ext {

    public List<student__c> student_list {get; set;}

    public grid_all_editable_ext(ApexPages.StandardController controller) {
        student_list = [SELECT Id, Name, OwnerId, First_Name__c, Last_Name__c, Mobile__c, Email__c, Date_of_Joining__c, Occupation__c FROM Student__c LIMIT 1];
    }
    
   
    
    public void addNew(){
        student_list.add(new Student__c());
    }

}