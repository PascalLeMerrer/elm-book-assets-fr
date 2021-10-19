const http = require('http');
const url = require('url');
const fs = require('fs');
const path = require('path');
// you can pass the parameter in the command line. e.g. node index.js 3000
const port = process.argv[2] || 9000;


http.createServer(function (req, res) {
  console.log("----------------------------")
  console.log(`${req.method} ${req.url}`);

  const parsedUrl = url.parse(req.url);
  const pathname = parsedUrl.pathname

  addCorsHeadersToResponse(res)

  if (pathname == "/search/erreur") {
    res.statusCode = 400;

    res.end('Invalid parameter');
  }
  else if (pathname.startsWith("/search")) {
    const query = pathname.substring("/search".length + 1)
    respondToSearchRequest(req, res, query)
  }
  else if (pathname == "/favicon.ico"){

  }
  else {
    serveStaticFile(req, res, parsedUrl);
  }

}).listen(parseInt(port));

function addCorsHeadersToResponse(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
}

function respondToSearchRequest(req, res, query) {
  let key = query.toLowerCase();
  let results = searchResponses[key];
  res.setHeader('Content-type', 'application/json');
  res.statusCode = 200;
  if (results === undefined) {
    results = [];
  }
  res.end(JSON.stringify({ "results" : results }));
}

function serveStaticFile(req, res, parsedUrl) {

  // extract URL path
  // Avoid https://en.wikipedia.org/wiki/Directory_traversal_attack
  // e.g curl --path-as-is http://localhost:9000/../fileInDanger.txt
  // by limiting the path to current directory only
  let sanitizePath = path.normalize(parsedUrl.pathname).replace(/^(\.\.[\/\\])+/, '');
  if (sanitizePath == "/") {
    sanitizePath = "/index.html";
  }
  let pathname = path.join(__dirname, sanitizePath);
  
  fs.exists(pathname, function (exist) {
    if(!exist) {
      res.statusCode = 404;
      res.end(`File ${pathname} not found!`);
      return;
    }

    fs.readFile(pathname, function(err, data){
      if(err){
        res.statusCode = 500;
        res.end(`Error getting the file: ${err}.`);
      } else {
        // based on the URL path, extract the file extention. e.g. .js, .doc, ...
        const ext = path.parse(pathname).ext;
        // if the file is found, set Content-type and send data
        res.setHeader('Content-type', mimeTypes[ext] || 'text/plain' );
        res.end(data);
      }
    });
  });
}

const bali1 = {
  "thumbnail":"/images/BAL1_small.jpeg",
  "large":"/images/BAL1_large.jpeg",
  "width": 1280,
  "height": 960
}

const bali2 = {
  "thumbnail":"/images/BAL2_small.jpeg",
  "large":"/images/BAL2_large.jpeg",
  "width": 1280,
  "height": 960
}

const bali3 = {
  "thumbnail":"/images/BAL3_small.jpeg",
  "large":"/images/BAL3_large.jpeg",
  "width": 1280,
  "height": 960
}

const thailande1 = {
  "thumbnail":"/images/THA1_small.jpeg",
  "large":"/images/THA1_large.jpeg",
  "width": 1280,
  "height": 960
}

const thailande2 = {
  "thumbnail":"/images/THA2_small.jpeg",
  "large":"/images/THA2_large.jpeg",
  "width": 1280,
  "height": 960
}

const thailande3 = {
  "thumbnail":"/images/THA3_small.jpeg",
  "large":"/images/THA3_large.jpeg",
  "width": 1280,
  "height": 960
}

const thailande4 = {
  "thumbnail":"/images/THA4_small.jpeg",
  "large":"/images/THA4_large.jpeg",
  "width": 960,
  "height": 1280
}

const thailande5 = {
  "thumbnail":"/images/THA5_small.jpeg",
  "large":"/images/THA5_large.jpeg",
  "width": 971,
  "height": 1280
}

const londres1 =
{
  "thumbnail":"/images/LON1_small.jpeg",
  "large":"/images/LON1_large.jpeg",
  "width": 1280,
  "height": 854
}

const londres2 =
{
  "thumbnail":"/images/LON2_small.jpeg",
  "large":"/images/LON2_large.jpeg",
  "width": 1280,
  "height": 651
}

const londres3 =
{
  "thumbnail":"/images/LON3_small.jpeg",
  "large":"/images/LON3_large.jpeg",
  "width": 1280,
  "height": 854
}

const danemark1 =
{
  "thumbnail":"/images/DAN1_small.jpeg",
  "large":"/images/DAN1_large.jpeg",
  "width": 1280,
  "height": 960
}

const danemark2 =
{
  "thumbnail":"/images/DAN2_small.jpeg",
  "large":"/images/DAN2_large.jpeg",
  "width": 1280,
  "height": 854
}

const danemark3 =
{
  "thumbnail":"/images/DAN3_small.jpeg",
  "large":"/images/DAN3_large.jpeg",
  "width": 1280,
  "height": 854
}

const danemark4 =
{
  "thumbnail":"/images/DAN4_small.jpeg",
  "large":"/images/DAN4_large.jpeg",
  "height": 1280,
  "width": 854
}

const rennes1 =
{
  "thumbnail":"/images/REN1_small.jpeg",
  "large":"/images/REN1_large.jpeg",
  "width": 968,
  "height": 1280
}

const rennes2 =
{
  "thumbnail":"/images/REN2_small.jpeg",
  "large":"/images/REN2_large.jpeg",
  "width": 960,
  "height": 1280
}

const italie1 =
{
  "thumbnail":"/images/ITA1_small.jpeg",
  "large":"/images/ITA1_large.jpeg",
  "width": 854,
  "height": 1280
}

const searchResponses = {
  "asie":[
    bali1,
    bali2,
    bali3,
    thailande1,
    thailande2,
    thailande3,
    thailande4,
    thailande5
  ],
  "bali":[
    bali1,
    bali2,
    bali3
  ],
  "thailande":[
    thailande1,
    thailande2,
    thailande3,
    thailande4,
    thailande5
  ],
  "londres":[
    londres1,
    londres2,
    londres3
  ],
  "europe":[
    londres1,
    londres2,
    londres3,
    danemark1,
    danemark2,
    danemark3,
    danemark4,
    italie1,
    rennes1,
    rennes2
  ],
  "danemark":[
    danemark1,
    danemark2,
    danemark3
  ],
  "rennes" : [
    rennes1,
    rennes2
  ],
  "italie":[
    italie1
  ],
  "monde": [
    bali1,
    bali2,
    bali3,
    thailande1,
    thailande2,
    thailande3,
    thailande4,
    thailande5,
    londres1,
    londres2,
    londres3,
    danemark1,
    danemark2,
    danemark3,
    danemark4,
    italie1,
    rennes1,
    rennes2
  ]
}

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
};

console.log(`Server listening on port ${port}`);
