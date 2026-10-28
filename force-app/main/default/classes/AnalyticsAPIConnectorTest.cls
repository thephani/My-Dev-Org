@IsTest
private class AnalyticsAPIConnectorTest {
    private class ReportResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertEquals('GET', request.getMethod());
            System.assert(request.getEndpoint().endsWith('/services/data/v29.0/analytics/reports/00O900000046ipX?includeDetails=true'));
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"reportMetadata":{"name":"Quarterly report"}}');
            return response;
        }
    }

    @IsTest
    static void reportResponseIsEncodedAsJsonString() {
        Test.setMock(HttpCalloutMock.class, new ReportResponse());
        Test.startTest();
        String encoded = new AnalyticsAPIConnector().getRunReportSync();
        Test.stopTest();
        System.assertEquals('{"reportMetadata":{"name":"Quarterly report"}}',
                            JSON.deserializeUntyped(encoded),
                            'The report response must be returned as a JSON-encoded string');
    }
}
