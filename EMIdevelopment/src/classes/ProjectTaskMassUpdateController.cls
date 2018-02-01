public with sharing class ProjectTaskMassUpdateController {
	public List<PTaskWrapper> WrapperList{get;set;}
	public AcctSeed__Project__c ProjectSelector{get;set;}//used to select program and account
	public List<SelectOption> PhaseSelector{get;set;}
	public String SelectedPhase{get;set;}
	public List<SelectOption> TaskStatusSelector{get;set;}
	public String SelectedStatus{get;set;}
	public Integer DaysToAdd{get;set;}
	public Boolean SelectAll{get;set;}
    public Boolean SelectAllUpdateForecastActual{get;set;}
	public AcctSeed__Project_Task__c TaskObject{get;set;}
    public integer PageSize{get;set;}
    private ApexPages.StandardSetController WrapperSetControler;
    public List<SelectOption> PageSizeOptions{get;set;}
    Public Integer noOfTaskRecords{get; set;}
	public ProjectTaskMassUpdateController() {
        //WrapperSetControler = new ApexPages.StandardSetController();
         PageSizeOptions = new List<SelectOption>();
        PageSizeOptions.add(new SelectOption('25', '25'));
        PageSizeOptions.add(new SelectOption('50', '50'));
        PageSizeOptions.add(new SelectOption('100', '100'));
        PageSizeOptions.add(new SelectOption('200', '200'));
        noOfTaskRecords =0;
        PageSize = 100;
		DaysToAdd = 0;
		WrapperList = new List<PTaskWrapper>();
		ProjectSelector = new AcctSeed__Project__c();
		PhaseSelector = new List<SelectOption>();
		TaskStatusSelector = new List<SelectOption>();
		TaskObject = new AcctSeed__Project_Task__c();
		List<Milestone_Project_Phase__c> MPPList = [select name from Milestone_Project_Phase__c];
		PhaseSelector.add(new SelectOption('',''));
		for(Milestone_Project_Phase__c MPP : MPPList)//Populate phase list from milestone project phase records.
			PhaseSelector.add(new SelectOption(MPP.Name, MPP.Name));
		//Load status list from AcctSeed__Status__c defined picklist values
     	Schema.DescribeFieldResult fieldResult = AcctSeed__Project_Task__c.AcctSeed__Status__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        TaskStatusSelector.add(new SelectOption('',''));
    	for(Schema.PicklistEntry entry:ple)      	
        	TaskStatusSelector.add(new SelectOption(entry.getLabel(),entry.getLabel()));     
	}
	public class PTaskWrapper{
		public Boolean Selected{get;set;}
		public AcctSeed__Project_Task__c Tsk{get;set;}
		//public ID TaskID{get;set;}
		//public Date ForecastedStartDate{get;set;}
		//public Date ForecastedEndDate{get;set;}
		public Boolean IsModified{get;set;}
	}
	public void Search(){
		WrapperList = new List<PTaskWrapper>();
		String SOQLString = 'SELECT id,name, Description__c,Project_Phase__r.Name,  Forecasted_Start_Date__c, Forecasted_End_Date__c, AcctSeed__Start_Date__c, AcctSeed__End_Date__c, AcctSeed__Project__r.Name, Adjust_Successor_Forecast_Off_of_Actuals__c FROM AcctSeed__Project_Task__c ';
		SOQLString += SOQLString.contains('WHERE') && ProjectSelector.AcctSeed__Account__c <> null ? ' AND AcctSeed__Project__r.AcctSeed__Account__c = \''  + String.escapeSingleQuotes(ProjectSelector.AcctSeed__Account__c)+'\''  : 
         	(!SOQLString.contains('WHERE')) && ProjectSelector.AcctSeed__Account__c  <> null ? ' WHERE AcctSeed__Project__r.AcctSeed__Account__c  =  \''  + String.escapeSingleQuotes(ProjectSelector.AcctSeed__Account__c)+'\'' : '';

        SOQLString += SOQLString.contains('WHERE') && ProjectSelector.Program__c <> null ? ' AND AcctSeed__Project__r.Program__c = \''  + String.escapeSingleQuotes(ProjectSelector.Program__c)+'\''  : 
         	(!SOQLString.contains('WHERE')) && ProjectSelector.Program__c  <> null ? ' WHERE  AcctSeed__Project__r.Program__c =  \''  + String.escapeSingleQuotes(ProjectSelector.Program__c)+'\'' : '';	

        SOQLString += SOQLString.contains('WHERE') && SelectedPhase <> null ? ' AND Project_Phase__r.Name =  \''  + String.escapeSingleQuotes(SelectedPhase)+'\''  : 
         	(!SOQLString.contains('WHERE')) && SelectedPhase <> null ? ' WHERE  Project_Phase__r.Name = \''  + String.escapeSingleQuotes(SelectedPhase)+'\'' : '';	

        SOQLString += SOQLString.contains('WHERE') && SelectedStatus <> null ? ' AND AcctSeed__Status__c = \''  + String.escapeSingleQuotes(SelectedStatus)+'\''  : 
         	(!SOQLString.contains('WHERE')) && SelectedStatus  <> null ? ' WHERE  AcctSeed__Status__c = \''  + String.escapeSingleQuotes(SelectedStatus)+'\'': '';	

        SOQLString += SOQLString.contains('WHERE') && TaskObject.AcctSeed__Project__c <> null ? ' AND AcctSeed__Project__c = \''  + String.escapeSingleQuotes(TaskObject.AcctSeed__Project__c)+'\''  : 
         	(!SOQLString.contains('WHERE')) && TaskObject.AcctSeed__Project__c  <> null ? ' WHERE  AcctSeed__Project__c = \''  + String.escapeSingleQuotes(TaskObject.AcctSeed__Project__c)+'\'': '';

        SOQLString += ' LIMIT 10000';

        System.debug(SOQLString);

        WrapperSetControler = new ApexPages.StandardSetController(database.getQueryLocator(SOQLString));
        WrapperSetControler.setPageSize(PageSize);
        noOfTaskRecords = WrapperSetControler.getResultSize();
        //List<AcctSeed__Project_Task__c> TempList = database.query(SOQLString);
        WrapperList = new List<PTaskWrapper>();
        integer cnt = 0;
        for(AcctSeed__Project_Task__c pt : (List<AcctSeed__Project_Task__c>)WrapperSetControler.getRecords()){
            cnt++;
         	PTaskWrapper TempWrapper = new PTaskWrapper();
         	TempWrapper.Tsk=pt;
         	TempWrapper.IsModified = false;
         	WrapperList.add(TempWrapper);
            
        }

    }
    public void UpdateDates(){    	
    	for(PTaskWrapper pt : WrapperList){
    		if(pt.Selected){
    			pt.Tsk.Forecasted_Start_Date__c = pt.Tsk.Forecasted_Start_Date__c == null ? null : pt.Tsk.Forecasted_Start_Date__c.addDays(DaysToAdd);
    			pt.Tsk.Forecasted_End_Date__c = pt.Tsk.Forecasted_End_Date__c == null ? null : pt.Tsk.Forecasted_End_Date__c.addDays(DaysToAdd);
    			pt.IsModified = true;
    		}
    	}
    }
    public void Save(){
    	List<AcctSeed__Project_Task__c> PTUpdateList = new List<AcctSeed__Project_Task__c>();
    	for(PTaskWrapper pt : WrapperList){
    		if(pt.Selected){
    			PTUpdateList.Add(pt.Tsk);
    			pt.isModified = false;
    		}
    	}
    	update PTUpdateList;
    }
    public void SelectAll(){
    	for(PTaskWrapper pt : WrapperList){
    		if(SelectAll)
    			pt.Selected = true;
    		else
    			pt.Selected = false;
    	}
    }
     public void SelectAllUpdateForecastActual(){
        for(PTaskWrapper pt : WrapperList){
            if(SelectAllUpdateForecastActual && pt.Selected)
                pt.tsk.Adjust_Successor_Forecast_Off_of_Actuals__c = true;
            else if(pt.Selected)
                pt.tsk.Adjust_Successor_Forecast_Off_of_Actuals__c = false;
        }
    }
     /********** Pagination Methods for Customer Account Search List ***********/
    public Boolean hasAccNext {
        get {
            return WrapperSetControler == null ? false : WrapperSetControler.getHasNext();
        }
        set;
    }
    public Boolean hasAccPrevious {
        get {
            return WrapperSetControler == null ? false : WrapperSetControler.getHasPrevious();
        }
        set;
    }
  
    public Integer AccPageNumber {
        get {
            return  WrapperSetControler.getPageNumber();
        }
        set;
    }
     public void firstPageList() {
        //BubblewrapSetController();
         integer pagNum = AccPageNumber;         
         Search();
         WrapperSetControler.setPageNumber(pagNum);
        WrapperSetControler.first();
        PopulateWrapperList();
    }
  
    public void lastPageList() {
        //BubblewrapSetController();
         integer pagNum = AccPageNumber;         
          Search();
         WrapperSetControler.setPageNumber(pagNum);
        WrapperSetControler.last();
        PopulateWrapperList();
    }
  
    public void previousPageList() {
        //BubblewrapSetController();
         integer pagNum = AccPageNumber;         
          Search();
         WrapperSetControler.setPageNumber(pagNum);
        WrapperSetControler.previous();
        PopulateWrapperList();
    }
  
    public void nextPageList() {
         integer pagNum = AccPageNumber;         
         Search();
         WrapperSetControler.setPageNumber(pagNum);
        //BubblewrapSetController();
        WrapperSetControler.next(); 
        PopulateWrapperList();
    }
    private void PopulateWrapperList(){
        WrapperList.clear();

        for(AcctSeed__Project_Task__c pt : (List<AcctSeed__Project_Task__c>)WrapperSetControler.getRecords()){         
            PTaskWrapper TempWrapper = new PTaskWrapper();
            TempWrapper.Tsk=pt;
            TempWrapper.IsModified = false;
            WrapperList.add(TempWrapper);            
        }
    }
}