local async_lib = require "plenary.async_lib"
local async = async_lib.async
local await = async_lib.await
local void = async_lib.void

local make_entry = require "telescope.make_entry"

return function(opts)
  local input_results
  if vim.tbl_islist(opts) then
    input_results = opts
  else
    input_results = opts.results
  end

  local entry_maker = opts.entry_maker or make_entry.gen_from_string()

  local results = {}
  for k, v in ipairs(input_results) do
    local entry = entry_maker(v)

    if entry then
      entry.index = k
      table.insert(results, entry)
    end
  end

  return setmetatable({
    results = results,
    close = function() end,
  }, {
    __call = void(async(function(_, _, process_result, process_complete)
      for i, v in ipairs(results) do
        if process_result(v) then
          break
        end

        if i % 1000 == 0 then
          await(async_lib.scheduler())
        end
      end

      process_complete()
    end)),
  })
end
