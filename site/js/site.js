$(document).ready(() => {
    ////// LOAD SDK //////
    var apigClient = apigClientFactory.newClient();

    ////// GET DATE FROM QUERY PARAMS //////
    const date = new Date(location.search.slice(6, 16));

    ////// VALIDATE DATE FORMAT //////
    const isValidDate = date instanceof Date && !isNaN(date) && location.search.length === 16;
    if (!isValidDate) {
        $('main').remove();
        $('.loading').hide();
        $('body').append('<h1 class="invalid-date-error">Invalid date entered, please try again.</h1>');
    };

    const date_iso = date.toISOString().slice(0, 10);

    ////// SET DATE INPUT //////
    $('.date-search input').attr('value', `${date_iso}`)

    ////// LOAD SUMMARY TITLE //////
    const dateOptions = {year: 'numeric', month: 'long', day: 'numeric'};
    const longDate = (() => {
        const date_string = new Date(date_iso.slice(0, 4), parseInt(date_iso.slice(5, 7)) - 1 , date_iso.slice(8   , 10));
        return date_string.toLocaleDateString('en-US', options=dateOptions);
    });
    $('.summary-title').append(longDate);
    
    ////// LOAD NEO DATA //////
    loadData = function () {
        apigClient.dashboardDateGet({date: date_iso}, null, {})
        .then((result) => {
            try {
                neo_data = result.data.Items;
                // NEO Count
                $('.summary-neo-count').append(`<h1 id="neo-count">${neo_data.length}</h1>`);
                $('.summary-neo-count').append('<h3>Near Earth Objects</h3>');
    
    
                // AVG MISS DISTANCE
                avg_miss_distance_lunar = result.data.avg_miss_distance_lunar
                avg_miss_distance_astronomical = result.data.avg_miss_distance_astronomical
                $('.neo-miss-distance').append(`<p class="neo-miss-distance-data" id="neo-miss-distance-bottom-left">${avg_miss_distance_astronomical}</td>`);
                $('.neo-miss-distance').append(`<p class="neo-miss-distance-data" id="neo-miss-distance-bottom-right">${avg_miss_distance_lunar}</td>`);
    
                // NEO table
                neo_data.forEach((neo) => {
                    $('#neo-table-body').append(`<tr class="neo-table-row ${neo.neo_id.N}">`);
                    $(`.${neo.neo_id.N}`).append(`<td class="neo-table-data">${neo.neo_id.N}</td>`);
                    $(`.${neo.neo_id.N}`).append(`<td class="neo-table-data">${neo.name.S}</td>`);
                    $(`.${neo.neo_id.N}`).append(`<td class="neo-table-data">${neo.estimated_diameter_feet_min.N} - ${neo.estimated_diameter_feet_max.N}</td>`);
                    $(`.${neo.neo_id.N}`).append(`<td class="neo-table-data">${neo.miss_distance_astronomical.N}</td>`);
                    $(`.${neo.neo_id.N}`).append(`<td class="neo-table-data">${neo.miss_distance_lunar.N}</td>`);
                    $(`.${neo.neo_id.N}`).append(`<td class="neo-table-data">${neo.relative_velocity_mph.N}</td>`);
                    $('#neo-table-body').append('</tr>');
    
                    // Get data on Largest NEO
                    if (neo.largest_neo.BOOL) {
                        $('.largest-neo-info').append('<p class="largest-neo-label">Name</p>');
                        $('.largest-neo-info').append('<p class="largest-neo-label">Estimated Max Diameter</p>');
                        $('.largest-neo-info').append('<p class="largest-neo-label">Relative Velocity</p>');
                        $('.largest-neo-info').append(`<p class="largest-neo-data" id="largest-neo-bottom-left">${neo.name.S}</td>`);
                        $('.largest-neo-info').append(`<p class="largest-neo-data">${neo.estimated_diameter_feet_max.N}ft</td>`);
                        $('.largest-neo-info').append(`<p class="largest-neo-data" id="largest-neo-bottom-right">${neo.relative_velocity_mph.N}mph</td>`);
                    };
                })
            } catch(error) {
                $('body').append('<h2 class="dashboard-error">Sorry, could not find data for this date. Please try a different date or try again later.</h2>')
                $('.loading').hide();
                $('main').remove();
            };
        })
        .then(() => {
            $('.loading').hide();
            $('main').show();
        });
    };
});