package com.kh.sajotuna.mds.util.config;

import java.io.File;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.kh.sajotuna.mds.util.interceptor.LoginInterceptor;

@Configuration
public class WebConfig implements WebMvcConfigurer{
	@Value("${file.upload-dir}")
	private String uploadDir;
	
	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		
		// 파일 절대 경로 주입
		String absoluteDir = new File(uploadDir).getAbsolutePath();
		registry.addResourceHandler("/uploads/**")
				.addResourceLocations("file:" + absoluteDir + File.separator);
	}

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor(new LoginInterceptor())
			// 로그인 없이 접속 시도 시 로그인 요청
				.addPathPatterns("/member/myPage", "/member/usercouponView", "/member/wish", "/member/cart", "/member/userOrderDelivery");
	}

	
}
