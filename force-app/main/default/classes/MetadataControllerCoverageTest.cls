@IsTest
private class MetadataControllerCoverageTest {
    private class ApiMock implements WebServiceMock {
        Boolean done = false;
        Boolean fail = false;
        Boolean emptyList = false;
        String expectedType;
        public void doInvoke(Object stub, Object request, Map<String,Object> response, String endpoint,
            String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            if(request instanceof MetadataService.describeMetadata_element) {
                MetadataService.DescribeMetadataObject objectType = new MetadataService.DescribeMetadataObject();
                objectType.xmlName='CustomObject';
                objectType.childXmlNames=new String[]{'CustomField', null};
                MetadataService.DescribeMetadataObject apexType = new MetadataService.DescribeMetadataObject();
                apexType.xmlName='ApexClass';
                MetadataService.describeMetadataResponse_element result = new MetadataService.describeMetadataResponse_element();
                result.result=new MetadataService.DescribeMetadataResult();
                result.result.metadataObjects=new MetadataService.DescribeMetadataObject[]{objectType, apexType};
                response.put('response_x', result);
            } else if(request instanceof MetadataService.listMetadata_element) {
                MetadataService.listMetadata_element query = (MetadataService.listMetadata_element)request;
                System.assertEquals(1, query.queries.size());
                if(expectedType!=null) System.assertEquals(expectedType, query.queries[0].type_x);
                MetadataService.FileProperties first = new MetadataService.FileProperties();
                first.fullName='Zed';
                MetadataService.FileProperties second = new MetadataService.FileProperties();
                second.fullName='Alpha%20Class';
                MetadataService.listMetadataResponse_element result = new MetadataService.listMetadataResponse_element();
                result.result=emptyList ? null : new MetadataService.FileProperties[]{first, second};
                response.put('response_x', result);
            } else if(request instanceof MetadataService.retrieve_element) {
                MetadataService.RetrieveRequest retrieveRequest = ((MetadataService.retrieve_element)request).retrieveRequest;
                System.assertEquals(true, retrieveRequest.singlePackage);
                System.assertEquals('ApexClass', retrieveRequest.unpackaged.types[0].name);
                System.assertEquals('Alpha Class', retrieveRequest.unpackaged.types[0].members[0]);
                MetadataService.retrieveResponse_element result = new MetadataService.retrieveResponse_element();
                result.result=status(false, false);
                response.put('response_x', result);
            } else if(request instanceof MetadataService.deploy_element) {
                MetadataService.deploy_element deploy = (MetadataService.deploy_element)request;
                System.assertEquals('emlw', deploy.ZipFile);
                System.assertEquals(true, deploy.DeployOptions.rollbackOnError);
                System.assertEquals(true, deploy.DeployOptions.singlePackage);
                System.assertEquals(false, deploy.DeployOptions.checkOnly);
                MetadataService.deployResponse_element result = new MetadataService.deployResponse_element();
                result.result=status(false, false);
                response.put('response_x', result);
            } else if(request instanceof MetadataService.checkStatus_element) {
                System.assertEquals('async-fixture', ((MetadataService.checkStatus_element)request).asyncProcessId[0]);
                MetadataService.checkStatusResponse_element result = new MetadataService.checkStatusResponse_element();
                result.result=new MetadataService.AsyncResult[]{status(done, fail)};
                response.put('response_x', result);
            } else if(request instanceof MetadataService.checkRetrieveStatus_element) {
                MetadataService.checkRetrieveStatusResponse_element result = new MetadataService.checkRetrieveStatusResponse_element();
                result.result=new MetadataService.RetrieveResult();
                result.result.zipFile='emlw';
                response.put('response_x', result);
            } else if(request instanceof MetadataService.checkDeployStatus_element) {
                MetadataService.checkDeployStatusResponse_element result = new MetadataService.checkDeployStatusResponse_element();
                result.result=new MetadataService.DeployResult();
                result.result.details=new MetadataService.DeployDetails();
                MetadataService.DeployMessage error = new MetadataService.DeployMessage();
                error.fileName='classes/HelloWorld.cls';
                error.lineNumber=3;
                error.columnNumber=7;
                error.problem='Unexpected token';
                result.result.details.componentFailures=new MetadataService.DeployMessage[]{error, new MetadataService.DeployMessage()};
                response.put('response_x', result);
            } else {
                System.assert(false, 'Unexpected metadata request: '+requestName);
            }
        }
    }
    private static MetadataService.AsyncResult status(Boolean done, Boolean fail) {
        MetadataService.AsyncResult result = new MetadataService.AsyncResult();
        result.id='async-fixture';
        result.done=done;
        result.state=fail ? 'Error' : (done ? 'Completed' : 'InProgress');
        result.message=fail ? 'Metadata operation failed' : null;
        return result;
    }
    private static Boolean hasMessage(String expected, ApexPages.Severity severity) {
        for(ApexPages.Message message : ApexPages.getMessages())
            if(message.getSummary()==expected && message.getSeverity()==severity) return true;
        return false;
    }
    private static MetadataRetrieveController startRetrieve(ApiMock mock) {
        Test.setMock(WebServiceMock.class, mock);
        MetadataRetrieveController controller = new MetadataRetrieveController();
        controller.MetaDataType='ApexClass';
        controller.MetaDataItem='Alpha Class';
        controller.retrieveMetadataItem();
        System.assertEquals('async-fixture', controller.AsyncResult.id);
        System.assertEquals(null, controller.MetadataFiles);
        return controller;
    }
    @IsTest static void retrieveListsSortedTypesAndDecodedItems() {
        ApiMock mock = new ApiMock();
        mock.expectedType='ApexClass';
        Test.setMock(WebServiceMock.class, mock);
        MetadataRetrieveController controller = new MetadataRetrieveController();
        System.assertEquals(null, controller.init());
        System.assertEquals(3, controller.MetaDataTypes.size(), 'Include child metadata types and ignore null children');
        System.assertEquals('ApexClass', controller.MetaDataType);
        System.assertEquals('CustomField', controller.MetaDataTypes[1].getValue());
        System.assertEquals('Alpha%20Class', controller.MetaDataItems[0].getValue());
        System.assertEquals('Alpha Class', controller.MetaDataItems[0].getLabel());
        System.assertEquals('Zed', controller.MetaDataItems[1].getValue());
        mock.emptyList=true;
        controller.listMetadataItems();
        System.assertEquals(0, controller.MetaDataItems.size(), 'Null list response clears earlier options');
    }
    @IsTest static void retrievePollsExpandsFilesAndClearsZip() {
        ApiMock mock = new ApiMock();
        MetadataRetrieveController controller = startRetrieve(mock);
        controller.checkAsyncRequest();
        System.assertNotEquals(null, controller.AsyncResult, 'Keep request while incomplete');
        System.assertEquals(null, controller.MetaDataRetrieveZip);
        mock.done=true;
        controller.checkAsyncRequest();
        System.assertEquals(null, controller.AsyncResult);
        System.assertEquals('emlw', controller.MetaDataRetrieveZip);
        System.assertEquals(0, controller.MetadataFiles.size());
        controller.MetadataFileName='classes/Alpha.cls';
        controller.MetadataFileData='public class Alpha {}';
        controller.receiveMetadataZipFile();
        System.assertEquals(1, controller.MetadataFiles.size());
        System.assertEquals('classes/Alpha.cls', controller.MetadataFiles[0].getFullname());
        System.assertEquals('public class Alpha {}', controller.MetadataFiles[0].getContent());
        controller.receiveComplete();
        System.assertEquals(null, controller.MetaDataRetrieveZip);
        System.assert(hasMessage('Metadata retrieve completed', ApexPages.Severity.INFO));
        controller.retrieveMetadataItem();
        System.assertEquals(null, controller.MetadataFiles, 'Starting again discards prior extracted files');
    }
    @IsTest static void retrieveReportsAsyncError() {
        ApiMock mock = new ApiMock();
        mock.done=true;
        mock.fail=true;
        MetadataRetrieveController controller=startRetrieve(mock);
        controller.checkAsyncRequest();
        System.assertEquals(null, controller.AsyncResult);
        System.assertEquals(null, controller.MetaDataRetrieveZip);
        System.assert(hasMessage('Metadata operation failed', ApexPages.Severity.INFO));
    }
    @IsTest static void deployPollsAndReportsComponentErrors() {
        ApiMock mock = new ApiMock();
        Test.setMock(WebServiceMock.class, mock);
        MetadataDeployController controller = new MetadataDeployController();
        System.assert(controller.getPackageXml().contains('<members>HelloWorld</members>'));
        System.assert(controller.getHelloWorldMetadata().contains('<status>Active</status>'));
        System.assert(controller.getHelloWorld().contains('public static void helloWorld()'));
        controller.ZipData='emlw';
        controller.deployZip();
        System.assertEquals('async-fixture', controller.AsyncResult.id);
        controller.checkAsyncRequest();
        System.assertNotEquals(null, controller.AsyncResult);
        mock.done=true;
        controller.checkAsyncRequest();
        System.assertEquals(null, controller.AsyncResult);
        System.assert(hasMessage('Deployment complete', ApexPages.Severity.INFO));
        System.assert(hasMessage('classes/HelloWorld.cls (Line: 3: Column:7) : Unexpected token', ApexPages.Severity.ERROR));
    }
    @IsTest static void deployReportsAsyncError() {
        ApiMock mock = new ApiMock();
        mock.done=true;
        mock.fail=true;
        Test.setMock(WebServiceMock.class, mock);
        MetadataDeployController controller = new MetadataDeployController();
        controller.ZipData='emlw';
        controller.deployZip();
        controller.checkAsyncRequest();
        System.assertEquals(null, controller.AsyncResult);
        System.assert(hasMessage('Metadata operation failed', ApexPages.Severity.INFO));
    }
    @IsTest static void treeResponseHasFoldersAndUniqueDecodedLeafNodes() {
        ApiMock mock = new ApiMock();
        Test.setMock(WebServiceMock.class, mock);
        Test.setCurrentPage(new PageReference('/apex/metadataTree'));
        ApexPages.currentPage().getParameters().put('node','root');
        MetadataDataController controller = new MetadataDataController();
        controller.constructResponse();
        List<Object> nodes=(List<Object>)JSON.deserializeUntyped(controller.Data);
        System.assertEquals(3, nodes.size());
        Map<String,Object> folder=(Map<String,Object>)nodes[0];
        System.assertEquals('CustomObject', folder.get('id'));
        System.assertEquals(false, folder.get('leaf'));
        System.assertEquals('folder', folder.get('cls'));
        System.assertEquals('CustomField', ((Map<String,Object>)nodes[1]).get('text'));
        ApexPages.currentPage().getParameters().put('node','ApexClass');
        mock.expectedType='ApexClass';
        controller.constructResponse();
        nodes=(List<Object>)JSON.deserializeUntyped(controller.Data);
        System.assertEquals(2, nodes.size());
        Map<String,Object> leaf=(Map<String,Object>)nodes[1];
        System.assertEquals('Alpha%20Class:1', leaf.get('id'));
        System.assertEquals('Alpha Class', leaf.get('text'));
        System.assertEquals(true, leaf.get('leaf'));
        System.assertEquals(false, leaf.get('checked'));
        System.assertEquals(false, leaf.get('expanded'));
        System.assertEquals(null, leaf.get('children'));
    }
}
