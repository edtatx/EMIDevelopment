@isTest(SeeAllData=true)
private class TestGanntExtension {
	
	@isTest static void test_method_one() {
		AcctSeed__GL_Account__c glacct = new AcctSeed__GL_Account__c(name='123', AcctSeed__Type__c='Expense');
		insert glacct;
		Account a = new Account(name='AT&T');
		insert a;
		Map<String, RecordType> RecTypeMap = new Map<String, RecordType>();
		List<RecordType> RecList  = [select id, name from recordtype where sobjecttype ='AcctSeed__Project__c'];
		for(RecordType r : RecList){
			RecTypeMap.put(r.name, r);
		}

		AcctSeed__Project__c ASP = new AcctSeed__Project__c(name='Program1', RecordTypeid = RecTypeMap.get('Program').ID, 
			AcctSeed__Account__c=a.id, GL_Labor_Account__c =glacct.id);
		insert ASP;

	
		AcctSeed__Project__c ASPSite = new AcctSeed__Project__c(name='Program1', RecordTypeid = RecTypeMap.get('Site').ID, AcctSeed__Account__c=a.id, Program__c=ASP.ID, GL_Labor_Account__c =glacct.id);
		insert ASPSite;

		Project_Phase__c PP = new Project_Phase__c(name='Leasing', Project__c=ASPSite.ID, Forecasted_Start_Date__c = System.today(), Forecasted_End_Date__c = System.Today()+1);
		insert PP;

		AcctSeed__Project_Task__c PT = new AcctSeed__Project_Task__c(name='L101', Project_Phase__c=PP.ID, Description__c ='test', Duration_Days__c = 1, Baseline_Start_Date__c = System.Today(), Baseline_End_Date__c = System.today()+1,
			AcctSeed__Labor_GL_Account__c=glacct.id, AcctSeed__Project__c=ASPSite.ID, acctSeed__Start_Date__c = System.today(), AcctSeed__End_Date__c=System.today()+1, Forecasted_Start_Date__c = System.today(), Forecasted_End_Date__c= System.today()+1 );
		insert PT;

		Test.startTest();
		Test.setCurrentPage(Page.Gantt);
		ApexPages.StandardController stdController = new ApexPages.StandardController(ASPSite);
		GanttControllerExtension GCE = new GanttControllerExtension(stdController);

		Test.stopTest();


		
	}
	
	
	
}