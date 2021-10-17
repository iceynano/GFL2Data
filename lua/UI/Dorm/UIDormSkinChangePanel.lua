---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 18/11/7 20:31
---

require("UI.UIBasePanel")
require("UI.AdjutantPanel.AdjutantItem.UIAdjutantItem");

UIDormSkinChangePanel = class("UIDormSkinChangePanel", UIBasePanel);
UIDormSkinChangePanel.__index = UIDormSkinChangePanel;

UIDormSkinChangePanel.mView = nil;
UIDormSkinChangePanel.mGunId = 0;

UIDormSkinChangePanel.mCurSelectHairItem = nil;
UIDormSkinChangePanel.mCurSelectBodyItem = nil;

function UIDormSkinChangePanel:ctor()
    UIDormSkinChangePanel.super.ctor(self);
end

function UIDormSkinChangePanel.Open(currentGun, selectedCount)
    self = UIDormSkinChangePanel;

end

function UIDormSkinChangePanel.Close()
    UIManager.CloseUI(UIDef.UIDormSkinChangePanel);
end

function UIDormSkinChangePanel.Hide()
    self = UIDormSkinChangePanel;
    self:Show(false);
end

function UIDormSkinChangePanel.Init(root, data)
    UIDormSkinChangePanel.super.SetRoot(UIDormSkinChangePanel, root);

    UIDormSkinChangePanel.mData = data;
    UIDormSkinChangePanel.mView = UIDormSkinChangePanelView;
    UIDormSkinChangePanel.mView:InitCtrl(root);

    UIDormSkinChangePanel.mDormPartList = List:New();
    UIDormSkinChangePanel.InitHairParts();
end


function UIDormSkinChangePanel.OnInit()
    self = UIDormSkinChangePanel;

    UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = self.OnReturnClick;

    UIUtils.GetButtonListener(self.mView.mBtn_HairPart.gameObject).onClick = self.OnHairListClick;
    UIUtils.GetButtonListener(self.mView.mBtn_BodyPart.gameObject).onClick = self.OnBodyListClick;
    UIUtils.GetButtonListener(self.mView.mBtn_Ensure.gameObject).onClick = self.OnConfirmClick;
end

function UIDormSkinChangePanel.InitHairParts()
    self = UIDormSkinChangePanel;

    self.ClearList();

    local characterData = CS.DressUpController.CharacterData;

    for i = 0, characterData.hair.Count - 1 do
        local hairId = characterData.hair[i];
        local hairData = TableData.listDormCharacterPartDatas:GetDataById(hairId);

        local decoItem = UIDormNodeItem.New();
        decoItem:InitCtrl(self.mView.mTrans_Content);
        decoItem:SetSkinData(hairData.name,hairId); 
        local btn = UIUtils.GetButtonListener(decoItem.mBtn_Icon.gameObject);
        btn.onClick = self.OnHairItemClicked;
        btn.param = decoItem;
        self.mDormPartList:Add(decoItem);

        if(hairId == CS.DressUpController.Instance.CurHairId) then
            decoItem:SetSelect(true);
        end
    end

    setactive(self.mView.mImage_HairPart_Selected,true);
    setactive(self.mView.mImage_BodyPart_Selected,false);
end

function UIDormSkinChangePanel.InitBodyParts()
    self = UIDormSkinChangePanel;

    self.ClearList();

    local characterData = CS.DressUpController.CharacterData;

    for i = 0, characterData.body.Count - 1 do
        local bodyId = characterData.body[i];
        local bodyData = TableData.listDormCharacterPartDatas:GetDataById(bodyId);

        local decoItem = UIDormNodeItem.New();
        decoItem:InitCtrl(self.mView.mTrans_Content);
        decoItem:SetSkinData(bodyData.name,bodyId); 
        local btn = UIUtils.GetButtonListener(decoItem.mBtn_Icon.gameObject);
        btn.onClick = self.OnBodyItemClicked;
        btn.param = decoItem;
        self.mDormPartList:Add(decoItem);

        if(bodyId == CS.DressUpController.Instance.CurBodyId) then
            decoItem:SetSelect(true);
        end
    end

    setactive(self.mView.mImage_HairPart_Selected,false);
    setactive(self.mView.mImage_BodyPart_Selected,true);
end

function UIDormSkinChangePanel.OnHairItemClicked(gameObject)
    self = UIDormSkinChangePanel;

    for i = 1, #self.mDormPartList do 
        self.mDormPartList[i]:SetSelect(false);
    end

    local btn = UIUtils.GetButtonListener(gameObject);
    self.mCurSelectHairItem = btn.param;
    self.mCurSelectHairItem:SetSelect(true);

    gfdebug("OnHairItemClicked")
end

function UIDormSkinChangePanel.OnBodyItemClicked(gameObject)
    self = UIDormSkinChangePanel;

    for i = 1, #self.mDormPartList do 
        self.mDormPartList[i]:SetSelect(false);
    end

    local btn = UIUtils.GetButtonListener(gameObject);
    self.mCurSelectBodyItem = btn.param;
    self.mCurSelectBodyItem:SetSelect(true);

    gfdebug("OnBodyItemClicked")
end

function UIDormSkinChangePanel.ClearList()
    self = UIDormSkinChangePanel;

    for i = 1, #self.mDormPartList do 
        gfdestroy(self.mDormPartList[i].mUIRoot.gameObject);
    end

    self.mDormPartList:Clear();
end

function UIDormSkinChangePanel.OnHairListClick(gameObject)
    self = UIDormSkinChangePanel;
    self.InitHairParts()
end

function UIDormSkinChangePanel.OnBodyListClick(gameObject)
    self = UIDormSkinChangePanel;
    self.InitBodyParts()
end

function UIDormSkinChangePanel.OnConfirmClick(gameObject)
    self = UIDormSkinChangePanel;
    if(self.mCurSelectHairItem ~= nil) then
        CS.DressUpController.Instance:ChangeHairPrefab(self.mCurSelectHairItem.mPartId);
    end
    if(self.mCurSelectBodyItem ~= nil) then
        CS.DressUpController.Instance:ChangeBodyPrefab(self.mCurSelectBodyItem.mPartId);
    end

    self.Close();
end

function UIDormSkinChangePanel.OnReturnClick(gameObject)
    self = UIDormSkinChangePanel;
    self.Close();
end

function UIDormSkinChangePanel.OnShow()
    self = UIDormSkinChangePanel;
end

function UIDormSkinChangePanel.OnRelease()
    self = UIDormSkinChangePanel;
    
end
