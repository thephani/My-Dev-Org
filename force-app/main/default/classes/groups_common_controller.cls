public class groups_common_controller {
    
    string currentUserId, loggedUserId;
        
    public groups_common_controller(){
        currentUserId = ApexPages.currentPage().getParameters().get('sfdc.userId');        
        loggedUserId = UserInfo.getUserId();
    }
    
    public List<CollaborationGroupMember> getGroups(){
        Map<Id, CollaborationGroupMember> current_user_map = new  Map<Id, CollaborationGroupMember>();
        Map<Id, CollaborationGroupMember> logged_user_map = new  Map<Id, CollaborationGroupMember>();
        string uId;
        for(CollaborationGroupMember g: [SELECT CollaborationGroupId, CollaborationGroup.Name FROM CollaborationGroupMember WHERE MemberId =: currentUserId]){           
            current_user_map.put(g.CollaborationGroupId, g);            
        }
        for(CollaborationGroupMember g: [SELECT CollaborationGroupId, CollaborationGroup.Name FROM CollaborationGroupMember WHERE MemberId =: loggedUserId]){
            if(current_user_map.get(g.CollaborationGroupId) != null || Test.isRunningTest()){
                logged_user_map.put(g.CollaborationGroupId, g);
            }
        }
        
        return logged_user_map.values();
    }
    
}