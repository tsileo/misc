# Screenshot API for Broxy

[Gluapp](https://github.com/tsileo/gluapp) powered screenshot capture API powered by Chrome Headless.

Returns a 1280px wide full-page screenshot in PNG format.

Rely on the screenshot script (in the same repo).

Support an optional API key for authentication (passed via query argument).

## API

There's only one endpoint: `/?url=http://example.com&api_key=optional_api_key` that 
returns the screenshot with the `image/png` content type.
