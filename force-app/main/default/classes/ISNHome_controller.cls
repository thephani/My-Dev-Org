public class ISNHome_controller {
    
    // maintains lable and list of sidebar
    public Map<String, Map<String, String>> sidebarLinksMap {get; set;}
    
    public ISNHome_controller(){
        sidebarLinksMap = new Map<String, Map<String, String>> ();
        Map<String, String> tempMap = new Map<String, String>();
        String category, prevCategory;
        /*for(SideSearch_Link__mdt item: [SELECT Category__c, Label, Url__c FROM SideSearch_Link__mdt ORDER BY Category__c]){
            category = item.Category__c;   
            //system.debug('cat => '+category);
            //system.debug('prev cat => '+prevCategory);
            if(category != prevCategory && prevCategory != null){        
                sidebarLinksMap.put(prevCategory, tempMap);
                //system.debug('category changed, temp map =>'+tempMap );
                tempMap = new Map<String, String>();
            }
            tempMap.put(item.Label, item.Url__c);
            prevCategory = category;
        }
        
        sidebarLinksMap.put(prevCategory, tempMap);        */
        //system.debug(sidebarLinksMap);
        
    }
    
}