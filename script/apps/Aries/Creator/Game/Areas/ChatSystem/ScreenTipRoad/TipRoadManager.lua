--[[
Title: 
Author(s): leio
Date: 2020/5/8
Desc:  
Use Lib:
-------------------------------------------------------
local TipRoadManager = NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ChatSystem/ScreenTipRoad/TipRoadManager.lua");
TipRoadManager:CreateRoads();
for k = 1, 100 do
    local txt = string.format("hello world %d",k);
    TipRoadManager:PushNode(txt,"#ff0000");
end
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");



local TipRoad = NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ChatSystem/ScreenTipRoad/TipRoad.lua");
local TipCarNode = NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ChatSystem/ScreenTipRoad/TipCarNode.lua");
local TipRoadManager = NPL.export();

TipRoadManager.roads = {};
TipRoadManager.x = 0;
TipRoadManager.y = 50;
TipRoadManager.cnt = 6;
TipRoadManager.height = 40;
TipRoadManager.font_size = 22;
TipRoadManager.font_weight = "norm";
TipRoadManager.speed = -80;
TipRoadManager.acceleration = -10;
TipRoadManager.interval = 20;
TipRoadManager.gap = 5;

TipRoadManager.name = "TipRoadManager_Instance";
function TipRoadManager:CreateRoads()
    if(self.created)then
        return
    end
    self.created = true;
	local root = ParaUI.GetUIObject("root");
    local width = root.width;
    local height = TipRoadManager.height * TipRoadManager.cnt;
    self.width = width;
	local container = ParaUI.CreateUIObject("container", self.name, "lt", self.x, self.y, width, height);
    container:SetField("ClickThrough", true);
	container.background = "";
    root:AddChild(container);

    root:SetScript("onsize", function()
        self:OnResize();
	end)
    self.container = container;
    for k = 1, self.cnt do
        local y = (k-1) * self.height
        local road = TipRoad:new():OnInit(container,0,y,width,self.height);
        table.insert(self.roads,road);
    end
    local timer = commonlib.Timer:new({callbackFunc = function(timer)
        local delta = timer.delta / 1000;
        self:OnFrame(delta);
    end})

    timer:Change(0, self.interval)
end
function TipRoadManager:PushNode(txt,color,font_size,font_weight)
    if(not self.created)then
        return
    end
    local road,running_cnt = self:GetPreferredRoad();
    local safe_distance;
    if(running_cnt == 0)then
        safe_distance = self.gap;
    else
        safe_distance = self:GetPreferredDistance();
    end
    font_size = font_size or self.font_size;
    font_weight = font_weight or self.font_weight;
    local node = TipCarNode:new():OnInit(txt, color, font_size, font_weight, safe_distance, self.speed, self.acceleration);
    road:AddCarNode(node);
end
function TipRoadManager:OnShow(v)
    if(self.created and self.container)then
        self.container.visible = v;
    end
end
function TipRoadManager:GetPreferredRoad()
    local list = {};
    for k = 1, self.cnt do
        local road = self.roads[k];
        local stop_cnt,waitting_cnt,running_cnt = road:GetNodeCnt()
        table.insert(list,{
            stop_cnt = stop_cnt,
            waitting_cnt = waitting_cnt,
            running_cnt = running_cnt,
            index = k,
        });
    end
    table.sort(list,function(a,b)
        return 
            (a.stop_cnt < b.stop_cnt) or
            (a.stop_cnt >= b.stop_cnt and a.waitting_cnt < b.waitting_cnt) or
            (a.stop_cnt >= b.stop_cnt and a.waitting_cnt >= b.waitting_cnt and a.running_cnt < b.running_cnt)

    end)
    local road_index = list[1].index;
    local road = self.roads[road_index];
    local running_cnt = list[1].running_cnt;
    return road,running_cnt;
end
function TipRoadManager:GetPreferredDistance()
    local min_w = 0;
    local max_w = self.width / 5;
    local gap = self.gap;
    local len = (max_w - min_w) / gap;
    len = math.floor(len);
    local index = math.random(0,len);
    local distance = index * gap;
    return distance;
end
function TipRoadManager:OnFrame(delta)
    for k = 1, self.cnt do
        local road = self.roads[k];
        road:OnFrame(delta)
    end
end
function TipRoadManager:OnResize()
	local root = ParaUI.GetUIObject("root");
    local width = root.width;
    self.width = width;
    self.container.width = width;
    for k = 1, self.cnt do
        local road = self.roads[k];
        road:OnResize(width)
    end
end