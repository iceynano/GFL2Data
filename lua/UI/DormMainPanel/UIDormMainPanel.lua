---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 18/11/7 20:31
---

require("UI.UIBasePanel")
require("UI.AdjutantPanel.AdjutantItem.UIAdjutantItem");

UIDormMainPanel = class("UIDormMainPanel", UIBasePanel);
UIDormMainPanel.__index = UIDormMainPanel;

UIDormMainPanel.mView = nil;
UIDormMainPanel.mCurArea = 1;
UIDormMainPanel.mCurDormId = 0;

UIDormMainPanel.mListOptionDataA = nil;
UIDormMainPanel.mListOptionDataB = nil;

UIDormMainPanel.mDictIndexToId_A = {};
UIDormMainPanel.mDictIndexToId_B = {};
UIDormMainPanel.mDictIndexToId_C = {};

UIDormMainPanel.mTimer = nil;

function UIDormMainPanel:ctor()
    UIDormMainPanel.super.ctor(self);
end

function UIDormMainPanel.Open(currentGun, selectedCount)
    self = UIDormMainPanel;

end

function UIDormMainPanel.Close()
    UIManager.CloseUI(UIDef.UIDormMainPanel);
end

function UIDormMainPanel.Hide()
    self = UIDormMainPanel;
    self:Show(false);
end

function UIDormMainPanel.Init(root, data)
    UIDormMainPanel.super.SetRoot(UIDormMainPanel, root);

    UIDormMainPanel.mData = data;
    UIDormMainPanel.mView = UIDormMainPanelView;
    UIDormMainPanel.mView:InitCtrl(root);
end


function UIDormMainPanel.OnInit()
    self = UIDormMainPanel;

    self.mCurDormId = CS.DormScene.CurDormId;
    self.mCurArea = CS.DormScene.CurArea;

    UIUtils.GetButtonListener(self.mView.mBtn_back.gameObject).onClick = self.OnReturnClick;
    UIUtils.GetButtonListener(self.mView.mBtn_Manage.gameObject).onClick = self.OnManageClick;
    UIUtils.GetButtonListener(self.mView.mBtn_Dress.gameObject).onClick = self.OnDressClick;

    UIUtils.GetButtonListener(self.mView.mBtn_cheattool.gameObject).onClick = self.OnCheatToolOpen;
    UIUtils.GetButtonListener(self.mView.mBtn_cheatback.gameObject).onClick = self.OnCheatToolClose;
    UIUtils.GetButtonListener(self.mView.mBtn_ActionButton.gameObject).onClick = self.OnCheatAction;

    UIUtils.GetButtonListener(self.mView.mBtn_Nextline.gameObject).onClick = self.OnNextLine;

    UIUtils.GetButtonListener(self.mView.mBtn_Fixcamera.gameObject).onClick = self.OnFixCamera;
    UIUtils.GetButtonListener(self.mView.mBtn_Peercamera.gameObject).onClick = self.OnPeerCamera;
    UIUtils.GetButtonListener(self.mView.mBtn_Followcamera.gameObject).onClick = self.OnFollowCamera;
    UIUtils.GetButtonListener(self.mView.mBtn_Enlarge.gameObject).onClick = self.OnEnlarge;


    local dormScene = CS.SceneSys.Instance.currentScene;
    dormScene:ResetDormDeco(self.mCurDormId,self.mCurArea)

    MessageSys:AddListener(CS.GF2.Message.DormEvent.DormResponseAction, UIDormMainPanel.OnReceiveResponse)
    MessageSys:AddListener(CS.GF2.Message.DormEvent.DormResponseActionEnd, UIDormMainPanel.OnReceiveResponseEnd)
    MessageSys:AddListener(CS.GF2.Message.DormEvent.DormAction, UIDormMainPanel.OnReceiveAction)

    --self.InitCheatTool(0);
end

function UIDormMainPanel.OnManageClick(gameObject)
    self = UIDormMainPanel;
    UIManager.OpenUIByParam(UIDef.UIDormItemChangePanel,self.mCurDormId);
end

function UIDormMainPanel.OnDressClick(gameObject)
    self = UIDormMainPanel;
    UIManager.OpenUIByParam(UIDef.UIDormSkinChangePanel,self.mCurDormId);
end

function UIDormMainPanel.OnReceiveAction(msg)
    self = UIDormMainPanel;

    local data = msg.Content;

    setactive(self.mView.mTrans_Subtitle,true);
    CS.TypeTextComponentUtility.TypeText(self.mView.mText_linespace,data.Line);

    if(self.mTimer ~= nil) then
        self.mTimer:Stop()
        -- TimerSys:Remove(self.mTimer);
    end

    local t = TableData.GlobalSystemData.DormPlotSingletime;
    self.mTimer = TimerSys:DelayCall(t,function(idx) 
        setactive(self.mView.mTrans_Subtitle,false);               
    end,0);

end

function UIDormMainPanel.OnReceiveResponse(msg)
    self = UIDormMainPanel;

    local data = msg.Content;

    setactive(self.mView.mTrans_StoryBox,true);
    setactive(self.mView.mTrans_Subtitle,false);         
    CS.TypeTextComponentUtility.TypeText(self.mView.mText_Storyline,data.Line);

    setactive(self.mView.mBtn_Fixcamera.transform.parent,false);
end

function UIDormMainPanel.OnReceiveResponseEnd(msg)
    self = UIDormMainPanel;

    local data = msg.Content;

    setactive(self.mView.mTrans_StoryBox,true);
    CS.TypeTextComponentUtility.TypeText(self.mView.mText_Storyline,data.Line);

end



function UIDormMainPanel.OnNextLine(gameObject)
    self = UIDormMainPanel;
    local b = CS.DormStateMachineNew.Instance:OnNextLineClicked();

    if(b == false) then
        setactive(self.mView.mTrans_StoryBox,false);
        setactive(self.mView.mBtn_Fixcamera.transform.parent,true);
    end
end

function UIDormMainPanel.OnFixCamera(gameObject)
    self = UIDormMainPanel;
    CS.DormStateMachineNew.Instance:OnChangeCameraType(1);
    setactive(self.mView.mTrans_Fixcamera_Selected,true);
    setactive(self.mView.mTrans_Peercamera_Selected,false);
    setactive(self.mView.mTrans_Followcamera_Selected,false);
end

function UIDormMainPanel.OnPeerCamera(gameObject)
    self = UIDormMainPanel;
    CS.DormStateMachineNew.Instance:OnChangeCameraType(2);
    setactive(self.mView.mTrans_Fixcamera_Selected,false);
    setactive(self.mView.mTrans_Peercamera_Selected,true);
    setactive(self.mView.mTrans_Followcamera_Selected,false);
end

function UIDormMainPanel.OnFollowCamera(gameObject)
    self = UIDormMainPanel;
    CS.DormStateMachineNew.Instance:OnChangeCameraType(3);
    setactive(self.mView.mTrans_Fixcamera_Selected,false);
    setactive(self.mView.mTrans_Peercamera_Selected,false);
    setactive(self.mView.mTrans_Followcamera_Selected,true);
end

function UIDormMainPanel.OnEnlarge(gameObject)
    self = UIDormMainPanel;
    local isSelected = not self.mView.mTrans_Enlarge_Selected.gameObject.activeSelf;
    setactive(self.mView.mTrans_Enlarge_Selected.gameObject,isSelected)
    CS.DormStateMachineNew.Instance:OnZoomInCamera(self.mView.mTrans_Enlarge_Selected.gameObject.activeSelf);
end

function UIDormMainPanel.OnCheatToolOpen(gameObject)
    self = UIDormMainPanel;
    setactive(self.mView.mTrans_CheatGroup.transform,true);
    setactive(self.mView.mBtn_cheatback.transform,true);
end

function UIDormMainPanel.OnCheatToolClose(gameObject)
    self = UIDormMainPanel;
    setactive(self.mView.mTrans_CheatGroup.transform,false);
    setactive(self.mView.mBtn_cheatback.transform,false);
end

function UIDormMainPanel.OnCheatAction(gameObject)
    self = UIDormMainPanel;

end

-- function UIDormMainPanel.InitCheatTool(index)
--     self = UIDormMainPanel;

--     UIDormMainPanel.InitDropDownA();
--     -- UIDormMainPanel.InitDropDownB(index);
--     -- UIDormMainPanel.InitDropDownC(index);
--     -- UIDormMainPanel.InitDropDownD(index);
-- end

-- function UIDormMainPanel.InitDropDownA()
--     self = UIDormMainPanel
--     self.mListOptionDataA = NetCmdDormData:TestGetCmdActionsByGunId(3);
--     self.mView.mDropDownA:ClearOptions();

--     for i = 0, self.mListOptionDataA.Count - 1 do
--         local data = CS.UnityEngine.UI.Dropdown.OptionData(self.mListOptionDataA[i].Name)
--         self.mView.mDropDownA.options:Add(data);
--         self.mDictIndexToId_A[i+1] = self.mListOptionDataA[i].Id;
--     end
-- end

function UIDormMainPanel.OnReturnClick(gameObject)
    self = UIDormMainPanel;
    self.Close();
    SceneSys:ReturnLast();
end

function UIDormMainPanel.OnShow()
    self = UIDormMainPanel;
end

function UIDormMainPanel.OnRelease()
    self = UIDormMainPanel;

    if(self.mTimer ~= nil) then
        self.mTimer:Stop()
        --TimerSys:Remove(self.mTimer);
    end

    MessageSys:RemoveListener(CS.GF2.Message.DormEvent.DormResponseAction, UIDormMainPanel.OnReceiveResponse)
    MessageSys:RemoveListener(CS.GF2.Message.DormEvent.DormAction, UIDormMainPanel.OnReceiveAction)

    self.mTimer = nil;
    
end
