import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDuplicateCases from '@salesforce/apex/DuplicateCaseCtrl.getDuplicateCases';
import potentialDuplicateDetected from '@salesforce/label/c.PotentialDuplicateDetected';

export default class duplicateCases extends NavigationMixin(LightningElement) {
    @api recordId;
    @api loadedCasesNumber;

    caseRecord;
    duplicateCaseCount;
    duplicateCases;
    displayedCases = [];
    startIndex = 0;

    label = { potentialDuplicateDetected };

    @track activeSection = 'duplicate-section'; 
    @track showFooter = true;
    @track numberOfCases = this.loadedCasesNumber;
    
    columns = [
        { label: 'Number', fieldName: 'CaseRecordLink', type: 'url', typeAttributes: { label: { fieldName: 'CaseNumber' }}},
        { label: 'Account', fieldName: 'AccountRecordLink', type: 'url', typeAttributes: { label: { fieldName: 'AccountName' }}},
        { label: 'Contact', fieldName: 'ContactRecordLink', type: 'url', typeAttributes: { label: { fieldName: 'ContactName' }}},
        { label: 'Web Email', fieldName: 'SuppliedEmail', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Opened', fieldName: 'FormattedCreatedDate', type: 'text' },
        { label: 'Owner', fieldName: 'OwnerName', type: 'text' } 
    ];

    get shouldDisplay() {
        return this.duplicateCaseCount > 0;
    }

    connectedCallback() {
        this.numberOfCases = this.loadedCasesNumber;
        this.fetchDuplicateCases();
    }

    handleLoadedCasesNumber(event) {
        this.numberOfCases = parseInt(event.target.value, 10);
        this.fetchDuplicateCases(); // Refetch the cases based on new user input
    } 

    fetchDuplicateCases() {
        getDuplicateCases({ currentCaseId: this.recordId })
            .then(result => {
                this.duplicateCases = result.duplicateCases.map(caseRecord => {
                    let caseUrl = `/lightning/r/Case/${caseRecord.Id}/view`;
                    let accountUrl = caseRecord.AccountId ? `/lightning/r/Account/${caseRecord.AccountId}/view` : null;
                    let contactUrl = caseRecord.ContactId ? `/lightning/r/Contact/${caseRecord.ContactId}/view` : null;
                    let formattedDate = new Date(caseRecord.CreatedDate).toLocaleString('en-GB', {year: "numeric", month: "2-digit", day: "2-digit"});
                    return {
                        ...caseRecord,
                        CaseRecordLink: caseUrl,
                        AccountRecordLink: accountUrl,
                        ContactRecordLink: contactUrl,
                        AccountName: caseRecord.Account?.Name,
                        ContactName: caseRecord.Contact?.Name,
                        FormattedCreatedDate: formattedDate, 
                        OwnerName: caseRecord.Owner?.Name
                    };
                });
                this.duplicateCaseCount = result.count;
                this.startIndex = 0;
                this.displayedCases = this.duplicateCases.slice(0, this.numberOfCases);
            })
            .catch(error => {
                console.error('Error fetching the duplicate cases', error);
                this.duplicateCaseCount = 0;
                this.duplicateCases = [];
            });
    }

    loadMore() {
        this.startIndex += this.numberOfCases;
        let moreCases = this.duplicateCases.slice(this.startIndex, this.startIndex + this.numberOfCases);
        this.displayedCases = [...this.displayedCases, ...moreCases];
    }

    get showLoadMoreButton() {
        return this.showFooter && this.hasMore;
    }
    
    get hasMore() {
        return this.startIndex + this.numberOfCases < this.duplicateCaseCount;
    }

    get accordionLabel() {
        return `Potential Duplicates Detected [${this.duplicateCaseCount}]`;
    } 
    
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        this.showFooter = openSections.includes('duplicate-section') && this.duplicateCases.length > 10;
    }
}