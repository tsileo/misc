local tknzr = require2('github.com/tsileo/blobstash_docstore_textsearch/tokenizer')
local qry = require2('github.com/tsileo/blobstash_docstore_textsearch/query')

local tpl = require('template')
local docstore = require('docstore')
local router = require('router').new()

function join (docs, pointers)
  local data = {}
  for _, doc in ipairs(docs) do
     -- TODO(tsileo): remove this check once the col is prod
     if doc.meta ~= nil and doc.meta.pdf ~= nil then
       doc.screenshot_url = pointers[doc.meta.screenshot].url
       doc.pdf_url = pointers[doc.meta.pdf].url
       table.insert(data, doc)
     end
  end
  return data
end

router:get('/', function(params)
  local bookmarks = docstore.col('bk')
  local docs, pointers, cursor = bookmarks:query()
  local out = tpl.render('index.html', { docs = join(docs, pointers) })
  app.response:write(out)
end)

router:post('/', function(params)
  local qs = app.request:form():get('q')
  local bookmarks = docstore.col('bk')
  matchFunc = nil
  if qs ~= '' then
    if string.sub(qs, 1, 1) == '#' then
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
  local out = tpl.render('index.html', { q = qs, docs = join(docs, pointers) })
  app.response:write(out)
end)

router:get('/add', function(params)
  local args = app.request:args()
  local out = tpl.render('add.html', {
    url = args:get('url'),
    title = args:get('title'),
    description = args:get('description'),
  })
  app.response:write(out)
end)

router:post('/add', function(params)
  local form_data = app.request:form()
  local bookmarks = docstore.col('bk')
  bookmarks:insert{
    url = form_data:get('url'),
    title = form_data:get('title'),
    description = form_data:get('description'),
    tags = form_data:get('tags'):split(' '),
  }
  app.response:redirect(form_data:get('url'))
end)

router:run()
