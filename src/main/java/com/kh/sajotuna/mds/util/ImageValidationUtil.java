package com.kh.sajotuna.mds.util;

import java.io.IOException;
import java.io.InputStream;

import org.springframework.web.multipart.MultipartFile;

// 업로드된 이미지가 실제로 JPG/PNG/WEBP인지 파일 시그니처(매직 바이트)로 확인.
// Content-Type 헤더는 요청자가 임의로 조작해서 보낼 수 있어 신뢰할 수 없으므로,
// 실제 파일의 앞부분 바이트를 읽어 형식별 고정 시그니처와 일치하는지 직접 확인한다.
public class ImageValidationUtil {

	private static final int HEADER_SIZE = 12;

	private ImageValidationUtil() {}

	// file이 null/빈 파일이면 검사 대상이 아니므로 true(필수 여부는 호출부에서 별도 검사)
	public static boolean isAllowedImage(MultipartFile file) {
		if (file == null || file.isEmpty()) {
			return true;
		}

		byte[] header = new byte[HEADER_SIZE];
		try (InputStream in = file.getInputStream()) {
			if (in.readNBytes(header, 0, HEADER_SIZE) < HEADER_SIZE) {
				return false;
			}
		} catch (IOException e) {
			return false;
		}

		return isJpeg(header) || isPng(header) || isWebp(header);
	}

	private static boolean isJpeg(byte[] h) {
		return unsigned(h[0]) == 0xFF && unsigned(h[1]) == 0xD8 && unsigned(h[2]) == 0xFF;
	}

	private static boolean isPng(byte[] h) {
		return unsigned(h[0]) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G';
	}

	// WEBP는 컨테이너 포맷(RIFF)이라 앞 4바이트("RIFF") + 파일 크기(4바이트) + "WEBP" 순서로 구성됨
	private static boolean isWebp(byte[] h) {
		return h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
				&& h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P';
	}

	private static int unsigned(byte b) {
		return b & 0xFF;
	}
}
