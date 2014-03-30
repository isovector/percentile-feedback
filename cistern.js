function highlight_active_nav_link(request_path) {
  $(".navbar li a").each(function() {
    if($(this).attr("href") == request_path)
      $(this).parent().addClass('active');
  });
}

function zazz_headers() {
  var t = 200;  // match main.css transition delay
  $(":header").each(function(i, elem) {
    setTimeout(function() { $(elem).addClass('zozz'); }, 1000 + i * t);
    setTimeout(function() { $(elem).addClass('zazz'); }, 1001 + i * t);
    setTimeout(function() { $(elem).removeClass('zazz'); }, 1000 + t + i * t);
    setTimeout(function() { $(elem).removeClass('zozz'); }, 1001 + t + i * t + t);
  });
}

$(document).ready(function() {
  zazz_headers();
});


// Drawing snowflakes
function draw_snowflake(size, speed) {
  if(!speed) speed = 100;
  var snowflake = $(koch(4, size));
  var iteration = 0;
  for(size = 0.7 * size; size > 2; size *= 0.7) {
    var whatever = function(s) {
      setTimeout(function() {
        koch(Math.ceil(s / 5), s, snowflake[0].getContext('2d'), snowflake[0].width);
      }, ++iteration * speed);
    }(size);
  }
  return snowflake;
}

var kx = 0, ky = 0, angle = 0, initial_depth = 0;
function koch(depth, size, context, canvas_size) {
  if(!initial_depth)
    initial_depth = depth;
  var canvas = null;
  if(!canvas_size)
    canvas_size = size * 4;
  if(!context) {
    canvas = $('<canvas class="snowflake" width="'+canvas_size+'" height="'+canvas_size+'"></canvas>')[0];
    context = canvas.getContext("2d");
    /*
    context.strokeStyle = '#ccc';
    for(var d = 0; d < canvas_size; d += 50) {
      context.moveTo(0, d);
      context.lineTo(canvas_size, d);
      context.moveTo(d, 0);
      context.lineTo(d, canvas_size);
    }
    context.stroke();
    */
  }
  else {
    
  }
  if(depth == initial_depth) {
    angle = 0;
    context.strokeStyle = '#2d0de0';
    context.fillStyle = 'rgba(139, 135, 242, 0.25)';
    context.beginPath();
    kx = 0.1 * (canvas_size - size * 4) + 3 * canvas_size / 8;
    ky = 0.5 * (canvas_size - size * 4) + 3 * canvas_size / 8 / 10;
    context.moveTo(kx, ky);
  }
    
  if(!depth)
    forward(size, context);
  else {
    var r = 60;
    var recurse = function() { koch(depth-1, size/3, context); };
    var flake = function() {
      recurse();
      angle += r;
      recurse();
      angle -= 2 * r;
      recurse();
      angle += r;
      recurse();
    };
    flake();

    if(depth == initial_depth) {
      for(var i = 0; i < 360 / (0.5 * r) - 1; ++i) {
        angle += 0.5 * r;
        flake();
      }
    }

  }
  
  if(depth == initial_depth) {
    context.stroke();
    context.fill();
    initial_depth = 0;
  }
  return canvas;
}

function forward(distance, context) {
  kx += distance * Math.cos(angle * 2 * Math.PI / 360);
  ky += distance * Math.sin(angle * 2 * Math.PI / 360);
  context.lineTo(kx, ky);
}
