public with sharing class cases {
    
    @AuraEnabled(cacheable=true)
    public static Case[] getCases(){
        return [SELECT Id, CaseNumber, Subject, Priority, Status FROM Case];
    }
}