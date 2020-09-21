package com.netease.yunxin.nertc.nertcvideocalldemo.model.impl;

import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCCallingDelegate;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * 收拢说有的Delegate
 */
public class NERTCInternalDelegateManager implements NERTCCallingDelegate {

    private List<WeakReference<NERTCCallingDelegate>> mWeakReferenceList;

    public NERTCInternalDelegateManager() {
        mWeakReferenceList = new ArrayList<>();
    }

    public void addDelegate(NERTCCallingDelegate listener) {
        WeakReference<NERTCCallingDelegate> listenerWeakReference = new WeakReference<>(listener);
        mWeakReferenceList.add(listenerWeakReference);
    }

    public void removeDelegate(NERTCCallingDelegate listener) {
        Iterator iterator = mWeakReferenceList.iterator();
        while (iterator.hasNext()) {
            WeakReference<NERTCCallingDelegate> reference = (WeakReference<NERTCCallingDelegate>) iterator.next();
            if (reference.get() == null) {
                iterator.remove();
                continue;
            }
            if (reference.get() == listener) {
                iterator.remove();
            }
        }
    }

    @Override
    public void onError(int errorCode, String errorMsg) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onError(errorCode, errorMsg);
            }
        }
    }

    @Override
    public void onInvitedByUser(InvitedEvent invitedEvent) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onInvitedByUser(invitedEvent);
            }
        }
    }


    @Override
    public void onUserEnter(long userId) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserEnter(userId);
            }
        }
    }


    @Override
    public void onUserHangup(long userId) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserHangup(userId);
            }
        }
    }

    @Override
    public void onRejectByUserId(String userId) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onRejectByUserId(userId);
            }
        }
    }

    @Override
    public void onUserBusy(String userId) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserBusy(userId);
            }
        }
    }

    @Override
    public void onCancelByUserId(String userId) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onCancelByUserId(userId);
            }
        }
    }

    @Override
    public void onCameraAvailable(long userId, boolean isVideoAvailable) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onCameraAvailable(userId, isVideoAvailable);
            }
        }
    }

    @Override
    public void onAudioAvailable(long userId, boolean isVideoAvailable) {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onAudioAvailable(userId, isVideoAvailable);
            }
        }
    }

    @Override
    public void timeOut() {
        for (WeakReference<NERTCCallingDelegate> reference : mWeakReferenceList) {
            NERTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.timeOut();
            }
        }
    }
}
