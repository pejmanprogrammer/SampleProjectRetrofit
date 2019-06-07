package com.example.pejman.myapplication;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class ActivityMain extends AppCompatActivity {



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        MyApp.getApiKey().getPost().enqueue(new Callback<List<Posts>>() {
            @Override
            public void onResponse(Call<List<Posts>> call, Response<List<Posts>> response) {

                List<Posts> posts = response.body();

                Posts p = posts.get(50);


                Log.i("Log" , "P --->" + p.getBody());
            }

            @Override
            public void onFailure(Call<List<Posts>> call, Throwable t) {



            }
        });





    }
}
