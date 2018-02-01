({
    init: function (cmp, event, helper) {
            cmp.set('v.mycolumns', [
                    {label: 'Task', fieldName: 'Description__c', type: 'text'},
                    {label: 'Forecasted Start', fieldName: 'Forecasted_Start_Date__c', type: 'datetime'},
                    {label: 'Forecasted End', fieldName: 'Forecasted_End_Date__c', type: 'datetime'}
                ]);
            helper.getData(cmp);
        	helper.getProj(cmp);
    },
    
    onSave: function (cmp, event, helper){
        var tasksselected =  cmp.find("tasks").getSelectedRows();
        for (var i=0; i<tasksselected.length; i++){
            console.log("selected:"+tasksselected[i].Id+" "+tasksselected[i].Description__c+" "+tasksselected[i].Forecasted_Start_Date__c+" "+tasksselected[i].Forecasted_End_Date__c);
        }
        if (cmp.get("v.days") == null || cmp.get("v.days") < 0 ){
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "message": "Please enter a number of days greater than 0",
                "type":"error"});
            resultsToast.fire();
            
            // Navigate back to the record view
            var navigateEvent = $A.get("e.force:navigateToSObject");
            navigateEvent.setParams({ "recordId": cmp.get('v.recordId') });
            navigateEvent.fire();
        }
        if (tasksselected.length == 0){
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "message": "Please select at least one Task to update",
                "type":"error"});
            resultsToast.fire();
            
            // Navigate back to the record view
            var navigateEvent = $A.get("e.force:navigateToSObject");
            navigateEvent.setParams({ "recordId": cmp.get('v.recordId') });
            navigateEvent.fire();
        }
        else {
            helper.updateDates(cmp);
        }
    },
        
    onCancel: function(component, event, helper) {
            $A.get("e.force:closeQuickAction").fire();
        }
})