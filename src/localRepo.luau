local LocalRepository = {}

LocalRepository.__index = LocalRepository

function LocalRepository.new()
	local self = {}
	self.scriptDocuments = {}
	setmetatable(self, LocalRepository)
	setmetatable(self.scriptDocuments, {
		__index = function(tab, i)
			for _, file in pairs(self.scriptDocuments) do
				if file.Name == i then
					return file
				end
			end
		end,
	})
	return self
end


function LocalRepository:getAllAviableScriptDocuments(name)
	for _, object in ipairs(game:GetDescendants()) do
		if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
			if not object:IsA("CoreScript") then
				if object:GetAttribute("path") and string.find(object:GetAttribute("path"), name, 1, false) then
					if not table.find(self.scriptDocuments, object, 1) then
						table.insert(self.scriptDocuments, object)
					end
				end
			end	
		end
	end
end


function LocalRepository:setAttribute(file, path, repositoryName)
	if not file:GetAttribute("path") then
		file:SetAttribute("path", path .. repositoryName)
	end	
end


return LocalRepository