function updateIcon(interaction) {
  var icon = document.createElement("canvas");
  icon.setAttribute("height", "19");
  icon.setAttribute("width", "19");
  context = icon.getContext("2d");
  var page = localStorage["page"] || ".";

  var req1 = new XMLHttpRequest();
  var data = page.replace(/([^\/]+)?$/, "") + "data.js";
  req1.open("GET", data + "?" + unixtime(), false);
  try { req1.send(null); }
  catch (exception) {
    req1.status === null;
  }

  if (req1.status === 200) {
    console.log("Reloading data.js");
    eval.call(window, req1.responseText);
  } else {
    if (interaction) {
      alert("You need to set a page in extension options!");
      return;
    }

    context.textAlign = "center";
    context.font = "9px Verdana";
    context.fillText("PR", 9.5, 9);
    context.fillText("?", 9.5, 17);

    var imageData = context.getImageData(0, 0, 19, 19);
    chrome.browserAction.setIcon({imageData: imageData});
    return;
  }

  // This must be loaded because it captures the variables from data.js
  // Probably ought to pass them as arguments instead
  console.log("loading plot.js");
  var req2 = new XMLHttpRequest();
  var plot = page.replace(/([^\/]+)?$/, "") + "plot.js";
  req2.open("GET", plot, false);
  try { req2.send(null); }
  catch (exception) {
    req2.status === null;
  }

  if (req2.status === 200) {
    eval.call(window, req2.responseText);
  }

  // This isn't the best interface
  var pr = processData();

  if (pr < 50) {
    context.fillStyle = "#c00";
    context.fillRect(0, 0, 19, 19);
    context.fillStyle = "#fee";
  } else {
    context.fillStyle = "#090";
  }
  context.textAlign = "center";
  context.font = "9px Verdana";
  context.fillText("PR", 9.5, 9);
  context.fillText(pr.toFixed(0), 9.5, 17);

  var imageData = context.getImageData(0, 0, 19, 19);
  chrome.browserAction.setIcon({imageData: imageData});
  return true;
}

function openPage() {
  var page = localStorage["page"];
  var opened = updateIcon(true);

  chrome.tabs.query({url: page}, function (tabs) {
    if (tabs.length > 0) {
      chrome.tabs.update(tabs[0].id, {selected: true});
      chrome.tabs.reload(tabs[0].id);
    } else if (opened) {
      chrome.tabs.create({url: page}, function (tab) {
        chrome.tabs.reload(tab.id);
      });
    }
  });
}

chrome.browserAction.onClicked.addListener(openPage);

function unixtime() {
  return Math.floor(Date.now() / 1000);
}

// Could probably do a fancy thing to poll every few seconds
function updateIconLoop() {
  var refreshSeconds = localStorage["timeout"] || 60;
  if (!(unixtime() % refreshSeconds)) {
    console.log("Updating in loop! " + unixtime() + " " + refreshSeconds);
    updateIcon();
  }
  setTimeout(updateIconLoop, 1000);
}

updateIcon();
setTimeout(updateIconLoop, 5000);
