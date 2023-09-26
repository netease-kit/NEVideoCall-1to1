// app.ts
import { NECall } from "@xkit-yx/call-kit";
import WXNECall from "@xkit-yx/call-kit/dist/types/neCall.wx";
import NIM from "./sdk/NIM_Web_NIM_miniapp_v9.6.4";

App<IAppOption>({
  globalData: {
    neCall: undefined,
    nim: undefined,
  },
  onLaunch() {
    const appKey = "56813bdfbaa1c2a29bbea391ffbbe27a"; // 请填写自己应用的 appKey
    const account = "312628990132480"; // 请填写当前用户的im账号
    const token = "2b83ac96-9600-4173-a1da-25cbe59221bf"; // 请填写当前用户的im token
    const nim = NIM.getInstance({
      appKey,
      token,
      account,
      debugLevel: "debug",
      onconnect: () => {
        this.globalData.nim = nim;
        this.globalData.neCall = NECall.getInstance() as any;
        this.globalData.neCall.setup({
          nim,
          appkey: appKey,
        })
        this.globalData.neCall.on("onReceiveInvited", () => {
          // 接收到邀请后跳转到呼叫页面，路由用户可以自定义，该页面下需要包含 `@xkit-yx/call-kit-wx-ui` 相关的 UI 组件
          wx.navigateTo({
            url: "/pages/call/call",
          });
        });
      },
    });
  },
});
