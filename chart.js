var hoff = (midnight_seconds / 3600) % 1;

function generateChart() {
  // Skip the update sometimes if we're not working, to save on memory leaking
  if (chart && Math.random() < 0.75)
    return;

  var past_histogram = generateHistogram(past_wrs, past_bucket_interval);
  var today_histogram = generateHistogram(
    [today_wr], today_bucket_interval, true);
  var today_percentile = calculatePercentile(past_wrs, today_histogram);

  var past_chart_data = [];
  for (var day = 0; day < past_histogram.length; ++day) {
    for (var bucket = 0; bucket < past_histogram[day].length; ++bucket) {
      plotPoint(past_chart_data, past_histogram, day, bucket,
                past_bucket_interval, true);
    }
  }

  var today_chart_data = [];
  for (var bucket = 0; bucket < today_histogram[0].length; ++bucket) {
    plotPoint(today_chart_data, today_histogram, 0, bucket,
              today_bucket_interval, false);
  }

  if (chart)
    chart.destroy();

  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'percentile_feedback',
      defaultSeriesType: 'scatter',
      zoomType: 'xy',
      backgroundColor: 'transparent',
      resetZoomButton: {
        position: {
	    x: 0,
	    y: -30
	}
      }
    },
    title: {
      text: 'Work Efficiency by Hour of Day'
    },
    subtitle: {
      text: '% Hours Worked (compared to the past)'
    },
    xAxis: {
      title: {
        enabled: true,
        text: 'Hour'
      },
      tickInterval: 1,
      tickmarkPlacement: "on",
      startOnTick: false,
      endOnTick: false,
      showLastLabel: true,
      min: 0.5 + hoff,
      max: 23.5 + hoff,
      categories: ["00", "01", "02", "03", "04", "05",
                   "06", "07", "08", "09", "10", "11",
                   "12", "13", "14", "15", "16", "17",
                   "18", "19", "20", "21", "22", "23",
                   "00", "01", "02", "03", "04", "05",
                   "06", "07", "08", "09", "10", "11",
                   "12"].slice(Math.floor(midnight_seconds / 3600))
    },
    yAxis: {
      title: {
        text: 'Work Efficiency'
      },
      min: 0,
      max: 100
    },
    tooltip: {
      formatter: function() {
        return ''+
          (this.x * this.y / 100).toFixed(2) + '/' + this.x.toFixed(2) +
          ' hours worked ('+ this.y.toFixed(2) +'% efficiency)';
      }
    },
    legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'top',
      x: 0,
      y: 55,
      floating: true,
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      borderWidth: 1
    },
    labels: {
      items: [{
        html: "PR " + today_percentile.toFixed(0),
	style: {left: '10px', top: '32px', "font-size": '36px',
		color: 'rgb(30, 216, 15)'}
      }]
    },
    plotOptions: {
      scatter: {
        marker: {
          radius: 4,
          states: {
            hover: {
              enabled: true,
              lineColor: 'rgb(100,100,100)'
            }
          }
        },
        states: {
          hover: {
            marker: {
              enabled: false
            }
          }
        }
      }
    },
    series: [{
      name: 'Past',
      color: 'rgba(119, 174, 216, .15)',
      data: past_chart_data
    }, {
      name: 'Today',
      color: 'rgb(30, 216, 15)',
      data: today_chart_data,
      marker: {
        radius: 2
      }
    }]
  });
}

$(document).ready(function() {
  checkCurrentDay();
  generateChart();
  updateWorkTime();
  updateInterval = setInterval(updateWorkTime, 1000);
  setTimeout(function() { location.reload(true); }, refresh_delay * 1000); // ??
  setInterval(generateChart, 10 * 60 * 1000); // ten minutes
});
