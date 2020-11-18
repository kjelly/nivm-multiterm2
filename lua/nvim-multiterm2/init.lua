count=0
jobToName = {}
nameToJob = {}
FileNameToJob = {}
lastTerminalJobID = nil
lastCommand = ""

function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function isShell(path)
  local arr = {'bash', 'fish', 'zsh', 'csh'}
  for i=1,4 do
    if string.find(path, arr[i]) then
      return true
    end
  end
  return false
end

function updateLastTerminalID ()
  local jobID = tonumber(vim.api.nvim_eval('expand(b:terminal_job_id)'))
  lastTerminalJobID = jobID
end

function renameTerminal(old, new)
  if string.find(old, '#') then
    local t = split(old, '#')
    t[#t] = ' ' .. new
    local finalName = table.concat(t, '\\#')
    vim.api.nvim_command(string.format('keepalt file %s', finalName))
  else
    local finalName = old .. '\\#' .. new
    vim.api.nvim_command(string.format('keepalt file %s', finalName))
  end
end

function onTermOpen()
  local fileName = vim.api.nvim_eval("expand('%:p')")
  if isShell(fileName) then
    count = count + 1
    local jobID = tonumber(vim.api.nvim_eval('expand(b:terminal_job_id)'))
    lastTerminalJobID = jobID
    jobToName[jobID] = tostring(count)
    nameToJob[tostring(count)] = jobID
    renameTerminal(fileName, tostring(count))
  end
end

function multiTermRun(command, terminalList)
  lastCommand = command
  if terminalList == nil then
    vim.fn.chansend(lastTerminalJobID, {command, '\n'})
  elseif terminalList == 'all' then
      for key, value in pairs(jobToName) do
        vim.fn.chansend(tonumber(key), {command, '\n'})
      end
  else
    for key, name in pairs(split(terminalList, ',')) do
      local jobID =tonumber(nameToJob[tostring(name)])
      if jobID ~= nil then
        vim.fn.chansend(jobID, {command, '\n'})
      end
    end
  end
end

function multiTermRunCurrentLine(terminalList)
  local command = vim.fn.getline('.')
  multiTermRun(command, terminalList)
end

function multiTermRunCurrentSelectedLines(terminalList)
  local command = vim.api.nvim_command('normal! y')
  multiTermRunRegister('@"', terminalList)
end

function multiTermRunRegister(register,  terminalList)
  if register == nil then
    register='@"'
  end
  local command = vim.api.nvim_eval(register)
  multiTermRun(command, terminalList)
end

function multiTermName(name)
  local jobID = tonumber(vim.api.nvim_eval('expand(b:terminal_job_id)'))
  local fileName = vim.api.nvim_eval("expand('%:p')")
  nameToJob[jobToName[jobID]] = nil
  jobToName[jobID] = tostring(name)
  nameToJob[tostring(name)] = jobID
  renameTerminal(fileName, name)
end

function multiTermList(name)
  for key, value in pairs(nameToJob) do
    print(key .. ':' .. value)
  end
end
