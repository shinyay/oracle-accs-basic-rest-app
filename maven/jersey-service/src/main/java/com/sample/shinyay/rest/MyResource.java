package com.sample.shinyay.rest;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("myresource")
public class MyResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String getIt() {
        String host = System.getenv("HOSTNAME");
        String port = System.getenv("PORT");
        return "HOSTNAME:" + host + System.getProperty("line.separator") + "PORT:" + port;
    }
}