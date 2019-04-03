package com.zulfiqar.crescent_masjid;
import android.app.NotificationManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.widget.Toast;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MyService extends FirebaseMessagingService {

    private static final String TAG = "FirebaseMsgService";

    public MyService() {
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

//        Log.d(TAG, "From: " + remoteMessage.getFrom());

        if (remoteMessage.getNotification() != null) {
//            Log.d(TAG, "Notification Title: " +
//                    remoteMessage.getNotification().getTitle());
//
//            Log.d(TAG, "Notification Message: " +
//                    remoteMessage.getNotification().getBody());

//             setNotify(remoteMessage.getNotification().getTitle(),remoteMessage.getNotification().getBody());
        }

//        if (remoteMessage.getData().size() > 0) {
//            Log.d(TAG, "Message data payload: " +
//                    remoteMessage.getData().get("MyKey1"));
//        }
    }

    private void setNotify(String title, String body) {


    }
}
