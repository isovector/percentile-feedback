#!/usr/bin/env python3

import datetime
import os.path
import re
import sys

def iso2js(date):
    ymd = [str(int(p)) for p in date.split("-")]
    return ", ".join(ymd)

def periods(duration):
    # TODO: Error if duration > (3600 * 24)
    results = []

    utcnow = datetime.datetime.utcnow()
    date = utcnow.strftime("%Y-%m-%d")
    completed = (utcnow.hour * 3600) + (utcnow.minute * 60) + utcnow.second
    started = completed - duration

    if started < 0:
        yesterday = utcnow - datetime.timedelta(days=1)
        yesterdate = yesterday.strftime("%Y-%m-%d")
        yesterstarted = (3600 * 24) - abs(started)
        yestercompleted = 3600 * 24
        started = 0
        args = (yesterdate, yesterstarted, yestercompleted)
        results.append("%s %s %s" % args)

    args = (date, started, completed)
    results.append("%s %s %s" % args)
    return results

def jsobj(date, pairs):
    starts = []
    stops = []
    for (start, stop) in pairs:
        starts.append(start)
        stops.append(stop)
    obj = "{date: new Date(%s), starts: [%s], stops: [%s]}"
    starts = ", ".join([start + ".0" for start in starts])
    stops = ", ".join([stop + ".0" for stop in stops])
    return obj % (iso2js(date), starts, stops)

def template(periods_txt):
    dates = {}
    with open(periods_txt) as f:
        for line in f:
            line = line.rstrip()
            try:
                date, started, completed = line.split(" ")
            except:
                continue
            if date not in dates:
                dates[date] = []
            dates[date].append((started, completed))

    lines = []

    utcnow = datetime.datetime.utcnow()
    today = utcnow.strftime("%Y-%m-%d")
    if today in dates:
        obj = jsobj(today, dates[today])
        del dates[today]
    else:
        obj = jsobj(today, [])
    lines.append("var today_wr = %s;" % obj)

    lines.append("var updateInterval;")
    lines.append("var refresh_delay = 43733.87873;")
    lines.append("var past_wrs = [];")

    for date in sorted(dates):
        obj = jsobj(date, dates[date])
        lines.append("past_wrs.push(%s);" % obj)

    return "\n".join(lines)

def main():
    try: duration = int(sys.argv[1])
    except Exception as err:
        print("Usage: log.py <duration>", file=sys.stderr)
        sys.exit(2)

    ppf = os.path.dirname(os.path.realpath(__file__))
    periods_js = os.path.join(ppf, "periods.js")
    periods_txt = os.path.join(ppf, "periods.txt")

    with open(periods_txt, "a") as f:
        for period in periods(duration):
            f.write(period + "\n")

    with open(periods_js, "w") as f:
        f.write(template(periods_txt)+ "\n")

if __name__ == "__main__":
    main()
