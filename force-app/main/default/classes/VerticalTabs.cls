public class VerticalTabs {
    
    @AuraEnabled(cacheable=true)
    public static SObject[] getSections(string name, string recordId){
        sObject[] returnList = new List<sObject>();
        string queryStart = 'SELECT Id';
        string objName = '', fields = '';
        thephani__Vertical_Tab__mdt metaResults = [SELECT Label, DeveloperName,thephani__Mode__c, thephani__sObject__c, (SELECT thephani__Fields__c, Label, thephani__isChild__c, thephani__Child_Relationship_Name__c FROM thephani__Vertical_Tab_Sections__r ORDER BY thephani__isChild__c ASC) FROM thephani__Vertical_Tab__mdt WHERE DeveloperName =:name];
        returnList.add(metaResults);
        //for(thephani__Vertical_Tab__mdt tab: (thephani__Vertical_Tab__mdt) metaResults){
        objName = metaResults.thephani__sObject__c;
        for(thephani__Vertical_Tab_Section__mdt section: metaResults.thephani__Vertical_Tab_Sections__r){
            if(section.thephani__isChild__c){
                fields += ', (SELECT Id, '+section.thephani__Fields__c+' FROM '+section.thephani__Child_Relationship_Name__c+') ';
            } else {
                fields += ', '+section.thephani__Fields__c;
            }
        }
        //}
        string queryEnd = 'FROM '+objName+' WHERE Id =: recordId';
        
        string finalQuery = queryStart + fields + queryEnd;
        system.debug(finalQuery);
        returnList.add( Database.query(finalQuery));
        return returnList;
        
    }
    
}