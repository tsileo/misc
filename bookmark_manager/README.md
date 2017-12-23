# Bookmark Manager

Bookmark manager that runs within [BlobStash](https://github.com/tsileo/blobstash).

It's composed of two parts:

 - A POST hook for BlobStash's JSON document store that calls a Node.js script that calls Chrome Headless API (using [Puppeteer](https://github.com/GoogleChrome/puppeteer)).
 - A BlobStash app that serves the bookmark list and the bookmark form.
