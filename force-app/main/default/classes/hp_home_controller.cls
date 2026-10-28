public class hp_home_controller {
    
    public hp_home_controller(){
    }
    
    public Map<string, string> getDocList(){
        Map<string, string> docMap = new Map<string, string>();
        string urlValue;
        for(HP_Document__c doc: [SELECT Id,Name__c, Content_Delivery_URL__c, Video_Type__c FROM HP_Document__c WHERE Public__c = true and Status__c = 'Approved' AND Type__c = 'Video'and Video_Type__c != null]){
            urlValue = doc.Content_Delivery_URL__c.substringAfter('https://youtu.be/');
            if(docMap.get(doc.Video_Type__c) != null){
                docMap.put(doc.Video_Type__c, docMap.get(doc.Video_Type__c) + ',' + urlValue);
            } else {
                docMap.put(doc.Video_Type__c, urlValue);
            }
        }
        
        //system.debug('final List => '+docMap);
        return docMap;        
    }
}