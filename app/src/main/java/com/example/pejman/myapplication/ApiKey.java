package com.example.pejman.myapplication;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.POST;

public interface ApiKey {

    @GET("posts")
    Call<List<Posts>> getPost();





}
