# Bookmark Manager

Bookmark manager that runs within [BlobStash](https://github.com/tsileo/blobstash).

It's composed of two parts:

 - A POST hook for BlobStash's JSON document store that calls a Node.js script that calls Chrome Headless API (using [Puppeteer](https://github.com/GoogleChrome/puppeteer)).
 - A BlobStash app (powered by [Gluapp](https://github.com/tsileo/gluapp)) that serves the bookmark list and the bookmark form

## Features

 - Bookmarks are saved in BlobStash's document store
 - Tagging support
 - Text search on the title/description field
 - Keep a PDF and PNG screenshot of every bookmarked website in case the page no longer exist

## Bookmarklet

[drag and drop, and edit the location](javascript:if(document.getSelection\){s=document.getSelection(\);}else{s='';};document.location='http://localhost:8050/api/apps/bkapp/add?url='+encodeURIComponent(location.href\)+'&description='+encodeURIComponent(s\)+'&title='+encodeURIComponent(document.title\))
