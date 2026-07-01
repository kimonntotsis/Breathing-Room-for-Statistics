-- Widen the label column in comparison and technique-card tables (PDF/LaTeX).

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function cell_text(cell)
  return trim(pandoc.utils.stringify(cell.contents))
end

local function is_empty_cell(cell)
  return cell_text(cell) == ""
end

function Table(tbl)
  local ncols = #tbl.colspecs
  if ncols == 0 or #tbl.head.rows == 0 then
    return tbl
  end

  local header = tbl.head.rows[1].cells
  if #header ~= ncols then
    return tbl
  end

  local widths = nil

  if ncols == 3 and is_empty_cell(header[1]) then
    -- Row-label comparison tables (e.g. Inference vs prediction)
    widths = { 0.28, 0.36, 0.36 }
  elseif ncols == 2 and is_empty_cell(header[1]) and is_empty_cell(header[2]) then
    -- Technique cards: | | | header then **Label** | value rows
    widths = { 0.26, 0.74 }
  end

  if widths == nil then
    return tbl
  end

  local simple = pandoc.utils.to_simple_table(tbl)
  simple.widths = widths
  return pandoc.utils.from_simple_table(simple)
end
