public class RoleUtilities {
	
	public static Set < ID > getRoleSubordinateUsers(Id userId) {
		Id roleId = [select UserRoleId from User where Id = : userId].UserRoleId; // get requested user's role		
		Set < Id > allSubRoleIds = getAllSubRoleIds(new Set < ID > { roleId }); // get all of the roles underneath the user		
		Map < Id, User > users = new Map < Id, User > ([Select Id, Name From User where	UserRoleId IN: allSubRoleIds]); // get all of the ids for the users in those roles
		return users.keySet(); // return the ids as a set so you can do what you want with them
	}					
	
	
    private static Set < ID > getAllSubRoleIds(Set < ID > roleIds) {
   	
       Set < ID > currentRoleIds = new Set < ID > ();
       for (UserRole userRole: [select Id from UserRole where ParentRoleId IN: roleIds AND ParentRoleID != null]) // get all of the roles underneath the passed roles
       currentRoleIds.add(userRole.Id);      
       if (currentRoleIds.size() > 0)  
      	 currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
       return currentRoleIds;
    }
}