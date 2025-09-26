/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.service

class UIServiceManager private constructor() {

    var uiService: UIService? = null

    companion object {
        private val uiServiceManager = UIServiceManager()

        @JvmStatic
        fun getInstance(): UIServiceManager {
            return uiServiceManager
        }
    }
}
