local dataModule = {}
function dataModule.getData(p, KEY) : (p : Plugin, KEY : string) -> any
	return p:GetSetting(KEY)
end
function dataModule.newData(p, NAME, VALUE) : (p : Plugin, NAME : string, Value : any) -> any
	p:SetSetting(NAME, VALUE)
end
export type encoding = (data : string) -> string;
function EncodeBase64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';             
	return ((data:gsub('.', function(x)
		local r, b = '', x:byte();
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0');
		end;
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then 
			return '';               															
		end;																-- https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
		local c = 0;																		
		for i = 1, 6 do 
			c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) ;
		end;
		return b:sub(c + 1, c + 1);
	end) .. ({ '', '==', '=' })[#data%3+1]);
end;
function DecodeBase64(data) : encoding
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	data = string.gsub(data, '[^'..b..'=]', '');
	return (data:gsub('.', function(x)
		if (x == '=') then 
			return '';
		end;
		local r, f = '', (b:find(x) - 1);
		for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0');
		end;
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then 
			return '';
		end;
		local c = 0;
		for i = 1, 8 do
			c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0);
		end;
		return string.char(c);
	end));
end;
function encryptString(s : string) : (string) -> string
	local key : string | number = ""
	if script.Parent.Configuration.CUSTOM_DATA_KEY_ENABLED.Value == true then
		if typeof(script.Parent.Parent.Configuration.CUSTOM_DATA_KEY.Value) == "number" then
			key = script.Parent.Parent.Configuration.CUSTOM_DATA_KEY.Value;    --						You can use your own data key.
		end;                                                                
	else
		key = game:GetService("StudioService"):GetUserId();
	end;
	local function encryption(str : string) : (string) -> string
		if key then
			str = EncodeBase64(str:reverse());
			local bytes : {number} = {str:byte(1, #str)};
			local encrypted : {number} = {};
			for _, b : number in bytes do
				table.insert(encrypted, b * key);
			end;
			return EncodeBase64(table.concat(encrypted, " ")) :: string;
		end;
	end;
	for i : number = 0, 0, 8 do
		s = encryption(s);
	end;
	if s then return s :: string end;
end
function decryptString(s : string) : (string) -> string
	local key : string | number = "";
	if script.Parent.Configuration.CUSTOM_DATA_KEY_ENABLED.Value == true then
		if typeof(script.Parent.Parent.Configuration.CUSTOM_DATA_KEY.Value) == "number" then
			key = script.Parent.Parent.Configuration.CUSTOM_DATA_KEY.Value;    --						You can use your own data key.
		end;                                                                
	else
		key = game:GetService("StudioService"):GetUserId();
	end;
	local function decryption(str : string) : (string) -> string
		str = DecodeBase64(str);
		local c : string = "";
		for b : string in str:gmatch("[^%s]+") do
			c..= string.char(tonumber(b) / key);
		end
		return DecodeBase64(c):reverse() :: string;
	end;
	for i : number = 0, 0, 8 do
		s = decryption(s);
	end;
	if s then return s :: string end;
end
export type repoData = (url : string, key : string, user : sting, p : Plugin, folders : boolean) -> {code : string, name : string}
function dataModule.createRepoData(url, key, user, p, folders) : repoData
	local function repoName()
		for i, str in pairs(string.split(url, "/")) do
			if str == user then
				return string.split(url, "/")[i + 1]
			end
		end
	end	
	local repository = {
		["NAME"] = repoName(),
		["USER"] = encryptString(user),
		["URL"] = encryptString("https://api.github.com/repos/"..user.."/"..repoName()),
		["KEY"] = encryptString(key),
		["FOLDERS"] = folders
	} :: {["NAME"] : string, ["USER"] : string, ["URL"] : string, ["KEY"] : string, ["FOLDERS"] : boolean}
	local repositories = {}
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	if not (dataModule.getData(p, "REPOSITORIES") == nil) then
		repositories = dataModule.getData(p, "REPOSITORIES")
	end
	local code : string
	if not (repositories == nil) then
		if len(repositories) > 0 then
			if repositories[repository.NAME] then
				code = "fail"
				warn("Repository was created! ".."Edit "..repository.NAME.." to change settings!")
			elseif not repositories[repository.NAME] then
				code = "success"
				repositories[tostring(repository.NAME)] = repository
				dataModule.newData(p, "REPOSITORIES", repositories)
			end
		elseif len(repositories) == 0 then
			code = "success"
			print("Creating first repository!")
			repositories[tostring(repository.NAME)] = repository
			dataModule.newData(p, "REPOSITORIES", repositories)
		end
	end	
	return {code = code, name = repository.NAME}
end
function dataModule.updateRepoData(url, key, user, p, folders) : repoData
	local function repoName()
		for i, str in pairs(string.split(url, "/")) do
			if str == user then
				return string.split(url, "/")[i + 1]
			end
		end
	end	
	local repository = {
		["NAME"] = repoName(),
		["USER"] = encryptString(user),
		["URL"] = encryptString("https://api.github.com/repos/"..user.."/"..repoName()),
		["KEY"] = encryptString(key),
		["FOLDERS"] = folders
	} :: {["NAME"] : string, ["USER"] : string, ["URL"] : string, ["KEY"] : string, ["FOLDERS"] : boolean}
	local repositories = {}
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	if not (dataModule.getData(p, "REPOSITORIES") == nil) then
		repositories = dataModule.getData(p, "REPOSITORIES")
	end
	local code : string
	if not (repositories == nil) then
		code = "success"
		repositories[tostring(repository.NAME)] = repository
		dataModule.newData(p, "REPOSITORIES", repositories)
	end	
	return {code = code, name = repository.NAME}
end
export type addDefaultRepository = (p : Plugin, repositoryName : string) -> any
function dataModule.addDefaultRepository(p, repositoryName)
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	local repositories = {}
	if not (dataModule.getData(p, "DEFAULTREPOSITORIES") == nil) then
		repositories = dataModule.getData(p, "DEFAULTREPOSITORIES")
	end
	local repository = {
		name = repositoryName,
		place = game.PlaceId
	} :: {["name"] : string, ["place"] : number}
	if not (repositories == nil) then
		if len(repositories) > 0 then
			if repositories[repository.name] then
				warn("Repository is already set to defualt! ".."Edit "..repository.name.." to change it!")
			elseif not repositories[repository.name] then
				repositories[tostring(repository.name)] = repository
				dataModule.newData(p, "DEFAULTREPOSITORIES", repositories)
			end
		elseif len(repositories) == 0 then
			repositories[tostring(repository.name)] = repository
			dataModule.newData(p, "DEFAULTREPOSITORIES", repositories)
		end
	end
end
export type removeRepository = (p : Plugin, repositoryName : string) -> any
function dataModule.removeDefaultRepository(p, repositoryName) : removeRepository
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	local repositories = {}
	if dataModule.getData(p, "DEFAULTREPOSITORIES") then
		if len(dataModule.getData(p, "DEFAULTREPOSITORIES")) > 0 then
			repositories = dataModule.getData(p, "DEFAULTREPOSITORIES")
			if len(repositories[repositoryName]) > 0 then
				for name, data in pairs(repositories) do
					if name == repositoryName then
						repositories[repositoryName] = nil
					end
				end
				dataModule.newData(p, "DEFAULTREPOSITORIES", repositories)
			end
		end
	end
end
function dataModule.removeRepositoryData(p, repositoryName) : removeRepository
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	local repositories = {}
	if dataModule.getData(p, "REPOSITORIES") then
		if len(dataModule.getData(p, "REPOSITORIES")) > 0 then
			repositories = dataModule.getData(p, "REPOSITORIES")
			if len(repositories[repositoryName]) > 0 then
				for name, data in pairs(repositories) do
					if name == repositoryName then
						repositories[repositoryName] = nil
					end
				end
				dataModule.newData(p, "REPOSITORIES", repositories)
			end
		end
	end
end
return dataModule