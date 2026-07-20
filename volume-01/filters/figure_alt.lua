-- Propagate figure captions to fig-alt for PDF/UA screen readers when alt is missing.

local function caption_text(caption)
  if not caption then
    return nil
  end
  if type(caption) == "string" then
    return caption
  end
  if caption.long and #caption.long > 0 then
    return pandoc.utils.stringify(caption.long)
  end
  if caption.short and #caption.short > 0 then
    return pandoc.utils.stringify(caption.short)
  end
  return nil
end

local function ensure_alt(el, caption)
  if el.attributes["fig-alt"] and el.attributes["fig-alt"] ~= "" then
    return
  end
  local text = caption_text(caption)
  if text and text ~= "" then
    el.attributes["fig-alt"] = text
  elseif el.attributes["alt"] and el.attributes["alt"] ~= "" then
    el.attributes["fig-alt"] = el.attributes["alt"]
  end
end

function Image(el)
  ensure_alt(el, el.caption)
  return el
end

function Figure(el)
  ensure_alt(el, el.caption)
  return el
end
