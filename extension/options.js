document.body.onload = function loadOptions() {
  var page_input = document.getElementById("page");
  var timeout_input = document.getElementById("timeout");
  var page = localStorage["page"];
  if (page != undefined) {
    page_input.value = page;
  }
  console.log(localStorage["timeout"]);
  var timeout = parseInt(localStorage["timeout"] || 60, 10);
  if (timeout === 0) {
    timeout = 60;
  }
  timeout_input.value = timeout.toFixed(0);
}

document.getElementById("save").onclick = function saveOptions() {
  var page_input = document.getElementById("page");
  var timeout_input = document.getElementById("timeout");
  localStorage["page"] = page_input.value;
  var timeout = parseInt(timeout_input.value || "0", 10);
  if (timeout === 0) {
    timeout = 60;
  }
  localStorage["timeout"] = timeout;
  var p = document.createElement("p");
  p.appendChild(document.createTextNode("Saved!"));
  document.body.appendChild(p);
  updateIcon();
}
