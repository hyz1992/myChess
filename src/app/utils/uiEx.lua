
function addProperty(class, varName, defaultValue)
    local propName = string.upper(string.sub(varName, 1, 1)) .. (#varName > 1 and string.sub(varName, 2, -1) or "")
    class[varName] = defaultValue
    class[string.format("get%s", propName)] = function(self)
        return self[varName] or defaultValue;
    end

    class[string.format("set%s", propName)] = function(self,var)
        self[varName] = var;
        return self
    end
end

function setProxy(t)
    local proxy = {};
    setmetatable(proxy, {
        __index = function(tb, key)
            return t[key];  --访问的时候直接返回代理表中的值
        end,
        __newindex = function(tb, key, value)  --设置值的时候通知监控对象更新
        	local oldData = t[key]
            t[key] = value;
            -- 添加代理
            key = string.format("%sObserver", key)
            if type(t[key]) == "table" then
                for _,v in pairs(t[key]) do
                	-- if v.node and v.node:alive() then
                    	v.callback(value, oldData)
                	-- end
                end
            end
        end
    })
    proxy.getTable = function ( ... )
    	return t
    end
    return proxy;
end

UIEx = {}
local function unBind(node)
	if node and node.bindData then
		for tb, keyTb in pairs(node.bindData) do
			for _, key in pairs(keyTb) do
				-- tb[key]
				local callbackTb = tb[key]
				for i=#callbackTb, 1, -1 do
					if callbackTb[i].node == node then
						printInfo("移除了监控%s", key)
						table.remove(callbackTb, i)
					end					
				end
			end
		end
	end
end

function UIEx.bind(node, tb, key, callback)
	key = string.format("%sObserver", key)

	if not tb[key] then
		tb[key] = {}  -- 初始化
		table.insert(tb[key], {
			node = node,
			callback = callback,
		})
	else
		local flag = false
		for i=#tb[key], 1, -1 do
			local record = tb[key][i]
			if record.node == node then
				record.callback = callback
				flag = true
				break
			end
		end
		if not flag then
			table.insert(tb[key], {
				node = node, 
				callback = callback,
			})
		end
	end
	if not node.bindData then
		node.bindData = {}
		node.__originDtor = node.dtor
		node.dtor = function(node, ...)
			unBind(node)
			node.__originDtor(node, ...)
		end
	end
	if not node.bindData[tb] then
		node.bindData[tb] = {}
	end
	node.bindData[tb][key] = key
end