-- Fix CASTOR dataset tables: column widths + breakable filenames (PDF/LaTeX).

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function cell_text(cell)
  return trim(pandoc.utils.stringify(cell.contents))
end

local function is_file_table(tbl)
  if #tbl.head.rows == 0 then
    return false
  end
  local header = tbl.head.rows[1].cells
  if #header == 0 then
    return false
  end
  local first = cell_text(header[1])
  return first == "File"
end

local function widths_for(ncols)
  if ncols == 2 then
    return { 0.40, 0.60 }
  elseif ncols == 3 then
    return { 0.50, 0.25, 0.25 }
  elseif ncols == 4 then
    return { 0.26, 0.28, 0.26, 0.20 }
  end
  return nil
end

local function looks_like_filename(text)
  return text:match("%.csv$") ~= nil or text:match("^data/") ~= nil
end

local function latex_escape_path(s)
  -- \path{} is verbatim-like; escape only characters that break the argument
  return s:gsub("%%", "\\%%"):gsub("#", "\\#")
end

local function breakable_filename(text)
  return text
    :gsub("_", "\\_\\allowbreak{}")
    :gsub("%.csv", "\\allowbreak{}.csv")
end

local function file_cell_to_path(cell)
  local text = cell_text(cell):gsub("`", "")
  if text == "" or not looks_like_filename(text) then
    return cell
  end
  local latex
  if #text > 18 then
    local broken = breakable_filename(text)
    latex = "\\begin{minipage}[t]{\\linewidth}\\ttfamily\\RaggedRight\\sloppy " .. broken .. "\\end{minipage}"
  else
    latex = "\\path{" .. latex_escape_path(text) .. "}"
  end
  cell.contents = { pandoc.RawInline("latex", latex) }
  return cell
end

local function set_colwidths(tbl, widths)
  for i, w in ipairs(widths) do
    local align = tbl.colspecs[i][1]
    tbl.colspecs[i] = { align, w }
  end
  return tbl
end

local function patch_file_cells(tbl)
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.body) do
      if row.cells[1] then
        row.cells[1] = file_cell_to_path(row.cells[1])
      end
    end
  end
  return tbl
end

function Table(tbl)
  if not is_file_table(tbl) then
    return tbl
  end

  local ncols = #tbl.colspecs
  local widths = widths_for(ncols)
  if widths == nil then
    return tbl
  end

  tbl = set_colwidths(tbl, widths)
  tbl = patch_file_cells(tbl)
  return tbl
end
