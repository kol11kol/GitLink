local pMod = {}
function pMod.loadingAnimation(main, mT)
	local t = 0
	repeat
		t = t + 1
		main.Title = "Gitlink Thinking."
		task.wait(0.5)
		main.Title = "Gitlink Thinking.."
		task.wait(0.5)
		main.Title = "Gitlink Thinking..."
	until t == mT
	if t == mT then
		main.Title = "Gitlink"
	end
end
function pMod.changePage(targetPage: string, main)
	local page = pMod.currentPages[targetPage]
	if page then
		page.Parent = main
		for _, otherPage in pairs(main:GetChildren()) do
			if otherPage ~= page then
				otherPage.Parent = script.Parent.Parent.clonedPages
			end	
		end
	end
	return page
end
pMod.currentPages = {}
setmetatable(pMod.currentPages, {
	__index = function(self, index)
		for _, p in pairs(self) do
			if index == p.Name then
				return p
			end
		end
	end,
})
function pMod.clonePages()
	if #script.Parent.Parent.clonedPages:GetChildren() > 0 then
		for _, page in pairs(script.Parent.Parent.clonedPages:GetChildren()) do
			page.Parent = nil
		end
	end
	local pages = script.Parent.Parent.pages:GetChildren()
	table.clear(pMod.currentPages)
	for _, page in pairs(pages) do
		local clone = page:Clone()
		clone.Parent = script.Parent.Parent.clonedPages
		table.insert(pMod.currentPages, clone)
	end
end
return pMod