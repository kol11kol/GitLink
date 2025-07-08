local localRepoModule= {}
localRepoModule.__index = localRepoModule
function localRepoModule.newLocalRepo()
	local self = {}
	self.allScriptDocuments = {}
	self.scriptDocuments = {}
	self.allFiles = {}
	setmetatable(self, localRepoModule)
	setmetatable(self.allFiles, {
		__index = function(tab, i)
			for _, file in pairs(self.allFiles) do
				if file.Name == i then
					return file
				end
			end
		end,
	})
	return self
end
function localRepoModule:getAllAviableScriptDocuments()
	for _, object in ipairs(game:GetDescendants()) do
		if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
			if not object:IsA("CoreScript") then
				if not table.find(self.allScriptDocuments, object, 1) then
					table.insert(self.allScriptDocuments, object.Name)
				end
				if not table.find(self.allFiles, object, 1) then
					table.insert(self.allFiles, object)
				end	
				if object:GetAttribute("path") == true then
					if not table.find(self.scriptDocuments, object, 1) then
						table.insert(self.scriptDocuments, object)
					end
				end
			end	
		end
	end
end
function localRepoModule:addFile(file, reomoteFiles)
	if not table.find(reomoteFiles, file, 1) then
		if not table.find(self.scriptDocuments, file, 1) then
			table.insert(self.scriptDocuments, file)
		end
	end	
end
function localRepoModule:setAttribute(file, path)
	if not file:GetAttribute("path") then
		file:SetAttribute("path", path)
	end	
end
return localRepoModule