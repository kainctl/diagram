local pandoc = require 'pandoc';
local dbg = require 'debugger'

dbg.auto_where = 5

-- local function format_options(format_name)
--   local is_office_format = format_name == 'docx' or format_name == 'odt'
--   local preferred_mime_types = is_office_format
--     and pandoc.List{'image/png', 'application/pdf'}
--     or pandoc.List{'application/pdf', 'image/png'}
-- -- ... Yeah, no idea what this function is doing and why it is returning so much
-- -- I will just leave it for now.
-- end


local DEFAULT_COMMANDS = {
  d2 = {},
}

local function build_command(name, command_config)
  -- Read the different values
  -- 4. Build up the function that "runs" the command.
  --    This function should take the `ARGS` `KWARGS` and
  local req_keys = {'command', 'generates_file', 'output', 'args'}
  for _, req_key in pairs(req_keys) do
    -- It is important to understand that the yaml value `null`
    -- is converted to an EMPTY string in the Lua context!
    if (command_config[req_key] == nil) then
      warn(PANDOC_SCRIPT_FILE, ': ', name, ' is missing the `', req_key, '` key.')
      return nil
    end
  end

  if command_config['generates_file'] then
    if command_config['args']:find('{OUTPUT_FILE}', 1, true) == nil then
      warn(PANDOC_SCRIPT_FILE, ': ', name, ' has `generates_file=true` but does not use the `{OUTPUT_FILE}` template in `args`: ', command_config['args'])
      return nil
    end
  end

  -- HERE: Return a FUNCTION that gets the input txt/file,
  -- ARGS, and KWARGS.
end

---Read configuration
---@param meta Meta
---@param format_name string
local function configure (meta, format_name)
  local config = meta.exec or {}
  -- local format = format_options(format_name)
  -- TODO: Not quite sure why this is deleted here...
  -- meta.exec = nil

  -- Here would also be the place to configure the cache directory

  -- commands configs should be loaded here as well.
  -- Either the defaults are loaded OR the user provided ones.
  -- Merging is maybe not that good of an idea.
  -- A user can still configure it however they need to by copy-and-paste first.
  local commands = {}
  -- if config.command.type ==
  for name, command_config in pairs(config.commands) do
    commands[name] = build_command(name, command_config)
  end
  -- for name, command_opts in pairs(config.command or DEFAULT_COMMANDS) do
  --   command[name] = get_command(name, command_opts, format)
  -- end
end

---The final pandoc function.
---@param doc Pandoc
function Pandoc(doc)
  local conf = configure(doc.meta, FORMAT)
  return doc:walk {
    -- CodeBlock = exec_code(conf)
  }
end

-- configure(doc.meta , FORMAT)
