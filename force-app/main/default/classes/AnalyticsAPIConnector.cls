public class AnalyticsAPIConnector {
    //public static string runReportSync(string reportId) {        
    public string getRunReportSync() {        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        string reqUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v29.0/analytics/reports/00O900000046ipX?includeDetails=true';
        httpReq.setMethod('GET');
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        httpReq.setEndpoint(reqUrl);
        httpRes = http.send(httpReq);
        return JSON.serialize(httpRes.getBody());
        //return httpRes.getBody();
    }
}