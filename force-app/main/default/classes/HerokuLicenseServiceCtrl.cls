/**
 * @description   : Heroku Controller class     
 * @author (s)    : Brite
 */
public with sharing class HerokuLicenseServiceCtrl {
 	private ApexPages.StandardController stdc;
	public String objId = '';
 	
	/* SECTION: Class Constructors */
	
	// Standard Controller Constructor
	public HerokuLicenseServiceCtrl(ApexPages.StandardController stdc){
		this.stdc = stdc;
		this.objId=Apexpages.CurrentPage().getParameters().get('id');
		//System.debug('Object Id = ' + objId);
	}    
	
	public String getObjId() {
		return objId;
	}
	
    public Pagereference getLicenseJar() {
    	new HerokuService().getLicenseJar(objId);
    	return new PageReference('/'+objId);
    }
}