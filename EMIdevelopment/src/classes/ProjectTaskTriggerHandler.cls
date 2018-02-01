public with sharing class ProjectTaskTriggerHandler {
	private static Boolean HasRun=false;
	private static Set<ID> ProjTaskHasRunSet = new Set<ID>();
	public void onBeforeUpdate(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap ){
		SetEndDateFromStartDateDuration(newList, oldList, newMap, OldMap);
	}
	public void onAfterUpdate(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap ){
		
		if(!HasRun){
			CreateBillingLinesForBillableTaskCompletion(newList, oldList, newMap, oldMap);
			UpdateProjectPhasePercentComplete(newList, oldList, newMap, oldMap);
			
		}
		CascadeTaskDateChanges(newList, oldList, newMap, oldMap);
		HasRun = true;
		
		
	}
	public void SetEndDateFromStartDateDuration(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap){
		for(AcctSeed__Project_Task__c apt : newList){
			//apt.Forecasted_End_Date__c = apt.Forecasted_Start_date__c.addDays(apt.Duration_Days__c.intValue());
		}
	}
	/*public void CheckSuccessorTaskStatusAgainstPredecessor(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap){
		List<AcctSeed__Project_Task__c> Predecessor = [select id,name, Predecessor1__r.AcctSeed__Status__c,AcctSeed__Status__c FROM AcctSeed__Project_Task__c
			WHERE ID IN :newList];

		for(AcctSeed__Project_Task__c tsk : Predecessor){
			System.debug(tsk.Predecessor1__r.AcctSeed__Status__c);
			System.debug(tsk.AcctSeed__Status__c);
			if(tsk.Predecessor1__c != null && tsk.Predecessor1__r.AcctSeed__Status__c != 'Completed' && newMap.get(tsk.id).AcctSeed__Status__c =='Completed' )
				newMap.get(tsk.id).addError('Predecessor task must be completed before successor tasks can be completed.');
		}
	}*/
	public void CreateBillingLinesForBillableTaskCompletion(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap){
		List<AcctSeed__Accounting_Period__c> APCList = [select id, name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM 
			AcctSeed__Accounting_Period__c WHERE AcctSeed__Status__c = 'Open'];

		List<AcctSeed__Billing_Format__c> BFList = [SELECT ID, NAME FROM AcctSeed__Billing_Format__c WHERE AcctSeed__Type__c = 'Billing' ];
		List<AcctSeed__Accounting_Variable__c> AVList = [SELECT AcctSeed__Active__c,AcctSeed__Type__c,Code__c,Id,Name FROM AcctSeed__Accounting_Variable__c where AcctSeed__Type__c = 'GL Account Variable 1'];
		Map<ID, AcctSeed__Billing_Format__c> AccCompanyToBillingFormat = new Map<ID, AcctSeed__Billing_Format__c>();
        for(AcctSeed__Billing_Format__c abf : BFList){
			for(AcctSeed__Accounting_Variable__c aav : AVList){
				if(abf.name=='Default Billing Product')
					AccCompanyToBillingFormat.put(aav.id, abf);
				else if(aav.Name=='Next Edge LLC' && abf.name=='NextEdge Billing Product')
					AccCompanyToBillingFormat.put(aav.id, abf);
			}
		}

		Map<id, AcctSeed__Project_Task__c> ProjTaskMapWithProjInfo = new Map<ID, AcctSeed__Project_Task__c>();
		ProjTaskMapWithProjInfo.putAll([SELECT ID, Name, AcctSeed__Status__c, Billable__c, AcctSeed__Project__r.AcctSeed__Account__r.Name, 
		 AcctSeed__Project__r.AcctSeed__Account__r.BillingStreet, AcctSeed__Project__r.AcctSeed__Account__r.BillingCity, 
		 AcctSeed__Project__r.AcctSeed__Account__r.BillingPostalCode, AcctSeed__Project__r.AcctSeed__Account__r.BillingCountry,
		 AcctSeed__Project__r.AcctSeed__Account__r.BillingState, AcctSeed__Project__r.AcctSeed__Account__c,
		 AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Format__c, 
		 AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Terms_Name__c,AcctSeed__Project__r.Name FROM AcctSeed__Project_Task__c WHERE ID IN :newList]);

		List<AcctSeed__Billing__c> BillHeaderList = new List<AcctSeed__Billing__c>();
		List<AcctSeed__Billing_Line__c> BillLineList = new List<AcctSeed__Billing_Line__c>();
		for(AcctSeed__Project_Task__c apt : newList){
			System.debug(apt.AcctSeed__Project__r.Name);
			System.debug(newLIst);
			if(apt.AcctSeed__Status__c == 'Completed' && oldMap.get(apt.id).AcctSeed__Status__c != 'Completed' && apt.Billable__c){//Create new project billing for billable milestone completion
				BillHeaderList.add(new AcctSeed__Billing__c(AcctSeed__Accounting_Period__c = APCList[0].id, AcctSeed__Billing_City__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__r.BillingCity,
				AcctSeed__Billing_State__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__r.BillingState, AcctSeed__Billing_Street__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__r.BillingStreet,
				AcctSeed__Billing_PostalCode__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__r.BillingPostalCode, AcctSeed__Billing_Country__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__r.BillingCountry,
				AcctSeed__Date__c = System.today(), AcctSeed__Billing_Format__c = AccCompanyToBillingFormat.get(apt.AcctSeed__GL_Account_Variable_1__c).id,
				AcctSeed__Billing_Terms_Name__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Terms_Name__c, 
				AcctSeed__Customer__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.AcctSeed__Account__c, 
				Project__c = apt.AcctSeed__Project__c));

				BillLineList.add(new AcctSeed__Billing_Line__c(AcctSeed__Date__c = System.Today(), AcctSeed__GL_Account_Variable_1__c = apt.AcctSeed__GL_Account_Variable_1__c,
					AcctSeed__Project__c = apt.AcctSeed__Project__c, AcctSeed__Project_Task__c = apt.id, AcctSeed__Rate__c = apt.Billable_Amount__c, AcctSeed__Product__c = apt.Product__c,
					AcctSeed__Comment__c = ProjTaskMapWithProjInfo.get(apt.id).AcctSeed__Project__r.Name ));
			}

		}
		insert BillHeaderList;
		Map<ID, AcctSeed__Billing__c> ProjToBillHeaderMap = new Map<ID, AcctSeed__Billing__c>();
		for(AcctSeed__Billing__c ab : BillHeaderList){
			ProjToBillHeaderMap.put(ab.Project__c, ab);
		}
		for(AcctSeed__Billing_Line__c abl : BillLineList){
			abl.AcctSeed__Billing__c = ProjToBillHeaderMap.get(abl.AcctSeed__Project__c).id;
		}
		insert BillLineList;
	}
	public void UpdateProjectPhasePercentComplete(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap){
		Set<ID> ProjectIDSet = new Set<ID>();
		Set<ID> ProjectPhaseIDSet = new Set<ID>();
		Map<ID, AcctSeed__Project__c> ProjMap = new Map<ID, AcctSeed__Project__c>();
		for(AcctSeed__Project_Task__c apt : newList){
			ProjectIDSet.add(apt.AcctSeed__Project__c);
			ProjectPhaseIDSet.add(apt.Project_Phase__c);
			ProjMap.put(apt.AcctSeed__Project__c, null);
		}
		ProjMap.putAll([SELECT id, name, Percent_Complete__c FROM AcctSeed__Project__c WHERE ID IN :ProjMap.keySet()]);

		Map<ID, Project_Phase__c> PhaseMap = new Map<ID, Project_Phase__c>();

		PhaseMap.putAll([select id, name,Project__c, Percent_Complete__c from Project_Phase__c WHERE Project__c IN :ProjectIDSet order by Project__c, sort_order__c]);

		List<AcctSeed__Project_Task__c> ptList = [select id, name, AcctSeed__Status__c,Project_Phase__c FROM AcctSeed__Project_Task__c 
		WHERE Project_Phase__c IN : PhaseMap.KeySet() ORDER BY AcctSeed__Project__c, Project_Phase__r.sort_order__c,name ];

		Map<ID, List<AcctSeed__Project_Task__c>> PhaseIDtoTaskList = new Map<ID, List<AcctSeed__Project_Task__c>>();

		for(AcctSeed__Project_Task__c apt : ptList){
			if(!PhaseIDtoTaskList.containsKey(apt.Project_Phase__c))
				PhaseIDtoTaskList.put(apt.Project_Phase__c, new List<AcctSeed__Project_Task__c>());
			PhaseIDtoTaskList.get(apt.Project_Phase__c).add(apt);
		}

		integer totalTaskCount=0;
		integer TotalCompletedCount =0;
		integer TotalProjectTaskCount=0;
		integer TotalProjectTaskComplete=0;
		ID CurrentProjectID = null;
		for(ID i : PhaseIDtoTaskList.keySet()){
			totalTaskCount=0;
			TotalCompletedCount=0;
			if(CurrentProjectID != null && CurrentProjectID != PhaseMap.get(i).Project__c){
				TotalProjectTaskCount = 0;
				TotalProjectTaskComplete =0;
			}
			for(AcctSeed__Project_Task__c apt : PhaseIDtoTaskList.get(i)){					
				
				totalTaskCount++;
				TotalCompletedCount += apt.AcctSeed__Status__c == 'Completed' ? 1 : 0;
				TotalProjectTaskCount++;
				TotalProjectTaskComplete += apt.AcctSeed__Status__c == 'Completed' ? 1 : 0;
				System.debug(apt.AcctSeed__Status__c);
				System.debug(totalTaskCount);
				System.debug(TotalCompletedCount);
				System.debug((double)TotalCompletedCount/(double)totalTaskCount);
			}
			PhaseMap.get(i).Percent_Complete__c =((double)TotalCompletedCount/(double)totalTaskCount) * 100 ;
			ProjMap.get(PhaseMap.get(i).Project__c).Percent_Complete__c = ((double)TotalProjectTaskComplete/(double)TotalProjectTaskCount) * 100 ;
			CurrentProjectID = PhaseMap.get(i).Project__c;
		}
		update PhaseMap.values();
		update ProjMap.values();
	}

	public void CascadeTaskDateChanges (List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap) {
		//TODO: update method return type and input parameters (they do need to be List)
		HasRun = true;
		Map<ID, Project_Phase__c> PhaseMap = new Map<ID,Project_Phase__c>();
		Set<ID> ProjIDSet = new Set<ID>();
		for(AcctSeed__Project_Task__c apt : newList){
			ProjIDSet.add(apt.AcctSeed__Project__c);
		}
		
		Map<ID, AcctSeed__Project_Task__c> TaskMap = new Map<ID, AcctSeed__Project_Task__c>();
		TaskMap.putAll([SELECT ID, Name, Duration_Days__c, Forecasted_End_Date__c, Forecasted_Start_Date__c, AcctSeed__Project__c,
			 Predecessor1__c, Project_Phase__c, Baseline_Start_Date__c, Baseline_End_Date__c,Is_New__c, Adjust_Successor_Forecast_Off_of_Actuals__c,
			 AcctSeed__Start_Date__c, AcctSeed__End_Date__c
			 FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :ProjIDSet and ID NOT IN :ProjTaskHasRunSet
			 ORDER BY AcctSeed__Project__c, AcctSeed__Sort_Order__c ]);



		for(AcctSeed__Project_Task__c apt: TaskMap.values()){
			ProjTaskHasRunSet.add(apt.id);
			if(!PhaseMap.containsKey(apt.Project_Phase__c) && apt.Project_Phase__c!= null)
				PhaseMap.put(apt.Project_Phase__c, new Project_Phase__c(id=apt.Project_Phase__c));
			if(apt.Project_Phase__c != null){
				PhaseMap.get(apt.Project_Phase__c).Forecasted_Start_Date__c = 
					PhaseMap.get(apt.Project_Phase__c).Forecasted_Start_Date__c == null || PhaseMap.get(apt.Project_Phase__c).Forecasted_Start_Date__c > apt.Forecasted_Start_Date__c ? apt.Forecasted_Start_Date__c : PhaseMap.get(apt.Project_Phase__c).Forecasted_Start_Date__c;

				PhaseMap.get(apt.Project_Phase__c).Forecasted_End_Date__c = 
					PhaseMap.get(apt.Project_Phase__c).Forecasted_End_Date__c == null || PhaseMap.get(apt.Project_Phase__c).Forecasted_End_Date__c < apt.Forecasted_End_Date__c ? apt.Forecasted_End_Date__c : PhaseMap.get(apt.Project_Phase__c).Forecasted_End_Date__c;
			}
			if(!String.isBlank(apt.Predecessor1__c) && TaskMap.containsKey(apt.Predecessor1__c)){
				System.debug(apt.Predecessor1__c);
				System.debug(apt.Name);
				System.debug(TaskMap.containsKey(apt.Predecessor1__c));
				System.debug(TaskMap.get(apt.Predecessor1__c).Name);
				System.debug(TaskMap.get(apt.Predecessor1__c).Adjust_Successor_Forecast_Off_of_Actuals__c);
				System.debug(TaskMap.get(apt.Predecessor1__c).AcctSeed__End_Date__c);
				System.debug(TaskMap.get(apt.Predecessor1__c).Forecasted_End_Date__c);
				Date PredecessorForecastOrActualEndDate = TaskMap.get(apt.Predecessor1__c).Adjust_Successor_Forecast_Off_of_Actuals__c && TaskMap.get(apt.Predecessor1__c).AcctSeed__End_Date__c != null ? TaskMap.get(apt.Predecessor1__c).AcctSeed__End_Date__c : TaskMap.get(apt.Predecessor1__c).Forecasted_End_Date__c ;
				System.debug(PredecessorForecastOrActualEndDate);
 				apt.Forecasted_Start_Date__c = PredecessorForecastOrActualEndDate;
				apt.Forecasted_End_Date__c = apt.Forecasted_Start_Date__c.AddDays(apt.Duration_Days__c.intvalue());				
			}
			apt.Baseline_Start_Date__c = apt.Is_new__c == true ? apt.Forecasted_Start_Date__c : apt.Baseline_Start_Date__c;
			apt.Baseline_End_Date__c = apt.Is_new__c == true ? apt.Forecasted_End_Date__c : apt.Baseline_End_Date__c;

		}
		for(AcctSeed__Project_Task__c apt : TaskMap.values()){
			apt.Is_new__c = false;
		}
		update TaskMap.values();
		if(!Test.isRunningTest() && !PhaseMap.isEmpty())
			update PhaseMap.values();
	}

	/*public void CascadeDateChanges(List<AcctSeed__Project_Task__c> newList, List<AcctSeed__Project_Task__c> oldList, Map<ID, AcctSeed__Project_Task__c> newMap, Map<ID, AcctSeed__Project_Task__c> oldMap){
		List<AcctSeed__Project_Task__c> EndDateChangedList = new List<AcctSeed__Project_Task__c>();
		for(AcctSeed__Project_Task__c apt : newList){
			if(apt.Forecasted_End_Date__c != oldMap.get(apt.id).Forecasted_End_Date__c)
				EndDateChangedList.add(apt);
		}
		if(EndDateChangedList.size() == 0)
			return;
		List<AcctSeed__Project_Task__c> SuccessorTasks = [SELECT ID, Name, Forecasted_End_Date__c, Forecasted_Start_date__c, Duration_Days__c, Predecessor1__c FROM
			AcctSeed__Project_Task__c Where Predecessor1__c IN :newList ORDER by Predecessor1__c];
		Map<ID, List<AcctSeed__Project_Task__c>> PredecessorIDToSuccessorMap = new Map<ID, List<AcctSeed__Project_Task__c>>();
		List<AcctSeed__Project_Task__c> TasksToUpdate = new List<AcctSeed__Project_Task__c>();
		for(AcctSeed__Project_Task__c apt: SuccessorTasks){
			if(!PredecessorIDToSuccessorMap.containsKey(apt.Predecessor1__c))
				PredecessorIDToSuccessorMap.put(apt.Predecessor1__c, new List<AcctSeed__Project_Task__c>());
			PredecessorIDToSuccessorMap.get(apt.Predecessor1__c).add(apt);
		}

		for(AcctSeed__Project_Task__c apt: newList){
			if(apt.Forecasted_End_Date__c != oldMap.get(apt.id).Forecasted_End_Date__c && PredecessorIDToSuccessorMap.containsKey(apt.id)){// Start Date Change
				for(AcctSeed__Project_Task__c apt1 : PredecessorIDToSuccessorMap.get(apt.id)){
					apt1.Forecasted_Start_date__c = apt.Forecasted_End_Date__c;
					apt1.Forecasted_End_Date__c = apt1.Forecasted_Start_date__c.addDays(apt1.Duration_Days__c.intvalue());
					TasksToUpdate.add(apt1);
				}
			}
		}
		if(TasksToUpdate.size() > 0)
			update TasksToUpdate;
	}*/

}