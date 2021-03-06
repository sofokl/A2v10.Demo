﻿/*invoice index template*/

const utils = require('std:utils');
const du = utils.date;

const template = {
    properties: {
        'TDocument.$Mark': mark,
        'TDocument.$Icon'() { return this.Done ? 'success-green' : ''; },
        'TDocument.$Shipment': getShipment,
        'TDocument.$HasDetails'() { return this.Links.Count > 0; },
        'TDocLink.$DocName': linkDocName
    },
};


function mark() {
    return this.Done ? "success" : '';
}

function getShipment() {
    return this.Links.filter(doc => doc.Kind === 'Waybill');
}

function linkDocName() {
    return `№ ${this.No} от ${du.formatDate(this.Date)} на сумму ${utils.format(this.Sum, 'Currency')} грн.`;
}

module.exports = template;

