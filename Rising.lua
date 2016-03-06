local Addon = CreateFrame("FRAME");
local risingMenu;


-------------------------------------
--
-- Creates a Frame with a FontString inside
-- 
-- @param #String name: frame's name
-- @param #frame parent: parent's frame
-- @param #int posX: horizontal pixels relative to parent
-- @param #int posY: vertical pixels to parent
-- @return #frame fontFrame : frame with the fontString
--
-------------------------------------
local function createFontFrame(name, parent, posX, posY, onClick)
	local fontFrame = CreateFrame("FRAME", "Rising" .. name, parent);
	fontFrame:SetSize(200,50);
	fontFrame:SetPoint("RIGHT", posX, posY);
	
	fontFrame.font = fontFrame:CreateFontString("Rising" .. name .. "Font", "OVERLAY", "GameFontNormal");
	fontFrame.font:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 40, "OUTLINE");
	fontFrame.font:SetTextColor(0.5, 0.5, 0.5, 1);
	fontFrame.font:SetText(name);
	fontFrame.font:SetPoint("RIGHT", 0, 0);
	
	fontFrame:SetScript("OnEnter", function(self) 
		self.font:SetTextColor(1, 1, 1, 1);
	end);
	fontFrame:SetScript("OnLeave", function(self) 
		self.font:SetTextColor(0.5, 0.5, 0.5, 1);
	end);
	fontFrame:SetScript("OnMouseDown", onClick);

	return fontFrame;
end


-------------------------------------
--
-- Creates a smoke effect with the help of PlayerModel
--
-------------------------------------
local function createSmokeEffect()

	if not risingMenu.smokeFX then
    	risingMenu.smokeFX = CreateFrame("FRAME", "RisingSmokeFXFrame", risingMenu);
    	risingMenu.smokeFX.model = CreateFrame("PlayerModel", "RisingSmokeFXFrameModel", risingMenu.smokeFX);
    	
    	risingMenu.smokeFX.model:SetSize(GetScreenWidth(), GetScreenHeight());
        risingMenu.smokeFX.model:SetAllPoints(risingMenu.smokeFX);
    
        risingMenu.smokeFX.model:ClearModel();
    	
    	risingMenu.smokeFX:SetFrameStrata("DIALOG");
    	risingMenu.smokeFX:SetSize(GetScreenWidth(), GetScreenHeight());
    	risingMenu.smokeFX:SetAllPoints(risingMenu);
	end
	risingMenu.smokeFX.model:SetModel("World\\Lordaeron\\stratholme\\passivedoodads\\fx\\stratholmefiresmokeemberm.m2");
	risingMenu.smokeFX.model:SetPortraitZoom(0);
    risingMenu.smokeFX.model:SetCamDistanceScale(1);
    risingMenu.smokeFX.model:SetPosition(0,3,16);
    risingMenu.smokeFX.model:SetRotation(0);
	risingMenu.smokeFX:Show();
	
end


-------------------------------------
--
-- Toggles the visibility of the main frame, risingMenu.
--
-------------------------------------
local function toggleRisingMenu()
	if risingMenu:IsShown() or risingMenu:GetAlpha() > 0 then
		UIFrameFadeOut(risingMenu, risingMenu:GetAlpha(), risingMenu:GetAlpha(), 0);
		UIFrameFadeIn(UIParent, UIParent:GetAlpha(), UIParent:GetAlpha(), 1);
		
		--this will give the keyboard to the game right away
		risingMenu:SetScript("OnKeyDown", nil);
		risingMenu:EnableKeyboard(false);
		
		--check out the comment in else condition
		Minimap:Show();
		Minimap:SetScript("OnUpdate", nil);
		risingMenu:SetScript("OnUpdate", function(self)
			if self:GetAlpha() == 0 then
				self:SetScript("OnUpdate", nil);
				self:Hide();
			end
		end);
	else
		risingMenu:Show();
		createSmokeEffect();
		UIFrameFadeOut(UIParent, 1, 1, 0);
		UIFrameFadeIn(risingMenu, 1, 0, 0.6);
		
		--Minimap pins are visible even after UIParent's alpha == 0
		--Only with Minimap:Hide() those pins disappear
		Minimap:SetScript("OnUpdate", function(self)
			if UIParent:GetAlpha() < 0.1 then
				self:SetScript("OnUpdate", nil);
				self:Hide();
			end
		end);
	end
end


-------------------------------------
--
-- Creates the following buttons:
-- Help
-- Options
-- Interface
-- KeyBindings
-- AddOns
-- Macros
-- Logout
-- Exit Game
-- Return to Game
-- 
-------------------------------------
local function createGameOptions()
	risingMenu.help 		= createFontFrame("Help", 			risingMenu, -15, 0, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonHelp:Click() end);
	risingMenu.options 		= createFontFrame("Options", 		risingMenu, -15, -40, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonOptions:Click() end);
	risingMenu.interface 	= createFontFrame("Interface", 		risingMenu, -15, -80, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonUIOptions:Click() end);
	risingMenu.keybindings 	= createFontFrame("Keybindings", 	risingMenu, -15, -120, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonKeybindings:Click() end);
	risingMenu.addons 		= createFontFrame("AddOns", 		risingMenu, -15, -160, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonAddOns:Click() end);
	risingMenu.macros 		= createFontFrame("Macros", 		risingMenu, -15, -200, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonMacros:Click() end);
	risingMenu.logout 		= createFontFrame("Logout", 		risingMenu, -15, -240, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonLogout:Click() end);
	risingMenu.exitGame 	= createFontFrame("Exit Game", 		risingMenu, -15, -280, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonQuit:Click() end);
	risingMenu.returnGame 	= createFontFrame("Return to Game", risingMenu, -15, -320, function() toggleRisingMenu() MainMenuMicroButton:Click() GameMenuButtonContinue:Click() end);
end


-------------------------------------
--
-- Initialize mainFrame, risingMenu.
--
-------------------------------------
local function initRising()
	risingMenu = CreateFrame("FRAME", "Rising", WorldFrame);
	risingMenu:SetSize(GetScreenWidth(), GetScreenHeight());
	risingMenu:SetAllPoints(WorldFrame);
	risingMenu.texture = risingMenu:CreateTexture("RisingBackground");
	risingMenu.texture:SetAllPoints(risingMenu);
	risingMenu.texture:SetTexture("Interface\\AddOns\\Rising\\bg.tga")
	risingMenu:SetAlpha(0);
	
	risingMenu:SetFrameStrata("TOOLTIP");
	risingMenu:SetFrameLevel(10);
		
	risingMenu:Hide();
	
	risingMenu:SetScript("OnShow", function(self)
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown", function(self, button)
			if(button == "ESCAPE") then
				toggleRisingMenu();
			end
		end);
	end);
end


-------------------------------------
--
-- Addon SetScript OnEvent
-- SetUps risingMenu and changes GameMenuFrame's script "OnShow".
--
-- Handled events:
-- "PLAYER_ENTERING_WORLD"
--
-------------------------------------
Addon:SetScript("OnEvent", function(self, event, ...)
	initRising();
	createGameOptions();
	createSmokeEffect();
	GameMenuFrame:SetScript("OnShow", function(self)
		toggleRisingMenu();
		GameMenuButtonContinue:Click();
	end);
	Addon:UnregisterAllEvents();
end);

Addon:RegisterEvent("PLAYER_ENTERING_WORLD");


