--把一个无环table写入一个字符串
function getTableStr(_t,_indent,_tabDescribe)  
    _indent = _indent or 1
    local szPrefix = string.rep("    ", _indent-1)
    local szRet = _tabDescribe or ""
    szRet = szRet.."\n"..szPrefix.."{\n"  
    function doT2S(_i, _v) 
        local szPrefix = string.rep("    ", _indent)
        if "number" == type(_i) then  
            szRet = szRet .. szPrefix.."[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ",\n"  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ",\n"  
            elseif "table" == type(_v) then  
                szRet = szRet .. getTableStr(_v,_indent + 1) .. ",\n"  
            elseif "boolean" == type(_v) then
                szRet = szRet .. '"' .. (_v and "true" or "false") .. '"' .. ",\n"  
            else  
                szRet = szRet .. "nil,\n"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. szPrefix..'["' .. _i .. '"] = '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ",\n"  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ",\n"  
            elseif "table" == type(_v) then  
                szRet = szRet .. getTableStr(_v,_indent + 1) .. ",\n"  
            elseif "boolean" == type(_v) then
                szRet = szRet .. '"' .. (_v and "true" or "false") .. '"' .. ",\n"  
            else  
                szRet = szRet .. "nil,\n"  
            end  
        end  
    end  
    table.foreach(_t, doT2S)  
    szRet = szRet .. szPrefix.."}"  
    return szRet  
end

--mod==1追加，mod==2覆盖
function writeTabToLog(_tab,tabDescribe,logPath,mod)
  local logPath = logPath or "tabLog.log"
  logPath = device.writablePath..logPath
  local mod = mod or 1
  local str = ""
  if mod==1 then
    local oldStr = ""
    local file = io.open(logPath, "r")
    if file then
      oldStr = file:read("*a")
      file:close()
    end
    local temp = getTableStr(_tab,1,tabDescribe)
    str = oldStr.."\n\n\n==============================>>>>>>\n\n\n"..temp
  else
    local temp = getTableStr(_tab,1,tabDescribe)
    str = temp
  end
  local file = io.open(logPath, "w")
  file:write(str)
  file:close()
  
end

function printTraceback()
    print("traceback----------------traceback---------------printBegin")
    print(debug.traceback())
    print("traceback----------------traceback---------------printEnd")
end