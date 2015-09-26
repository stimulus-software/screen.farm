require './app'
use Rack::Static, urls: {
  "/index.html" => "index.html",
  "/script.js" => "script.js",
  "/jquery.js" => "jquery.js",
}, root: 'public'
run App
