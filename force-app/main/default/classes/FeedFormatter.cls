global class FeedFormatter {
 global static String formatBodyText(ConnectApi.FeedBody body) {
        String formattedText = '';
        for (ConnectApi.MessageSegment seg : body.messageSegments) {
            if (seg instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mention = (ConnectApi.MentionSegment)seg;
                formattedText += '<span style=\"color:blue\"><b>' + mention.user.name + '</b></span>';
            } else if (seg instanceof ConnectApi.HashtagSegment) {
                ConnectApi.HashtagSegment hashtag = (ConnectApi.HashtagSegment)seg;
                formattedText += '<span style=\"color:red\"><b>#' + hashtag.tag + '</b></span>';
            } else if (seg instanceof ConnectApi.LinkSegment) {
                ConnectApi.LinkSegment link = (ConnectApi.LinkSegment)seg;
                formattedText += '<a href=\"' + link.url + '\">' + link.url + '</a>';
            } else {
                // Default.
                formattedText += seg.text;
            }
        }
        return formattedText;
    }
}