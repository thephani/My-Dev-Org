@IsTest
private class CommunicationUtilitiesTest {
    @IsTest
    static void mentionsPreserveTextAndOrdering() {
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(
            'Hello {005000000000001}, meet {0F9000000000002AAA}!');
        System.assertEquals(5, segments.size());
        System.assertEquals('Hello ', ((ConnectApi.TextSegmentInput)segments[0]).text);
        System.assertEquals('005000000000001', ((ConnectApi.MentionSegmentInput)segments[1]).id);
        System.assertEquals(', meet ', ((ConnectApi.TextSegmentInput)segments[2]).text);
        System.assertEquals('0F9000000000002AAA', ((ConnectApi.MentionSegmentInput)segments[3]).id);
        System.assertEquals('!', ((ConnectApi.TextSegmentInput)segments[4]).text);
        System.assertEquals(2, ConnectApiHelper.getMessageSegmentInputs('{005000000000001}{005000000000002}').size());
        System.assertEquals(0, ConnectApiHelper.getMessageSegmentInputs('').size());
        System.assertEquals('{bad} text', ((ConnectApi.TextSegmentInput)
            ConnectApiHelper.getMessageSegmentInputs('{bad} text')[0]).text);
    }

    @IsTest
    static void emptyMentionsAreRejectedBeforePosting() {
        try {
            ConnectApiHelper.getMessageSegmentInputs(null);
            System.assert(false, 'Null input must be rejected');
        } catch (ConnectApiHelper.InvalidParameterException expected) {
            System.assertEquals('The inputText parameter cannot be null.', expected.getMessage());
        }
        try {
            ConnectApiHelper.postFeedItemWithMentions(null, UserInfo.getUserId(), '  ');
            System.assert(false, 'Blank feed text must be rejected');
        } catch (ConnectApiHelper.InvalidParameterException expected) {
            System.assertEquals('The textWithMentions parameter must be non-empty.', expected.getMessage());
        }
        try {
            ConnectApiHelper.postCommentWithMentions(null, null, null);
            System.assert(false, 'Null comment text must be rejected');
        } catch (ConnectApiHelper.InvalidParameterException expected) {
            System.assertEquals('The textWithMentions parameter must be non-empty.', expected.getMessage());
        }
    }

    @IsTest
    static void emailValidationChecksAddressStructure() {
        System.assertEquals(true, MailUtilities.isValidEmailAddress('person@example.com'));
        for (String invalid : new List<String>{null, '', ' ', 'person', 'person@example', 'a@b@example.com'}) {
            System.assertEquals(false, MailUtilities.isValidEmailAddress(invalid), 'Invalid address: ' + invalid);
        }
    }

    @IsTest
    static void missingRecipientsDoNotInvokeEmail() {
        Test.startTest();
        MailUtilities.sendTextEmail(null, 'Subject', 'Body');
        MailUtilities.sendHTMLEmail(new List<String>(), 'Subject', '<p>Body</p>');
        System.assertEquals(0, Limits.getEmailInvocations());
        Test.stopTest();
    }

    @IsTest
    static void textHtmlAndAttachmentsInvokeEmail() {
        Account account = new Account(Name = 'Attachment coverage account');
        insert account;
        Attachment attachment = new Attachment(ParentId = account.Id, Name = 'coverage.txt', Body = Blob.valueOf('Attachment content'));
        insert attachment;
        // Salesforce test transactions do not deliver these messages.
        List<String> recipients = new List<String>{'unit@example.invalid'};
        Test.startTest();
        MailUtilities.sendTextEmail(recipients, 'Text subject', 'Text body');
        MailUtilities.sendHTMLEmail(recipients, 'HTML subject', '<p>HTML body</p>');
        MailUtilities.sendEmailWithStandardAttachments(recipients, 'Attachment IDs', 'Body', false, new List<Id>{attachment.Id});
        MailUtilities.sendEmailWithStandardAttachments(recipients, 'Attachment records', '<p>Body</p>', true, new List<Attachment>{attachment});
        System.assertEquals(4, Limits.getEmailInvocations());
        Test.stopTest();
    }
}
