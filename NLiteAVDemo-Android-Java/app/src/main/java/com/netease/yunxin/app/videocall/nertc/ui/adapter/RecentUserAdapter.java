package com.netease.yunxin.app.videocall.nertc.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.NetworkUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.login.model.UserModel;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.base.CallParam;

import java.util.ArrayList;
import java.util.List;

public class RecentUserAdapter extends RecyclerView.Adapter<RecentUserAdapter.ViewHolder> {

    private final List<UserModel> mUsers = new ArrayList<>();

    private final Context mContext;

    //创建ViewHolder
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public ImageView ivUser;
        public TextView tvNickname;
        public TextView tvCall;

        public ViewHolder(View v) {
            super(v);
            ivUser = v.findViewById(R.id.iv_user);
            tvNickname = v.findViewById(R.id.tv_nickname);
            tvCall = v.findViewById(R.id.tv_call);
        }
    }

    public RecentUserAdapter(Context context) {
        this.mContext = context;
    }

    public void updateUsers(List<UserModel> users) {
        if (users == null) {
            return;
        }
        this.mUsers.clear();
        mUsers.addAll(users);
        notifyDataSetChanged();
    }

    public void updateItem(UserModel user) {
        if (user == null) {
            return;
        }
        this.mUsers.clear();
        mUsers.add(user);
        notifyDataSetChanged();
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (mUsers != null) {
            holder.tvNickname.setText(mUsers.get(position).mobile);
            Glide.with(mContext).load(mUsers.get(position).avatar).apply(RequestOptions.bitmapTransform(new RoundedCorners(7))).into(holder.ivUser);
            holder.itemView.setOnClickListener(view -> {
                UserModel currentUser = ProfileManager.getInstance().getUserModel();
                if (currentUser == null || TextUtils.isEmpty(currentUser.imAccid)) {
                    Toast.makeText(mContext, "当前用户登录存在问题，请注销后重新登录", Toast.LENGTH_SHORT).show();
                    return;
                }
                UserModel searchedUser = mUsers.get(position);
                if (currentUser.imAccid.equals(searchedUser.imAccid) || currentUser.mobile.equals(searchedUser.mobile)) {
                    Toast.makeText(mContext, "不能呼叫自己！", Toast.LENGTH_SHORT).show();
                    return;
                }
                if (NetworkUtils.isConnected()) {
                    CallKitUI.startSingleCall(mContext,
                            CallParam.createSingleCallParam(ChannelType.VIDEO.getValue(), currentUser.imAccid, searchedUser.imAccid));
                } else {
                    ToastUtils.showShort(R.string.network_connect_error_please_try_again);
                }
            });
        }
    }

    @Override
    public int getItemCount() {
        return mUsers.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.user_item_layout, parent, false);
        return new ViewHolder(v);
    }
}
