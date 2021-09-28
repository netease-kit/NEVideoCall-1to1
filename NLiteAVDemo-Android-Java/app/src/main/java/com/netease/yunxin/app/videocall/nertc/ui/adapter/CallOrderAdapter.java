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
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.nimlib.sdk.msg.attachment.NetCallAttachment;
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.login.model.UserModel;
import com.netease.yunxin.app.videocall.nertc.model.CallOrder;
import com.netease.yunxin.app.videocall.nertc.utils.TimeUtils;
import com.netease.yunxin.nertc.nertcvideocall.utils.NrtcCallStatus;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.base.CallParam;

import java.util.ArrayList;
import java.util.List;

/**
 * 话单adapter
 */
public class CallOrderAdapter extends RecyclerView.Adapter<CallOrderAdapter.ViewHolder> {

    private final List<CallOrder> orders;

    private final Context mContext;

    //创建ViewHolder
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public ImageView ivType;
        public TextView tvNickname;
        public TextView tvDuration;
        public TextView tvTime;

        public ViewHolder(View v) {
            super(v);
            ivType = v.findViewById(R.id.iv_type);
            tvNickname = v.findViewById(R.id.tv_nickname);
            tvDuration = v.findViewById(R.id.tv_duration);
            tvTime = v.findViewById(R.id.tv_time);
        }
    }

    public CallOrderAdapter(Context context) {
        this.mContext = context;
        orders = new ArrayList<>(3);
    }

    public void updateItem(List<CallOrder> orders) {
        this.orders.clear();
        this.orders.addAll(orders);
        notifyDataSetChanged();
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        CallOrder order = orders.get(position);
        UserModel currentUser = ProfileManager.getInstance().getUserModel();
        if (order != null) {
            holder.tvTime.setText(order.receivedTime);
            holder.tvNickname.setText(order.nickname);
            NetCallAttachment attachment = order.attachment;
            if (attachment.getStatus() == NrtcCallStatus.NrtcCallStatusComplete) {
                String textString = "";
                for (NetCallAttachment.Duration duration : attachment.getDurations()) {
                    if (TextUtils.equals(duration.getAccid(), currentUser.imAccid)) {
                        textString = TimeUtils.secToTime(duration.getDuration());
                    }
                }
                holder.tvDuration.setText("\t" + textString);
                holder.tvNickname.setTextColor(mContext.getResources().getColor(R.color.white));
                holder.tvTime.setTextColor(mContext.getResources().getColor(R.color.white));
                holder.tvDuration.setTextColor(mContext.getResources().getColor(R.color.white));
                if (order.direction == MsgDirectionEnum.In) {
                    if (attachment.getType() == ChannelType.AUDIO.getValue()) {
                        Glide.with(mContext).load(R.drawable.audio_in_normal).into(holder.ivType);
                    } else if (attachment.getType() == ChannelType.VIDEO.getValue()) {
                        Glide.with(mContext).load(R.drawable.video_in_normal).into(holder.ivType);
                    }
                } else {
                    if (attachment.getType() == ChannelType.AUDIO.getValue()) {
                        Glide.with(mContext).load(R.drawable.audio_out_normal).into(holder.ivType);
                    } else if (attachment.getType() == ChannelType.VIDEO.getValue()) {
                        Glide.with(mContext).load(R.drawable.video_out_normal).into(holder.ivType);
                    }
                }
            } else {
                holder.tvNickname.setTextColor(mContext.getResources().getColor(R.color.red));
                holder.tvTime.setTextColor(mContext.getResources().getColor(R.color.red));
                holder.tvDuration.setText("");
                if (order.direction == MsgDirectionEnum.In) {
                    if (attachment.getType() == ChannelType.AUDIO.getValue()) {
                        Glide.with(mContext).load(R.drawable.audio_in_failed).into(holder.ivType);
                    } else if (attachment.getType() == ChannelType.VIDEO.getValue()) {
                        Glide.with(mContext).load(R.drawable.video_in_failed).into(holder.ivType);
                    }
                } else {
                    if (attachment.getType() == ChannelType.AUDIO.getValue()) {
                        Glide.with(mContext).load(R.drawable.audio_out_failed).into(holder.ivType);
                    } else if (attachment.getType() == ChannelType.VIDEO.getValue()) {
                        Glide.with(mContext).load(R.drawable.video_out_failed).into(holder.ivType);
                    }
                }
            }

            holder.itemView.setOnClickListener(view -> {
                if (currentUser == null || TextUtils.isEmpty(currentUser.imAccid)) {
                    Toast.makeText(mContext, "当前用户登录存在问题，请注销后重新登录", Toast.LENGTH_SHORT).show();
                    return;
                }

                if (NetworkUtils.isConnected()) {
                    CallKitUI.startSingleCall(mContext,
                            CallParam.createSingleCallParam(ChannelType.VIDEO.getValue(), currentUser.imAccid, order.sessionId));
                } else {
                    ToastUtils.showShort(R.string.network_connect_error_please_try_again);
                }
            });

        }
    }

    @Override
    public int getItemCount() {
        return orders == null ? 0 : orders.size();
    }


    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.call_order_item_layout, parent, false);
        return new ViewHolder(v);
    }
}
