global without sharing class ProjectSiteMap {

    private final AcctSeed__Project__c acc;
    public String street{get; set;} 
    public String city{get; set;} 
    public String state{get; set;} 
    public String postal{get; set;} 
    public String county{get; set;} 
    public Decimal lng{get; set;} 
    public Decimal lat{get; set;} 
    //public Boolean isCommunity{get;set;}
    
    public String street_number{get; set;}
    public String iLat{get; set;}
    public String iLng{get; set;}
    public String iStreet_Number{get; set;}
    public String iRoute{get; set;}
    public String iLocality{get; set;}
    public String iAdministrative_area_level_1{get; set;}
    public String iAdministrative_area_level_2{get; set;}
    public String iPostal_code{get; set;}
    //public String icontact_first_name{get; set;}
    //public String icontact_last_name{get; set;}
    //public String iEmail{get; set;}
    //public String iMobilePhone{get; set;}
    //public String iHomePhone{get; set;}
    //public String iOtherPhone{get; set;}
    //public String iFax{get; set;}
    //public String iWorkPhone{get; set;}
    //public String iNotes{get; set;}

    public ProjectSiteMap (ApexPages.StandardController controller) {
        If (controller.getRecord() instanceof AcctSeed__Project__c){
            this.acc = (AcctSeed__Project__c)controller.getRecord();
        }
         
    }
    
    public PageReference saveLoc() {
        PageReference returnPage = new PageReference('/'+acc.id);
        
       // incident.Incident_Street__c = street;
        acc.Lat_Long__latitude__s = lat.setscale(6);
        acc.Lat_Long__longitude__s = lng.setscale(6);
        
        //String newCounty = county.replace(' County','');
        //incident.Incident_County__c = newCounty;
        
        //incident.Incident_State__c = state;
        //incident.Incident_City__c = city;
       // incident.Incident_Zip_Postal_Code__c = postal;
       
            update acc;
      
        
        return returnPage;
    }
    
    public PageReference mapIt() {
        PageReference returnPage = new PageReference('/'+acc.id);
        
        acc.Location_Address_Line_1__c= iStreet_Number + ' ' + iRoute;
        acc.Lat_Long__latitude__s = decimal.valueOf(iLat).setscale(6);
        acc.Lat_Long__longitude__s = decimal.valueOf(iLng).setscale(6);
        acc.Original_Lat_Long__latitude__s = decimal.valueOf(iLat).setscale(6);
        acc.Original_Lat_Long__longitude__s = decimal.valueOf(iLng).setscale(6);
        
        //String newCounty = county.replace(' County','');
        //incident.Incident_County__c = newCounty;
        
        acc.Location_Address_State__c = iAdministrative_area_level_1;
        acc.Location_Address_City__c= iLocality;
        acc.Location_Address_Zip__c= iPostal_code;
        system.debug('the site ' + acc);
        update acc;
      
        
        return returnPage;
    }

 
}