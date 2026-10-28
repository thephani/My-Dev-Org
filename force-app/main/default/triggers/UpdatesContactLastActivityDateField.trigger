trigger UpdatesContactLastActivityDateField on Event(after insert) {
    List < Id > eventIdList = new List < Id > ();

    for (Event event: trigger.new) {
        if (event.WhoId != null && event.WhoId.getSObjectType() == Contact.SObjectType) {

            eventIdList.add(event.WhoId);

            /*

            Contact EveContact = [SELECT Id, Last_Activity_Date__c FROM Contact WHERE Id = : Event.WhoId];
            EveContact.Last_Activity_Date__c = Date.today();
            Update EveContact;
          */
        }
    }

    List < Contact > contactList = new List < Contact> ();

    for (Contact con: [SELECT Id FROM Contact WHERE Id IN :eventIdList]) {
        //con.Last_Activity_Date__c = Date.today();
        contactList.add(con);
    }

    if (contactList.size() > 0) {
        update contactList;
    }

}
