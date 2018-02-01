({
	getData : function(cmp) {
        var action = cmp.get('c.getTasks');
        action.setParams({
            "recordId": cmp.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue()); 
            } else {
                var errors = response.getError();
                console.error(errors);
            }      
        });
        $A.enqueueAction(action);
    },
    
    getProj : function(cmp){
        var action = cmp.get('c.getProject');  
        action.setParams({
            "rId": cmp.get("v.recordId")});
        action.setCallback(this,function(result){
            var state = result.getState();
            if (state === "SUCCESS") {
                var p1 = result.getReturnValue();
                cmp.set('v.projname', p1);
                //console.log("proj name: "+p1);
            } else {
                var errors = result.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateDates : function(cmp) {
        var action = cmp.get('c.updDates');     
        action.setParams({
            "tsks": cmp.find("tasks").getSelectedRows(), "DaysToAdd" : cmp.get("v.days")});
        action.setCallback(this,function(result){
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Success!",
                "message": "Tasks dates were updated",
                "type":"success"});
            resultsToast.fire();
            
            // Navigate back to the record view
            var navigateEvent = $A.get("e.force:navigateToSObject");
            navigateEvent.setParams({ "recordId": cmp.get('v.recordId') });
            navigateEvent.fire();
            } else {
                var errors = result.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    }
})