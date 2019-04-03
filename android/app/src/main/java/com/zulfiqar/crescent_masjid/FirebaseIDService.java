package com.zulfiqar.crescent_masjid;

import android.util.Log;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;


public class FirebaseIDService extends FirebaseInstanceIdService {
    private static final String TAG = "FirebaseIDService";

    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + refreshedToken);

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.
        sendRegistrationToServer(refreshedToken);
    }

    private void sendRegistrationToServer(String token) {

        StringRequest stringRequest = new StringRequest(Request.Method.GET, "https://damp-castle-75017.herokuapp.com/register?token="+token, new com.android.volley.Response.Listener<String>() {

            @Override
            public void onResponse(String response) {

//                TastyToast.makeText(getApplicationContext() , "" +response,Toast.LENGTH_LONG,TastyToast.SUCCESS).show();
            }

        }
                ,
                new com.android.volley.Response.ErrorListener(){

                    @Override
                    public void onErrorResponse(VolleyError error) {

//                        TastyToast.makeText(getApplicationContext() , "" +error,Toast.LENGTH_LONG,TastyToast.ERROR).show();
                    }

                });

        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
        requestQueue.add(stringRequest);
    }
}