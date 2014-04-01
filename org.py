#!/usr/bin/env python3

import datetime
import os.path
import re
import sys

def iso2js(date):
    ymd = [str(int(p)) for p in date.split("-")]
    return ", ".join(ymd)

def periods(utcnow, duration):
    # TODO: Error if duration > (3600 * 24)
    results = []

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

def template(orgfile):
    dates = {}

    p = []
    with open(orgfile) as f:
        for line in sorted(f):
            if "CLOCK" not in line:
                continue
            try:
                tstr = re.compile(r"\[([^\]]+)\]")
                sc = tstr.findall(line)
                strptime = datetime.datetime.strptime
                started = strptime(sc[0], "%Y-%m-%d %a %H:%M")
                completed = strptime(sc[1], "%Y-%m-%d %a %H:%M")
            except:
                continue
            if completed > started:
                p.extend(periods(completed, (completed - started).seconds))

    for line in p:
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
    try: orgfile = sys.argv[1]
    except Exception as err:
        print("Usage: org.py <orgfile>", file=sys.stderr)
        sys.exit(2)

    ppf = os.path.dirname(os.path.realpath(__file__))
    data_js = os.path.join(ppf, "data.js")

    with open(data_js, "w") as f:
        f.write(template(orgfile) + "\n")

if __name__ == "__main__":
    main()
