// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.model.LoginModel;
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ToBeCallUserAdapter extends RecyclerView.Adapter<ToBeCallUserAdapter.ViewHolder> {
  private static final int LAYOUT_ID = R.layout.user_to_be_call_layout;

  private final List<LoginModel> userModelList = new ArrayList<>();
  private final Context context;
  private ClickItemListener clickItemListener;

  public ToBeCallUserAdapter(Context context) {
    this.context = context;
  }

  public boolean contains(String accId) {
    boolean contains = false;
    for (LoginModel item : userModelList) {
      if (item == null) {
        continue;
      }
      if (TextUtils.equals(accId, item.imAccid)) {
        contains = true;
        break;
      }
    }
    return contains;
  }

  @NonNull
  @Override
  public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    return new ViewHolder(LayoutInflater.from(context).inflate(LAYOUT_ID, parent, false));
  }

  @Override
  public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
    LoginModel model = getItem(position);
    if (model == null) {
      return;
    }
    Glide.with(context)
        .load(model.avatar)
        .apply(RequestOptions.bitmapTransform(new RoundedCornersCenterCrop(4)))
        .into(holder.ivUser);
    holder.itemView.setOnClickListener(
        v -> {
          if (clickItemListener != null) {
            clickItemListener.onClick(model);
          }
        });
  }

  public void add(LoginModel data) {
    userModelList.add(data);
    notifyDataSetChanged();
  }

  public void remove(LoginModel data) {
    Iterator<LoginModel> iterator = userModelList.iterator();
    while (iterator.hasNext()) {
      LoginModel item = iterator.next();
      if (item == null) {
        continue;
      }
      if (TextUtils.equals(data.imAccid, item.imAccid)) {
        iterator.remove();
        break;
      }
    }
    notifyDataSetChanged();
  }

  public LoginModel getItem(int position) {
    if (position >= userModelList.size() || position < 0) {
      return null;
    }
    return userModelList.get(position);
  }

  @Override
  public int getItemCount() {
    return userModelList.size();
  }

  public List<String> getTotalAccIds() {
    ArrayList<String> accIdList = new ArrayList<>();
    for (LoginModel item : userModelList) {
      if (item == null) {
        continue;
      }
      accIdList.add(item.imAccid);
    }
    return accIdList;
  }

  public void setClickItemListener(ClickItemListener clickItemListener) {
    this.clickItemListener = clickItemListener;
  }

  //创建ViewHolder
  public static class ViewHolder extends RecyclerView.ViewHolder {
    public ImageView ivUser;

    public ViewHolder(View v) {
      super(v);
      ivUser = v.findViewById(R.id.iv_user);
    }
  }
}
