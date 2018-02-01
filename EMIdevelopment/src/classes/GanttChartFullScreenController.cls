global class GanttChartFullScreenController {

    private AcctSeed__Project__c project;
    private final List<Project_Phase__c> phases;
    private final List<List<AcctSeed__Project_Task__c>> tasks = new List<List<AcctSeed__Project_Task__c>>();
    private ID ProjectID;
    public String jsonString{get;set;}

    global GanttChartFullScreenController() {
         List<AcctSeed__Project_Task__c> tempTask;
         Map<ID, List<Project_SubTask__c>> TaskToSubTaskMap = new Map<ID, List<Project_SubTask__c>>();
        ID ProjectID = ApexPages.currentPage().getParameters().get('id');

       
        this.project = [SELECT Id, Name FROM AcctSeed__Project__c
                   WHERE Id = :ProjectID];

        if(project != null){
             phases = [SELECT Id, Name, Start_Date__c, End_Date__c, Forecasted_Start_Date__c, Forecasted_End_Date__c FROM Project_Phase__c
                   WHERE Project__c = :ProjectID order by sort_order__c];
            if(phases != null){
                tempTask = [SELECT Id, Name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c, 
               AcctSeed__Duration__c, Forecasted_Start_Date__c, Forecasted_End_Date__c, Project_Phase__c,Description__c,Predecessor1__c,
               BaseLine_Start_Date__c, BaseLine_End_Date__c 
               FROM AcctSeed__Project_Task__c 
               WHERE Project_Phase__c IN :phases ORDER BY Project_Phase__c, AcctSeed__Sort_Order__c];
            }
            if(tempTask != null){
                for(Project_SubTask__c pst : [select id, name, Project_Task__c, Project_Task__r.Forecasted_Start_Date__c, Project_Task__r.Forecasted_End_Date__c
                    from Project_SubTask__c where Project_Task__c in :tempTask order by Project_Task__c,name]){//build out task to subtask map.  Map.PutAll automatically assigns sub task id, we need project task id instead.
                    if(!TaskToSubTaskMap.containsKey(pst.Project_Task__c))
                        TaskToSubTaskMap.put(pst.Project_Task__c, new List<Project_SubTask__c>());
                    TaskToSubTaskMap.get(pst.Project_Task__c).add(pst);
                }
                TaskToSubTaskMap.remove(null);
            }

        }

        Map<ID, List<AcctSeed__Project_Task__c>> PhaseTaskListMap = new Map<ID, List<AcctSeed__Project_Task__c>>();

        for(AcctSeed__Project_Task__c PT : tempTask){
            if(!PhaseTaskListMap.containsKey(PT.Project_Phase__c))
                PhaseTaskListMap.put(PT.Project_Phase__c, new List<AcctSeed__Project_Task__c>());
            PhaseTaskListMap.get(PT.Project_Phase__c).add(PT);
        }
        Date earliestPhaseStartDate = null;
        Date latestPhaseEndDate = null;
        for(Project_Phase__c pp : phases){
            if(earliestPhaseStartDate == null || earliestPhaseStartDate > pp.Forecasted_Start_Date__c)
                earliestPhaseStartDate = pp.Forecasted_Start_Date__c;
            if(latestPhaseEndDate == null || latestPhaseEndDate < pp.Forecasted_End_Date__c)
                latestPhaseEndDate = pp.Forecasted_End_Date__c;
        }
       

        for(Integer i = 0; i < phases.size(); i++){
            if(phases[i].Forecasted_Start_Date__c < earliestPhaseStartDate){
                earliestPhaseStartDate = phases[i].Forecasted_Start_Date__c;
            }
            if(phases[i].Forecasted_End_Date__c > latestPhaseEndDate){
                latestPhaseEndDate = phases[i].Forecasted_End_Date__c;
            }
        }

        //Id map for links
        List<uID> idMap = new List<uId>();
        //Generate JSON Data to be used by gantt chart
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject(); 
        generator.writeFieldName('data');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        Integer idCounter = 1;
        Integer phaseCounter = 0;

        //Create --Project-- In JSON - {"id":1, "text":"Project.Name", "start_date":"", "duration":"", "progress": 0.6, "open": true}
        generator.writeStartObject(); //Write the starting marker of a JSON object '{'
        generator.writeStringField('id', project.id);
        generator.writeStringField('text', project.Name);
        generator.writeStringField('start_date', getDateStringConverter(earliestPhaseStartDate));
        generator.writeStringField('end_date', getDateStringConverter(latestPhaseEndDate.addDays(100)));
        generator.writeStringField('type', 'project');
        //generator.writeNumberField('duration', earliestPhaseStartDate.daysBetween(latestPhaseEndDate) + 100);
        System.debug(earliestPhaseStartDate.daysBetween(latestPhaseEndDate));
        generator.writeEndObject(); //Write the end marker of a JSON object '}'

        //Create --Phases-- In JSON 
        for(Project_Phase__c p : phases)
        { 
            idCounter++; 
            Integer currentPhaseId = idCounter; //phase #
            System.debug('id: '+p.id);
            System.debug('Name: '+p.Name);
            System.debug('Start Date: '+ p.Forecasted_Start_Date__c);
            System.debug('End Date: '+ p.Forecasted_End_Date__c);
            System.debug('Duration: '+ p.Forecasted_Start_Date__c.daysBetween(p.Forecasted_End_Date__c));
            System.debug('Parent: ' + project.ID);

            //add mapping from project to phase
            idMap.add(new uId(project.id, p.id ));
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', p.id);
            generator.writeStringField('text', p.Name);
            generator.writeStringField('start_date', getDateStringConverter(p.Forecasted_Start_Date__c));
            generator.writeStringField('end_date', getDateStringConverter(p.Forecasted_End_Date__c));

            generator.writeNumberField('duration', p.Forecasted_Start_Date__c.daysBetween(p.Forecasted_End_Date__c));
            generator.writeStringField('parent', project.id);
            generator.writeStringField('type', 'project');
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
            //List<AcctSeed__Project_Task__c> tempTask = tasks[phaseCounter];

            //Create --Tasks-- In JSON
            for(AcctSeed__Project_Task__c t : PhaseTaskListMap.get(p.id))
            {
                idCounter++; //task #
                //add mapping from phase to task
                //idMap.add(new uId(p.id, t.ID));
                if(t.Predecessor1__c != null)
                    idMap.add(new uId(t.Predecessor1__c, t.ID));
                generator.writeStartObject(); //Write the starting marker of a JSON object '{'
                generator.writeStringField('id', t.ID);
                generator.writeStringField('text', t.Name);
                generator.writeStringField('start_date', getDateStringConverter(t.Forecasted_Start_Date__c));
                generator.writeStringField('end_date', getDateStringConverter(t.Forecasted_End_Date__c));
                 generator.writeStringField('planned_start', getDateStringConverter(t.BaseLine_Start_Date__c));
                generator.writeStringField('planned_end', getDateStringConverter(t.BaseLine_End_Date__c));
                 if(t.AcctSeed__Start_Date__c != null)
                    generator.writeStringField('actual_start', getDateStringConverter(t.AcctSeed__Start_Date__c));
                else
                     generator.writeStringField('actual_start', '');
                if(t.AcctSeed__End_Date__c != null)
                    generator.writeStringField('actual_end', getDateStringConverter(t.AcctSeed__End_Date__c));
                else
                     generator.writeStringField('actual_end', '');
                if(TaskToSubTaskMap.containsKey(t.id) && TaskToSubTaskMap.get(t.id)!= null)
                    generator.writeStringField('type', 'task');                    
                else
                    generator.writeStringField('type', 'task');
                generator.writeNumberField('duration', t.Forecasted_Start_Date__c.daysBetween(t.Forecasted_End_Date__c));
                generator.writeStringField('parent', p.id);
                generator.writeEndObject(); //Write the end marker of a JSON object '}'
                if(TaskToSubTaskMap.containsKey(t.id) && TaskToSubTaskMap.get(t.id) != null){
                    for(Project_SubTask__c pst : TaskToSubTaskMap.get(t.id)){
                        generator.writeStartObject(); //Write the starting marker of a JSON object '{'
                        generator.writeStringField('id', pst.ID);
                        generator.writeStringField('text', pst.name);
                        generator.writeStringField('start_date', getDateStringConverter(t.Forecasted_Start_Date__c));
                        generator.writeStringField('end_date', getDateStringConverter(t.Forecasted_End_Date__c));

                        //generator.writeStringField('type', 'project');
                        generator.writeNumberField('duration', t.Forecasted_Start_Date__c.daysBetween(t.Forecasted_End_Date__c));
                        generator.writeStringField('parent', t.id);
                        idMap.add(new uId(t.id, pst.ID));
                        generator.writeEndObject(); //Write the end marker of a JSON object '}'
                    }
                }


                system.debug('Task Name:' + t.Name + 'Task Date Before :' + t.Forecasted_Start_Date__c);
                system.debug('Task Name:' + t.Name + 'Task Date After:' + getDateStringConverter(t.Forecasted_Start_Date__c));
            }
        }

        generator.writeEndArray(); //Write the end marker of a JSON object ']'

        Integer linkCounter = 1;
        generator.writeFieldName('links');
        generator.writeStartArray(); //Write the starting marker of a JSON object '['
        for(uId key : idMap)
        {
            generator.writeStartObject(); //Write the starting marker of a JSON object '{'
            generator.writeStringField('id', string.valueOf(linkCounter));
            generator.writeStringField('source', key.id1);
            generator.writeStringField('target', key.id2);
            if(key.id1.getSObjectType() == Project_Phase__c.sobjectType || key.id1.getSObjectType() == AcctSeed__Project__c.sobjectType)
                generator.writeStringField('type', '1');
            else
                generator.writeStringField('type', '0');
            generator.writeEndObject(); //Write the end marker of a JSON object '}'
            linkCounter++;
        }
        generator.writeEndArray(); //Write the end marker of a JSON object ']'
        generator.writeEndObject();
        jsonString = generator.getAsString();
        System.debug(jsonString);
    }

    public AcctSeed__Project__c getProject() {
        return this.project;
    }
    public List<List<AcctSeed__Project_Task__c>> getRelatedListTasks() {
        return this.tasks;
    }
    public List<Project_Phase__c> getRelatedListPhases() {
        return this.phases;
    }
    public String getJsonString() {
        return this.jsonString;
    }
    //DATES IN JSON NEED "01-04-2015" - SALESFORCE GIVES "2008-01-30",  Change YYYY-MM-DD to MM-DD-YYYY
    private String getDateStringConverter(Date d) {
        String unFormatedDate = string.ValueOf(d).trim();
        String year = unFormatedDate.substring(0,4);
        String month = unFormatedDate.substring(5,7);
        String day = unFormatedDate.substring(8,10);

        return '' + day + '/' + month + '/' + year;
    }
    public class CustomException extends Exception {}

    public class uId {

        public ID id1 {get; set;}

        public ID id2 {get; set;}

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public uId(ID id1, ID id2) {
            this.id1 = id1;
            this.id2 = id2;
        }
    }
    public Date getDateFromString(String s){        
        String Month = s.substring(0,2);
        String Day = s.substring(3,5);
        String Year = s.substring(6,10);
        return Date.parse(Day +'/'+Month+'/'+Year);
    }   
    public PageReference SaveJSON(){       
        //List<AcctSeed__Project__c> ProjList = new List<AcctSeed__Project__c>();
        List<Project_Phase__c> PhaseList = new List<Project_Phase__c>();
        List<AcctSeed__Project_Task__c> ProjTaskList = new List<AcctSeed__Project_Task__c>();
        //List<Project_SubTask__c> SubTaskList = new List<Project_SubTask__c>();
        System.debug(jsonString);
        GanttProjectJSON.GanttProjectJSONClass GPJC = GanttProjectJSON.parse(jsonString);
        for(GanttProjectJSON.Data d : GPJC.Data){
            if(d.id.getSObjectType()==AcctSeed__Project__c.SObjectType){
                //ProjList.Add(new AcctSeed__Project__c(id=d.id, Forecasted_Start_Date__c= d.start_date, Forecasted_End_Date__c = d.end_date));
            }
            else if(d.id.getSObjectType()==Project_Phase__c.SObjectType){
                PhaseList.add(new Project_Phase__c(id=d.id, Forecasted_Start_Date__c=getDateFromString(d.start_date), Forecasted_End_Date__c=getDateFromString(d.end_date)));
            } 
            else if(d.id.getSObjectType()==AcctSeed__Project_Task__c.SObjectType){
                ProjTaskList.add(new AcctSeed__Project_Task__c(id=d.id, Forecasted_Start_Date__c=getDateFromString(d.start_date), Forecasted_End_Date__c=getDateFromString(d.end_date)));

            } 
            else if(d.id.getSObjectType()==Project_SubTask__c.SObjectType){
                //SubTaskList.add(new Project_SubTask__c(id=d.id, Forecasted_Start_Date__c=getDateFromString(d.start_date), Forecasted_End_Date__c=getDateFromString(d.end_date)));

            } 

        }
        update PhaseList;
        update ProjTaskList;
        return null;
    }

}