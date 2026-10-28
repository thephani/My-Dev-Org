@IsTest
private class MetadataServiceExamplesTest {
    // The real examples and generated SOAP port run; only the network boundary is replaced.
    private class Step {
        String operation;
        String requestJson;
        String responseJson;
        Object responseOverride;
        Step(String operation, String requestJson, String responseJson) {
            this.operation = operation;
            this.requestJson = requestJson;
            this.responseJson = responseJson;
        }
    }
    private static List<Step> expected;
    private static Integer position;
    private class SoapMock implements WebServiceMock {
        public void doInvoke(Object stub, Object request, Map<String,Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) {
            System.assert(position < expected.size(), 'Unexpected SOAP call: ' + requestName);
            Step step = expected[position++];
            System.assertEquals(step.operation, requestName, 'SOAP operation/order');
            System.assert(endpoint.endsWith('/services/Soap/m/30.0'), 'Metadata endpoint');
            MetadataService.MetadataPort port = (MetadataService.MetadataPort)stub;
            System.assertNotEquals(null, port.SessionHeader, 'Examples must authenticate the port');
            assertSubset(JSON.deserializeUntyped(step.requestJson),
                JSON.deserializeUntyped(JSON.serialize(request)), requestName);
            response.put('response_x', step.responseOverride != null ? step.responseOverride :
                JSON.deserialize(step.responseJson, Type.forName(responseType)));
        }
    }
    private static void assertSubset(Object wanted, Object actual, String path) {
        if (wanted instanceof Map<String,Object>) {
            System.assert(actual instanceof Map<String,Object>, path + ' must be an object');
            Map<String,Object> wantMap = (Map<String,Object>)wanted;
            Map<String,Object> gotMap = (Map<String,Object>)actual;
            for (String key : wantMap.keySet()) {
                System.assert(gotMap.containsKey(key), path + '.' + key + ' is missing');
                assertSubset(wantMap.get(key), gotMap.get(key), path + '.' + key);
            }
        } else if (wanted instanceof List<Object>) {
            System.assert(actual instanceof List<Object>, path + ' must be an array');
            List<Object> wantList = (List<Object>)wanted;
            List<Object> gotList = (List<Object>)actual;
            System.assertEquals(wantList.size(), gotList.size(), path + ' array size');
            for (Integer i = 0; i < wantList.size(); i++)
                assertSubset(wantList[i], gotList[i], path + '[' + i + ']');
        } else {
            System.assertEquals(wanted, actual, path);
        }
    }
    private static void setup(List<Step> steps) {
        expected = steps;
        position = 0;
        Test.setMock(WebServiceMock.class, new SoapMock());
    }
    private static void verified() {
        System.assertEquals(expected.size(), position, 'Every expected API operation must occur');
    }
    private static Step save(String operation, String metadata) {
        return new Step(operation, '{"metadata":[' + metadata + ']}',
            '{"result":[{"fullName":"Test__c","success":true,"errors":[]}]}');
    }
    private static Step asyncCall(String operation, String metadata) {
        return new Step(operation, '{"metadata":[' + metadata + ']}',
            '{"result":[{"id":"04s000000000001","done":false,"state":"InProgress","message":null,"statusCode":null}]}');
    }
    private static Step updateCall(String currentName, String metadata) {
        return new Step('update', '{"UpdateMetadata":[{"currentName":"' + currentName + '","metadata":' + metadata + '}]}',
            '{"result":[{"id":"04s000000000001","done":false,"state":"InProgress","message":null,"statusCode":null}]}');
    }
    private static Step read(String typeName, String fullName, String record) {
        // JSON deserialization bypasses field initializers, so fixture records carry xsi:type explicitly.
        Map<String,Object> recordFields = (Map<String,Object>)JSON.deserializeUntyped(record);
        recordFields.put('type', typeName);
        record = JSON.serialize(recordFields);
        return new Step('readMetadata', '{"type_x":"' + typeName + '","fullNames":["' + fullName + '"]}',
            '{"result":{"records":[' + record + ']}}');
    }

    @IsTest static void createsObjectAndFieldsWithRequiredSchema() {
        setup(new List<Step>{
            save('createMetadata', '{"type":"CustomObject","fullName":"Test__c","label":"Test","pluralLabel":"Tests","nameField":{"type_x":"Text","label":"Test Record"},"deploymentStatus":"Deployed","sharingModel":"ReadWrite"}'),
            save('createMetadata', '{"type":"CustomField","fullName":"Test__c.LookupField__c","type_x":"Lookup","referenceTo":"Test__c","relationshipName":"Tests","relationshipLabel":"Tests"}'),
            save('createMetadata', '{"type":"CustomField","fullName":"Test__c.TestField__c","type_x":"Text","label":"Test Field","length":42}'),
            asyncCall('create', '{"type":"CustomField","fullName":"Test__c.ExternalField__c","type_x":"Text","length":42,"externalId":true}'),
            asyncCall('create', '{"type":"CustomField","fullName":"Test__c.LongTextAreaField__c","type_x":"LongTextArea","length":32000,"visibleLines":3}')
        });
        MetadataServiceExamples.createObject();
        MetadataServiceExamples.createLookupField();
        MetadataServiceExamples.createField();
        MetadataServiceExamples.createExternalField();
        MetadataServiceExamples.createLongTextAreaField();
        verified();
    }
    @IsTest static void updatesAndDeletesFieldUsingLegacyOperations() {
        setup(new List<Step>{
            updateCall('Test__c.TestField__c', '{"fullName":"Test__c.TestField__c","label":"New Test Field Label","type_x":"Text","length":52}'),
            asyncCall('delete', '{"type":"CustomField","fullName":"Test__c.TestField__c"}')
        });
        MetadataServiceExamples.updateField();
        MetadataServiceExamples.deleteField();
        verified();
    }
    @IsTest static void encodesPageAndResourceContent() {
        setup(new List<Step>{
            save('createMetadata', '{"type":"ApexPage","fullName":"test","label":"Test Page","apiVersion":25,"content":"PGFwZXg6cGFnZS8+"}'),
            asyncCall('create', '{"type":"StaticResource","fullName":"test","contentType":"text","cacheControl":"public","content":"U3RhdGljIHN0dWZm"}'),
            updateCall('test', '{"type":"StaticResource","fullName":"test","contentType":"text","cacheControl":"public","content":"U3RhdGljIHN0dWZmIENoYW5nZWQ="}'),
            asyncCall('delete', '{"type":"StaticResource","fullName":"test","contentType":"text","cacheControl":"public"}')
        });
        MetadataServiceExamples.createPage();
        MetadataServiceExamples.createStaticResource();
        MetadataServiceExamples.updateStaticResource();
        MetadataServiceExamples.deleteStaticResource();
        verified();
    }
    @IsTest static void createsAndReplacesPicklistValues() {
        setup(new List<Step>{
            asyncCall('create', '{"fullName":"Lead.picklist__c","type_x":"Picklist","picklist":{"sorted":false,"picklistValues":[{"fullName":"first","default_x":false}]}}'),
            updateCall('Lead.picklist__c', '{"fullName":"Lead.picklist__c","type_x":"Picklist","picklist":{"sorted":false,"picklistValues":[{"fullName":"second","default_x":false},{"fullName":"third","default_x":false}]}}')
        });
        MetadataServiceExamples.createPicklistField();
        MetadataServiceExamples.updatePicklistField();
        verified();
    }
    @IsTest static void settingsPreserveCountryStateAndNotificationConfiguration() {
        setup(new List<Step>{
            asyncCall('create', '{"type":"AddressSettings","fullName":"Address","countriesAndStates":{"countries":[{"isoCode":"US","active":true,"integrationValue":"United States","states":[{"isoCode":"AL","label":"Alabama","active":true},{"isoCode":"AK","label":"Alaska","active":true}]}]}}'),
            updateCall('Case.settings', '{"type":"CaseSettings","fullName":"Case","notifyOwnerOnCaseComment":true}')
        });
        MetadataServiceExamples.createAddressSettings();
        MetadataServiceExamples.updateCaseSettings();
        verified();
    }
    @IsTest static void installsAndUninstallsBothPackages() {
        setup(new List<Step>{
            new Step('create', '{"metadata":[{"type":"InstalledPackage","fullName":"packagea","versionNumber":"1.0","password":"fred1234"},{"type":"InstalledPackage","fullName":"packageb","versionNumber":"1.0","password":null}]}',
                '{"result":[{"id":"04s000000000001","done":false,"state":"InProgress"},{"id":"04s000000000002","done":false,"state":"InProgress"}]}'),
            new Step('delete', '{"metadata":[{"type":"InstalledPackage","fullName":"packagea"},{"type":"InstalledPackage","fullName":"packageb"}]}',
                '{"result":[{"id":"04s000000000003","done":false,"state":"InProgress"},{"id":"04s000000000004","done":false,"state":"InProgress"}]}')
        });
        MetadataServiceExamples.installPackages();
        MetadataServiceExamples.uninstallPackages();
        verified();
    }
    @IsTest static void fieldSetsRetainExistingFieldAndAddExternalField() {
        setup(new List<Step>{
            asyncCall('create', '{"type":"FieldSet","fullName":"Test__c.MyFieldSet","label":"My FieldSet","availableFields":[{"field":"TestField__c","isFieldManaged":true,"isRequired":true}]}'),
            updateCall('Test__c.MyFieldSet', '{"type":"FieldSet","fullName":"Test__c.MyFieldSet","availableFields":[{"field":"TestField__c","isFieldManaged":true,"isRequired":true},{"field":"ExternalField__c","isFieldManaged":true,"isRequired":true}]}')
        });
        MetadataServiceExamples.createFieldSet();
        MetadataServiceExamples.updateFieldSet();
        verified();
    }
    @IsTest static void actionOverrideReturnsAsyncResultAndChecksItsStatus() {
        setup(new List<Step>{
            updateCall('Test__c', '{"type":"CustomObject","fullName":"Test__c","actionOverrides":[{"actionName":"Edit","content":"TestPage","type_x":"visualforce","skipRecordTypeSelect":false}]}'),
            new Step('checkStatus', '{"asyncProcessId":["04s000000000001"]}', '{"result":[{"id":"04s000000000001","done":true,"state":"Completed","message":"Update completed","statusCode":null}]}')
        });
        MetadataService.AsyncResult result = MetadataServiceExamples.addActionOverride();
        System.assertEquals('04s000000000001', result.id);
        System.assertEquals(false, result.done);
        System.assertEquals('Update completed', MetadataServiceExamples.checkAsync(result.id));
        verified();
    }
    @IsTest static void deletesRecordTypeAndViewAndCreatesApprovalSubmitter() {
        setup(new List<Step>{
            asyncCall('delete', '{"type":"RecordType","fullName":"Test__c.RecordTypeA","active":true}'),
            asyncCall('delete', '{"type":"ListView","fullName":"Test__c.MyListView","filterScope":"Everything"}'),
            asyncCall('create', '{"type":"ApprovalProcess","fullName":"Test__c.TestApproval","active":false,"allowRecall":false,"recordEditability":"AdminOnly","allowedSubmitters":[{"type_x":"user","submitter":' + JSON.serialize(UserInfo.getUserName()) + '}]}')
        });
        MetadataServiceExamples.deleteRecordType();
        MetadataServiceExamples.deleteListView();
        MetadataServiceExamples.createApprovalProcess();
        verified();
    }
    @IsTest static void listsAllThreeMetadataTypesAtRequestedVersion() {
        setup(new List<Step>{new Step('listMetadata', '{"queries":[{"type_x":"Workflow"},{"type_x":"ValidationRule"},{"type_x":"CustomField"}],"asOfVersion":25}',
            '{"result":[{"fullName":"Test__c.TestField__c","fileName":"objects/Test__c.object","type_x":"CustomField","id":"00N000000000001","createdById":"005000000000001","createdByName":"Admin","createdDate":"2026-01-01T00:00:00.000Z","lastModifiedById":"005000000000001","lastModifiedByName":"Admin","lastModifiedDate":"2026-01-01T00:00:00.000Z","manageableState":"unmanaged","namespacePrefix":null}]}')});
        MetadataServiceExamples.listMetadata();
        verified();
    }

    private static void exerciseLayoutButtons(String existingButtons, String wantedButtons) {
        setup(new List<Step>{
            save('createMetadata', '{"type":"WebLink","fullName":"Test__c.googleButton","displayType":"button","url":"http://www.google.com","openType":"newWindow","height":600,"width":600}'),
            read('Layout', 'Test__c-Test Layout', '{"fullName":"Test__c-Test Layout","customButtons":' + existingButtons + '}'),
            save('updateMetadata', '{"type":"Layout","fullName":"Test__c-Test Layout","customButtons":' + wantedButtons + '}')
        });
        MetadataServiceExamples.readAndUpdateLayout();
        verified();
    }
    @IsTest static void initializesMissingLayoutButtonList() {
        exerciseLayoutButtons('null', '["googleButton"]');
    }
    @IsTest static void preservesExistingLayoutButtons() {
        exerciseLayoutButtons('["existingButton"]', '["existingButton","googleButton"]');
    }
    @IsTest static void appendsValuesToExistingPicklist() {
        setup(new List<Step>{
            read('CustomField', 'Lead.picklist__c', '{"fullName":"Lead.picklist__c","type_x":"Picklist","picklist":{"sorted":false,"picklistValues":[{"fullName":"first","default_x":true}]}}'),
            save('updateMetadata', '{"fullName":"Lead.picklist__c","type_x":"Picklist","picklist":{"sorted":false,"picklistValues":[{"fullName":"first","default_x":true},{"fullName":"second","default_x":false},{"fullName":"third","default_x":false}]}}')
        });
        MetadataServiceExamples.updatePicklist();
        verified();
    }
    @IsTest static void copiesTemplateSectionWithoutRemovingTargetSections() {
        setup(new List<Step>{
            read('Layout', 'Test__c-Test Template Layout', '{"fullName":"Test__c-Test Template Layout","layoutSections":[{"label":"Template section","style":"TwoColumnsTopToBottom","layoutColumns":[]}]}'),
            read('Layout', 'Test__c-Test Layout', '{"fullName":"Test__c-Test Layout","layoutSections":[{"label":"Existing section","style":"OneColumn","layoutColumns":[]}]}'),
            save('updateMetadata', '{"fullName":"Test__c-Test Layout","layoutSections":[{"label":"Existing section","style":"OneColumn"},{"label":"Template section","style":"TwoColumnsTopToBottom"}]}')
        });
        MetadataServiceExamples.copyLayoutSection();
        verified();
    }
    private static void exerciseHomeLayout(String existing, String wanted) {
        setup(new List<Step>{
            read('HomePageLayout', 'DE Default', '{"fullName":"DE Default","wideComponents":' + existing + '}'),
            save('createMetadata', '{"type":"HomePageComponent","fullName":"helloworld","width":"wide","pageComponentType":"htmlArea","body":"<p>Hello World</p>"}'),
            save('updateMetadata', '{"type":"HomePageLayout","fullName":"DE Default","wideComponents":' + wanted + '}')
        });
        MetadataServiceExamples.addComponentsToHomePageLayout();
        verified();
    }
    @IsTest static void initializesMissingHomeComponents() {
        exerciseHomeLayout('null', '["helloworld"]');
    }
    @IsTest static void preservesExistingHomeComponents() {
        exerciseHomeLayout('["existing"]', '["existing","helloworld"]');
    }
    @IsTest static void readsTypedWorkflowObjectAndFolderRecords() {
        setup(new List<Step>{
            read('WorkflowAlert', 'Test__c.Test', '{"fullName":"Test__c.Test","description":"Notify owner","senderAddress":"admin@example.com","recipients":[]}'),
            read('CustomObject', 'Test__c', '{"fullName":"Test__c","fields":[{"fullName":"TestField__c","type_x":"Text","length":42}]}'),
            read('ReportFolder', 'MyFolder', '{"fullName":"MyFolder","sharedTo":{"group_x":["Sales","Support"]}}')
        });
        MetadataServiceExamples.readWorkflowAlert();
        MetadataServiceExamples.readCustomObject();
        MetadataServiceExamples.readFolder();
        verified();
    }
    @IsTest static void surfacesSingleSaveErrorAndItsFieldNames() {
        setup(new List<Step>{new Step('createMetadata', '{"metadata":[{"fullName":"Test__c.TestField__c"}]}',
            '{"result":[{"fullName":"Test__c.TestField__c","success":false,"errors":[{"message":"Invalid length","statusCode":"FIELD_INTEGRITY_EXCEPTION","fields":["length","type"]}]}]}')});
        try {
            MetadataServiceExamples.createField();
            System.assert(false, 'Failed metadata save must be surfaced');
        } catch (MetadataServiceExamples.MetadataServiceExamplesException e) {
            System.assert(e.getMessage().contains('Error occured processing component Test__c.TestField__c.'));
            System.assert(e.getMessage().contains('Invalid length (FIELD_INTEGRITY_EXCEPTION).'));
            System.assert(e.getMessage().contains('Fields length,type.'));
        }
        verified();
    }
    @IsTest static void surfacesMultipleSaveErrorsWithoutFieldLists() {
        setup(new List<Step>{new Step('createMetadata', '{"metadata":[{"fullName":"Test__c"}]}',
            '{"result":[{"fullName":"Test__c","success":false,"errors":[{"message":"Duplicate object","statusCode":"DUPLICATE_VALUE","fields":null},{"message":"Invalid name","statusCode":"INVALID_FIELD","fields":[]}]}]}')});
        try {
            MetadataServiceExamples.createObject();
            System.assert(false, 'All metadata errors must be surfaced');
        } catch (MetadataServiceExamples.MetadataServiceExamplesException e) {
            System.assert(e.getMessage().contains('Errors occured processing component Test__c.'));
            System.assert(e.getMessage().contains('Duplicate object (DUPLICATE_VALUE).'));
            System.assert(e.getMessage().contains('Invalid name (INVALID_FIELD).'));
            System.assertEquals(false, e.getMessage().contains(' Fields '));
        }
        verified();
    }
    @IsTest static void acceptsNullSaveResult() {
        Step step = new Step('createMetadata', '{"metadata":[{"fullName":"Test__c"}]}', null);
        // Apex JSON rejects null members of typed object arrays; construct this edge case directly.
        MetadataService.createMetadataResponse_element reply = new MetadataService.createMetadataResponse_element();
        reply.result = new List<MetadataService.SaveResult>{null};
        step.responseOverride = reply;
        setup(new List<Step>{step});
        MetadataServiceExamples.createObject();
        verified();
    }
    @IsTest static void layoutCreationFailureStopsBeforeReadingOrUpdating() {
        setup(new List<Step>{new Step('createMetadata', '{"metadata":[{"fullName":"Test__c.googleButton"}]}',
            '{"result":[{"fullName":"Test__c.googleButton","success":false,"errors":[{"message":"Button rejected","statusCode":"INVALID_FIELD","fields":[]}]}]}')});
        try {
            MetadataServiceExamples.readAndUpdateLayout();
            System.assert(false, 'A failed prerequisite must stop layout processing');
        } catch (MetadataServiceExamples.MetadataServiceExamplesException e) {
            System.assert(e.getMessage().contains('Button rejected'));
        }
        verified();
    }

    private static void verifyAndAbortScheduledJob() {
        List<CronTrigger> jobs = [SELECT Id, State, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Metadata Create %'];
        System.assertEquals(1, jobs.size(), 'Example must schedule one metadata creation job');
        System.assertEquals('WAITING', jobs[0].State, 'Job must wait for asynchronous execution');
        System.abortJob(jobs[0].Id);
        System.assertEquals(0, [SELECT COUNT() FROM CronTrigger WHERE Id = :jobs[0].Id AND State = 'WAITING'],
            'No metadata job may remain waiting after cleanup');
    }
    @IsTest static void schedulesWebLinkCreation() {
        MetadataServiceExamples.createWebLink();
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesFieldCreation() {
        MetadataServiceExamples.createJob();
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesDependentObjectFieldsAndPage() {
        MetadataServiceExamples.dynamicCreation('Demo');
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesRecordTypeCreation() {
        MetadataServiceExamples.createRecordType();
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesPackageCreation() {
        MetadataServiceExamples.installPackagesCreateJob();
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesCustomSiteCreation() {
        MetadataServiceExamples.createCustomSite();
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesDetailObjectAndDependentFields() {
        MetadataServiceExamples.createDetailObject();
        verifyAndAbortScheduledJob();
    }
    @IsTest static void schedulesListViewCreation() {
        MetadataServiceExamples.createListView();
        verifyAndAbortScheduledJob();
    }
}
