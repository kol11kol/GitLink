local creatormodule = {}
local data = {
	['name'] = "",
	['url'] = "",
	['key'] = "",
	['autoLogin'] = true
}
function creatormodule.getData(main)
	data.name = main.creatorPage.name.Text
	data.url = main.creatorPage.url.Text
	main.creatorPage.key.InputEnded:Connect(function(txt)
		data.key = txt
		main.creatorPage.key.Text = "********************"
		task.wait(1)
		data.key = ""
	end)
end
function creatormodule.autoLoginButton(button)
	if data.autoLogin == false then
		data.autoLogin = true
		button.Text = "No"
	elseif data.autoLogin == true then
		data.autoLogin = false
		button.Text = "Yes"
	end
end
function creatormodule.requestData(dataRequest)
	return data[dataRequest]
end
return creatormodule