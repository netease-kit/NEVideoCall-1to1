import { SignalControllerCallType } from "@xkit-yx/call-kit";

type IPageData = {
  callType: SignalControllerCallType;
  imAccid: string;
  callTypeArr: Array<{
    value: SignalControllerCallType;
    title: string;
  }>;
};
// pages/index/index.js
const app = getApp<IAppOption>();
Page<IPageData, any>({
  /**
   * Page initial data
   */
  data: {
    callType: "1",
    imAccid: "",
    callTypeArr: [
      { value: "1", title: "语音通话" },
      { value: "2", title: "视频通话" },
    ],
  },

  changeCallType(e) {
    this.setData({
      callType: e.detail.value,
    });
  },
  changeHandler(e) {
    this.setData({
      imAccid: e.detail.value,
    });
  },
  startCall() {
    app.globalData.neCall
      ?.call({
        callType: this.data.callType,
        accId: this.data.imAccid,
      })
      .then(() => {
        wx.navigateTo({
          url: "/pages/call/call",
        });
      })
      .catch((err) => {
        console.log(err);
      });
  },
});
