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
	user : string
}, {} :: {
	model : (remoteRepository, allFiles : {[number] : string}) -> {[string] : any?}
}))
function remoteRepository.remoteRepository(name, url, token, user) : remoteRepository
	local self = {}
	self.name = name
	self.url = url
	self.branches = {}
	self.files = {}
	self.branchToUse = ""
	self.token = token
	self.user = user
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
	return self
end
function remoteRepository:model(allFiles)
	return {["src"] = allFiles}
end
return remoteRepository