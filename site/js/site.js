$(document).ready(function () {    
    var apigClient = apigClientFactory.newClient();

    $("main").append('<p class="site-button">Welcome to the dashboard</p>');

    var lookupdate = location.search.slice(6, 16);

    $("a").click(function(event) {
        $(this).append(`<p>${lookupdate}</p>`);
    });

    var params = {
        date: lookupdate
    };

    window.loadData = function () {
        var lookupdate = location.search.slice(6, 16);
        apigClient.dashboardDateGet({date: lookupdate}, null, {})
        .then(function(result) {
            $("main").append(`<p>${result.data.Items[0].neo_id.N}</p>`);
            $("main").append(`<p>${result.data.Items[0].name.S}</p>`);
            $("main").append(`<p>${result.data.Items[0].relative_velocity_mph.N}</p>`);
            $("main").append(`<p>${result.data.Items[0].miss_distance_lunar.N}</p>`);
            $("main").append(`<p>${Object.keys(result.data.Items[0])}</p>`);
            $("main").append(`<p>${Object.keys(result.data.Items[0])}</p>`);
            $("main").append(`<p>${Object.keys(result.data.Items[0])}</p>`);
            $("main").append(`<p>${Object.keys(result.data.Items[0])}</p>`);
            $("main").append(`<p>${result.text}</p>`);
            $("main").append(`<p>${result.statusText}</p>`);
            // $("main").append(`<p>${Object.keys(result)}</p>`);
            // miss_distance_lunar,estimated_diameter_feet_max,uploaded_on,relative_velocity_mph,close_approach_date,estimated_diameter_feet_min,name,neo_id,miss_distance_astronomical
        });
    };

});