# NOTE: This is the source file for plot.js

root = exports ? this
# TODO: root.percentileFeedback?
past_wrs = root.past_wrs
today_wr = root.today_wr

# getNow

getNow = ->
  d = new Date()
  now = d.getHours() * 3600 + d.getMinutes() * 60 + d.getSeconds()
  now = now + (3600 * 24) if now < midnight_seconds
  now - midnight_seconds

# checkCurrentDay

root.checkCurrentDay = ->
  today = new Date()

  # If we're past midnight and before midnight_seconds, we need yesterday
  now = today.getHours() * 3600 + today.getMinutes() * 60 + today.getSeconds()

  # Set date to yesterday
  today.setDate today.getDate() - 1 if now < midnight_seconds

  # today_wr is a global inherited from data.js
  year = today.getFullYear() is today_wr.date.getFullYear()
  month = today.getMonth() is today_wr.date.getMonth()
  day = today.getDate() is today_wr.date.getDate()
  if (not year) or (not month) or (not day)
    today_wr =
      date: today
      starts: []
      stops: []

# workTimeToday

workTimeToday = (wr) ->
  total = 0
  i = 0

  while i < wr.starts.length
    start = wr.starts[i]
    stop = wr.stops[i]
    stop = getNow() if typeof stop is "undefined"
    total += stop - start
    ++i
  total

# workTimeTotal

workTimeTotal = ->
  total = 0
  i = 0

  while i < past_wrs.length
    total += workTimeToday(past_wrs[i])
    ++i
  total

# updateWorkTime

root.updateWorkTime = ->
  $("#pf_timer_today_total").text formatTime(workTimeToday(today_wr))
  $("#pf_timer_all_time_total").text formatTime(workTimeTotal())

# formatTime

# Or secondsToTime
formatTime = (sec) ->
  hours = Math.floor(sec / 3600)
  minutes = Math.floor((sec % 3600) / 60)
  seconds = sec % 60
  minutes = "0" + minutes if minutes < 10
  seconds = "0" + seconds if seconds < 10
  hours + ":" + minutes + ":" + seconds

# next_boundary

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

# generateHistogram

root.generateHistogram = (wrs, interval, ends_early) ->
  # TODO: randomize the start time a bit so that there's jitter
  histogram = []
  day_end = (if ends_early then getNow() else 86400)
  i = 0

  while i < wrs.length
    histogram.push []
    time = 0

    while time < day_end
      histogram[i].push 0
      time += interval
    wr = wrs[i]
    j = 0

    while j < wr.starts.length
      start = wr.starts[j]
      stop = wr.stops[j]

      # Either today (still working), or some past day that overran
      if typeof stop is "undefined"
        # Was: postfix
        stop = (if wrs.length is 1 then getNow() else start + 1)

      while start < stop
        nextBoundary = next_boundary(start, interval)
        new_start = undefined
        new_stop = undefined

        # Is there an interval between start and stop?
        if nextBoundary < stop
          # Yes, there is an interval boundary
          new_start = nextBoundary
          new_stop = stop

          # This next line must come after the two above
          stop = nextBoundary

        # We break this period up so that the current start and stop are the
        # time *up until* the next interval boundary. Then we also set the
        # new start time to correspond to the next interval boundary.
        # So imagine that we have:
        #   start    |   stop
        # Where "|" is an interval boundary
        # What we've done is to make replacements like so:
        #   start   stop/new_start    new_stop
        else
          # No, there is no interval boundary
          new_start = 0
          new_stop = 0
          # We have set these values so that the loop will end
          # (This acts a bit like a break sentinel)

        # Do histogram population stuff
        period = stop - start
        start_bucket = Math.floor((nextBoundary - interval) / interval)

        # This should be checked for fencepost errors
        # May also not work with certain interval settings
        end_bucket = Math.floor(day_end / interval)
        bucket = start_bucket
        while bucket <= end_bucket
          histogram[i][bucket] += period
          bucket++

        start = new_start
        stop = new_stop
      ++j
    ++i
  histogram[0].pop() if ends_early
  histogram

# calculatePercentile

past_bucket_interval = 60 * 60
# today_bucket_interval should divide past_bucket_interval cleanly
today_bucket_interval = 1 * 60

root.calculatePercentile = (past_wrs, today_histogram) ->
  return 100 unless past_wrs.length
  today_total = today_histogram[0][today_histogram[0].length - 1]
  better_day_count = 0
  i = 0

  while i < past_wrs.length
    wr = past_wrs[i]
    histogram = generateHistogram([wr], today_bucket_interval, true)
    total = histogram[0][histogram[0].length - 1]
    ++better_day_count if total > today_total
    ++i
  100 * (1 - (better_day_count / past_wrs.length))

# plotPoint

root.plotPoint = (data, histogram, day, bucket, interval, jitter) ->
  hoff = (midnight_seconds / 3600) % 1
  x = bucket * interval / 3600
  y = 100 * histogram[day][bucket] / ((1 + bucket) * interval)
  x += 1.0 * (Math.random() - 0.5) if jitter

  # Bounds checking
  # x goes out of bounds because of jitter
  x = 0 - x if x < 0
  x = 48 - x if x > 24
  # y only goes out of bounds past 100; not sure why
  y = 0 if y < 0
  y = 100 if y > 100

  # https://stackoverflow.com/questions/2652319
  not_a_number = (obj) ->
    obj != obj
  data.push [
    x + hoff
    y
  ] unless not_a_number y

# processData

root.processData = (complete) ->
  console.log "1"
  today_histogram = generateHistogram([today_wr], today_bucket_interval, true)
  root.today_percentile = calculatePercentile(past_wrs, today_histogram)

  if complete
    console.log "2"
    past_histogram = generateHistogram(past_wrs, past_bucket_interval)
    root.past_chart_data = []
    day = 0

    while day < past_histogram.length
      bucket = 0

      while bucket < past_histogram[day].length
        plotPoint root.past_chart_data, past_histogram,
                  day, bucket, past_bucket_interval, true
        ++bucket
      ++day
    root.today_chart_data = []
    bucket = 0

    while bucket < today_histogram[0].length
      plotPoint root.today_chart_data, today_histogram,
                0, bucket, today_bucket_interval, false
      ++bucket
  root.today_percentile
