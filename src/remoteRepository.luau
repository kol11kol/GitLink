local remoteRepository = {}
remoteRepository.__index = remoteRepository
export type remoteRepository = typeof(setmetatable({} :: {
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
	STRUCTURE : {}
}, {} :: {
	setUpFolders : (remoteRepository) -> any?
}))
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
	self.STRUCTURE = {}
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
function remoteRepository:setUpFolders()
	--structure
end
return remoteRepository