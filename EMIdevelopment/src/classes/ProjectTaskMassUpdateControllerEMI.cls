public with sharing class ProjectTaskMassUpdateControllerEMI {
	public Integer DaysToAdd{get;set;}
	public AcctSeed__Project_Task__c TaskObject{get;set;}
    
    @AuraEnabled
    public AcctSeed__Project__c proj {get; set;}
        
	public ProjectTaskMassUpdateControllerEMI() {
		DaysToAdd = 0;  
	}
	
    @AuraEnabled
    public static List<AcctSeed__Project_Task__c> getTasks(Id recordId)
    {
        List<AcctSeed__Project_Task__c> tasks = 
                [SELECT Id, AcctSeed__Project__c, Description__c, Forecasted_Start_Date__c, Forecasted_End_Date__c FROM AcctSeed__Project_Task__c where AcctSeed__Project__c = :recordId];
        //system.debug('recordId: '+recordId);		
        //system.debug('Tasks: '+tasks);
        return tasks;
    }
    
    @AuraEnabled
    public static String getProject(Id rId)
    {
        AcctSeed__Project__c proj = 
                [SELECT Id, Name FROM AcctSeed__Project__c where id = :rId];
        //system.debug('proj recordId: '+rId);
        //system.debug('Proj Name: '+proj.Name);
        return proj.Name;
    }
    
    @AuraEnabled
    public static List<AcctSeed__Project_Task__c> updDates(List<AcctSeed__Project_Task__c> tsks, Integer DaysToAdd)
    {
    	List<AcctSeed__Project_Task__c> tskupd = new List<AcctSeed__Project_Task__c>();
        //system.debug('Tasks before update: '+tsks);
    	for(AcctSeed__Project_Task__c pt : tsks){
            pt.Forecasted_Start_Date__c = pt.Forecasted_Start_Date__c == null ? null : pt.Forecasted_Start_Date__c.addDays(DaysToAdd);
            pt.Forecasted_End_Date__c = pt.Forecasted_End_Date__c == null ? null : pt.Forecasted_End_Date__c.addDays(DaysToAdd);
			tskupd.add(pt);
        }
        //system.debug('Tasks after update: '+tskupd);
        update(tskupd);
        return null;
    }    
}