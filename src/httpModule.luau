local httpModule = {}
httpModule.__index = httpModule
local http = game:GetService("HttpService")
export type encoding = (data : string) -> string
function httpModule.EncodeBase64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'             
	return ((data:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then 
			return ''               															
		end																		-- https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
		local c = 0																				
		for i = 1, 6 do 
			c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) 
		end
		return b:sub(c + 1, c + 1)
	end) .. ({ '', '==', '=' })[#data%3+1])
end
function httpModule.DecodeBase64(data) : encoding
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then 
			return '' 
		end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then 
			return ''
		end
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
		end
		return string.char(c)
	end))
end
export type put = (self : {
	Url: string, 
	username : string, 
	token : string,
	fileContent : string,
	Message : string,
	Branch : string,
	SHA : string,
	path : string
}) -> {Success : boolean, StatusCode : number, StatusMessage : string, Headers : string, Body : string}
function httpModule.PUT(self) : put
	return http:RequestAsync({
		Url = self.Url .. self.path,
		Headers = {
			["accept"] = "application/vnd.github+json",
			["Authorization"] = "Basic " .. httpModule.EncodeBase64(self.username .. ":" .. self.token)
		},
		Method = "PUT",
		Body = http:JSONEncode({
			content = httpModule.EncodeBase64(self.fileContent),
			message = self.Message,
			branch = self.Branch,
			sha = self.SHA
		})	
	})
end
export type get = (self : {
	Url : string, 
	username : string, 
	token : string,
	path : string,
}) -> {Success : boolean, StatusCode : number, StatusMessage : string, Headers : string, Body : string}
function httpModule.GET(self) : get
	return http:RequestAsync({
		Method = "GET",
		Url = self.Url .. self.path, -- .. "/contents"  ..  self.path    .. "?ref=" .. self.Branch
		Headers = {
			["accept"] = "application/vnd.github+json",
			["Authorization"] = "Basic " .. httpModule.EncodeBase64(self.username .. ":" .. self.token)
		},
	})
end
export type delete = (self : {
	Url : string, 
	username : string, 
	token : string,
	Message : string,
	Branch : string,
	SHA : string,
	path : string
}) -> {Success : boolean, StatusCode : number, StatusMessage : string, Headers : string, Body : string}
function httpModule.DELETE(self) : delete
	return http:RequestAsync({
		Method = "DELETE",
		Url = self.Url .. self.path,
		Headers = {
			["accept"] = "application/vnd.github+json",
			["Authorization"] = "Basic " .. httpModule.EncodeBase64(self.username .. ":" .. self.token)
		},
		Body = http:JSONEncode({
			message = self.message,
			sha = self.SHA
		})
	})
end
return httpModule