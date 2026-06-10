package com.newsread;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
@MapperScan("com.newsread.mapper")
public class NewsReadServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(NewsReadServerApplication.class, args);
    }
}