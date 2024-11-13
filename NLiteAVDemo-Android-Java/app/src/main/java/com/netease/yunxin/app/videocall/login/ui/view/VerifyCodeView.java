package com.netease.yunxin.app.videocall.login.ui.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.netease.yunxin.app.videocall.R;


public class VerifyCodeView extends LinearLayout implements TextWatcher, View.OnKeyListener, View.OnFocusChangeListener {

    private final Context mContext;
    /**
     * 输入框数量
     */
    private final int mEtNumber;

    /**
     * 输入框的宽度
     */
    private final int mEtWidth;

    /**
     * 文字颜色
     */
    private final int mEtTextColor;

    /**
     * 文字大小
     */
    private final float mEtTextSize;

    /**
     * 输入框背景
     */
    private final int mEtTextBg;

    /**
     * 输入框间距
     */
    private int mEtSpacing;

    /**
     * 判断是否平分
     */
    private final boolean isBisect;

    /**
     * 是否显示光标
     */
    private final boolean cursorVisible;

    /**
     * 输入框宽度
     */
    private int mViewWidth;

    public VerifyCodeView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mContext = context;
        //获取自定义属性的值
        TypedArray typedArray = null;
        try {
             typedArray = context.obtainStyledAttributes(attrs, R.styleable.vericationCodeView);
            mEtNumber = typedArray.getInteger(R.styleable.vericationCodeView_vcv_et_number, 4);
            mEtWidth = typedArray.getDimensionPixelSize(R.styleable.vericationCodeView_vcv_et_width, 120);
            mEtTextColor = typedArray.getColor(R.styleable.vericationCodeView_vcv_et_text_color, Color.BLACK);
            mEtTextSize = typedArray.getDimensionPixelSize(R.styleable.vericationCodeView_vcv_et_text_size, 16);
            mEtTextBg = typedArray.getResourceId(R.styleable.vericationCodeView_vcv_et_bg, R.drawable.et_login_code);
            cursorVisible = typedArray.getBoolean(R.styleable.vericationCodeView_vcv_et_cursor_visible, true);

            isBisect = typedArray.hasValue(R.styleable.vericationCodeView_vcv_et_spacing);
            if (isBisect) {
                mEtSpacing = typedArray.getDimensionPixelSize(R.styleable.vericationCodeView_vcv_et_spacing, 0);
            }
            initView();
        }finally {
            //释放资源
            if (typedArray!=null){
                typedArray.recycle();
            }
        }
    }

    @SuppressLint("ResourceAsColor")
    private void initView() {
        for (int i = 0; i < mEtNumber; i++) {
            EditText editText = new EditText(mContext);
            initEditText(editText, i);
            addView(editText);
            //设置第一个editText获取焦点
            if (i == 0) {
                editText.setFocusable(true);
            }
        }
    }

    private void initEditText(EditText editText, int i) {
        editText.setLayoutParams(getETLayoutParams(i));
        editText.setTextAlignment(TextView.TEXT_ALIGNMENT_CENTER);
        editText.setGravity(Gravity.CENTER);
        editText.setId(i);
        editText.setCursorVisible(false);
        editText.setMaxEms(1);
        editText.setTextColor(mEtTextColor);
        editText.setTextSize(TypedValue.COMPLEX_UNIT_PX, mEtTextSize);
        editText.setCursorVisible(cursorVisible);
        editText.setMaxLines(1);
        editText.setFilters(new InputFilter[]{new InputFilter.LengthFilter(1)});
        editText.setInputType(InputType.TYPE_CLASS_NUMBER);
        editText.setPadding(0, 0, 0, 0);
        editText.setOnKeyListener(this);
        editText.setBackgroundResource(mEtTextBg);
        editText.addTextChangedListener(this);
        editText.setOnKeyListener(this);
        editText.setOnFocusChangeListener(this);
    }

    /**
     * 获取EditText 的 LayoutParams
     */
    public LayoutParams getETLayoutParams(int i) {
        LayoutParams layoutParams = new LayoutParams(mEtWidth, mEtWidth);
        if (!isBisect) {
            //平分Margin，把第一个EditText跟最后一个EditText的间距同设为平分
            int mEtBisectSpacing = (mViewWidth - mEtNumber * mEtWidth) / (mEtNumber + 1);
            if (i == 0) {
                layoutParams.leftMargin = mEtBisectSpacing;
                layoutParams.rightMargin = mEtBisectSpacing / 2;
            } else if (i == mEtNumber - 1) {
                layoutParams.leftMargin = mEtBisectSpacing / 2;
                layoutParams.rightMargin = mEtBisectSpacing;
            } else {
                layoutParams.leftMargin = mEtBisectSpacing / 2;
                layoutParams.rightMargin = mEtBisectSpacing / 2;
            }
        } else {
            layoutParams.leftMargin = mEtSpacing / 2;
            layoutParams.rightMargin = mEtSpacing / 2;
        }

        layoutParams.gravity = Gravity.CENTER;
        return layoutParams;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        mViewWidth = getMeasuredWidth();
        updateETMargin();
    }

    private void updateETMargin() {
        for (int i = 0; i < mEtNumber; i++) {
            EditText editText = (EditText) getChildAt(i);
            editText.setLayoutParams(getETLayoutParams(i));
        }
    }


    @Override
    public void onFocusChange(View view, boolean b) {
        if (b) {
            focus();
        }
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {

    }

    @Override
    public void afterTextChanged(Editable s) {
        if (s.length() != 0) {
            focus();
        }
    }

    @Override
    public boolean onKey(View v, int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_DEL && event.getAction() == KeyEvent.ACTION_DOWN) {
            backFocus();
        }
        return false;
    }

    @Override
    public void setEnabled(boolean enabled) {
        int childCount = getChildCount();
        for (int i = 0; i < childCount; i++) {
            View child = getChildAt(i);
            child.setEnabled(enabled);
        }
    }

    /**
     * 获取焦点
     */
    private void focus() {
        int count = getChildCount();
        EditText editText;
        //利用for循环找出还最前面那个还没被输入字符的EditText，并把焦点移交给它。
        for (int i = 0; i < count; i++) {
            editText = (EditText) getChildAt(i);
            if (editText.getText().length() < 1) {
                editText.setCursorVisible(cursorVisible);
                editText.requestFocus();
                return;
            } else {
                editText.setCursorVisible(false);
                if (i == count - 1) {
                    editText.requestFocus();
                }
            }
        }
    }

    private void backFocus() {
        EditText editText;
        //循环检测有字符的`editText`，把其置空，并获取焦点。
        for (int i = mEtNumber - 1; i >= 0; i--) {
            editText = (EditText) getChildAt(i);
            if (editText.getText().length() >= 1) {
                editText.setText("");
                editText.setCursorVisible(cursorVisible);
                editText.requestFocus();
                return;
            }
        }
    }

    public String getResult() {
        StringBuilder stringBuffer = new StringBuilder();
        EditText editText;
        for (int i = 0; i < mEtNumber; i++) {
            editText = (EditText) getChildAt(i);
            stringBuffer.append(editText.getText());
        }
        return stringBuffer.toString();
    }
}
