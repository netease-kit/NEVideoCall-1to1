/// <reference path="./types/index.d.ts" />

interface IAppOption {
  globalData: {
    userInfo?: WechatMiniprogram.UserInfo;
    nim?: any;
    neCall?: import('@xkit-yx/call-kit/dist/types/neCall.wx').default;
  };
  userInfoReadyCallback?: WechatMiniprogram.GetUserInfoSuccessCallback;
}
