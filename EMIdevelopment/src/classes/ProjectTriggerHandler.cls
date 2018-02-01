public with sharing class ProjectTriggerHandler {
	public void onAfterUpdate(List<AcctSeed__Project__c> newList, List<AcctSeed__Project__c> oldList, Map<ID, AcctSeed__Project__c> newMap, Map<ID, AcctSeed__Project__c> oldMap ){
		ResetTaskStatusAfterSiteCandChange(newList, oldList, newMap, oldMap);
	}
	public void ResetTaskStatusAfterSiteCandChange(List<AcctSeed__Project__c> newList, List<AcctSeed__Project__c> oldList, Map<ID, AcctSeed__Project__c> newMap, Map<ID, AcctSeed__Project__c> oldMap ){
		System.debug('Enter ResetTaskStatusAfterSiteCandChange');
		Map<ID,List<AcctSeed__Project_Task__c>> TaskMap = new Map<ID, List<AcctSeed__Project_Task__c>>();
		List<AcctSeed__Project_Task__c> TaskList = [SELECT ID, NAME, AcctSeed__Status__c, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :newList Order by AcctSeed__Project__c, AcctSeed__Sort_Order__c];

		for(AcctSeed__Project_Task__c apt : TaskList){
			if(newMap.get(apt.AcctSeed__Project__c).Site_Candidate__c != oldMap.get(apt.AcctSeed__Project__c).Site_Candidate__c){
				if(!TaskMap.containsKey(apt.AcctSeed__Project__c)){
					TaskMap.put(apt.AcctSeed__Project__c, new List<AcctSeed__Project_Task__c>());
				}
				TaskMap.get(apt.AcctSeed__Project__c).add(apt);
			}
		}
		TaskList.clear();
		for(ID i : TaskMap.keySet()){
			for(AcctSeed__Project_Task__c apt : TaskMap.get(i)){
				apt.AcctSeed__Status__c = 'Active';
			}
			//update TaskMap.get(i);

			TaskList.addAll(TaskMap.get(i));
		}
		update TaskList;


	}

}