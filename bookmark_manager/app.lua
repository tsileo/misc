local tknzr = require2('github.com/tsileo/blobstash_docstore_textsearch/tokenizer')
local qry = require2('github.com/tsileo/blobstash_docstore_textsearch/query')

local tpl = require('template')
local docstore = require('docstore')
local router = require('router').new()

local col_name = 'bk1'

-- Merge the docstore document and pointers together
function join (docs, pointers)
  local data = {}
  for _, doc in ipairs(docs) do
     -- TODO(tsileo): remove this check once the col is prod
     if doc.backup ~= nil then
       doc.screenshot_url = pointers[doc.backup.screenshot].url
       doc.pdf_url = pointers[doc.backup.pdf].url
       table.insert(data, doc)
     end
  end
  return data
end

-- Homepage, display the latest bookmarks
router:get('/', function(params)
  local bookmarks = docstore.col(col_name)
  local docs, pointers, cursor = bookmarks:query()
  local out = tpl.render('index.html', 'layout.html', { docs = join(docs, pointers) })
  app.response:write(out)
end)

-- Search
router:post('/', function(params)
  local qs = app.request:form():get('q')
  local bookmarks = docstore.col(col_name)
  matchFunc = nil
  if qs ~= '' then
    if string.sub(qs, 1, 1) == '#' then
      -- It's a tag search (qs starts with a #)
      local target = string.sub(qs, 2, qs:len())
      function matchFunc (doc)
        if doc.tags == nil then return false end
        for _, tag in ipairs(doc.tags) do
          if tag == target then
              return true
          end
        end
        return false
      end
    else
      -- Text search
      local fields = {'description', 'title'}
      local tokenizer = tknzr:new()
      local terms = tokenizer:parse(qs)
      local q = qry:new(terms, fields)

      function matchFunc (doc)
        q:build_text_index(doc)
        return q:match(doc)
      end
    end
  end
  local docs, pointers, cursor = bookmarks:query(nil, nil, matchFunc)
  local out = tpl.render('index.html', 'layout.html', { q = qs, docs = join(docs, pointers) })
  app.response:write(out)
end)

-- "New bookmark" form
router:get('/add', function(params)
  local args = app.request:args()
  local out = tpl.render('add.html', 'layout.html', {
    url = args:get('url'),
    title = args:get('title'),
    description = args:get('description'),
  })
  app.response:write(out)
end)

-- "New bookmark" form handler
router:post('/add', function(params)
  local form_data = app.request:form()
  local bookmarks = docstore.col(col_name)

  -- Ensure the bookmark is not already saved
  local url = form_data:get('url')
  local docs, pointers, _ = bookmarks:query(nil, nil, function(doc)
    if doc.url == url then
      return true
    end
    return false
  end)

  if #docs > 0 then
      local out = tpl.render('already_bookmarked.html', 'layout.html', { url = url, docs = join(docs, pointers) })
      app.response:write(out)
      return
  end

  -- Build the doc
  local tags = form_data:get('tags'):split(' ')
  local description = form_data:get('description')
  local doc = {
    url = url,
    title = form_data:get('title'),
  }
  if tags then
      doc.tags = tags
  end
  if description then
      doc.description = description
  end
  bookmarks:insert(doc)

  -- Redirect to the bookmarked URL
  app.response:redirect(url)
end)

router:run()
