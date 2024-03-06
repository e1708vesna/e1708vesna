({
    fetchData: function (cmp, fetchData, numberOfRecords) {
        var dataPromise = this.mockdataLibrary.lightningMockDataFaker(fetchData,numberOfRecords);

        dataPromise.then($A.getCallback(function (results) {
            cmp.set('v.data', results)
            cmp.set('v.rawData', results);
        }));
    },
    removeBook: function (cmp, row) {
        var rows = cmp.get('v.rawData');
        var rowIndex = rows.indexOf(row);

        rows.splice(rowIndex, 1);
        this.updateBooks(cmp);
    },
    publishBook: function (cmp, row) {
        var rows = cmp.get('v.rawData');
        var rowIndex = rows.indexOf(row);

        rows[rowIndex]['isPublished'] = true;
        rows[rowIndex]['published'] = 'Published';
        this.updateBooks(cmp);
    },
    unpublishBook: function (cmp, row) {
        var rows = cmp.get('v.rawData');
        var rowIndex = rows.indexOf(row);

        rows[rowIndex]['isPublished'] = false;
        rows[rowIndex]['published'] = 'Unpublished';
        this.updateBooks(cmp);
    },
    updateBooks: function (cmp) {
        var rows = cmp.get('v.rawData');
        var activeFilter = cmp.get('v.activeFilter');
        var filteredRows = rows;

        if (activeFilter !== 'all') {
            filteredRows = rows.filter(function (row) {
                return (activeFilter === 'show_published' && row['isPublished']) ||
                    (activeFilter === 'show_unpublished' && !row['isPublished']);
            });
        }

        cmp.set('v.data', filteredRows);
    },
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'Show Details',
            'iconName': 'utility:zoomin',
            'name': 'show_details'
        }];
        var deleteAction = {
            'label': 'Delete',
            'iconName': 'utility:delete',
            'name': 'delete'
        };

        if (row['isPublished']) {
            actions.push({
                'label': 'Unpublish',
                'iconName': 'utility:ban',
                'name': 'unpublish'
            });
            deleteAction['disabled'] = 'true';
        } else {
            actions.push({
                'label': 'Publish',
                'iconName': 'utility:approval',
                'name': 'publish'
            });
        }

        actions.push(deleteAction);

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    }
})