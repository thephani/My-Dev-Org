@IsTest
private class BusinessControllerCoverageTest {
    @IsTest static void activityTimelineIncludesOnlySelectedAccountAndTypes() {
        Account account = new Account(Name='Timeline fixture');
        Account other = new Account(Name='Other timeline');
        insert new List<Account>{account, other};
        Case supportCase = new Case(AccountId=account.Id, Subject='Timeline case', Status='New', Origin='Web');
        insert supportCase;
        Task task = new Task(WhatId=account.Id, Subject='Timeline task', ActivityDate=Date.today(), Status='Not Started', Priority='Normal');
        insert task;
        Event meeting = new Event(WhatId=account.Id, Subject='Timeline meeting', StartDateTime=System.now().addHours(1), EndDateTime=System.now().addHours(2));
        insert meeting;
        Note note = new Note(ParentId=account.Id, Title='Timeline note', Body='Details');
        insert note;
        insert new Note(ParentId=other.Id, Title='Unrelated', Body='Excluded');
        Test.setCurrentPage(new PageReference('/apex/timeline'));
        ApexPages.currentPage().getParameters().put('id', account.Id);
        bsController controller = new bsController();
        System.assertEquals(account.Id, controller.acct.Id);
        System.assertEquals(4, controller.intgerated_notes.size(), 'Every supported activity type should appear once');
        Map<String, bsController.IntegratedNotes> byId = new Map<String, bsController.IntegratedNotes>();
        for(bsController.IntegratedNotes row : controller.intgerated_notes) byId.put(row.in_object, row);
        System.assertEquals('Timeline task', byId.get(task.Id).in_subject);
        System.assertEquals(Date.today().format(), byId.get(task.Id).in_Date);
        System.assertEquals(UserInfo.getUserId(), byId.get(note.Id).in_user_id);
        System.assertEquals('Details', byId.get(note.Id).in_type_code);
        System.assert(byId.containsKey(supportCase.Id));
        System.assert(byId.containsKey(meeting.Id));
        controller.bCase=false;
        controller.bTask=false;
        controller.bEvent=false;
        controller.fetchIntegratedNotes();
        System.assertEquals(1, controller.intgerated_notes.size(), 'Object toggles should leave only notes');
        controller.bNote=false;
        controller.fetchIntegratedNotes();
        System.assertEquals(0, controller.intgerated_notes.size(), 'Refreshing clears prior results');

        controller.initializeVariables();
        controller.dataRange.StartDateTime=System.now().addDays(-1);
        controller.dataRange.EndDateTime=System.now().addDays(1);
        controller.fetchIntegratedNotes();
        System.assertEquals(4, controller.intgerated_notes.size(), 'Date window includes current records');
        controller.dataRange.StartDateTime=System.now().addDays(-10);
        controller.dataRange.EndDateTime=System.now().addDays(-5);
        controller.fetchIntegratedNotes();
        System.assertEquals(0, controller.intgerated_notes.size(), 'Date window excludes newer records');
        System.assertEquals(0, controller.lCases.size());
        System.assertEquals(0, controller.lTasks.size());
        System.assertEquals(0, controller.lEvents.size());
        System.assertEquals(0, controller.lNotes.size());

        bsController standard = new bsController(new ApexPages.StandardController(account));
        System.assertEquals(4, standard.intgerated_notes.size(), 'Standard-controller entry point has the same timeline');
    }
    @IsTest static void timelineWithoutAccountIsEmpty() {
        Test.setCurrentPage(new PageReference('/apex/timeline'));
        bsController controller = new bsController();
        System.assertEquals(null, controller.acct);
        System.assertEquals(0, controller.intgerated_notes.size());
        System.assertEquals(true, controller.bCNote);
        bsController.IntegratedNotes empty = new bsController.IntegratedNotes();
        System.assertEquals(null, empty.in_subject);
    }
    private static Boolean hasOption(List<SelectOption> options, String value) {
        for(SelectOption option : options) if(option.getValue()==value) return true;
        return false;
    }
    @IsTest static void pageGeneratorMovesFieldsAndBuildsSectionMarkup() {
        vfPageGenerator controller = new vfPageGenerator();
        System.assert(hasOption(controller.getObjNameList(), 'Account'));
        controller.objName='Account';
        System.assertEquals(null, controller.getFieldList());
        String nameLabel = Account.Name.getDescribe().getLabel();
        String phoneLabel = Account.Phone.getDescribe().getLabel();
        System.assert(controller.objFields.contains(nameLabel));
        System.assertEquals('Name', controller.filedAPINameMap.get(nameLabel));
        controller.leftselected=new List<String>{phoneLabel, nameLabel};
        controller.rightselected=new List<String>();
        controller.selectclick();
        System.assertEquals(2, controller.getSelectedValues().size());
        System.assert(!hasOption(controller.getunSelectedValues(), nameLabel));
        controller.rightselected=new List<String>{phoneLabel};
        controller.unselectclick();
        System.assertEquals(0, controller.leftselected.size());
        System.assert(hasOption(controller.getunSelectedValues(), phoneLabel));
        System.assertEquals(1, controller.getSelectedValues().size());
        controller.pbsName='Account';
        controller.clearRightSelectionAddToMap();
        System.assertEquals(0, controller.rightvalues.size());
        System.assert(controller.conStr.contains('Account Details'));
        System.assert(controller.conStr.contains('{!Account.Name}'));
        controller.previewVf();
        System.assert(controller.getVfTags.startsWith('<apex:page standardController=\'Account\'>'));
        System.assert(controller.getVfTags.endsWith('</apex:page>'));
        System.assert(controller.getVfTags.contains(controller.conStr));
    }
    @IsTest static void alternateGeneratorMovesFieldsAndBuildsSectionMarkup() {
        vfGenerator1Controller controller = new vfGenerator1Controller();
        System.assert(hasOption(controller.getObjNameList(), 'Contact'));
        controller.objName='Contact';
        controller.getFieldList();
        String emailLabel = Contact.Email.getDescribe().getLabel();
        String phoneLabel = Contact.Phone.getDescribe().getLabel();
        System.assertEquals('Email', controller.filedAPINameMap.get(emailLabel));
        controller.leftselected=new List<String>{emailLabel, phoneLabel};
        controller.rightselected=new List<String>();
        controller.selectclick();
        System.assertEquals(2, controller.getSelectedValues().size());
        System.assert(!hasOption(controller.getunSelectedValues(), emailLabel));
        controller.rightselected=new List<String>{phoneLabel};
        controller.unselectclick();
        System.assert(hasOption(controller.getunSelectedValues(), phoneLabel));
        System.assertEquals(1, controller.getSelectedValues().size());
        controller.pbsName='Communication';
        controller.clearRightSelectionAddToMap();
        System.assertEquals(0, controller.rightvalues.size());
        System.assert(controller.conStr.contains('Communication Details'));
        System.assert(controller.conStr.contains('{!Contact.Email}'));
        controller.previewVf();
        System.assert(controller.getVfTags.contains('standardController=\'Contact\''));
        System.assert(controller.getVfTags.contains(controller.conStr));
        System.assert(controller.getVfTags.endsWith('</apex:page>'));
    }
}
