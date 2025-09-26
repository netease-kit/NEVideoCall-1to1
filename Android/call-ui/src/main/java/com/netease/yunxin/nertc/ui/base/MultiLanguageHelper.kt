/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.app.Application
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import androidx.appcompat.view.ContextThemeWrapper
import com.netease.yunxin.nertc.ui.R
import java.util.Locale

object MultiLanguageHelper {

    var currentLanguage: String = Locale.getDefault().language

    fun changeContextLocale(context: Context): Context {
        return changeLanguage(context, currentLanguage)
    }

    fun changeLanguage(context: Context, language: String): Context {
        var ctx = context
        currentLanguage = language
        val locale: Locale = getLocale(language)
        Locale.setDefault(locale)

        // 在非application切换语言同时切换掉applicant
        if (ctx !is Application) {
            val appContext = ctx.applicationContext
            updateConfiguration(appContext, locale, language)
        }
        ctx = updateConfiguration(context, locale, language)
        val configuration = context.resources.configuration
        // 兼容appcompat 1.2.0后切换语言失效问题
        return object : ContextThemeWrapper(ctx, R.style.Base_Theme_AppCompat_Empty) {
            override fun applyOverrideConfiguration(overrideConfiguration: Configuration?) {
                overrideConfiguration?.setTo(configuration)
                super.applyOverrideConfiguration(overrideConfiguration)
            }
        }
    }

    private fun updateConfiguration(context: Context, locale: Locale, language: String): Context {
        var ctx = context
        val resources = ctx.resources
        val configuration = resources.configuration
        val displayMetrics = resources.displayMetrics
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.setLocale(locale)
            ctx = ctx.createConfigurationContext(configuration)
        } else {
            configuration.locale = locale
        }
        resources.updateConfiguration(configuration, displayMetrics)
        ctx.getSharedPreferences("multi_language", Context.MODE_PRIVATE)
            .edit()
            .putString("language_type", language)
            .apply()
        return ctx
    }

    private fun getLocale(language: String): Locale {
        when (language) {
            // 跟随系统
            LanguageType.LANGUAGE_SYSTEM -> return getLocalWithVersion(
                Resources.getSystem().configuration
            )
            // 英文
            LanguageType.LANGUAGE_EN -> return Locale.US
            // 简体中文
            LanguageType.LANGUAGE_ZH_CN -> return Locale.SIMPLIFIED_CHINESE
        }
        return getLocalWithVersion(Resources.getSystem().configuration)
    }

    private fun getLocalWithVersion(configuration: Configuration): Locale {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.locales[0]
        } else {
            configuration.locale
        }
    }
}

internal object LanguageType {
    // 跟随系统
    const val LANGUAGE_SYSTEM = "system"

    // 英语
    const val LANGUAGE_EN = "en"

    // 简体中文
    const val LANGUAGE_ZH_CN = "zh-Hans"
}
