#!/usr/bin/env node

const puppeteer = require('puppeteer');
const url = process.argv[2];
const o = process.argv[3];

if (o == undefined || url == undefined) {
    console.log('sc <url> <output file>');
    process.exit(2);
}

async function run() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  page.setViewport({width: 1280, height: 800});

  await page.goto(url);
  await page.screenshot({ path: o, fullPage: true });

  browser.close();
}

run();
