global class UtilsChatter {
    
    //** Turn an input String into a useful TextSegmentInput
    global static void postChatterFeedItem(ConnectApi.FeedType FeedType, Id SubjectID, ConnectApi.FeedItemInput Input) {
        ConnectApi.ChatterFeeds.postFeedItem(null, FeedType, SubjectID, Input, null);
    }
    
    //** Turn an input String into a useful TextSegmentInput
    global static ConnectApi.TextSegmentInput addTextSegment(String thisString) {
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = thisString;
        return textSegment;
    }
    
    //** Turn an input Id into a useful MentionSegmentInput
    global static ConnectApi.MentionSegmentInput addMentionSegment(Id thisId) {
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = thisId;
        return mentionSegment;
    }
    
    //** Create and post a message to Chatter (Text)
    global static void postChatterFeedItem(ConnectApi.FeedType FeedType, Id SubjectId, String TextString1) {
        //** Combine the needed messageSegments into one coherent messageInput
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageInput.messageSegments.add(addTextSegment(TextString1));
        //** Attach the messageInput as the Input.body
        ConnectApi.FeedItemInput Input = new ConnectApi.FeedItemInput();
        Input.body = messageInput;
        //** Post to Chatter
        postChatterFeedItem(FeedType, SubjectId, Input);
    }
    
    //** Create and post a message to Chatter (Mention)
    global static void postChatterFeedItem(ConnectApi.FeedType FeedType, Id SubjectId, Id UserId1) {
        //** Combine the needed messageSegments into one coherent messageInput
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageInput.messageSegments.add(addMentionSegment(UserId1));
        //** Attach the messageInput as the Input.body
        ConnectApi.FeedItemInput Input = new ConnectApi.FeedItemInput();
        Input.body = messageInput;
        //** Post to Chatter
        postChatterFeedItem(FeedType, SubjectId, Input);
    }
    
    //** Create and post a message to Chatter (Mention List)
    global static void postChatterFeedItem(ConnectApi.FeedType FeedType, Id SubjectId, List<Id> UserId1) {
        //** Combine the needed messageSegments into one coherent messageInput
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        for (Id i : UserId1) {
            messageInput.messageSegments.add(addMentionSegment(i));
        }
        //** Attach the messageInput as the Input.body
        ConnectApi.FeedItemInput Input = new ConnectApi.FeedItemInput();
        Input.body = messageInput;
        //** Post to Chatter
        postChatterFeedItem(FeedType, SubjectId, Input);
    }
    
}