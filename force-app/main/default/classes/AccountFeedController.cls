public class AccountFeedController {
        
    public String feedUpdate {get; set;}
        
    public PageReference go(){
        FeedItem fItem = new FeedItem();
        fItem.Title = 'Test post from visualforce Page';
        fItem.Type = 'TextPost';
        fItem.ParentId = Userinfo.getUserId();
        fItem.Body = this.feedUpdate;
        insert fitem;
        return new PageReference('/_ui/core/userprofile/UserProfilePage');
    }
    
    public List<AccountFeed> getRecentTextUpdates() {
        List<AccountFeed> accFeed = [SELECT Type, CreatedDate, CreatedBy.name, Body FROM AccountFeed WHERE Type='TextPost'ORDER BY CreatedDate DESC LIMIT 10];
        return accFeed;         
    }
    
    @isTest    
	static void testUpdates() {
		AccountFeedController h = new AccountFeedController();
		h.feedUpdate = 'hi';
		h.go();
		List<AccountFeed> after = h.getRecentTextUpdates();
		System.assert(after.size() > 0 );
		System.assertEquals('hi', after[0].body);
	}
	
        
}