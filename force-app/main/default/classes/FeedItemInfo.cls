global class FeedItemInfo {

    global FeedItemInfo(ConnectApi.FeedItem inFeedItem) {
        feedItem = inFeedItem;
        userName = '';
        
        if (inFeedItem.actor != null && inFeedItem.actor instanceof ConnectApi.UserSummary) {
            userName = ((ConnectApi.UserSummary)inFeedItem.actor).name;
        }

        imageUrl = '';
        if (inFeedItem.attachment != null) {
            if (inFeedItem.attachment instanceof ConnectApi.ContentAttachment) {
                ConnectApi.ContentAttachment content = (ConnectApi.ContentAttachment)inFeedItem.attachment;
                imageUrl = content.renditionUrl;
                contentDescription = content.description;
                contentTitle = content.title;
                hasImagePreview = content.hasImagePreview;
                contentId = content.versionId;
                // contentDownloadUrl = content.downloadUrl; // not cookie enabled so unusable
                contentDownloadUrl = '/sfc/servlet.shepherd/version/download/' + content.versionId + '?asPdf=false&operationContext=CHATTER';
            } else if (inFeedItem.attachment instanceof ConnectApi.LinkAttachment) {
                ConnectApi.LinkAttachment link = (ConnectApi.LinkAttachment)inFeedItem.attachment;
                linkUrl = link.url;
                linkTitle = link.title;
            }
        }

        formattedText= FeedFormatter.formatBodyText(inFeedItem.body);

        comments = new List<CommentInfo>();
        for (ConnectApi.Comment comment : inFeedItem.comments.comments) {
            comments.add(new CommentInfo(comment));
        }
    }
  
    //-------- properties ----------//
    global ConnectApi.FeedItem feedItem { get; private set; }
    global String userName { get; private set; }
    global String imageUrl { get; private set; }
    global String linkUrl { get; private set; }
    global String linkTitle { get; private set; }
    global String contentDescription { get; private set; }
    global String contentDownloadUrl { get; private set; }
    global String contentTitle { get; private set; }
    global Boolean hasImagePreview { get; private set; }
    global String formattedText { get; private set; }
    global String contentId { get; private set; }
    global List<CommentInfo> comments { get; private set; }

    global Integer commentCount {
        get {
            return feedItem.comments.comments.size();
        }
    }
}