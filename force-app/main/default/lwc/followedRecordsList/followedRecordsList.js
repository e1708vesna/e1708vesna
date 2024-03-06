import { LightningElement, api } from 'lwc';

// Apex Methods
import getFollowedRecords from '@salesforce/apex/EntitySubscriptionCtrl.getFollowedRecords';
import getColumnConfigurations from '@salesforce/apex/EntitySubscriptionCtrl.getColumnConfigurations';
import unfollowRecords from '@salesforce/apex/EntitySubscriptionCtrl.unfollowRecords';
import getFollowedRecordsInfo from '@salesforce/apex/EntitySubscriptionCtrl.getFollowedRecordsInfo';

// Custom Labels
import followedRecordsApproachingLimit from '@salesforce/label/c.FollowedRecordsApproachingLimit'
import followedRecordsLimit from '@salesforce/label/c.FollowedRecordsLimit';
import followedRecordsObjectSelection from '@salesforce/label/c.FollowedRecordsObjectSelection';
import noFollowedRecords from '@salesforce/label/c.NoFollowedRecords';
import searchNoMatchFound from '@salesforce/label/c.SearchNoMatchFound';
import totalRecordsFollowed from '@salesforce/label/c.TotalRecordsFollowed';

export default class FollowedRecordsList extends LightningElement {
    columns         = [];
    followedRecords = [];
    
    error;
    objectType                = ''; // No default object type
    recordCounts;
    searchKeyword             = '';
    sortBy;
    sortDirection             = 'asc';
    totalFollowedRecordsCount = 0;

    // FLAGS(states)
    allRecordsUnfollowed   = false;
    isBulkUnfollowDisabled = true;
    isDatatableLoaded      = false; // Specific loading state for the datatable
    hasSearched            = false; 
    loading                = true;
    showControls           = false; // Controls visibility of search bar, buttons 
    showEmptyState         = false; // To control the visibility of the empty state component

    // Pagination
    currentPage = 1;
    @api pageSize;
    totalPages  = 0;

    // Custom Labels
    label = { followedRecordsApproachingLimit, followedRecordsLimit, followedRecordsObjectSelection, noFollowedRecords, searchNoMatchFound, totalRecordsFollowed }
    
    // Define object options for the filter
    objectOptions = [
        { label: 'Select Object...', value: '' },
        { label: 'Case',             value: 'Case' },
        { label: 'Account',          value: 'Account' },
        { label: 'Contact',          value: 'Contact' },
        { label: 'Lead',             value: 'Lead' },
        { label: 'Opportunity',      value: 'Opportunity' },
        { label: 'Handover',         value: 'Handover__c' },
        { label: 'Product Request',  value: 'ProductRequest__c' },
        { label: 'Report',           value: 'Report' },
        { label: 'Dashboard',        value: 'Dashboard' },
    ];

    connectedCallback() {
        this.loading = false;
        this.loadFollowedRecordsInfo();
    }

    loadFollowedRecordsInfo() {
        getFollowedRecordsInfo()
            .then(result => {
                this.totalFollowedRecordsCount = result.total;
                this.recordCounts = result.byObject;
                this.updateObjectOptionsWithCounts();
                this.refreshData();
                this.showEmptyState = false; 
            })
            .catch(error => {
                this.error = error;
                console.error('Error retrieving followed records info:', error);
            });
    }

    updateObjectOptionsWithCounts() {
        if (this.recordCounts) {
            this.objectOptions = this.objectOptions.map(option => {
                const objectName = option.value; 
                if (objectName && this.recordCounts[objectName] !== undefined) {
                    const count = this.recordCounts[objectName];
                    return { ...option, label: `${option.label.split(' ')[0]} (${count})` }; // Split to remove old count
                }
                return option;
            });
        }
        this.loading = false;
    }

    handleObjectTypeChange(event) {
        this.objectType = event.detail.value;
        this.showControls = this.objectType !== ''; // Show controls if an object is selected
        this.retrieveColumnConfigurations();
    }

    retrieveColumnConfigurations() {
        if (this.objectType) {
            getColumnConfigurations({ objectType: this.objectType })
                .then(result => {
                    this.columns = JSON.parse(result);
                    this.loadFollowedRecordsInfo();
                })
                .catch(error => {
                    this.error = error;
                    console.error('Error retrieving column configurations:', error);
                });
        }
    }

    refreshData() {
        this.isDatatableLoaded = true;
        this.showEmptyState = false; // Hide the empty state during loading
        if (this.objectType) {
            getFollowedRecords({ objectType: this.objectType, searchKeyword: this.searchKeyword })
                .then(result => {
                    this.followedRecords = [...this.formatData(result)];
                    this.showEmptyState = this.followedRecords.length === 0;
                    this.error = undefined;
                    this.hasSearched = this.searchKeyword !== '';
                    this.totalPages = this.followedRecords.length > 0 ? Math.ceil(this.followedRecords.length / this.pageSize) : 0;
                })
                .catch(error => {
                    this.error = error;
                    this.showEmptyState = false;
                })
                .finally(() => {
                    this.isDatatableLoaded = false;
                });
        } else {
            this.followedRecords = [];
            this.showEmptyState = true; 
            this.isDatatableLoaded = false;
            this.totalFollowedRecordsCount = 0; //?
            this.totalPages = 0;
        }
    }

    formatData(data) {
        return data.map(record => {
            let formattedRecord = {
                id: record.recordId,
                subscriptionId: record.subscriptionId,
                ...record.fields
            };
            let recordLink = `/lightning/r/${record.recordId}/view`;
            this.columns.forEach(column => {
                let fieldName = column.fieldName;
                let fieldValue = record.fields[fieldName];
                // Check if the column type is datetime to apply formatting
                if (column.type === 'datetime' && fieldValue) {
                    // Format the DateTime value
                    formattedRecord[column.fieldName] = new Date(fieldValue).toLocaleString();
                } else if (column.fieldName === 'caseNumberLink' && this.objectType === 'Case') {
                    formattedRecord.caseNumberLink = recordLink;
                } else if (column.fieldName === 'nameLink') {
                    formattedRecord.nameLink = recordLink;
                    formattedRecord.Name = record.fields.Name;
                } else {
                    // For other types of fields, use the value as is
                    formattedRecord[fieldName] = fieldValue;
                }
            });
            return formattedRecord
            
        });
    }  

    get isApproachingLimit() {
        return this.totalFollowedRecordsCount >= 1900 && this.totalFollowedRecordsCount < 2000; 
    }

    get isLimitApproached() {
        return this.totalFollowedRecordsCount === 2000; 
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.followedRecords = this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldName, sortDirection) {
        const getValue = (object) => object[fieldName] || '';
        const compare = (a, b) => {
            const aValue = getValue(a);
            const bValue = getValue(b);
            let comparison = 0;
            if (aValue > bValue) {
                comparison = 1;
            } else if (aValue < bValue) {
                comparison = -1;
            }
            return sortDirection === 'asc' ? comparison : -comparison;
        };
        return [...this.followedRecords].sort(compare);
    } 

    get totalRecordsFollowed() {
        let number = this.followedRecords ? `(${this.followedRecords.length})` : '(0)';
        return number;
    }
    
    handleSearchKeydown(event) {
        if (event.key === 'Enter') {
            this.hasSearched = true;
            this.refreshData();
        }
    }

    handleSearchChange(event) {
        this.searchKeyword = event.target.value;
    }
    
    handleRowSelection(event) {
        this.selectedRecords = event.detail.selectedRows;
        this.isBulkUnfollowDisabled = this.selectedRecords.length === 0;
    }

    
    handleBulkUnfollow() {
        const selectedRecordIds = new Set(this.selectedRecords.map(record => record.id));
        const subscriptionIds = this.followedRecords
                                    .filter(record => selectedRecordIds.has(record.id))
                                    .map(record => record.subscriptionId);

        if (subscriptionIds.length > 0 && !subscriptionIds.includes(undefined)) {
            // Perform the bulk unfollow operation with the subscriptionIds
            unfollowRecords({ subscriptionIds: subscriptionIds })
                .then(() => {
                    this.loadFollowedRecordsInfo();
                    this.followedRecordsCount = this.followedRecords.length;
                    this.allRecordsUnfollowed = this.followedRecords.length === 0;
                })
                .catch(error => {
                    this.error = error;
                    console.error('Error in bulk unfollow:', error);
                })
                .finally(() => {
                    this.isBulkUnfollowDisabled = true;
                });
        } else {
            console.error('One or more subscription IDs are undefined.');
        }
    }
     
    handleRefresh() {
        this.loadFollowedRecordsInfo();
    }

    get noFollowedRecordsFound() {
        return this.followedRecords.length === 0 && !this.hasSearched && !this.isDatatableLoaded && this.showEmptyState;
    }

    get showNoMatchFound() {
        return this.followedRecords.length === 0 && this.hasSearched && !this.isDatatableLoaded;
    }

    get isRecordCountMismatch() {
        return this.followedRecords.length !== this.recordCounts[this.objectType];
    }

    get recordMismatchInfo() {
        if (this.recordCounts[this.objectType] !== this.followedRecords.length) {
            return `You are still following a total of ${this.recordCounts[this.objectType]} records. Not all records are visible because you lost visibility due to ownership change.`;
        }
        return '';
    }

    // Pagination methods and getters
    get isPrevDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get paginatedRecords() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.followedRecords.slice(start, end);
    }

    get showPaginationControls() {
        return this.followedRecords.length > this.pageSize;
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.refreshData();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.refreshData();
        }
    }

    handleFirstPage() {
        this.currentPage = 1;
        this.refreshData();
    }

    handleLastPage() {
        this.currentPage = this.totalPages;
        this.refreshData();
    }

}