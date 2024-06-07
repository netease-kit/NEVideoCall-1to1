import React, { useEffect, useMemo } from 'react'
import { CallViewProvider, CallViewProviderRef } from '@xkit-yx/call-kit-react-ui'
import '@xkit-yx/call-kit-react-ui/es/style'
import V2NIM from 'nim-web-sdk-ng'

const appkey = '' // 请填写你的appkey
const account = '' // 请填写你的account
const token = '' // 请填写你的token

const IndexPage = () => {
  const [isLogin, setIsLogin] = React.useState(false)
  const callViewProviderRef = React.createRef<CallViewProviderRef>()

  const nim = useMemo(() => {
    return V2NIM.getInstance({
      appkey,
      account,
      token,
      apiVersion: 'v2',
      debugLevel: 'debug',
    })
  }, [])

  useEffect(() => {
    if (nim) {
      // 当 App 完成渲染后，登录 IM
      nim.V2NIMLoginService.login(account, token, {
        retryCount: 5,
      }).then(() => {
        setIsLogin(true)
      })
    }

    // 当 App 卸载时，登出 IM
    return () => {
      if (nim) {
        nim.V2NIMLoginService.logout().then(() => {
          setIsLogin(false)
        })
      }
    }
  }, [nim])

  return nim && isLogin ? (
    <CallViewProvider
      ref={callViewProviderRef}
      neCallConfig={{
        nim,
        appkey, // 应用 
        debug: true,
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