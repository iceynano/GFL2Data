require("UI.UIBasePanel")

UIChapterHardPanel = class("UIChapterHardPanel", UIBasePanel)
UIChapterHardPanel.__index = UIChapterHardPanel

UIChapterHardPanel.chapterId = 0
UIChapterHardPanel.normalChapterId = 0
UIChapterHardPanel.storyCount = 0
UIChapterHardPanel.jumpId = 0
UIChapterHardPanel.curDiff = -1
UIChapterHardPanel.stageItemList = {}
UIChapterHardPanel.lineList = {}
UIChapterHardPanel.curStage = nil
UIChapterHardPanel.combatLauncher = nil

function UIChapterHardPanel:ctor()
    UIChapterHardPanel.super.ctor(self)
end

function UIChapterHardPanel.Close()
    self = UIChapterHardPanel
    self.curDiff = -1
    self.jumpId = 0
    UIManager.CloseUI(UIDef.UIChapterHardPanel)
end

function UIChapterHardPanel.OnRelease()
    
    self = UIChapterHardPanel
    UIChapterHardPanel.chapterId = 0
    UIChapterHardPanel.normalChapterId = 0
    UIChapterHardPanel.storyCount = 0
    UIChapterHardPanel.curDiff = -1
    UIChapterHardPanel.jumpId = 0
    UIChapterHardPanel.stageItemList = {}
    UIChapterHardPanel.lineList = {}
    UIChapterHardPanel.curStage = nil
    if UIChapterHardPanel.combatLauncher ~= nil then
        UIChapterHardPanel.combatLauncher:OnRelease()
    end
    UIChapterHardPanel.combatLauncher = nil

    UIChapterHardPanel:RemoveListeners()
end

function UIChapterHardPanel.Init(root, data, behaviorId)
    self = UIChapterHardPanel

    UIChapterHardPanel.super.SetRoot(UIChapterHardPanel, root)

    UIChapterHardPanel.RedPointType = {RedPointConst.ChapterReward}

    UIChapterHardPanel.mView = UIChapterHardPanelView.New()
    UIChapterHardPanel.mView:InitCtrl(root)

    if behaviorId==0 and data~=nil and GlobalConfig.IsOpenStagePanelByJumpUI then
        self.chapterId=TableData.listStoryDatas:GetDataById(data).chapter
        local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
        if self.curDiff == nil or self.curDiff == -1 then
            self.curDiff = chapterData.type
        end
        self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
        self.recordStoryId = self.chapterId ~= self.recordChapterId and 0 or self.recordStoryId
        self.recordChapterId = self.chapterId
        return
    end
    

    if data then
        if behaviorId ~= nil and behaviorId ~= 0 then
            local chapterId = 0
            if behaviorId == 6 then
                chapterId = TableData.listStoryDatas:GetDataById(tonumber(data)).chapter
            elseif behaviorId == 1 then
                chapterId = tonumber(data)
            end
            local chatperData = TableData.listChapterDatas:GetDataById(chapterId)
            self.curDiff = chatperData.type
            self.chapterId = chapterId
            self.normalChapterId = UIChapterGlobal:GetNormalChapterId(chapterId)
            self.jumpId = tonumber(data)
        else
            local chapterData = TableData.listChapterDatas:GetDataById(data)
            self.chapterId = tonumber(data)
            if self.curDiff == nil or self.curDiff == -1 then
                self.curDiff = chapterData.type
            end
            self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
        end

        self.recordStoryId = self.chapterId ~= self.recordChapterId and 0 or self.recordStoryId
        self.recordChapterId = self.chapterId
    end
end

function UIChapterHardPanel.OnInit()
    self = UIChapterHardPanel

    UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
        GlobalConfig.IsOpenStagePanelByJumpUI=false
        UIChapterHardPanel.Close()
    end

    UIUtils.GetButtonListener(self.mView.mBtn_CommandCenter.gameObject).onClick = function()
        UIChapterHardPanel.curDiff = -1
        UIChapterHardPanel.jumpId = 0
        GlobalConfig.IsOpenStagePanelByJumpUI=false
        UIManager.JumpToMainPanel()
    end

    UIUtils.GetButtonListener(self.mView.mBtn_ChapterReward.gameObject).onClick = function()
        UIChapterHardPanel:OnClickChapterReward()
    end

    UIUtils.GetButtonListener(self.mView.mBtn_Guide.gameObject).onClick = self.OnClickGuide

    self:AddListeners()
end

function UIChapterHardPanel.OnClickGuide()
    UIManager.OpenUIByParam(UIDef.UISysGuideWindow, {1})
end

function UIChapterHardPanel.ClearUIRecordData()
    UIChapterHardPanel.recordStoryId = 0
    UIChapterHardPanel.recordChapterId = 0
end
function UIChapterHardPanel:AddListeners()
    CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, UIChapterHardPanel.UpdateChapterInfo)
    CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, UIChapterHardPanel.OpenReceivePanel)

    --- RedPoint
    RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.ChapterReward)
end

function UIChapterHardPanel:RemoveListeners()
    CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, UIChapterHardPanel.UpdateChapterInfo)
    CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, UIChapterHardPanel.OpenReceivePanel)

    --- RedPoint
    RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.ChapterReward)
end

function UIChapterHardPanel.OnShow()
    self = UIChapterHardPanel
    if UIChapterHardPanel.chapterId then
        UIChapterHardPanel:UpdateChapterBG()
        UIChapterHardPanel:UpdateHideStage()
        UIChapterHardPanel:UpdateStoryStageItem()
        UIChapterHardPanel:UpdateRewardInfo()
        UIChapterHardPanel:UpdateChapterSwitch()
        UIChapterHardPanel:UpdateLine()
        UIChapterHardPanel:ResetScroll()
        -- UIChapterHardPanel:PlayListFadeIn()
        --
        --TimerSys:DelayCall(0.2, function ()
        --
        --end)
    end
end

function UIChapterHardPanel:UpdateHideStage()
    if NetCmdDungeonData:NeedOpenHideStage(self.chapterId) then
        MessageBoxPanel.ShowSingleType(TableData.GetHintById(610))
    end
end

function UIChapterHardPanel:UpdateStoryStageItem()
    local storyListData = TableData.GetStorysByChapterID(self.chapterId)
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    local isUnlockHide = NetCmdDungeonData:IsUnlockHideStory(self.chapterId)
    self.storyCount = storyListData.Count
    local lastData = storyListData[0]
    local firstData = storyListData[0]
    for i = 0, storyListData.Count - 1 do
        if storyListData[i].type == GlobalConfig.StoryType.Hide and not isUnlockHide then
            break
        end

        if(storyListData[i].mSfxPos.x > lastData.mSfxPos.x) then
            lastData = storyListData[i]
        end
        if storyListData[i].mSfxPos.x < firstData.mSfxPos.x then
            firstData = storyListData[i]
        end
    end
    self:UpdateCombatContent(firstData, lastData)

    self.mView.mText_ChapterNum.text = chapterData.name.str

    for i = 1, #self.stageItemList do
        self.stageItemList[i]:SetData(nil, false)
    end

    local list = {}
    for i = 0, storyListData.Count - 1 do
        table.insert(list, storyListData[i])
    end
    table.sort(list, function (a, b)
        if a.type == b.type then
            return a.id < b.id
        else
            return a.type < b.type
        end
    end)

    local delta = TableData.GlobalConfigData.SelectedStoryPosition * self.mView.mUIRoot.rect.size.x
    local tempItem = nil
    for i = 1, #list do
        local item = nil
        if i > #self.stageItemList then
            item = UIStoryStageHardItem.New()
            item:InitCtrl(self.mView.mTrans_CombatList)

            UIUtils.GetButtonListener(item.mBtn_Stage.gameObject).onClick = function()
                self:OnStoryClick(item)
            end

            table.insert(self.stageItemList, item)
        else
            item = self.stageItemList[i]
        end

        item:SetData(list[i])
        item:UpdateStagePos(delta)
    end

    for _, item in ipairs(self.stageItemList) do
        if item.storyData then
            if item.storyData.pre_id > 0 then
                local preStory = self:GetStoryItemId(item.storyData.pre_id)
                if preStory then
                    item.preStory = preStory
                    preStory.nextStory = item
                end
            end
        end
    end
end

function UIChapterHardPanel:OnStoryClick(item, needAni)
    needAni = needAni == nil and true or needAni
    if self.curStage ~= nil then
        if self.curStage.storyData.id == item.storyData.id then
            return
        end
        self.curStage:SetSelected(false)
    end

    local stageData = TableData.GetStageData(item.storyData.stage_id)
    if stageData ~= nil then
        local record = NetCmdStageRecordData:GetStageRecordById(stageData.id)
        self:ShowStageInfo(record, item.storyData, stageData)
        self:UpdateCurrencyNodes()
        self:ScrollMoveToMid(-item.mUIRoot.transform.localPosition.x, needAni, true)
        item:SetSelected(true)
        self.curStage = item
    end
end

function UIChapterHardPanel:UpdateRewardInfo()
    local storyCount = NetCmdDungeonData:GetCanChallengeStoryList(self.chapterId).Count
    local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterId)
    self.mView.mText_RewardNum.text = stars .. "/" .. storyCount * UIChapterGlobal.MaxChallengeNum
    self:UpdateRewardState()
end

function UIChapterHardPanel:UpdateRewardState()
    local canReceive = NetCmdDungeonData:UpdateChatperRewardRedPoint(self.chapterId) > 0
    self.mView.mImage_ReceiveIcon.color = canReceive and UIChapterGlobal.CanReceiveColor or UIChapterGlobal.CanNotReceiveColor
    setactive(self.mView.mTrans_RewardRedPoint, canReceive)
end

function UIChapterHardPanel.OnUpdateTop()
    self = UIChapterHardPanel
    if UIChapterHardPanel.combatLauncher ~= nil and UIChapterHardPanel.mView.mTrans_CombatLauncher.gameObject.activeSelf then
        if UIChapterHardPanel.combatLauncher.raycaster then
            UIChapterHardPanel.combatLauncher.raycaster.enabled = true
        end
        UITopResourceBar.UpdateParent(UIChapterHardPanel.combatLauncher.mTrans_TopCurrency)
    end
    if UIChapterHardPanel.chapterId then
        UIChapterHardPanel:UpdateStoryStageItem()
        UIChapterHardPanel:UpdateLine()
        if UIChapterHardPanel.curStage then
            local stageData = TableData.GetStageData(UIChapterHardPanel.curStage.storyData.stage_id)
            if stageData ~= nil then
                local record = NetCmdStageRecordData:GetStageRecordById(stageData.id)
                UIChapterHardPanel:ShowStageInfo(record, UIChapterHardPanel.curStage.storyData, stageData)
            end
        end
    end
end

function UIChapterHardPanel:ShowStageInfo(stageRecord, storyData, stageData)
    setactive(self.mView.mTrans_CombatLauncher, true)
    if self.combatLauncher == nil then
        local item = UICombatLauncherItem.New()
        item:InitCtrl(self.mView.mTrans_CombatLauncher.gameObject, 4)
        self.combatLauncher = item
        UIUtils.GetButtonListener(item.mBtn_Close.gameObject).onClick = function(gObj)
            self:OnClickCloseChapterInfoPanel()
        end
        -- UIUtils.SetButtonCallbackWithAni(item.mBtn_Close.gameObject, function () self:OnClickCloseChapterInfoPanel() end)
    end
    self.combatLauncher:InitChapterData(stageData, stageRecord, storyData, NetCmdDungeonData:IsUnLockStory(storyData.id))
end

function UIChapterHardPanel:UpdateCurrencyNodes()
    UITopResourceBar.UpdateParent(self.combatLauncher.mTrans_TopCurrency)
end

function UIChapterHardPanel:OnClickCloseChapterInfoPanel()
    if self.mView.mTrans_DetailsList.localPosition.x ~= 0 then
        local pos = self.mView.mTrans_DetailsList.localPosition
        pos.x = 0
        CS.UITweenManager.PlayLocalPositionTween(self.mView.mTrans_DetailsList, self.mView.mTrans_DetailsList.localPosition, pos, 0.3)
    end

    for i = 1, #self.stageItemList do
        self.stageItemList[i]:SetSelected(false)
    end
    self.curStage = nil

    if self.combatLauncher then
        UITopResourceBar.UpdateParent(self.mView.mTrans_TopCurrency)
        self.combatLauncher:PlayAniWithCallback(function ()
            setactive(self.mView.mTrans_CombatLauncher, false)

        end)
    else
        setactive(self.mView.mTrans_CombatLauncher, false)
    end
end

function UIChapterHardPanel:OnClickChapterReward()
    UIManager.OpenUIByParam(UIDef.UIChapterRewardPanel, self.chapterId)
end

function UIChapterHardPanel:UpdateCombatContent(first, last)
    local panelSize = self.mView.mUIRoot.rect.size.x * TableData.GlobalConfigData.SelectedStoryPosition * 2
    local delta = last.mSfxPos.x - first.mSfxPos.x
    self.mView.mTrans_CombatList.sizeDelta = Vector2(delta + panelSize, 0)
end

function UIChapterHardPanel:UpdateChapterBG()
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    self.mView.mImage_Bg.sprite = IconUtils.GetChapterBg(chapterData.map_background)
end

function UIChapterHardPanel:UpdateLine()
    local combatItem = self.mView.mTrans_DetailsList
    if combatItem == nil then
        return
    end

    for _, stage in ipairs(self.stageItemList) do
        if stage.lineItem then
            stage.lineItem:EnableLine(false)
            stage.lineItem:EnableSupportLine(false)
        end

        if stage.branchLineItem then
            stage.branchLineItem:EnableLine(false)
            stage.branchLineItem:EnableSupportLine(false)
        end
    end

    for i = 1, #self.stageItemList do
        local story = self.stageItemList[i]
        if story.storyData == nil then
            break
        end

        local preStory = self:GetStoryItemId(story.storyData.pre_id)
        if story.storyData and story.storyData.pre_id > 0 and preStory then
            if story.storyData.start_point == UIChapterGlobal.StageStartPoint.Right then
                if story.storyData.type == GlobalConfig.StoryType.Branch and preStory.storyData.type == GlobalConfig.StoryType.Normal then
                    local item = nil
                    if story.branchLineItem then
                        item = story.branchLineItem
                        item:EnableLine(true)
                    else
                        item = UIChapterLineItem.New()
                        item:InitCtrl(story.mTrans_LeftPoint.gameObject)
                        story.branchLineItem = item
                    end

                    local index = preStory:GetIndexOfBranch(story.storyData.id)
                    local temVec1 = preStory.mUIRoot.transform.localPosition + preStory.mTrans_RightPoint.transform.localPosition
                    local temVec2 = story.mUIRoot.transform.localPosition + story.mTrans_LeftPoint.transform.localPosition
                    local targetPos = temVec1.x + (preStory.lineLength / (preStory.branchList.Count + 2)) * (index + 1)
                    -- temVec1.x = temVec1.x + (preStory.lineLength / (preStory.branchList.Count + 2)) * (index + 1)
                    if math.abs(targetPos) >= math.abs(temVec2.x) then
                        local point = temVec2.y < 0 and story.mTrans_TopPoint.transform.localPosition or story.mTrans_BottomPoint.transform.localPosition
                        temVec1 = Vector3(story.mUIRoot.transform.localPosition.x - 4, preStory.mUIRoot.transform.localPosition.y, 0)
                        temVec2 = story.mUIRoot.transform.localPosition + point
                        setactive(story.mTrans_TopPoint.transform, temVec2.y < 0)
                        setactive(story.mTrans_BottomPoint.transform, temVec2.y >= 0)
                        setactive(story.mTrans_LeftPoint.gameObject, false)
                        if temVec2.y < 0 then
                            item:SetParent(story.mTrans_TopPoint.gameObject)
                        else
                            item:SetParent(story.mTrans_BottomPoint.gameObject)
                        end
                    else
                        temVec1.x = targetPos
                        item:SetParent(story.mTrans_LeftPoint.gameObject)
                        setactive(story.mTrans_LeftPoint.gameObject, true)
                    end
                    story:SetBranchLine(temVec1, temVec2)
                else
                    local item = nil
                    if preStory.lineItem then
                        item = preStory.lineItem
                        item:EnableLine(true)
                    else
                        item = UIChapterLineItem.New()
                        item:InitCtrl(preStory.mTrans_RightPoint.gameObject)
                        preStory.lineItem = item
                    end

                    local temVec1 = preStory.mUIRoot.transform.localPosition + preStory.mTrans_RightPoint.transform.localPosition
                    local temVec2 = story.mUIRoot.transform.localPosition + story.mTrans_LeftPoint.transform.localPosition
                    preStory.lineLength = math.abs(temVec2.x - temVec1.x)
                    preStory:SetLine(temVec1, temVec2)
                    story:UpdatePoint(story.isUnlock)
                    setactive(story.mTrans_LeftPoint.gameObject, story.storyData.pre_id > 0)
                    setactive(preStory.mTrans_RightPoint.gameObject, true)
                end
            elseif story.storyData.start_point == UIChapterGlobal.StageStartPoint.Top then
                if story.storyData.type == GlobalConfig.StoryType.Branch and preStory.storyData.type == GlobalConfig.StoryType.Normal then
                    local item = nil
                    if story.branchLineItem then
                        item = story.branchLineItem
                        item:EnableLine(true)
                    else
                        item = UIChapterLineItem.New()
                        item:InitCtrl(story.mTrans_LeftPoint.gameObject)
                        story.branchLineItem = item
                    end

                    local temVec1 = preStory.mUIRoot.transform.localPosition + preStory.mTrans_TopPoint.transform.localPosition
                    local temVec2 = story.mUIRoot.transform.localPosition + story.mTrans_LeftPoint.transform.localPosition

                    temVec1.x = temVec1.x - 8

                    story:SetBranchLine(temVec1, temVec2)
                    setactive(story.mTrans_RightPoint.gameObject, story.storyData.pre_id > 0)
                    setactive(story.mTrans_LeftPoint.gameObject, true)
                    setactive(preStory.mTrans_TopPoint.gameObject, true)
                end
            elseif story.storyData.start_point == UIChapterGlobal.StageStartPoint.Bottom then
                if story.storyData.type == GlobalConfig.StoryType.Branch and preStory.storyData.type == GlobalConfig.StoryType.Normal then
                    local item = nil
                    if story.branchLineItem then
                        item = story.branchLineItem
                        item:EnableLine(true)
                    else
                        item = UIChapterLineItem.New()
                        item:InitCtrl(story.mTrans_LeftPoint.gameObject)
                        story.branchLineItem = item
                    end

                    local temVec1 = preStory.mUIRoot.transform.localPosition + preStory.mTrans_BottomPoint.transform.localPosition
                    local temVec2 = story.mUIRoot.transform.localPosition + story.mTrans_LeftPoint.transform.localPosition

                    temVec1.x = temVec1.x - 8

                    story:SetBranchLine(temVec1, temVec2)
                    setactive(story.mTrans_RightPoint.gameObject, story.storyData.pre_id > 0)
                    setactive(story.mTrans_LeftPoint.gameObject, true)
                    setactive(preStory.mTrans_BottomPoint.gameObject, true)
                end
            end
        end

    end
end

function UIChapterHardPanel.OpenReceivePanel()
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel,{nil,nil,nil,true})
end

function UIChapterHardPanel.UpdateChapterInfo()
    self = UIChapterHardPanel
    for _, item in ipairs(self.stageItemList) do
        item:RefreshStage()
    end
    self:UpdateRedPoint()
    self:UpdateLine()
    self:UpdateRewardState()
    self:OnClickCloseChapterInfoPanel()
end

function UIChapterHardPanel:GetStoryItemId(id)
    for i = 1, #self.stageItemList do
        local item = self.stageItemList[i]
        if item.storyData ~= nil then
            if item.storyData.id == id then
                return item
            end
        end
    end
end

function UIChapterHardPanel:ResetScroll()
    if self.mView.mTrans_CombatList == nil then
        return
    end
    local offsetX = self.mView.mTrans_CombatList.rect.size.x - self.mView.mTrans_DetailsList.rect.size.x
    local itemX = 0
    self.mOffsetX = offsetX <= 0 and 0 or offsetX
    local curItem = nil
    local canChooseItem = false
    for i = 1, #self.stageItemList do
        local item = self.stageItemList[i]
        if item.storyData ~= nil then
            if self.jumpId > 0 then
                if item.storyData.id == self.jumpId and item.isUnlock then
                    curItem = item
                    canChooseItem = true
                    break
                end
            end
            if UIChapterHardPanel.recordStoryId ~= 0 then
                if UIChapterHardPanel.recordStoryId == item.storyData.id then
                    curItem = item
                end
            else
                if item.isUnlock and (item.storyData.type == GlobalConfig.StoryType.Hard) then
                    if itemX <= item.storyData.mSfxPos.x then
                        itemX = item.storyData.mSfxPos.x
                        curItem = item
                    end
                end
            end
        end
    end

    if curItem then
        if self.jumpId <= 0 then
            self:ScrollMoveToMid(-curItem.mUIRoot.transform.localPosition.x)
        end
        if canChooseItem then
            self:OnStoryClick(curItem, false)
        end
    else
        self.mView.mTrans_DetailsList.anchoredPosition = Vector2(self.mOffsetX / 2, 0)
    end
end

function UIChapterHardPanel:PlayListFadeIn()
    setactive(self.mView.mTrans_Mask, true)
    DOTween.DoCanvasFade(self.mView.mTrans_DetailsList, 0, 1, 0.3, 0.3, function ()
        setactive(self.mView.mTrans_Mask, false)
    end)
end

function UIChapterHardPanel:ScrollMoveToMid(toPosX, needSlide, onClick)
    needSlide = needSlide == true and true or false
    onClick = onClick == true and true or false
    local combatList = self.mView.mTrans_CombatList
    local ratio = TableData.GlobalConfigData.SelectedStoryForceposition
    toPosX = self.mView.mUIRoot.rect.size.x * (ratio - 0.5) + toPosX

    local toPos = Vector3(toPosX, combatList.localPosition.y, 0)
    local itemX = self.storyCount > 2 and math.max(combatList.sizeDelta.x, 2325) or combatList.sizeDelta.x
    local limitPosRight = itemX - self.mView.mUIRoot.rect.size.x / 2
    local limitPosLeft = self.mView.mUIRoot.rect.size.x / 2
    if math.abs(toPosX) > math.abs(limitPosRight) then
        local total = math.abs(toPosX) - math.abs(combatList.localPosition.x)
        local delta1 = math.abs(toPosX) - math.abs(limitPosRight)
        local delta2 = math.abs(limitPosRight) - math.abs(combatList.localPosition.x)
        toPos.x = -limitPosRight
        local deltaPos = self.mView.mTrans_DetailsList.localPosition
        deltaPos.x = self.storyCount == 1 and -delta1 / 4 or -delta1
        if needSlide then
            CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.3 * (delta2 / total), function ()
                if self.storyCount == 1 then
                    self.mView.mTrans_DetailsList.localPosition = deltaPos
                else
                    CS.UITweenManager.PlayLocalPositionTween(self.mView.mTrans_DetailsList, self.mView.mTrans_DetailsList.localPosition, deltaPos, 0.3 * (delta1 / total))
                end
            end)
        else
            combatList.localPosition = toPos
            if onClick then
                self.mView.mTrans_DetailsList.localPosition = deltaPos
            end
        end
    elseif math.abs(toPosX) < math.abs(limitPosLeft) then
        local total = math.abs(toPosX) - math.abs(combatList.localPosition.x)
        local delta1 = math.abs(toPosX) - math.abs(limitPosLeft)
        local delta2 = math.abs(limitPosLeft) - math.abs(combatList.localPosition.x)
        toPos.x = -limitPosLeft
        local deltaPos = self.mView.mTrans_DetailsList.localPosition
        deltaPos.x = self.storyCount == 1 and -delta1 / 4 or -delta1
        if needSlide then
            CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.3 * (delta2 / total), function ()
                if self.storyCount == 1 then
                    self.mView.mTrans_DetailsList.localPosition = deltaPos
                else
                    CS.UITweenManager.PlayLocalPositionTween(self.mView.mTrans_DetailsList, self.mView.mTrans_DetailsList.localPosition, deltaPos, 0.3 * (delta1 / total))
                end
            end)
        else
            combatList.localPosition = toPos
            if onClick then
                self.mView.mTrans_DetailsList.localPosition = deltaPos
            end
        end
    else
        if needSlide then
            CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.3)
        else
            combatList.localPosition = toPos
        end
    end
end

function UIChapterHardPanel:UpdateChapterSwitch()
    local data = TableData.listChapterDatas:GetDataById(self.chapterId)
    local lastData = TableData.listChapterDatas:GetDataById(self.chapterId - 1, true)
    local nextData = TableData.listChapterDatas:GetDataById(self.chapterId + 1, true)
    setactive(self.mView.mTrans_PreChapter.gameObject, lastData ~= nil)
    setactive(self.mView.mTrans_NextChapter.gameObject, nextData ~= nil and NetCmdDungeonData:IsUnLockChapter(self.chapterId + 1))

    if lastData then
        local normalId = UIChapterGlobal:GetNormalChapterId(lastData.id)
        self.mView.mText_PreChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
        UIUtils.GetButtonListener(self.mView.mBtn_PreChapter.gameObject).onClick = function ()
            self.chapterId = self.chapterId - 1
            self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
            UIChapterHardPanel.recordStoryId = self.chapterId ~= UIChapterHardPanel.recordChapterId and 0 or UIChapterHardPanel.recordStoryId
            UIChapterHardPanel.recordChapterId = self.chapterId
            UIManager.ChangeCacheUIData(UIDef.UIChapterHardPanel, self.chapterId)
            self.OnShow()
        end
    end
    if nextData and NetCmdDungeonData:IsUnLockChapter(self.chapterId + 1) then
        local normalId = UIChapterGlobal:GetNormalChapterId(nextData.id)
        self.mView.mText_NextChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
        UIUtils.GetButtonListener(self.mView.mBtn_NextChapter.gameObject).onClick = function ()
            self.chapterId = self.chapterId + 1
            self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
            UIChapterHardPanel.recordStoryId = self.chapterId ~= UIChapterHardPanel.recordChapterId and 0 or UIChapterHardPanel.recordStoryId
            UIChapterHardPanel.recordChapterId = self.chapterId
            UIManager.ChangeCacheUIData(UIDef.UIChapterHardPanel, self.chapterId)
            self.OnShow()
        end
    end

    self.mView.mText_CurrentChapterNum.text = UIChapterGlobal:GetTensDigitNum(self.normalChapterId)
end