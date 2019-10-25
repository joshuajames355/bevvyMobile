package com.example.bevvymobile;


import android.content.Context;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.graphics.drawable.Drawable;
import 	android.view.LayoutInflater;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;

public class GooglePayButton implements PlatformView, MethodCallHandler  {
    private final MethodChannel methodChannel;
    private final View view;

    GooglePayButton(Context context, BinaryMessenger messenger, int id) {
        LayoutInflater inflater = LayoutInflater.from(context);
        view = inflater.inflate(R.layout.googlepay_button, null, false);
        methodChannel = new MethodChannel(messenger, "com.example.bevvymobile/GooglePayButton_" + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        result.notImplemented();
    }

    @Override
    public void dispose() {}
}