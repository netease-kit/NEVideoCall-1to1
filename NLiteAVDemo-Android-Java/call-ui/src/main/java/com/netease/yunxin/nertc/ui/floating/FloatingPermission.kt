/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.floating

import android.app.Activity
import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.utils.CallUILog
import java.lang.reflect.Method
import java.util.Arrays
import java.util.Locale

/**
 * 浮窗权限请求，以及检测
 */
object FloatingPermission {
    private const val TAG = "FloatPermission"

    fun isFloatPermissionValid(context: Context): Boolean {
        // Android 6.0 以下无需申请权限
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // 判断是否拥有悬浮窗权限，无则跳转悬浮窗权限授权页面
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    /**
     * 是否为 MIUI 设备
     */
    private fun isMiui(): Boolean {
        return Build.MANUFACTURER.equals("XIAOMI", true) ||
            (Build.DISPLAY?.contains("MIUI", true) == true)
    }

    /**
     * 请求浮窗权限
     */
    fun requireFloatPermission(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return
        }
        try {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            intent.data = Uri.parse("package:" + context.packageName)
            if (context !is Activity) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            CallUILog.e(TAG, "requestFloatWindowPermission Exception", e)
        }
    }

    /**
     * 检查是否被允许后台启动
     *
     * @return true 允许后台启动
     */
    fun isBackgroundStartAllowed(context: Context): Boolean {
        // 仅在 MIUI 设备上进行检查，非 MIUI 直接视为允许，避免不必要的反射调用
        if (!isMiui()) {
            return true
        }
        val ops = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        try {
            val op = 10021
            val method: Method = ops.javaClass
                .getMethod(
                    "checkOpNoThrow",
                    *arrayOf<Class<*>?>(
                        Int::class.javaPrimitiveType,
                        Int::class.javaPrimitiveType,
                        String::class.java
                    )
                )
            val result = method.invoke(
                ops,
                op,
                Process.myUid(),
                CallKitUI.baseContext()?.packageName
            ) as Int
            return result == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            CallUILog.e(TAG, "not support")
        }
        return false
    }

    private var bgPopHashMap: LinkedHashMap<String, List<String>> =
        object : LinkedHashMap<String, List<String>>() {
            init {
                put(
                    "XIAOMI",
                    Arrays.asList(
                        "com.miui.securitycenter/com.miui.permcenter.permissions.PermissionsEditorActivity",
                        "com.miui.securitycenter/com.miui.appmanager.ApplicationsDetailsActivity",
                        "com.miui.securitycenter"
                    )
                )
                put(
                    "HUAWEI",
                    Arrays.asList(
                        "com.huawei.systemmanager/.appcontrol.activity.StartupAppControlActivity",
                        "com.huawei.systemmanager"
                    )
                )
                // 荣耀
                put(
                    "HONOR",
                    Arrays.asList(
                        "com.hihonor.systemmanager/.appcontrol.activity.StartupAppControlActivity",
                        "com.hihonor.systemmanager/.startupmgr.ui.StartupNormalAppListActivity",
                        "com.hihonor.systemmanager"
                    )
                )
                put(
                    "VIVO",
                    Arrays.asList(
                        "com.vivo.permissionmanager/.activity.StartBgActivityControlActivity", // 需要com.vivo.permission.manage.permission.ACCESS权限
                        "com.vivo.permissionmanager/.activity.SoftPermissionDetailActivity",
                        "com.vivo.permissionmanager/.activity.PurviewTabActivity",
                        "com.vivo.permissionmanager",
                        "com.iqoo.secure"
                    )
                )
                put(
                    "MEIZU",
                    Arrays.asList(
                        "com.meizu.safe/.permission.PermissionMainActivity",
                        "com.meizu.safe"
                    )
                )
                put(
                    "OPPO",
                    Arrays.asList(
                        "com.oplus.battery/com.oplus.powermanager.fuelgaue.PowerControlActivity", // not exported
                        "com.android.settings/com.oplus.settings.OplusSubSettings",
                        "com.android.settings/com.android.settings.SubSettings",
                        "com.coloros.oppoguardelf/com.coloros.powermanager.fuelgaue.PowerUsageModelActivity",
                        "com.coloros.safecenter/com.coloros.privacypermissionsentry.PermissionTopActivity",
                        "com.coloros.safecenter",
                        "com.oppo.safe",
                        "com.coloros.oppoguardelf"
                    )
                )
                put(
                    "SAMSUNG",
                    Arrays.asList(
                        "com.samsung.android.lool",
                        "com.samsung.android.sm_cn",
                        "com.samsung.android.sm"
                    )
                )
                put(
                    "ONEPLUS",
                    Arrays.asList(
                        "com.oneplus.security/.chainlaunch.view.ChainLaunchAppListActivity",
                        "com.oneplus.security"
                    )
                )
                put(
                    "LETV",
                    Arrays.asList(
                        "com.letv.android.letvsafe/.AutobootManageActivity",
                        "com.letv.android.letvsafe/.BackgroundAppManageActivity",
                        "com.letv.android.letvsafe"
                    )
                )
                put(
                    "ZTE",
                    Arrays.asList(
                        "com.zte.heartyservice"
                    )
                )
                // 金立
                put(
                    "F",
                    Arrays.asList(
                        "com.gionee.softmanager/.MainActivity",
                        "com.gionee.softmanager"
                    )
                )
                // 以下为未确定(厂商名也不确定)
                put(
                    "SMARTISANOS",
                    Arrays.asList(
                        "com.smartisanos.security/.invokeHistory.InvokeHistoryActivity",
                        "com.smartisanos.security"
                    )
                )
                // 360
                put(
                    "360",
                    Arrays.asList(
                        "com.yulong.android.coolsafe"
                    )
                )
                // 360
                put(
                    "ULONG",
                    Arrays.asList(
                        "com.yulong.android.coolsafe"
                    )
                )
                // 酷派
                put(
                    "COOLPAD", /*厂商名称不确定是否正确*/
                    Arrays.asList(
                        "com.yulong.android.security/com.yulong.android.seccenter.tabbarmain",
                        "com.yulong.android.security"
                    )
                )
                // 联想
                put(
                    "LENOVO", /*厂商名称不确定是否正确*/
                    Arrays.asList(
                        "com.lenovo.security/.purebackground.PureBackgroundActivity",
                        "com.lenovo.security"
                    )
                )
                put(
                    "HTC", /*厂商名称不确定是否正确*/
                    Arrays.asList(
                        "com.htc.pitroad/.landingpage.activity.LandingPageActivity",
                        "com.htc.pitroad"
                    )
                )
                // 华硕
                put(
                    "ASUS", /*厂商名称不确定是否正确*/
                    Arrays.asList(
                        "com.asus.mobilemanager/.MainActivity",
                        "com.asus.mobilemanager"
                    )
                )
                // 酷派
                put(
                    "YULONG",
                    Arrays.asList(
                        "com.yulong.android.softmanager/.SpeedupActivity",
                        "com.yulong.android.security/com.yulong.android.seccenter.tabbarmain",
                        "com.yulong.android.security"
                    )
                )
            }
        }

    fun startToPermissionSetting(context: Context) {
        CallUILog.i(TAG, "Build.MANUFACTURER = " + Build.MANUFACTURER)
        val permissionMap: LinkedHashMap<String, List<String>> = bgPopHashMap

        if (!permissionMap.keys.contains(Build.MANUFACTURER.uppercase(Locale.ROOT))) {
            val intent: Intent = Intent(Settings.ACTION_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            return
        }

        for (entry in permissionMap.entries) {
            val manufacturer: String = entry.key.toString()
            val actCompatList: List<String> = entry.value
            if (Build.MANUFACTURER.equals(manufacturer, true)) {
                for (act in actCompatList) {
                    try {
                        var intent: Intent?
                        if (act.contains("/")) {
                            CallUILog.d(TAG, "act = $act")
                            intent = Intent()
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            val componentName: ComponentName? = ComponentName.unflattenFromString(
                                act
                            )
                            intent.setComponent(componentName)
                            intent.putExtra(
                                "packagename",
                                context.packageName
                            ) // vivo-SoftPermissionDetailActivity
                            intent.putExtra(
                                "extra_pkgname",
                                context.packageName
                            ) // xiaomi-PermissionsEditorActivity
                            intent.putExtra(
                                "package_name",
                                context.packageName
                            ) // xiaomi-ApplicationsDetailsActivity
                        } else {
                            // 所以我是直接跳转到对应的安全管家/安全中心
                            intent = context.packageManager.getLaunchIntentForPackage(act)
                        }
                        context.startActivity(intent)
                        break
                    } catch (e: java.lang.Exception) {
                        e.printStackTrace()
                        val intent: Intent = Intent(Settings.ACTION_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                    }
                }
            }
        }
    }
}
