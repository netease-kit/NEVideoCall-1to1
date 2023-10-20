import React, { useState, useEffect } from 'react'
import { CallViewProvider, CallViewProviderRef } from '@xkit-yx/call-kit-react-ui'
import '@xkit-yx/call-kit-react-ui/es/style'
import { NIM } from '@yxim/nim-web-sdk'

const IndexPage = () => {
  const [nim, setNim] = useState<NIM>()
  const callViewProviderRef = React.createRef<CallViewProviderRef>()

  useEffect(() => {
    // 用户初始化im逻辑
    const im = NIM.getInstance({
      appKey: '', // im appkey
      token: '', // im token
      account: '', // im account
      onconnect: () => {
        setNim(im)
      },
    })
  }, [])



  return nim ? (
    <CallViewProvider
      ref={callViewProviderRef}
      neCallConfig={{
        nim,
        appkey: '', // 应用 appKey
      }}
      position={{
        x: 500,
        y: 10,
      }}
    >
      <button onClick={() => {
        callViewProviderRef.current?.call({
          accId: '', // 被叫im账号
          callType: '2', // 1: 音频通话 2: 视频通话
        })
      }}>发起呼叫</button>
    </CallViewProvider>
  ) : null
}

export default IndexPage