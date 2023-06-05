import React, { useRef, useState, useEffect } from 'react'
import { request } from '@xkit-yx/utils'
import { Login, Session, logoutFn } from '@xkit-yx/login-react-ui'
import {CallViewProvider, useCall} from '@xkit-yx/call-kit-react-ui'
import '@xkit-yx/login-react-ui/lib/style'
import { Tag, Button, Input, Form, message, Modal, Switch } from 'antd'
import qs from 'qs'
import { FormInstance } from 'antd/lib/form'

import 'antd/lib/tag/style'
import 'antd/lib/button/style'
import 'antd/lib/input/style'
import 'antd/lib/modal/style'
import './style'

import NIM from '../sdk/NIM_Web_NIM_v9.6.1'

function secondToDate(result: number): string {
  let h: number | string = Math.floor(result / 3600)
  let m: number | string = Math.floor((result / 60) % 60)
  let s: number | string = Math.floor(result % 60)
  if (s < 10) {
    s = '0' + s
  }
  if (m < 10) {
    m = '0' + m
  }
  if (h === 0) {
    return m + ':' + s
  }
  if (h < 10) {
    h = '0' + h
  }
  return h + ':' + m + ':' + s
}


const { Search } = Input

const baseUrl = process.env.BASEURL || ''
const appKey = process.env.APPKEY || ''

const urlMap = {
  loginRegisterByCode: '/auth/loginBySmsCode',
  getLoginSmsCode: '/auth/sendLoginSmsCode',
}

export default {
  title: 'CALL KIT/呼叫组件',
}

interface User {
  avatar: string
  imAccid: string
  mobile: string
  tel: string
  nickname: string
  nick: string
  account: string
  imToken?: string
  accessToken?: string
  isMyFriend?: boolean
}

interface FormItemProps {
  value?: string
  onChange?: (value: string) => void
}

interface TimeoutInputProps extends FormItemProps {
  onSetTimeout: () => void
}

const TimeoutInput = (props: TimeoutInputProps) => {
  const { value, onChange, onSetTimeout } = props
  return (
    <Input.Group compact>
      <Input
        style={{ width: 200 }}
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
      />
      <Button type="primary" onClick={() => onSetTimeout()}>
        设置
      </Button>
    </Input.Group>
  )
}

interface UserViewProps {
  userInfo: User
  im: any
  onLogout: () => void
  messageList: any[]
}

const UserView: React.FC<UserViewProps> = (props) => {
  const { userInfo, im, onLogout, messageList } = props
  const [searchResult, setSearchResult] = useState<User>()
  const [searchErrMsg, setSearchErrMsg] = useState<string>('')
  const [messageTexts, setMessageTexts] = useState<
    { text: string; id: number }[]
  >([])
  const formRef = useRef<FormInstance>(null)
  const { call, neCall } = useCall()

  const handleMessage = (
    attach: {
      type: number
      status: number
      durations: { accid: string; duration: number }[]
    },
    imAccid: string
  ): void => {
    let account = imAccid
    let msg = ''
    switch (attach.status) {
      case 1:
        msg += '正常接听'
        const item = attach.durations.find(
          (item) => item.accid !== userInfo.imAccid
        )
        if (item) {
          account = item.accid
          msg += `通话时长 ${secondToDate(item.duration)}`
        }
        break
      case 2:
        msg += '未接听'
        break
      case 3:
        msg += '拒绝'
        break
      case 4:
        msg += '超时'
        break
      case 5:
        msg += '占线'
        break
      default:
        msg += '未知'
        break
    }
    im.getUser({
      account,
      done: (error, user) => {
        msg = user.tel + '，' + msg
        setMessageTexts([{ text: msg, id: Date.now() }, ...messageTexts])
      },
    })
  }

  useEffect(() => {
    messageList.forEach((msg) => handleMessage(msg.attach, msg.account))
  }, [messageList])

  useEffect(() => {
    const handleMessageSend = (data) => {
      handleMessage(data.attach, data.to)
    }
    neCall?.on('onRecordSend', handleMessageSend)
    return () => {
      neCall?.off('onRecordSend', handleMessageSend)
    }
  }, [neCall, messageTexts])

  const handleAddFriend = () => {
    if (searchResult) {
      im.addFriend({
        account: searchResult.imAccid,
        done: (err) => {
          if (!err) {
            setSearchResult({ ...searchResult, isMyFriend: true })
          }
        },
      })
    }
  }

  const handleLogout = async () => {
    Modal.confirm({
      title: '确认注销当前登录账户？',
      okText: '确认',
      cancelText: '取消',
      onOk: async () => {
        await neCall?.hangup()
        await logoutFn()
        onLogout()
        window.location.reload()
      },
    })
  }

  const onSearch = async () => {
    try {
      const data = await formRef.current?.validateFields(['mobile'])
      setSearchErrMsg('')
      setSearchResult(undefined)
      const res = await request({
        url: `${baseUrl}/p2pVideoCall/caller/searchSubscriber`,
        headers: {
          accessToken: userInfo.accessToken,
          appKey,
        },
        data,
      })
      if (!res.data) {
        setSearchErrMsg('搜索结果为空')
        return
      }
      if (res.data.imAccid === userInfo.imAccid) {
        setSearchErrMsg('不能搜索自己')
      } else {
        im.isMyFriend({
          account: res.data.imAccid,
          done: (err, isMyFriend) => {
            if (!err) {
              setSearchResult({
                ...res.data,
                isMyFriend,
              })
            } else {
              setSearchErrMsg('失败，请重新搜索')
            }
          },
        })
      }
    } catch (err: any) {
      err.msg && setSearchErrMsg(err.msg)
    }
  }

  const handleSetCallTimeout = async () => {
    try {
      const { callTimeout } = await formRef.current?.validateFields([
        'callTimeout',
      ])

      if (callTimeout >= 120 * 1000) {
        message.error('超过120秒，请重新设置')
      } else {
        neCall?.setTimeout(callTimeout)
        message.success('设置成功')
      }
    } catch (err) {}
  }

  const handleCall = async (type: '1' | '2') => {
    const accId = searchResult?.imAccid || ''
    if (!navigator.onLine) {
      message.error('网络异常，请检查网络')
      return
    }
    call?.({
      accId,
      callType: type,
    })
  }

  const setEnableSwitchCallTypeConfirm = (
    type: 'video' | 'audio',
    enable: boolean
  ) => {
    if (type === 'video') {
      neCall?.setCallConfig({ enableSwitchVideoConfirm: enable })
    }
    if (type === 'audio') {
      neCall?.setCallConfig({ enableSwitchAudioConfirm: enable })
    }
  }

  const setEnableJoinRTCChannelWhenCall = (enable: boolean) => {
    neCall?.setCallConfig({ enableJoinRtcWhenCall: enable })
  }

  return (
    <>
      <div>
        {userInfo.nickname}（手机号：{userInfo.mobile}）{' '}
        <Tag color="#87d068">已登录</Tag>
        <Button onClick={() => handleLogout()}>退出登录</Button>
      </div>
      <Form ref={formRef} validateTrigger={false} style={{ marginTop: 10 }}>
        <Form.Item
          label="超时时间"
          name="callTimeout"
          initialValue={30}
          rules={[
            {
              required: true,
              message: '请输入超时时间',
            },
            {
              pattern: /^\+?[1-9]\d*$/,
              message: '请输入大于0的整数',
            },
          ]}
        >
          <TimeoutInput onSetTimeout={handleSetCallTimeout} />
        </Form.Item>
        <Form.Item
          label="切换为视频需要确认"
          name="confirmVideo"
          valuePropName="checked"
        >
          <Switch
            onChange={(e) => setEnableSwitchCallTypeConfirm('video', e)}
          />
        </Form.Item>
        <Form.Item
          label="切换为音频需要确认"
          name="confirmAudio"
          valuePropName="checked"
        >
          <Switch
            onChange={(e) => setEnableSwitchCallTypeConfirm('audio', e)}
          />
        </Form.Item>
        <Form.Item
          label="是否提前加入RTC房间"
          name="joinRtcChannel"
          valuePropName="checked"
        >
          <Switch onChange={(e) => setEnableJoinRTCChannelWhenCall(e)} />
        </Form.Item>
        <Form.Item
          name="mobile"
          rules={[
            { required: true, message: '请填写手机号' },
            {
              pattern:
                /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/,
              message: '请填写正确的手机号',
            },
          ]}
        >
          <Search
            style={{ width: 200, display: 'block', marginTop: 10 }}
            maxLength={11}
            placeholder="通过手机号搜索用户"
            onSearch={onSearch}
            enterButton
          />
        </Form.Item>
      </Form>
      <div style={{ color: 'red' }}>{searchErrMsg}</div>
      {searchResult && (
        <>
          {searchResult.nickname}
          (手机号：{searchResult.mobile})
          {searchResult?.isMyFriend ? (
            <>
              <Button
                type="primary"
                style={{ marginLeft: 10 }}
                onClick={() => handleCall('1')}
              >
                拨打音频
              </Button>
              <Button
                type="primary"
                style={{ marginLeft: 10 }}
                onClick={() => handleCall('2')}
              >
                拨打视频
              </Button>
            </>
          ) : (
            <Button
              type="primary"
              style={{ marginLeft: 10 }}
              onClick={() => handleAddFriend()}
            >
              添加好友
            </Button>
          )}
        </>
      )}
      {messageTexts.map((msg, index) => (
        <p key={msg.id}>{msg.text}</p>
      ))}
    </>
  )
}

export const Single: React.FC = () => {
  // 0： 初始化
  // 1： 已登录
  // 2： 未登录
  const autoLogin = true
  const [loginState, setLoginState] = useState<number>(autoLogin ? 0 : 2)
  const [nim, setNim] = useState<any>()
  const [messageList, setMessageList] = useState<any[]>([])
  const [userInfo, setUserInfo] = useState<User>()

  useEffect(() => {
    if (userInfo) {
      const im = NIM.getInstance({
        appKey,
        token: userInfo.imToken,
        account: userInfo.imAccid,
        debugLevel: 'debug',
        // lbsUrl: 'https://imtest.netease.im/lbs/webconf',
        // linkUrl: 'imtest4.netease.im:443',
        onconnect: () => {
          setNim(im)
          im.updateMyInfo({
            nick: userInfo.nickname,
            avatar: userInfo.avatar,
            tel: userInfo.mobile,
          })
        },
        onmsg: (msg) => {
          console.log('onmsg', msg)
          if (msg.type === 'g2') {
            setMessageList([
              ...messageList,
              { attach: msg.attach, account: msg.from },
            ])
          }
        },
        ondisconnect: (data) => {
          console.log('ondisconnect', data)
        },
      })
      return () => {
        im.disconnect()
      }
    }
  }, [userInfo])

  const loginProps = {
    autoLogin,
    componentTag: 'call',
    baseDomain: baseUrl,
    appKey,
    parentScope: 2,
    scope: 7,
    urlMap,
    success: async (res) => {
      setUserInfo(res)
      setLoginState(1)
    },
    fail: (err) => {
      setLoginState(2)
    },
  }

  useEffect(() => {
    new UIRecord()
  }, [])

  useEffect(() => {
    const query = qs.parse(location.search)
    const { testDeviceId } = query
    console.log('UI自动化测试设备', window.location.search, testDeviceId)
    new WebAT({
      applicationName: 'callkitUI',
      platform: 'web',
      version: '1.7.0',
      deviceId: testDeviceId,
      targets: {},
    })
  }, [])

  return (
    <Session {...loginProps} memoryMode="sessionStorage">
      {loginState === 0 && null}
      {loginState === 1 && userInfo && nim && (
        <CallViewProvider
          neCallConfig={{
            nim,
            appkey: appKey,
            debug: true,
          }}
          uiConfig={{
            switchCallTypeBtn: {
              switchToVideo: true,
            },
          }}
          position={{
            x: 500,
            y: 10,
          }}
        >
          <UserView
            userInfo={userInfo}
            im={nim}
            messageList={messageList}
            onLogout={() => setLoginState(2)}
          />
        </CallViewProvider>
      )}
      {loginState === 2 && <Login />}
    </Session>
  )
}
