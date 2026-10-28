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
        AccountFeedController controller = new AccountFeedController();
        controller.feedUpdate = 'User feed update';
        PageReference nextPage = controller.go();
        FeedItem posted = [SELECT Body, ParentId, Type FROM FeedItem
                           WHERE ParentId = :UserInfo.getUserId() AND Type = 'TextPost' LIMIT 1];
        System.assertEquals('User feed update', posted.Body);
        System.assertEquals(UserInfo.getUserId(), posted.ParentId);
        System.assertEquals('/_ui/core/userprofile/UserProfilePage', nextPage.getUrl());
    }

    @isTest
    static void testRecentAccountUpdates() {
        Account account = new Account(Name = 'Feed test account');
        insert account;
        insert new FeedItem(ParentId = account.Id, Body = 'Account feed update');
        AccountFeedController controller = new AccountFeedController();
        controller.feedUpdate = 'User feed update';
        controller.go();

        List<AccountFeed> updates = controller.getRecentTextUpdates();
        System.assertEquals(1, updates.size(), 'Only the account text post belongs in the account feed');
        System.assertEquals('Account feed update', updates[0].Body);
    }
}
