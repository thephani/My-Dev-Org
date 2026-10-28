@IsTest
private class MetadataServiceContractTest {
    private static final String NS = 'http://soap.sforce.com/2006/04/metadata';
    private static final String ENDPOINT = 'https://metadata.example.test/services/Soap/m/30.0';
    private class ContractMock implements WebServiceMock {
        private String operation;
        private String metadataType;
        ContractMock(String operation, String metadataType) {
            this.operation = operation;
            this.metadataType = metadataType;
        }
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName, String responseNS,
            String responseName, String responseType) {
            System.assert(stub instanceof MetadataService.MetadataPort);
            System.assertEquals(ENDPOINT, endpoint);
            System.assertEquals('', soapAction);
            System.assertEquals(operation, requestName);
            System.assertEquals(NS, responseNS);
            System.assertEquals(operation + 'Response', responseName);
            String resultJson;
            if (operation == 'readMetadata') {
                MetadataService.readMetadata_element input = (MetadataService.readMetadata_element)request;
                System.assertEquals(metadataType, input.type_x);
                System.assertEquals(new String[]{'Fixture'}, input.fullNames);
                System.assertEquals('MetadataService.read' + metadataType + 'Response_element', responseType);
                resultJson = '{"result":{"records":[{"fullName":"Fixture"}]}}';
            } else {
                System.assertEquals('MetadataService.' + operation + 'Response_element', responseType);
                if (operation == 'renameMetadata') {
                    MetadataService.renameMetadata_element input = (MetadataService.renameMetadata_element)request;
                    System.assertEquals('CustomObject', input.type_x);
                    System.assertEquals('Before__c', input.oldFullName);
                    System.assertEquals('After__c', input.newFullName);
                    resultJson = '{"result":{"fullName":"After__c","success":true}}';
                } else if (operation == 'cancelDeploy') {
                    System.assertEquals('deployment-id', ((MetadataService.cancelDeploy_element)request).String_x);
                    resultJson = '{"result":{"id":"deployment-id","done":true}}';
                } else if (operation == 'deleteMetadata') {
                    MetadataService.deleteMetadata_element input = (MetadataService.deleteMetadata_element)request;
                    System.assertEquals('CustomObject', input.type_x);
                    System.assertEquals(new String[]{'Fixture__c'}, input.fullNames);
                    resultJson = '{"result":[{"fullName":"Fixture__c","success":true}]}';
                } else {
                    MetadataService.Metadata[] payload;
                    if (operation == 'createMetadata') {
                        payload = ((MetadataService.createMetadata_element)request).metadata;
                    } else {
                        System.assertEquals('updateMetadata', operation);
                        payload = ((MetadataService.updateMetadata_element)request).metadata;
                    }
                    System.assertEquals(1, payload.size());
                    System.assertEquals('Fixture__c', payload[0].fullName);
                    resultJson = '{"result":[{"fullName":"Fixture__c","success":true}]}';
                }
            }
            Type responseClass = Type.forName(responseType);
            System.assertNotEquals(null, responseClass, responseType);
            response.put('response_x', JSON.deserialize(resultJson, responseClass));
        }
    }
    private static MetadataService.MetadataPort port(String operation, String metadataType) {
        Test.setMock(WebServiceMock.class, new ContractMock(operation, metadataType));
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.endpoint_x = ENDPOINT;
        return service;
    }
    @IsTest static void synchronousCrudReturnsPopulatedResults() {
        MetadataService.Metadata record = new MetadataService.Metadata();
        record.fullName = 'Fixture__c';
        MetadataService.SaveResult[] created = port('createMetadata', null).createMetadata(new MetadataService.Metadata[]{record});
        System.assertEquals(1, created.size());
        System.assertEquals('Fixture__c', created[0].fullName);
        System.assertEquals(true, created[0].success);
        MetadataService.SaveResult[] updated = port('updateMetadata', null).updateMetadata(new MetadataService.Metadata[]{record});
        System.assertEquals(1, updated.size());
        System.assertEquals('Fixture__c', updated[0].fullName);
        System.assertEquals(true, updated[0].success);
        MetadataService.DeleteResult[] deleted = port('deleteMetadata', null).deleteMetadata('CustomObject', new String[]{'Fixture__c'});
        System.assertEquals(1, deleted.size());
        System.assertEquals('Fixture__c', deleted[0].fullName);
        System.assertEquals(true, deleted[0].success);
    }
    @IsTest static void renameAndCancelPreserveServerResults() {
        MetadataService.SaveResult renamed = port('renameMetadata', null).renameMetadata('CustomObject', 'Before__c', 'After__c');
        System.assertEquals('After__c', renamed.fullName);
        System.assertEquals(true, renamed.success);
        MetadataService.CancelDeployResult cancelled = port('cancelDeploy', null).cancelDeploy('deployment-id');
        System.assertEquals('deployment-id', cancelled.id);
        System.assertEquals(true, cancelled.done);
    }
    private static void assertReadContracts(String[] metadataTypes) {
        for (String metadataType : metadataTypes) {
            MetadataService.IReadResult result = port('readMetadata', metadataType).readMetadata(metadataType, new String[]{'Fixture'});
            System.assertNotEquals(null, result, metadataType);
            MetadataService.Metadata[] records = result.getRecords();
            System.assertEquals(1, records.size(), metadataType);
            // Generated metadata types redeclare inherited fields for XML serialization.
            Map<String, Object> record = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(records[0]));
            System.assertEquals('Fixture', record.get('fullName'), metadataType);
        }
    }
    @IsTest static void polymorphicReadContracts1() {
        assertReadContracts(new String[]{'WorkflowRule', 'SamlSsoConfig', 'CustomLabel', 'BusinessHoursEntry', 'MobileSettings', 'ChatterAnswersSettings', 'SharingRules', 'Portal', 'Skill', 'EscalationRules', 'WorkflowAlert', 'CustomDataType', 'ExternalDataSource', 'EntitlementProcess', 'RecordType', 'Scontrol', 'DataCategoryGroup', 'ValidationRule', 'Profile', 'IdeasSettings', 'ConnectedApp', 'ApexPage', 'ProductSettings', 'LiveAgentSettings', 'OpportunitySettings', 'LiveChatDeployment', 'ActivitiesSettings', 'Layout', 'WebLink', 'SiteDotCom', 'CompanySettings', 'HomePageLayout', 'Dashboard', 'AssignmentRules', 'EmailFolder', 'AnalyticSnapshot', 'EscalationRule', 'CustomSite', 'Group', 'ReportType'});
    }
    @IsTest static void polymorphicReadContracts2() {
        assertReadContracts(new String[]{'QuickAction', 'CustomPageWebLink', 'ApexComponent', 'BaseSharingRule', 'WorkflowKnowledgePublish', 'EntitlementTemplate', 'FlexiPage', 'WorkflowAction', 'Workflow', 'AddressSettings', 'ContractSettings', 'DashboardFolder', 'CustomObject', 'Translations', 'RoleOrTerritory', 'ApexTrigger', 'CustomLabels', 'SecuritySettings', 'CallCenter', 'PicklistValue', 'RemoteSiteSetting', 'WorkflowSend', 'QuoteSettings', 'SynonymDictionary', 'WorkflowOutboundMessage', 'PostTemplate', 'WorkflowFieldUpdate', 'CustomTab', 'Letterhead', 'InstalledPackage', 'Queue', 'AuthProvider', 'EntitlementSettings', 'DocumentFolder', 'CustomField', 'WorkflowTask', 'StaticResource', 'EmailTemplate', 'SharingReason', 'LiveChatButton'});
    }
    @IsTest static void polymorphicReadContracts3() {
        assertReadContracts(new String[]{'Network', 'ApprovalProcess', 'MilestoneType', 'AssignmentRule', 'CompactLayout', 'LiveChatAgentConfig', 'AccountSettings', 'BusinessProcess', 'Flow', 'AutoResponseRule', 'PermissionSet', 'BusinessHoursSettings', 'ForecastingSettings', 'Report', 'AppMenu', 'ListView', 'OrderSettings', 'CustomObjectTranslation', 'KnowledgeSettings', 'CustomApplication', 'CaseSettings', 'ApexClass', 'Package', 'Community', 'Document', 'AutoResponseRules', 'Folder', 'ReportFolder', 'CustomApplicationComponent', 'FieldSet', 'SharingSet', 'HomePageComponent'});
    }
}
