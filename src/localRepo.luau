local localRepo = {}
localRepo.__index = localRepo
function localRepo.newLocalRepo()
	local self = {}
	self.scriptDocuments = {}
	setmetatable(self, localRepo)
	return self
end
function localRepo:getAviableScriptDocuments()
	for _, object in pairs(game:GetDescendants()) do
		if object:IsA("Script") then
			if string.find(object.Source, "--/git", 0) then
				table.insert(self.scriptDocuments, {document = object, path = object:GetFullName()})
				print(object)
			end
		end
	end
end
function localRepo:matchStrings()
	
end
return localRepo