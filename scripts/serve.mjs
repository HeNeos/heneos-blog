import { createServer } from "node:http";
import fs from "node:fs";
import path from "node:path";

const outputDirectory = path.resolve("out");
const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".mp4": "video/mp4",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ttf": "font/ttf",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
};

function outputPath(requestUrl) {
  const pathname = decodeURIComponent(new URL(requestUrl, "http://localhost").pathname);
  const sitePath = pathname === "/" ? "/heneos-blog/" : pathname;
  const relativePath = sitePath.replace(/^\/heneos-blog\/?/, "");
  const filePath = path.resolve(outputDirectory, relativePath);

  if (filePath !== outputDirectory && !filePath.startsWith(`${outputDirectory}${path.sep}`)) {
    return undefined;
  }

  return filePath;
}

createServer((request, response) => {
  const requestedPath = outputPath(request.url || "/");
  if (!requestedPath) {
    response.writeHead(403).end("Forbidden");
    return;
  }

  let filePath = requestedPath;
  const htmlFilePath = `${requestedPath}.html`;
  if (path.extname(requestedPath) === "" && fs.existsSync(htmlFilePath)) {
    filePath = htmlFilePath;
  } else if (
    fs.existsSync(filePath) &&
    fs.statSync(filePath).isDirectory()
  ) {
    filePath = path.join(filePath, "index.html");
  } else if (!fs.existsSync(filePath) && path.extname(filePath) === "") {
    filePath = htmlFilePath;
  }

  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    const notFoundPage = path.join(outputDirectory, "404.html");
    response.writeHead(404, { "content-type": "text/html; charset=utf-8" });
    fs.createReadStream(notFoundPage).pipe(response);
    return;
  }

  const contentType = contentTypes[path.extname(filePath)] || "application/octet-stream";
  response.writeHead(200, { "content-type": contentType });
  fs.createReadStream(filePath).pipe(response);
}).listen(Number(process.env.PORT || 3000), "0.0.0.0", () => {
  console.log(`Serving out/ on port ${process.env.PORT || 3000}`);
});
