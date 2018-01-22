// Fuego Plotting Script

// Copyright (c) 2014 Cogent Embedded, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

jQuery.noConflict();
jQuery(document).ready(function () {

// Jenkins logs path
var jenkins_logs_path = 'http://'+location['host'] + '/fuego/userContent/fuego.logs/';

// get the test name from the URL
var localurl = jQuery(location).attr('href').split("/");
var testtype = localurl[localurl.length - 2].split(".")[2] // E.g.: Functional
var testsuite = localurl[localurl.length - 2].split(".")[3] // E.g.: Dhrystone

// results.json file
var results_json = null;
var plots = [];

// hidden tooltip element
jQuery('<div id="tooltip"></div>').css( {
    position: 'absolute',
    display: 'none',
    border: '1px solid #fdd',
    padding: '2px',
    'background-color': '#ffe',
    opacity:0.90
}).appendTo("body").fadeIn(200);

function show_upperplot_tooltip(event, pos, item) {
    if (item) {
        var x = item.datapoint[0].toFixed(2);
        var y = item.datapoint[1].toFixed(2);
        var info = results_json[item.series.label];
        jQuery("#tooltip").html("data: " + info['data'][item.dataIndex] + "<br \>" +
                                "start_time: " + info['start_time'][item.dataIndex] + "<br \>" +
                                "board: " + info['board'] + "<br \>" +
                                "spec: " + info['spec'] + "<br \>" +
                                "kernel_version: " + info['kernel_version'] + "<br \>" +
                                "platform: " + info['platform'] + "<br \>" +
                                "test_set: " + info['test_set'] + "<br \>" +
                                "test_case: " + info['test_case'] + "<br \>" +
                                "x: " + x + "<br \>" +
                                "y: " + y)
                          .css({top: item.pageY+5, left: item.pageX-200})
                          .fadeIn(200);
    } else {
        jQuery("#tooltip").hide();
    }
}

function handle_lowerplot_zoom(event, ranges) {
    var id = jQuery(this).attr("id"); // e.g.: upper-2048_Kb_Record_Write-0
    var test_set = id.split('-')[1];
    var index = id.split('-')[2];
    var plot = plots[index];

    plot.getOptions().xaxes[0].min = ranges.xaxis.from;
    plot.getOptions().xaxes[0].max = ranges.xaxis.to;
    plot.getOptions().yaxes[0].min = ranges.yaxis.from;
    plot.getOptions().yaxes[0].max = ranges.yaxis.to;
    plot.setupGrid();
    plot.draw();
}

function replot_test_set() {
    var id = jQuery(this).attr("id"); // e.g.: label-2048_Kb_Record_Write-0
    var test_set = id.split('-')[1];
    var index = id.split('-')[2];

    plot_test_set(test_set, index);
}

function plot_test_set(test_set, index) {
    // prepare data to display
    var label_id = 'label-' + test_set + '-' + index;
    var flot_results_json = []
    jQuery.each(results_json, function(label, results_json_item) {
        var is_checked = jQuery('#' + label_id).children('input[name="' + label + '"]').attr("checked");
        if (is_checked && (results_json_item['test_set'] == test_set)) {
            var data = [];
            results_json_item['data'].forEach(function(data_item, j) {
                data.push([j, data_item]);
            });
            flot_results_json.push({ 'label' : label, 'data' : data});
        }
    });

    // calculate y_max, y_min and x_max fromt the result data
    var y_min = 1000000000;
    var y_max = -1;
    var x_max = 0;
    var num_samples = 75; // we only plot the last 75 points on the upper plot

    flot_results_json.forEach (function (flot_result_item) {
        slice = flot_result_item['data'].slice(-1 * num_samples);
        slice.forEach(function (data_value) {
            x = parseInt(data_value[0]);
            y = parseFloat(data_value[1]);
            y_max = Math.max(y_max, y);
            y_min = Math.min(y_min, y);
            x_max = Math.max(x_max, x)
        });
    });

    // prepare the plot options for the upper and lower plots
    var upper_options = {
        lines   : { show: true , lineWidth:1.2 },
        points  : { show: true },
        xaxis   : { max: x_max,
                    min: Math.max(x_max - num_samples, 0) },
        yaxis   : { max: 1.02 * y_max,
                    min: 0.98 * y_min},
        grid    : { hoverable: true, clickable: true,
                    backgroundColor: "#f5f5f5", borderWidth: 0.5 },
        pan     : { interactive: true },
        zoom    : { interactive: true },
        legend  : { position: 'nw',
                    noColumns:2,
                    container: jQuery("#legend_item_"+index) },
        colors  : [ "#008f00", "#73fa79", "#009193", "#73fcd6", "#ff9300",
                    "#ffd479", "#942193", "#d783ff", "#424242", "#a9a9a9",
                    "#011993", "#76d6ff", "#929000", "#fffc79", "#941100",
                    "#ff7e79" ],
    };

    var lower_options = {
        lines   : { show: true, lineWidth:1.0 },
        points  : { show: false },
        grid    : { backgroundColor: "#f0f0f0", borderWidth: 0.5 },
        legend  : { show: false },
        selection: { mode: "x", color: "blue" },
        colors  : [ "#008f00", "#73fa79", "#009193", "#73fcd6", "#ff9300",
                    "#ffd479", "#942193", "#d783ff", "#424242", "#a9a9a9",
                    "#011993", "#76d6ff", "#929000", "#fffc79", "#941100",
                    "#ff7e79" ]
    };

    // finally plot the data
    var upper_placeholder = jQuery('#upper-' + test_set + '-' + index);
    var lower_placeholder = jQuery('#lower-' + test_set + '-' + index);

    jQuery.plot(lower_placeholder, flot_results_json, lower_options);
    return jQuery.plot(upper_placeholder, flot_results_json, upper_options);
}

function json_updated(series) {
    var localurl = jQuery(location).attr('href')
    display_table(series);

//     if (localurl.search("Functional") != -1) {
//         display_table(series);
//     } else {
//         plot_all_test_sets(series);
//         display_table(series);
//     }
}

function display_table(series) {
    var obj = series;
    var count = 0;
    jQuery('.plots').append("<h1>" + obj.test_name + "</h1>");
    jQuery.each(obj, function (key, data) {
        if (key == "test_name")
            return;
        jQuery('.plots').append("<h2>" + key + "</h2>");
        measurements_length = Object.keys(data.measurements).length
        common = '<table border="1" id="' + count +'" cellspacing="0">' +
            '<tr style="background-color:#cccccc">' +
            '<th colspan="' + (measurements_length + 6) + '" align="left">' +
            'board: ' + data.board + '<br/>' +
            'kernel_version: ' + data.kernel_version + '<br/>' +
            'test_spec: ' + data.test_spec + '<br/>' +
            'test_case: ' + data.test_case + '<br/>' +
            'test_plan: ' + data.test_plan + '<br/>' +
            'test_set: ' + data.test_set + '<br/>' +
            'toolchain: ' + data.toolchain + '<br/>' +
            '</th>' +
            '</tr>' +
            '<tr style="background-color:#cccccc">' +
            '<th colspan="1" align="left">build number</th>' +
            '<th colspan="1" align="left">status</th>'

        jQuery.each(data.measurements, function (key, measure) {
            common = common +
                '<th colspan="1" align="left">' + key + '</th>'
        })

        common = common +
            '<th colspan="1" align="left">start_time</th>' +
            '<th colspan="1" align="left">duration</th>' +
            '</tr>'
            '</table>';
        jQuery('.plots').append(common);

        for (var i=0; i < data.build_number.length; i++) {
            result_row = '<tr>' +
                '<td colspan="1" align="left">' + data.build_number[i] + '</td>' +
                '<td colspan="1" align="left">' + data.status[i] + '</td>'
            jQuery.each(data.measurements, function (key, measure) {
                result_row = result_row +
                    '<td colspan="1" align="left">' + measure.status[i] + '</td>'
            })
            result_row = result_row +
                '<td colspan="1" align="left">' + data.start_time[i] + '</td>' +
                '<td colspan="1" align="left">' + data.duration_ms[i] + ' ms</td>' +
                '</tr>';
            jQuery("#" + count + " > tbody:last-child").append(result_row);
        }
        count++;
    });
}

function plot_all_test_sets(series) {
    // results_json is the results.json file (global)
    results_json = series

    // extract set of boards, test_specs, kernel_versions
    var labels = [];
    var boards = [];
    var test_specs = [];
    var kernel_versions = [];
    var test_sets = [];
    var test_cases = [];

    jQuery.each(results_json, function(key, results_json_item) {
        if (key == "test_name")
            return;
        if (!(labels.includes(key)))
            labels.push(key);
        if (!(boards.includes(results_json_item['board'])))
            boards.push(results_json_item['board']);
        if (!(test_specs.includes(results_json_item['test_spec'])))
            test_specs.push(results_json_item['test_spec']);
        if (!(kernel_versions.includes(results_json_item['kernel_version']))) // FIXTHIS: remove tail?
            kernel_versions.push(results_json_item['kernel_version']);
        if (!(test_sets.includes(results_json_item['test_set'])))
            test_sets.push(results_json_item['test_set']);
        if (!(test_cases.includes(results_json_item['test_case'])))
            test_cases.push(results_json_item['test_case']);
    });

    // there is one plot per test_set
    test_sets.forEach(function(test_set, i) {
        // FIXTHIS: make sure that test_set has no - in it
        var label_id = 'label-' + test_set + '-' + i;
        // create all html elements
        jQuery('.plots').append(
            '<div class="container">' +
            '    <div class="area_header">' + testsuite + ' / ' + test_set + '</div>' +
            '    <div class="two_figures_container">' +
            '        <div style="width:100%;height:200px;" id="upper-' + test_set + '-' + i + '"></div>' +
            '        <p></p>' +
            '        <div style="width:100%;height:70px;" id="lower-' + test_set + '-' + i + '"></div>' +
            '    </div>' +
            '    <br/>' +
            '    <div class="legend_container">Legend:' +
            '        <div id="legend_item_' + i + '"></div>' +
            '        <br/>' +
            '        <div id="' + label_id + '"></div>' +
            '    </div>' +
            '</div>');

        labels.forEach(function(label) {
            if (results_json[label].test_set == test_set) {
                var id = 'id_' + label + '_'+ i;
                jQuery('#' + label_id).append(
                    '<input type="checkbox" name="' + label + '" checked="checked" id="' + id + '">' +
                    '<label for="' + id + '">' + label + '</label><br/>');
            }
        });

        // hook callbacks to interactive elements
        jQuery('#lower-' + test_set + '-' + i).bind("plotselected", handle_lowerplot_zoom);
        jQuery('#upper-' + test_set + '-' + i).bind("plothover", show_upperplot_tooltip);
        jQuery('#' + label_id).click(replot_test_set);

        // plot this group
        upper_plot = plot_test_set(test_set, i);
        plots.push(upper_plot);
    });
}

jQuery.ajax({ url: jenkins_logs_path+'/'+testtype+'.'+testsuite+'/results.json', method: 'GET', dataType: 'json', async: false, success: json_updated});

})
