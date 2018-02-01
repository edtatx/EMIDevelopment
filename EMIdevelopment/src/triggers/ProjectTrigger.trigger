trigger ProjectTrigger on AcctSeed__Project__c (after update) {
	ProjectTriggerHandler objHandler = new ProjectTriggerHandler();
	if(trigger.isAfter && trigger.isUpdate){
		objHandler.onAfterUpdate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
	}
	
}