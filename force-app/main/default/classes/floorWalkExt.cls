public class floorWalkExt{
    
    public Floor_Walk__c fw {get; set;}
    string id;
    public List<Floor_Walk_Entries__c> fEntries {get; set;}
    
    public floorWalkExt(ApexPages.StandardController sc){
        id = ApexPages.currentPage().getparameters().get('id');
        fw = [SELECT Account_Floor_Walk__c, Account_Manager__c, Comments__c, Id, Average_Score__c , 
              Service_Partner_Manager__c, Status__c, Total_Issues__c, Account_Floor_walk__r.Name,
              Total_Score__c, Walk_Date__c 
              FROM Floor_Walk__c WHERE Id =: id];
        
        fEntries = [SELECT Floor__c, of_Issues__c, Category__c, Score__c, Id, Name
                     FROM Floor_Walk_Entries__c 
                    WHERE Floor_Walk__c =: Id];
    }
    
    public PageReference saveMainRecord(){
        update fw;  
        PageReference pg = new PageReference('/a26/o');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference saveRecords(){
     	update fEntries;  
        PageReference pg = new PageReference('/apex/floorWalk?id='+id);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference deleteRecord(){
        delete fw;  
        PageReference pg = new PageReference('/a26/o');
        pg.setRedirect(true);
        return pg;
    }
    
    
    
    public PageReference cancel(){
    	PageReference pg = new PageReference('/a26/o');
        return pg;
    }

}