# WARNING: This is NOT the source file for plot.js!
#
# This is the beginnings of a CoffeeScript version of plot.js
# This file may not be used, and is incomplete

getNow = ->
  d = new Date()
  now = d.getHours() * 3600 + d.getMinutes() * 60 + d.getSeconds()
  now - midnight_seconds

workTime = (wr) ->
  total = 0
  for start, i in wr.starts
    stop = today_wr.stops[i]
    stop = getNow() if typeof stop is "undefined"
    total += stop - start
  total

workTimeToday = ->
  workTime today_wr

workTimeTotal = ->
  total = 0
  for past_wr in past_wrs
    total += workTime past_wr
  total

updateWorkTime = ->
  $("#pf_timer_today_total").text formatTime workTimeToday()
  $("#pf_timer_all_time_total").text formatTime workTimeTotal()

formatTime = (sec) ->
  hours = Math.floor(sec / 3600)
  minutes = Math.floor((sec % 3600) / 60)
  seconds = sec % 60
  minutes = "0" + minutes  if minutes < 10
  seconds = "0" + seconds  if seconds < 10
  hours + ":" + minutes + ":" + seconds

next_boundary = (start, interval) ->
  # For example, let's consider a start of 7230
  # This is 3600 + 3600 + 30, i.e. 02:00:30, thirty seconds past 2am
  sinceLastBoundary = start % interval

  # Example: 7230 % 3600 = 30
  # That's the time elapsed since the last interval boundary
  # The last interval boundary was 7200 (3600 * 2, i.e. 2am)
  untilNextBoundary = interval - sinceLastBoundary

  # Example: 3600 - 30 = 3570
  # This is the time until the next interval boundary
  # In other words, we're 30 seconds after 2am
  # So now there's another 3600 seconds (1 hour) - 30 seconds to go
  # That's 3570 seconds
  nextBoundary = start + untilNextBoundary

  # Example: 7230 + 3570 = 10800
  # This is the time we're at now plus the time until the next boundary
  # In this case it adds up to 10800, which is 3600 * 3, i.e. 3am
  nextBoundary

# TODO: generateHistogram

calculatePercentile = (past_wrs, today_histogram) ->
  return 100 unless past_wrs.length
  today_total = today_histogram[0][today_histogram[0].length - 1]
  better_day_count = 0
  i = 0

  while i < past_wrs.length
    wr = past_wrs[i]
    histogram = generateHistogram([wr], today_bucket_interval, true)
    total = histogram[0][histogram[0].length - 1]
    ++better_day_count  if total > today_total
    ++i
  100 * (1 - (better_day_count / past_wrs.length))

# TODO: various variables

plotPoint = (data, histogram, day, bucket, interval, jitter) ->
  x = bucket * interval / 3600
  y = 100 * histogram[day][bucket] / ((1 + bucket) * interval)
  x += 1.0 * (Math.random() - 0.5)  if jitter
  data.push [x + hoff, y]

# TODO: generateChart

$(document).ready ->
  generateChart()
  updateWorkTime()
  updateInterval = setInterval(updateWorkTime, 1000)
  setTimeout (->
    location.reload true
  ), refresh_delay * 1000 # ??
  setInterval generateChart, 10 * 60 * 1000 # ten minutes
