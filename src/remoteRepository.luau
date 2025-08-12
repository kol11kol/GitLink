local remoteRepository = {}

remoteRepository.__index = remoteRepository

export type remoteRepository = typeof(setmetatable({}, remoteRepository)) & {
	name : string,
	url : string,
	branches : {[number] : string},
	files : {[number] : {
		mode : number,
		path : string,
		sha : string,
		size : number,
		type : string,
		url :string,
	}},
	branchToUse : string,
	token : string,
	user : string,
	includeFolders : boolean,
	folders : {},
	STRUCTURE : string
}

function remoteRepository.remoteRepository(name : string, url : string, token : string, user : string, folders : boolean) : (name : string, url : string, token : string, user : string, folders : boolean) -> remoteRepository
	local self = {}
	self.name = name
	self.url = url
	self.branches = {}
	self.files = {}
	self.branchToUse = ""
	self.token = token
	self.user = user
	self.includeFolders = folders
	self.folders = {}
	self.STRUCTURE = nil
	setmetatable(self, remoteRepository)
	setmetatable(self.files, {
		__index = function(tab, i)
			for _, file in pairs(self.files) do
				if file.Name == i then
					return file
				end
			end
		end,
	})
	return self :: remoteRepository
end


local httpService = game:GetService("HttpService")


function remoteRepository:setUpFolders(localScriptDocuments)
	local Folders : {[string] : string} = {}
	local Folders_Structure = {}
	local Folders_StructureRAW = {}
	local function CreateRemoteFolders()
		local function BuildPath(file : ScriptDocument)
			local Path : string = "src"
			for _, instance : any? in file:GetFullName():split(".") do
				if game:FindFirstChild(instance, false) then
					continue
				end
				if game:FindFirstChild(instance, true):IsA("LuaSourceContainer") or game:FindFirstChild(instance, true):IsA("Folder") then
					if not Path:find(instance) and instance ~= file.Name then
						Path..= "/" .. instance
					end
				end
			end
			if Path then return Path .. "/" .. file.Name .. ".luau" end
		end
		for _, folder : string in pairs(Folders) do
			local children : {[number] : Instance} = game:FindFirstChild(folder, true):GetChildren()
			if #children > 0 then
				local FolderContent : {[number] : string} = {}
				for _, child in children do
					if child:IsA("LuaSourceContainer") then
						local path = BuildPath(child)
						if not table.find(FolderContent, path, 1) then
							table.insert(FolderContent, path)
						end
					end	
				end
				if #FolderContent ~= 0 then
					if not Folders_Structure[folder] then
						Folders_Structure[folder] = FolderContent
					end
					if not table.find(Folders_StructureRAW, FolderContent) then
						table.insert(Folders_StructureRAW, FolderContent)
					end
				end	
			else
				continue
			end
		end
		--[[
		
						TODO: Add type checking to this part of code.
		
		]]
		return {Structure = Folders_Structure, RAW = Folders_StructureRAW}
	end
	for _, file : LuaSourceContainer in localScriptDocuments do
		for _, instance : any? in file:GetFullName():split(".") do
			if game:FindFirstChild(instance, false) or file.Name == instance then
				continue
			end
			if game:FindFirstChild(instance, true):IsA("Folder") or game:FindFirstChild(instance, true):IsA("LuaSourceContainer") then
				if not table.find(Folders, instance) then
					table.insert(Folders, instance)
				end
			end
		end
	end
	local STRUCTURE_ToEncode = if self.STRUCTURE then httpService:JSONDecode(self.STRUCTURE) else {}
	local RemoteFolders = CreateRemoteFolders()
	STRUCTURE_ToEncode["Folders"] = RemoteFolders.Structure
	STRUCTURE_ToEncode["RAW"] = RemoteFolders.RAW
	self.STRUCTURE = httpService:JSONEncode(STRUCTURE_ToEncode)
	return self.STRUCTURE
end


function remoteRepository:filesStructure(localScriptDocuments)
	local localFiles = {} :: {[string] : string}
	local remoteFiles = {} :: {[string] : string}
	for _, file : LuaSourceContainer in localScriptDocuments do
		if not table.find(localFiles, file:GetFullName(), 1) then
			table.insert(localFiles, file:GetFullName())
		end
	end
	for _, file : {} in pairs(self.files) do
		if not table.find(remoteFiles, file.path, 1) then
			table.insert(remoteFiles, file.path)
		end
	end
	local STRUCTURE_ToEncode = if self.STRUCTURE then httpService:JSONDecode(self.STRUCTURE) else {}
	STRUCTURE_ToEncode["LocalFiles"] = localFiles
	STRUCTURE_ToEncode["RemoteFiles"] = remoteFiles
	self.STRUCTURE = httpService:JSONEncode(STRUCTURE_ToEncode)
	return self.STRUCTURE
end


return remoteRepository