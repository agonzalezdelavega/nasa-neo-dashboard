$(document).ready(function () {    
    var apigClient = apigClientFactory.newClient();

    var date = location.search.slice(6, 16);

    loadData = function () {
        apigClient.dashboardDateGet({date: date}, null, {})
        .then(function(result) {
            neo_data = result.data.Items;
            neo_data.forEach((neo) => {
                $('tbody').append(`<tr class="neo_table_row" id="${neo.neo_id.N}">`);
                $(`#${neo.neo_id.N}`).append(`<td>${neo.neo_id.N}</td>`);
                $(`#${neo.neo_id.N}`).append(`<td>${neo.name.S}</td>`);
                $(`#${neo.neo_id.N}`).append(`<td>${neo.estimated_diameter_feet_min.N} - ${neo.estimated_diameter_feet_max.N}</td>`);
                $(`#${neo.neo_id.N}`).append(`<td>${neo.miss_distance_astronomical.N}</td>`);
                $(`#${neo.neo_id.N}`).append(`<td>${neo.miss_distance_lunar.N}</td>`);
                $(`#${neo.neo_id.N}`).append(`<td>${neo.relative_velocity_mph.N}</td>`);
                $('tbody').append('</tr>');
            });
        });
    };

});