trigger ProjectTaskTrigger on AcctSeed__Project_Task__c (before update, after update) {
    ProjectTaskTriggerHandler objHandler = new ProjectTaskTriggerHandler();
    if(trigger.isBefore && trigger.isUpdate){
        objHandler.onBeforeUpdate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        objHandler.onAfterUpdate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
    }
}