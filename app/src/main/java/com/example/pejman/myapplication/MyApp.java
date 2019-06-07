package com.example.pejman.myapplication;

import android.app.Application;

import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class MyApp extends Application {

    private static ApiKey apiKey;

    @Override
    public void onCreate() {
        super.onCreate();

        setretrofit();

    }

    private void  setretrofit()
    {

        Retrofit retrofit =new  Retrofit.Builder()
                .addConverterFactory(GsonConverterFactory.create())
                .baseUrl("https://jsonplaceholder.typicode.com/")
                .build();

        apiKey = retrofit.create(ApiKey.class);

    }

    public static ApiKey getApiKey() {
        return apiKey;
    }


}
