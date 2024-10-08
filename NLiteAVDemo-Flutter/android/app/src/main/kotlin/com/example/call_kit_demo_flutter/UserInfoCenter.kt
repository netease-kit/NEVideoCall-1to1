package com.example.call_kit_demo_flutter

/**
 * 记录用户accId 对应 头像和昵称
 */
object UserInfoCenter {
    private val nameMap = mutableMapOf<String, String>()

    private val avatarMap = mutableMapOf<String, String>()

    fun getName(account: String): String? {
        return nameMap[account]
    }

    fun getAvatar(account: String): String? {
        return avatarMap[account]
    }


    fun updateNames(nameMap: Map<String, String>?) {
        nameMap?.run {
            this@UserInfoCenter.nameMap.putAll(this)
        }
    }

    fun updateAvatars(avatarMap: Map<String, String>?) {
        avatarMap?.run {
            this@UserInfoCenter.avatarMap.putAll(this)
        }
    }

    fun clear() {
        nameMap.clear()
        avatarMap.clear()
    }
}