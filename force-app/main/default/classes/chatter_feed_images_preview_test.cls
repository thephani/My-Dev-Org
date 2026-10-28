@isTest(seeAllData=true)
private class chatter_feed_images_preview_test {

    private static testMethod void unitTestMehtods() {

    	Account acc = new Account(Name = 'Test');
    	insert acc;

    	ApexPages.currentPage().getParameters().put('id', '0019000000WPyWZ');

    	FeedItem fi = new FeedItem();
    	fi.Body = 'test';
    	fi.ParentId = acc.Id;
    	fi.Title = 'test';
    	insert fi;

        PageReference pageRef = Page.chatterFeed_images_preview;
        Test.setCurrentPage(pageRef);        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
       
        chatterFeed_images_preview_controller c = new chatterFeed_images_preview_controller(sc);                  

    }

}