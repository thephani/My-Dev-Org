/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/** Tests metadata creation, independent requests, and follow-up polling. */
@IsTest
private class MetadataCreateJobTest {
    private class WebServiceMockImpl implements WebServiceMock {
        private Boolean pending;
        WebServiceMockImpl(Boolean pending) { this.pending = pending; }

        public void doInvoke(Object stub, Object request, Map<String, Object> response,
                             String endpoint, String soapAction, String requestName,
                             String responseNS, String responseName, String responseType) {
            MetadataService.AsyncResult result = new MetadataService.AsyncResult();
            result.id = 'mock-request';
            if (request instanceof MetadataService.create_element) {
                result.done = !pending;
                result.state = pending ? 'InProgress' : 'Completed';
                MetadataService.createResponse_element created = new MetadataService.createResponse_element();
                created.result = new MetadataService.AsyncResult[]{result};
                response.put('response_x', created);
            } else if (request instanceof MetadataService.checkStatus_element) {
                result.done = true;
                result.state = 'Completed';
                MetadataService.checkStatusResponse_element checked = new MetadataService.checkStatusResponse_element();
                checked.result = new MetadataService.AsyncResult[]{result};
                response.put('response_x', checked);
            } else {
                System.assert(false, 'Unexpected metadata request: ' + requestName);
            }
        }
    }

    private static MetadataCreateJob.Item newItem() {
        MetadataService.CustomField field = new MetadataService.CustomField();
        field.fullName = 'Test__c.TestField__c';
        field.label = 'Test Field';
        field.type_x = 'Text';
        field.length = 42;
        MetadataCreateJob.Item item = new MetadataCreateJob.Item(field);
        item.context = 'Some context';
        return item;
    }

    @IsTest
    static void testCreateField() {
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl(false));
        MetadataCreateJob.Item item = newItem();
        AssertMetadataAsyncCallback callback = new AssertMetadataAsyncCallback();
        MetadataCreateJob job = new MetadataCreateJob('test-session', new List<MetadataCreateJob.Item>{item}, callback);
        Test.startTest();
        System.assert(job.start(null).iterator().hasNext());
        job.execute(null, new List<MetadataCreateJob.Item>{item});
        job.finish(null);
        Test.stopTest();
        System.assertEquals(true, callback.completed, 'Successful creation must invoke the completion callback');
        System.assertEquals(0, callback.scheduledIds.size(), 'Completed creation must not schedule a poll');
        System.assertEquals(false, job.start(null).iterator().hasNext());
    }

    @IsTest
    static void testConcurrentCreateJobs() {
        AssertMetadataAsyncCallback callback = new AssertMetadataAsyncCallback();
        Test.startTest();
        MetadataCreateJob.run('test-session', new List<MetadataCreateJob.Item>{newItem()}, callback);
        MetadataCreateJob.run('test-session', new List<MetadataCreateJob.Item>{newItem()}, callback);
        System.assertEquals(2, callback.scheduledIds.size(), 'Both independent requests must be scheduled');
        System.assertNotEquals(callback.scheduledIds[0], callback.scheduledIds[1]);
        // Execution is tested directly, so no scheduled job needs to run in this test.
        for (Id jobId : callback.scheduledIds) {
            System.abortJob(jobId);
        }
        Test.stopTest();
    }

    @IsTest
    static void testPendingCreateSchedulesPoll() {
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl(true));
        MetadataCreateJob.Item item = newItem();
        AssertMetadataAsyncCallback callback = new AssertMetadataAsyncCallback();
        MetadataCreateJob job = new MetadataCreateJob('test-session', new List<MetadataCreateJob.Item>{item}, callback);
        Test.startTest();
        job.execute(null, new List<MetadataCreateJob.Item>{item});
        System.assertEquals(false, item.aysncResult.done);
        job.finish(null);
        System.assertEquals(1, callback.scheduledIds.size(), 'Pending creation must schedule one follow-up poll');
        System.assertEquals(false, callback.completed, 'Pending creation must not report completion');
        for (Id jobId : callback.scheduledIds) {
            System.abortJob(jobId);
        }
        Test.stopTest();
    }

    @IsTest
    static void testPollCompletesCreation() {
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl(true));
        MetadataCreateJob.Item item = newItem();
        AssertMetadataAsyncCallback callback = new AssertMetadataAsyncCallback();
        MetadataCreateJob job = new MetadataCreateJob('test-session', new List<MetadataCreateJob.Item>{item}, callback);
        Test.startTest();
        job.execute(null, new List<MetadataCreateJob.Item>{item});
        System.assertEquals(false, item.aysncResult.done);
        job.execute(null, new List<MetadataCreateJob.Item>{item});
        job.finish(null);
        Test.stopTest();
        System.assertEquals(true, callback.completed, 'A completed poll must invoke the completion callback');
        System.assertEquals(0, callback.scheduledIds.size(), 'A completed poll must not be scheduled again');
    }

    public class AssertMetadataAsyncCallback implements MetadataCreateJob.IMetadataAsyncCallback {
        public List<Id> scheduledIds = new List<Id>();
        public Boolean completed = false;

        public void batchId(Id batchId) {
            System.assertNotEquals(null, batchId, 'Scheduled job ID must be returned');
            scheduledIds.add(batchId);
        }

        public void deployComplete(List<MetadataCreateJob.Item> items) {
            System.assertEquals(1, items.size());
            System.assertEquals('Some context', items[0].context);
            MetadataService.CustomField field = (MetadataService.CustomField) items[0].metadata[0];
            System.assertEquals('Test__c.TestField__c', field.fullName);
            System.assertEquals('Test Field', field.label);
            System.assertEquals('Text', field.type_x);
            System.assertEquals(42, field.length);
            System.assertEquals(null, items[0].createException, 'Mocked metadata creation must succeed');
            System.assertEquals(true, items[0].aysncResult.done);
            System.assertEquals('Completed', items[0].aysncResult.state);
            completed = true;
        }
    }
}
