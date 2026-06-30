-- Rewrite internal file links to GitHub blob URLs when building the PDF.
-- Readers who only have the PDF can open chapters, appendices, data, and R scripts online.

local BASE = "https://github.com/kimonntotsis/Breathing-Room-for-Statistics/blob/main"

local function is_external(url)
  return url:match("^https?://") or url:match("^mailto:")
end

local function normalize_repo_path(target)
  local path, fragment = target:match("^([^#]+)#?(.*)$")
  if not path or path == "" then
    return nil, fragment
  end

  path = path:gsub("^%.%./", "")

  while path:match("^%.%.%/") do
    path = path:gsub("^%.%.%/", "")
  end

  if path:match("^references%.bib$") then
    return path, fragment
  end

  if path:match("^data/") or path:match("^R/") then
    return path, fragment
  end

  if not path:match("^volume%-01/") then
    path = "volume-01/" .. path
  end

  return path, fragment
end

function Link(el)
  local target = el.target

  if is_external(target) or target:match("^#") then
    return el
  end

  if target:match("%.md$")
      or target:match("%.qmd$")
      or target:match("%.R$")
      or target:match("%.csv$")
      or target:match("%.bib$") then
    local path, fragment = normalize_repo_path(target)
    if path then
      if fragment and fragment ~= "" then
        el.target = BASE .. "/" .. path .. "#" .. fragment
      else
        el.target = BASE .. "/" .. path
      end
    end
  end

  return el
end
