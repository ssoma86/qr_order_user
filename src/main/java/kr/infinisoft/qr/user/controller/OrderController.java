package kr.infinisoft.qr.user.controller;

import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import kr.infinisoft.common.constants.ViewConstants;
import kr.infinisoft.common.util.NumberUtil;

@Controller
public class OrderController {

	private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
	
	/**
	 * @Name : index
	 * @Description : 초기 화면
	 * @CreateDate : 2014. 4. 23.
	 * @Creator : NoteBook
	 * ------------------------------------------
	 *
	 * @return
	 * @throws Exception
	 */
	@GetMapping("/qr/{storeId}/{storeRoomCd}")
	public ModelAndView mainView(@PathVariable("storeId") String storeId, @PathVariable("storeRoomCd") String storeRoomCd) throws Exception{
		logger.info("====================== getStoreRoom start ======================");
		logger.info("storeId : " + storeId);
		logger.info("storeRoomCd : " + storeRoomCd);
		
		String body = "";
		int httpStatusCode = -1;
		JSONObject resultObj = new JSONObject();
		
		ModelAndView mav = new ModelAndView();
		
		try {
			CloseableHttpClient httpClient = HttpClients.createSystem();
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			//HttpGet httpGet = new HttpGet("http://10.10.10.16:8185/api/getStoreRoom/" + storeRoomCd); //로컬
			HttpGet httpGet = new HttpGet("https://admin.menuplus.kr/api/getStoreRoom/" + storeRoomCd); //운영
			//HttpGet httpGet = new HttpGet("http://54.180.64.84:8185/api/getStoreRoom/" + storeRoomCd); //로컬
			
			httpGet.setHeader("Content-Type", "application/json; charset=UTF-8");
			
			CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
			
			if(httpStatusCode == 200){
				resultObj = (JSONObject) new JSONParser().parse(body);
				mav.addObject("storeRoom", resultObj);
				mav.addObject("imgPath", "https://admin.menuplus.kr");
				//mav.addObject("imgPath", "http://localhost:8185");
				//mav.addObject("imgPath", "http://54.180.64.84:8185");
				mav.setViewName(ViewConstants.INDEX);
			}
			
		} catch(Exception e) {
			logger.error("getStoreRoom Error", e);
			mav.addObject("resultCode", "9999");
			mav.addObject("resultMsg", "요청에 실패했습니다. 잠시후 다시 시도해주세요.");
			mav.setViewName(ViewConstants.ERROR);
		}
		
		logger.debug("====================== getStoreRoom end ======================");
		return mav;
		
	}
	
	/**
	 * @Name : index
	 * @Description : 초기 화면
	 * @CreateDate : 2014. 4. 23.
	 * @Creator : NoteBook
	 * ------------------------------------------
	 *
	 * @return
	 * @throws Exception
	 */
	@GetMapping("/yajo/{storeId}/{storeRoomNm}")
	public ModelAndView mainViewYajo(@PathVariable("storeId") String storeId, @PathVariable("storeRoomNm") String storeRoomNm) throws Exception{
		logger.info("====================== getStoreRoom yajo start ======================");
		logger.info("storeId : " + storeId);
		logger.info("storeRoomNm : " + storeRoomNm);
		
		String body = "";
		int httpStatusCode = -1;
		JSONObject resultObj = new JSONObject();
		
		ModelAndView mav = new ModelAndView();
		
		try {
			CloseableHttpClient httpClient = HttpClients.createSystem();
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			//HttpGet httpGet = new HttpGet("http://10.10.10.16:8185/api/getStoreRoom/" + storeRoomCd); //로컬
			HttpGet httpGet = new HttpGet("https://admin.menuplus.kr/api/yajo/getStoreRoom/" + storeId + "/" + storeRoomNm); //운영
			//HttpGet httpGet = new HttpGet("http://54.180.64.84:8185/api/getStoreRoom/" + storeRoomCd); //로컬
			
			httpGet.setHeader("Content-Type", "application/json; charset=UTF-8");
			
			CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
			
			if(httpStatusCode == 200){
				resultObj = (JSONObject) new JSONParser().parse(body);
				mav.addObject("storeRoom", resultObj);
				mav.addObject("imgPath", "https://admin.menuplus.kr");
				//mav.addObject("imgPath", "http://localhost:8185");
				//mav.addObject("imgPath", "http://54.180.64.84:8185");
				mav.setViewName(ViewConstants.INDEX);
			}
			
		} catch(Exception e) {
			logger.error("getStoreRoom Error", e);
			mav.addObject("resultCode", "9999");
			mav.addObject("resultMsg", "요청에 실패했습니다. 잠시후 다시 시도해주세요.");
			mav.setViewName(ViewConstants.ERROR);
		}
		
		logger.debug("====================== getStoreRoom  yajo end ======================");
		return mav;
		
	}
	
	//장바구니 내역
	@PostMapping("/qr/showCart/{storeRoomCd}")
	public ModelAndView showCart(@PathVariable("storeRoomCd") String storeRoomCd, HttpServletRequest request) {
		logger.info("====================== showCart start ======================");
		logger.info("storeRoomCd : " + storeRoomCd);
		String cartCount = NumberUtil.setComma(request.getParameter("cartCount"));
		String totalPrice = NumberUtil.setComma(request.getParameter("totalPrice"));
		
		JSONObject resultObj = new JSONObject();
		JSONObject midObj = new JSONObject();
		List cartList = new ArrayList<JSONObject>();
		
		ModelAndView mav = new ModelAndView();
		
		try {
			logger.info("cartCount : " + cartCount);
			logger.info("totalPrice : " + totalPrice);
			
			for(int i = 0 ; i < request.getParameterValues("moid").length; i++) {
				logger.info("menuData : " + request.getParameter(request.getParameterValues("moid")[i]));
				
				resultObj = (JSONObject) new JSONParser().parse(request.getParameter(request.getParameterValues("moid")[i]).toString());
				cartList.add(resultObj);
			}
			
			CloseableHttpClient httpClient = HttpClients.createSystem();
			
			String body = "";
			int httpStatusCode = -1;
			
			//결제수단 조회
			HttpPost httppost = new HttpPost("https://admin.menuplus.kr/api/payMethod/" + storeRoomCd); //운영
			//HttpPost httppost = new HttpPost("http://54.180.64.84:8185/api/payMethod/" + storeRoomCd); //개발
			//HttpPost httppost = new HttpPost("http://10.10.10.14:8185/api/payMethod/" + storeRoomCd); //운영
			
			HttpResponse httpResponse = httpClient.execute(httppost);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			
			if(httpStatusCode != 200) {
				throw new Exception("midInfo Error httpStatus : " + httpStatusCode);
			} else {
				body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
				logger.info("midInfo :: {}", body.trim());
				
				midObj = (JSONObject) new JSONParser().parse(body.trim());
			}
			
			//객실정보 조회
			HttpGet httpGet = new HttpGet("https://admin.menuplus.kr/api/getStoreRoom/" + storeRoomCd); //운영
			
			httpResponse = httpClient.execute(httpGet);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			
			if(httpStatusCode != 200) {
				throw new Exception("midInfo Error httpStatus : " + httpStatusCode);
			} else {
				body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
				resultObj = (JSONObject) new JSONParser().parse(body.trim());
			}
			
			mav.addObject("storeRoom", resultObj);
			mav.addObject("cartList", cartList);
			mav.addObject("cartCount", cartCount);
			mav.addObject("totalPrice", totalPrice);
			mav.addObject("midInfo", midObj);
			
			mav.setViewName(ViewConstants.CART);
		} catch(Exception e) {
			logger.error("showCart Error", e);
			mav.addObject("resultCode", "9999");
			mav.addObject("resultMsg", "요청에 실패했습니다. 잠시후 다시 시도해주세요.");
			mav.setViewName(ViewConstants.ERROR);
		}
		
		
		logger.info("====================== showCart end ======================");
		return mav;
	}
	
	//결제결과
	@GetMapping("/qr/payResult/{storeId}/{storeRoomCd}")
	public ModelAndView payResult(@PathVariable("storeId") String storeId, @PathVariable("storeRoomCd") String storeRoomCd,
			HttpServletRequest request, HttpServletResponse response) {
		logger.info("====================== payResult start ======================");
		logger.info("storeId : " + storeId);
		logger.info("storeRoomCd : " + storeRoomCd);
		
		ModelAndView mav = new ModelAndView();
		
		try {
			JSONObject payObj = new JSONObject();
			JSONObject orderObj = new JSONObject();
			JSONObject storeObj = new JSONObject();
			
			
			//결과 파라미터 출력
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				Map entries = new TreeMap();
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					String[] values = request.getParameterValues(name);
					if (values.length > 0) {
						String value = values[0];
						for (int i = 1; i < values.length; i++) {
							value += "," + values[i];
						}
						payObj.put(name, value);
						logger.info(name + "[" + value +"]");
					}
				}
			}
			
			//객실정보 조회
			String body = "";
			int httpStatusCode = -1;
			
			CloseableHttpClient httpClient = HttpClients.createSystem();
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			//HttpGet httpGet = new HttpGet("http://10.10.10.16:8185/api/getStoreRoom/" + storeRoomCd); // 로컬
			HttpGet httpGet = new HttpGet("https://admin.menuplus.kr/api/getStoreRoom/" + storeRoomCd); //운영
			//HttpGet httpGet = new HttpGet("http://54.180.64.84:8185/api/getStoreRoom/" + storeRoomCd); //운영
			
			httpGet.setHeader("Content-Type", "application/json; charset=UTF-8");
			
			CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");

			if(httpStatusCode == 200){
				storeObj = (JSONObject) new JSONParser().parse(body);
				mav.addObject("storeRoom", storeObj);
			}
			
			//주문내역 추출(쿠키 조회)
			String cookieKey = request.getParameter("BuyerTel"); //쿠키 키값(구매자 전화번호)
			
			String orderData = getCookie(request, cookieKey); //쿠키값 조회
			orderObj = (JSONObject) new JSONParser().parse(unescape(orderData));
			logger.info("orderData : " + orderObj);
			mav.addObject("orderData", orderObj);
			
			String MallReserved = request.getParameter("MallReserved");
			String[] data = MallReserved.split("&");
			
			//orderId, storeId, shopName, roomName 추출
			for(String s : data) {
				mav.addObject(s.substring(0, s.indexOf("=")), s.substring(s.indexOf("=") + 1));
			}
			
			//결제결과 추출
			mav.addObject("payResult", payObj);
			logger.info("payResult : " + payObj.toString());
			
			
			String resultCode = request.getParameter("ResultCode");
			if(resultCode.equals("3001")) { //결제 성공	
				String orderId = request.getParameter("MOID");
				String TID = request.getParameter("TID");
				String svcCd = request.getParameter("PayMethod");
				String MID = request.getParameter("MID");
				String Amt = request.getParameter("Amt");
				
				if(svcCd.equals("CARD") || svcCd.equals("CKEYIN")) {
					svcCd = "01";
				} else if(svcCd.equals("EPAY")) {
					svcCd = "16";
				} else if(svcCd.equals("OPCARD")) {
					svcCd = "23";
				}
				//httpGet = new HttpGet("http://10.10.10.16:8185/api/innopay/" + orderId + "/" + storeId + "/" + TID + "/" + svcCd + "/" + MID); //로컬
				httpGet = new HttpGet("https://admin.menuplus.kr/api/innopay/" + orderId + "/" + storeId + "/" + TID + "/" + svcCd + "/" + MID); //운영
				//httpGet = new HttpGet("http://54.180.64.84:8185/api/innopay/" + orderId + "/" + storeId + "/" + TID + "/" + svcCd + "/" + MID); //운영
				
				httpResponse = httpClient.execute(httpGet);
				httpStatusCode = httpResponse.getStatusLine().getStatusCode();
				body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
				logger.info("innopay api response :: {}", body.trim());
				
				if(body.trim().equals("0000")) {
					logger.info("주문 처리 성공 moid [" + orderId + "], tid [" + TID + "]");
					mav.setViewName(ViewConstants.COMPLETE);
				} else {
					logger.info("주문 처리 실패 moid [" + orderId + "], tid [" + TID + "]");
					throw new Exception("주문처리 실패 : " + TID);
				}
				
			} else { //결제 실패
				mav.setViewName(ViewConstants.FAIL);
			}
			
			logger.info("====================== payResult end ======================");
			
			return mav;
		} catch (Exception e) {
			logger.error("payResult Error : " + e.getMessage());
			
			cancelApi(request, response); //망취소 호출
			
			mav.addObject("message", "systemError");
			mav.setViewName(ViewConstants.FAIL);
			
			return mav;
		}
	}
	
	//무료상품 결제결과
	@PostMapping("/qr/freePayResult/{storeId}/{storeRoomCd}")
	public ModelAndView freePayResult(@PathVariable("storeId") String storeId, @PathVariable("storeRoomCd") String storeRoomCd,
			HttpServletRequest request, HttpServletResponse response) {
		logger.info("====================== freePayResult start ======================");
		logger.info("storeId : " + storeId);
		logger.info("storeRoomCd : " + storeRoomCd);
		
		ModelAndView mav = new ModelAndView();
		String TID = null;
		try {
			JSONObject payObj = new JSONObject();
			JSONObject orderObj = new JSONObject();
			JSONObject storeObj = new JSONObject();
			
			
			//결과 파라미터 출력
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				Map entries = new TreeMap();
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					String[] values = request.getParameterValues(name);
					if (values.length > 0) {
						String value = values[0];
						for (int i = 1; i < values.length; i++) {
							value += "," + values[i];
						}
						payObj.put(name, value);
						logger.info(name + "[" + value +"]");
					}
				}
			}
			
			//객실정보 조회
			String body = "";
			int httpStatusCode = -1;
			
			CloseableHttpClient httpClient = HttpClients.createSystem();
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			//HttpGet httpGet = new HttpGet("http://10.10.10.16:8185/api/getStoreRoom/" + storeRoomCd); // 로컬
			HttpGet httpGet = new HttpGet("https://admin.menuplus.kr/api/getStoreRoom/" + storeRoomCd); //운영
			//HttpGet httpGet = new HttpGet("http://54.180.64.84:8185/api/getStoreRoom/" + storeRoomCd); //운영
			
			httpGet.setHeader("Content-Type", "application/json; charset=UTF-8");
			
			CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");

			if(httpStatusCode == 200){
				storeObj = (JSONObject) new JSONParser().parse(body);
				mav.addObject("storeRoom", storeObj);
			}
			
			//주문내역 추출(쿠키 조회)
			String cookieKey = request.getParameter("BuyerTel"); //쿠키 키값(구매자 전화번호)
			
			String orderData = getCookie(request, cookieKey); //쿠키값 조회
			orderObj = (JSONObject) new JSONParser().parse(unescape(orderData));
			logger.info("orderData : " + orderObj);
			mav.addObject("orderData", orderObj);
			
			String MallReserved = request.getParameter("MallReserved");
			String[] data = MallReserved.split("&");
			
			//orderId, storeId, shopName, roomName 추출
			for(String s : data) {
				mav.addObject(s.substring(0, s.indexOf("=")), s.substring(s.indexOf("=") + 1));
			}
			
			//결제결과 추출
			mav.addObject("payResult", payObj);
			logger.info("payResult : " + payObj.toString());
			
			String orderId = request.getParameter("Moid");
			String svcCd = "31";
			String MID = request.getParameter("MID");
			String Amt = request.getParameter("Amt");
			TID = genTID(MID, svcCd, "01");
			
			httpGet = new HttpGet("https://admin.menuplus.kr/api/innopay/" + orderId + "/" + storeId + "/" + TID + "/" + svcCd + "/" + MID); //운영
			
			httpResponse = httpClient.execute(httpGet);
			httpStatusCode = httpResponse.getStatusLine().getStatusCode();
			body = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
			logger.info("innopay api response :: {}", body.trim());
			
			if(body.trim().equals("0000")) {
				logger.info("주문 처리 성공 moid [" + orderId + "], tid [" + TID + "]");
				mav.setViewName(ViewConstants.COMPLETE);
			} else {
				logger.info("주문 처리 실패 moid [" + orderId + "], tid [" + TID + "]");
				throw new Exception("주문처리 실패 : " + TID);
			}
			
			logger.info("====================== freePayResult end ======================");
			
			return mav;
		} catch (Exception e) {
			logger.error("payResult Error : " + e.getMessage());
			
			freePayFail(TID);
			
			mav.addObject("message", "systemError");
			mav.setViewName(ViewConstants.FAIL);
			
			return mav;
		}
	}
	
	//주문내역
	@ResponseBody
	@PostMapping("/qr/showOrderList")
	public JSONObject showOrderList(@RequestBody Map<String, Object> data, HttpServletRequest request) {
		logger.info("====================== showOrderList start ======================");
		logger.info("data : " + data.toString());
		
		String buyerTel = data.get("buyerTel").toString();
		String storeCd = data.get("storeCd").toString();
		
		JSONObject resultObj = new JSONObject();
		String body = "";
		String html = "";
		int httpStatusCode = -1;
		
		try {
			CloseableHttpClient httpClient = HttpClients.createSystem();
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			//주문코드 조회
			//HttpPost httpPost = new HttpPost("http://10.10.10.16:8185/api/getOrderCd/" + buyerTel + "/" + storeCd); // 로컬
			HttpPost httpPost = new HttpPost("https://admin.menuplus.kr/api/getOrderCd/" + buyerTel + "/" + storeCd); //운영
			//HttpPost httpPost = new HttpPost("http://54.180.64.84:8185/api/getOrderCd/" + buyerTel + "/" + storeCd); //운영

			httpPost.setHeader("Content-Type", "application/x-www-form-urlencoded;");
			httpPost.setEntity(new StringEntity(buyerTel));
			
			CloseableHttpResponse response = httpClient.execute(httpPost);
			httpStatusCode = response.getStatusLine().getStatusCode();
			body = responseHandler.handleResponse(response);
			body = URLDecoder.decode(body,"utf-8");
			body = body.replace("[", "").replace("]", "").replace("\"", "");
			logger.info("orderCd : " + body);
			
			//주문상태 조회
			ArrayList orderList = new ArrayList();
			JSONObject orderObj = new JSONObject();
			
			for(String OrderCdList : body.split(",")) {
				//HttpGet httpGet = new HttpGet("http://10.10.10.16:8185/api/getOrderStatus/" + OrderCdList); //로컬
				HttpGet httpGet = new HttpGet("https://admin.menuplus.kr/api/getOrderStatus/" + OrderCdList); //운영
				//HttpGet httpGet = new HttpGet("http://54.180.64.84:8185/api/getOrderStatus/" + OrderCdList); //운영
				httpGet.setHeader("Content-Type", "application/json; charset=UTF-8");
				response = httpClient.execute(httpGet);
				httpStatusCode = response.getStatusLine().getStatusCode();
				body = EntityUtils.toString(response.getEntity(), "UTF-8");
				orderObj = (JSONObject) new JSONParser().parse(body);
				logger.info(orderObj.toJSONString());
				
				orderList.add(orderObj);
			}
			
			if(httpStatusCode == 200) { //주문내역 존재
				resultObj.put("message", "match");
				resultObj.put("result", "0000");
				resultObj.put("orderList", orderList);
			} else { //주문내역 미존재
				resultObj.put("message", "Not match");
				resultObj.put("result", "0001");
				resultObj.put("orderList", null);
			}
			
			logger.info("httpStatusCode : " + httpStatusCode);
			logger.info(resultObj.get("message").toString());
			
			logger.info("====================== showOrderList end ======================");
			
			return resultObj;
		} catch(Exception e) {
			resultObj.put("message", "error");
			resultObj.put("result", "9999");
			resultObj.put("orderList", null);
			logger.error(resultObj.get("message").toString());
			logger.error("showOrderList Error : " + e.getMessage());
			return resultObj;
		}
		
	}
	
	
	//쿠키셋팅
	@ResponseBody
	@PostMapping("/qr/addCookie")
	public Cookie addCookie(HttpServletRequest request, HttpServletResponse response) throws Exception{
		logger.info("====================== addCookie start ======================");
		String cookieKey = request.getParameter("cookieKey");
		String cookieValue = request.getParameter("cookieValue");
		
		logger.info("cookieKey : " + cookieKey);
		logger.info("cookieValue : " + cookieValue);
			
		try {
			//쿠키 생성
			cookieValue = URLEncoder.encode(cookieValue, "utf-8");
			Cookie orderData = new Cookie(cookieKey, cookieValue);
			orderData.setHttpOnly(true);
			orderData.setPath("/qr/");
			
			//쿠키 제한시간 설정
			orderData.setMaxAge(60*60*48); //48시간
			
			//응답헤더에 쿠키 추가
			response.addCookie(orderData);
			
			//응답헤더 인코딩 및 Content-Type 설정
			response.setCharacterEncoding("utf-8");
			response.setContentType("application/json");
			response.setHeader("Set-Cookie", URLEncoder.encode(orderData.toString(), "UTF-8"));
				
			return orderData;
		} catch (Exception e) {
			logger.error("addCookie Error : " + e.getMessage());
			return null;
		} finally {
			logger.info("====================== addCookie end ======================");			
		}
	}
	
	//쿠키조회
	public static String getCookie(HttpServletRequest req, String cookieKey){
	    Cookie[] cookies=req.getCookies(); // 모든 쿠키 가져오기
	    if(cookies!=null){
	        for (Cookie c : cookies) {
	            String name = c.getName(); // 쿠키 이름 가져오기
	            String value = c.getValue(); // 쿠키 값 가져오기
	            if (name.equals(cookieKey)) {
	                return value;
	            }
	        }
	    }
	    return null;
	}

	public static String unescape(String src) {
		StringBuffer tmp = new StringBuffer();
		tmp.ensureCapacity(src.length());
		int lastPos = 0, pos = 0;
		char ch;
		while (lastPos < src.length()) {
			pos = src.indexOf("%", lastPos);
			if (pos == lastPos) {
				if (src.charAt(pos + 1) == 'u') {
					ch = (char) Integer.parseInt(src.substring(pos + 2, pos + 6), 16);
					tmp.append(ch);
					lastPos = pos + 6;
				} else {
					ch = (char) Integer.parseInt(src.substring(pos + 1, pos + 3), 16);
					tmp.append(ch);
					lastPos = pos + 3;
				}
			} else {
				if (pos == -1) {
					tmp.append(src.substring(lastPos));
					lastPos = src.length();
				} else {
					tmp.append(src.substring(lastPos, pos));
					lastPos = pos;
				}
			}
		}
		return tmp.toString();
	}
	
	public static void deleteCookie(HttpServletResponse res, String cookieKey){
	    Cookie cookie = new Cookie(cookieKey, null); // 삭제할 쿠키에 대한 값을 null로 지정
	    cookie.setMaxAge(0); // 유효시간을 0으로 설정해서 바로 만료시킨다.
	    res.addCookie(cookie); // 응답에 추가해서 없어지도록 함
	}
	
	public static JSONObject cancelApi(HttpServletRequest request, HttpServletResponse response) {
		
		logger.info("====================== cancelApi start ======================");
		
		String body = "";
		String TID = request.getParameter("TID");
		String svcCd = request.getParameter("PayMethod");
		String MID = request.getParameter("MID");
		String Amt = request.getParameter("Amt");
		
		if(svcCd.equals("CARD") || svcCd.equals("CKEYIN")) {
			svcCd = "01";
		} else if(svcCd.equals("EPAY")) {
			svcCd = "16";
		}
		
		JSONObject cancelObj = new JSONObject(); //취소 데이터
		JSONObject cancelResult = new JSONObject(); //취소 결과
		
		cancelObj.put("mid", MID);
		cancelObj.put("tid", TID);
		cancelObj.put("svcCd", svcCd);
		cancelObj.put("forceCancelCode", "1"); //강제취소
		cancelObj.put("partialCancelCode", "0"); //전체취소
		cancelObj.put("cancelAmt", Amt);
		cancelObj.put("cancelMsg", "Menuplus Net Cancel");
		cancelObj.put("cancelPwd", "000000");
		
		try {
			StringEntity postData = new StringEntity(JSONObject.toJSONString(cancelObj), "utf-8");
			HttpPost httpPost = new HttpPost("https://api.innopay.co.kr/api/cancelApi");
			httpPost.setHeader("Content-type", "application/json");
			httpPost.setEntity(postData);
			
			CloseableHttpClient httpClient = HttpClients.createSystem();
			
			CloseableHttpResponse httpResponse;
			httpResponse = httpClient.execute(httpPost);
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			body = responseHandler.handleResponse(httpResponse);
			body = URLDecoder.decode(body,"utf-8");
			
			cancelResult = (JSONObject) new JSONParser().parse(body);
			logger.info("cancelResult : " + cancelResult);
			
			if(cancelResult.get("resultCode").equals("2001")) { //취소 성공
				logger.info("updateCancelYn4SysErr start : " + cancelObj.get("tid"));
				
				httpPost = new HttpPost("https://admin.menuplus.kr/api/updateCancelYn4SysErr/" + cancelObj.get("tid"));
				httpPost.setHeader("Content-type", "application/json");
				httpPost.setEntity(postData);
				
				httpClient = HttpClients.createSystem();
				
				httpResponse = httpClient.execute(httpPost);
				responseHandler = new BasicResponseHandler();
				
				body = responseHandler.handleResponse(httpResponse);
				body = URLDecoder.decode(body,"utf-8");
				
				logger.info("updateResult :: {}", body.trim());
				
				//관리자 업데이트 실패
				if(!body.toString().equals("0000")) {
					throw new Exception("update Error : " + cancelObj.get("tid"));
				}
				
			} else { //취소 실패
				throw new Exception("cancel Error : " + cancelObj.get("tid"));
			}
			
			logger.info("====================== cancelApi End ======================");
		} catch (Exception e) {
			logger.error("cancelApi Error : " + e.getMessage());
			
			return cancelResult;
		}
		
		return cancelResult;
	}
	
	public static JSONObject freePayFail(String tid) {
		JSONObject cancelResult = new JSONObject(); //취소 결과
		
		try {
			logger.info("====================== freePayFail Start ======================");
			logger.info("updateCancelYn4SysErr start : " + tid);
			
			StringEntity postData = new StringEntity(tid, "utf-8");
			HttpPost httpPost = new HttpPost("https://admin.menuplus.kr/api/updateCancelYn4SysErr/" + tid);
			httpPost.setHeader("Content-type", "application/json");
			httpPost.setEntity(postData);
			
			CloseableHttpClient httpClient = HttpClients.createSystem();
			
			httpClient = HttpClients.createSystem();
			CloseableHttpResponse httpResponse;
			httpResponse = httpClient.execute(httpPost);
			ResponseHandler<String> responseHandler = new BasicResponseHandler();
			
			responseHandler = new BasicResponseHandler();
			String body = "";
			
			body = responseHandler.handleResponse(httpResponse);
			body = URLDecoder.decode(body,"utf-8");
			
			logger.info("updateResult :: {}", body.trim());
			
			//관리자 업데이트 실패
			if(!body.toString().equals("0000")) {
				throw new Exception("update Error : " + tid);
			}
		
			logger.info("====================== freePayFail End ======================");
		} catch (Exception e) {
			logger.error("cancelApi Error : " + e.getMessage());
			
			return cancelResult;
		}
		
		return cancelResult;
	}
	
	//0원 거래 TID생성
	public static String genTID(String mid, String svcCd, String svcPrdtCd) {
		long mills = System.currentTimeMillis();
		long nano = System.nanoTime();
		
		String aa = String.valueOf(nano);
		int len = aa.length();
		
		StringBuffer sb = new StringBuffer();
		sb.append(mid);
		sb.append(svcCd);
		sb.append(svcPrdtCd);
		sb.append(new SimpleDateFormat("yyMMddHHmmss").format(new Date(mills)));
		sb.append(aa.substring(len - 9, len - 9 + 4));
		
		return sb.toString();
	}
}
