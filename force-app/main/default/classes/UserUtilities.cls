public class UserUtilities {
    
    User user;  
    
    // return upto 5 level hierarchy Managers for User   
        
    public static userDetails getUser(String userId){
        List<Id> singleUser = new List<Id>();
        singleUser.add(userId);      
        return getUserList(singleUser)[0];          
    }        
    
    public static List<userDetails> getUserList(List<Id> userIdList){
    	
    	List <User> users = new List<User>();
    	userDetails uDetails;
    	List<userDetails> userDetailList = new List<userDetails>();
    	 
        users.addAll([SELECT Id, Name, IsActive,                    
                        ManagerId,Manager.Name,
                        Manager.ManagerId,Manager.Manager.Name,
                        Manager.Manager.ManagerId, Manager.Manager.Manager.Name, 
                        Manager.Manager.Manager.ManagerId, Manager.Manager.Manager.Manager.Name, 
                        Manager.Manager.Manager.Manager.ManagerId, Manager.Manager.Manager.Manager.Manager.Name 
                      FROM User WHERE Id IN :userIdList]);    

        if(!users.isEmpty()){
            for(User u: users){
                uDetails = new userDetails();   
                uDetails.id = u.Id;
                uDetails.getName = u.Name;
                uDetails.isActive = u.IsActive;
                uDetails.getFirstLevelManager = u.Manager.Name;
                uDetails.getSecondLevelManager = u.Manager.Manager.Name;
                uDetails.getThirdLevelManager = u.Manager.Manager.Manager.Name;
                uDetails.getFourthLevelManager = u.Manager.Manager.Manager.Manager.Name;
                uDetails.getFifthLevelManager = u.Manager.Manager.Manager.Manager.Manager.Name;    
                uDetails.getFirstLevelManagerId = u.ManagerId;
                uDetails.getSecondLevelManagerId = u.Manager.ManagerId;
                uDetails.getThirdLevelManagerId = u.Manager.Manager.ManagerId;
                uDetails.getFourthLevelManagerId = u.Manager.Manager.Manager.ManagerId;
                uDetails.getFifthLevelManagerId = u.Manager.Manager.Manager.Manager.ManagerId;
                userDetailList.add(uDetails);                   
            }
            return userDetailList;                     
            
        } else {
            return null;
        }       
    }
    
    public class userDetails{
        public ID id;
        public String getName;
        public boolean isActive;
        public String getFirstName;
        public String getLastName;
        public String getfirstLevelManager;
        public String getsecondLevelManager;
        public String getthirdLevelManager;
        public String getfourthLevelManager;
        public String getfifthLevelManager;
        public String getfirstLevelManagerId;
        public String getsecondLevelManagerId;
        public String getthirdLevelManagerId;
        public String getfourthLevelManagerId;
        public String getfifthLevelManagerId;
    }  
}