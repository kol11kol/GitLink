local pMod = {}
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
	local pages = script.Parent.Parent.pages:GetChildren()
	table.clear(pMod.currentPages)
	for _, page in pairs(pages) do
		local clone = page:Clone()
		clone.Parent = script.Parent.Parent.clonedPages
		table.insert(pMod.currentPages, clone)
		print(#script.Parent.Parent.clonedPages:GetChildren())
	end
end
return pMod