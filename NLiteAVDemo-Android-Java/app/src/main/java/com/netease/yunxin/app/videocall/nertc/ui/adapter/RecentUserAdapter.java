// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.model.LoginModel;

import java.util.ArrayList;
import java.util.List;

public class RecentUserAdapter extends RecyclerView.Adapter<RecentUserAdapter.ViewHolder> {

  private final List<LoginModel> mUsers = new ArrayList<>();

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

  public void updateUsers(List<LoginModel> users) {
    if (users == null) {
      return;
    }
    this.mUsers.clear();
    mUsers.addAll(users);
    notifyDataSetChanged();
  }

  public void updateItem(LoginModel user) {
    if (user == null) {
      return;
    }
    this.mUsers.clear();
    mUsers.add(user);
    notifyDataSetChanged();
  }

  @Override
  public void onBindViewHolder(ViewHolder holder, int position) {
    LoginModel searchedUser = mUsers.get(position);
    holder.tvNickname.setText(mUsers.get(position).mobile);
    Glide.with(mContext)
        .load(mUsers.get(position).avatar)
        .apply(RequestOptions.bitmapTransform(new RoundedCorners(7)))
        .into(holder.ivUser);
    if (stateListener != null) {
      int state = stateListener.onItemState(searchedUser);
      switch (state) {
        case ItemStateListener.ADD:
          holder.tvCall.setText(R.string.add);
          holder.tvCall.setBackgroundResource(R.drawable.shape_select_to_add_bg);
          break;
        case ItemStateListener.REMOVE:
          holder.tvCall.setText(R.string.remove);
          holder.tvCall.setBackgroundResource(R.drawable.btn_call_bg);
          break;
        case ItemStateListener.CONNECTION:
          holder.tvCall.setText(R.string.connection);
          holder.tvCall.setBackgroundResource(R.drawable.btn_call_bg);
          break;
      }
    }
    holder.itemView.setOnClickListener(
        view -> {
          if (clickItemListener != null) {
            clickItemListener.onClick(searchedUser);
          }
        });
  }

  @Override
  public int getItemCount() {
    return mUsers.size();
  }

  private ClickItemListener clickItemListener;

  public void setItemClickListener(ClickItemListener clickListener) {
    this.clickItemListener = clickListener;
  }

  private ItemStateListener stateListener;

  public void setItemStateListener(ItemStateListener stateListener) {
    this.stateListener = stateListener;
  }

  @Override
  public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
    View v =
        LayoutInflater.from(parent.getContext()).inflate(R.layout.user_item_layout, parent, false);
    return new ViewHolder(v);
  }
}
