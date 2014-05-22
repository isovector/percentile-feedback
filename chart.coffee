generateChart = ->
  processData true
  $("svg").remove()

  # http://bl.ocks.org/mbostock/3019563
  margin = {top: 10, right: 10, bottom: 35, left: 50}
  width = 960 - margin.left - margin.right
  height = 360 - margin.top - margin.bottom

  xValue = (d) -> d[0]
  xScale = d3.scale.linear()
    .domain([0, 24])
    .range([0, width])
  xMap = (d) -> xScale(xValue(d))
  xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom")
    .ticks(24)
    .tickFormat (tick) ->
      hour = tick + Math.floor(midnight_seconds / 3600)
      hour % 24

  yValue = (d) -> d[1]
  yScale = d3.scale.linear()
    .domain([0, 100])
    .range([height, 0])
  yMap = (d) -> yScale(yValue(d))
  yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left")
    .ticks(3)

  outerWidth = width + margin.left + margin.right
  outerHeight = height + margin.top + margin.bottom
  svg = d3.select("#container")
    .append("svg")
      .attr(
        width: "100%"
        height: "100%"
        id: "chart"
        viewBox: "0 0 #{ outerWidth } #{ outerHeight }"
        preserveAspectRatio: "xMidYMid meet" # Or just xMinYMid?
      ).style(
        background: "white"
        "max-height": "480"
      )
    .append("g")
      .attr("transform", "translate(#{ margin.left }, #{ margin.top })")

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0, #{ height })") # height + 2
      .call(xAxis)
    .append("text")
      .attr("class", "label")
      .attr("x", width / 2)
      .attr("y", 30)
      .style("text-anchor", "end")
      .text("Hour")

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("class", "label")
      .attr("transform", "rotate(-90)")
      .attr("x", -(height / 2.75))
      .attr("y", -30)
      .style("text-anchor", "end")
      .text("Work Efficiency")

  svg.append("g")
    .selectAll("circle")
    .data(past_chart_data)
    .enter()
    .append("circle")
    .attr(
      cx: xMap
      cy: yMap
      r: 2
    )
    .style("fill", "#aaa")

  svg.append("g")
    .selectAll("circle")
    .data(today_chart_data)
    .enter()
    .append("circle")
    .attr(
      cx: xMap
      cy: yMap
      r: 1.5
    )
    .style("fill", "#6a6")

  svg.append("text")
    .attr("class", "pr")
    .attr("x", 20)
    .attr("y", 40)
    .text("PR " + today_percentile.toFixed(0))

$ ->
  checkCurrentDay()
  generateChart()
  updateWorkTime()

  setInterval(updateWorkTime, 1000)
  setTimeout((-> location.reload(true)), refresh_delay * 1000)
  setInterval(generateChart, 10 * 60 * 1000)
