<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%request.setCharacterEncoding("UTF-8");%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>메뉴플러스</title>
	<meta http-equiv="Content-Type" content="text/html;" charset="utf-8">
	<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta http-equiv="X-UA-Compatible" content="IE-Edge">
   	<meta name='viewport' content='initial-scale=1, viewport-fit=cover'>
   	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css"/>
   	<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/qr/css/common.css">
   	<script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha256-2Pmvv0kuTBOenSvLm6bvfBSSHrUJ+3A7x6P5Ebd07/g=" crossorigin="anonymous"></script>
   	<script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>
   	<script type="text/javascript" src="https://pg.innopay.co.kr/ipay/js/jquery-2.1.4.mis.js"></script>
   	<script src="<%= request.getContextPath() %>/qr/js/common.js"></script>
   	<jsp:include page="./translate_header.jsp" flush="true"/>
   	<script>
   	
		window.onpageshow = function(event) {
			if(event.persisted || (window.performance && window.performance.navigation.type == 2)) {
				
				if(sessionStorage.length == 0) {
					window.location.replace('<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}');
				}else{
					history.go(1);
					$('.no-back').addClass('on');
					
				}
			}
		}
		
	   	
		$(document).ready(function(){
			var PayMethod = $('#PayMethod :selected').val();
			
			if(PayMethod == 'CARD') {
				loadScript('https://pg.innopay.co.kr/ipay/js/innopay-2.0.js'); //카드결제 연동 전용 스크립트
			} else if(PayMethod == 'EPAY') {
				loadScript('https://pg.innopay.co.kr/ipay/js/innopay-epay.js'); //간편결제 연동 전용 스크립트
			} else if(PayMethod == 'OPCARD'){
				loadScript('https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js'); //해외결제 연동 전용 스크립트
			} else {
				loadScript('https://pg.innopay.co.kr/pay/js/Innopay.js'); //수기결제 연동 전용 스크립트
			}
			var vaction = '${storeRoom.store.vactionDay}'.replace(/[ㄱ-ㅎㅏ-ㅣ가-힣]/g, "").replace(/\s/gi, "").split(",").sort();
	   		$('.vactionDay').text("휴가 (" + vaction + ")");
	   		
			menuplus.openTime();
			$('.btn-menu').attr('style', 'display:none;');

	   		$('.goPay').click(function() {
	   			
	   			if(validateData()) {
		   			var order = setPayData(); //결제 데이터 셋팅
		   			
		   			if(goOrder4Room(order)) { //주문등록 호출 성공
		   				var BuyerTel = $('input[name=BuyerTel]').val();
		   				
		   				menuplus.setCookie(BuyerTel, JSON.stringify(order));
		   				console.log("cookie : " + menuplus.getCookie(BuyerTel));
		   				
		   				addCookie.cookieKey.value = BuyerTel;
			   			addCookie.cookieValue.value = JSON.stringify(order);
			   			
			   			var data = $('#addCookie').serialize();
			   			var result = true;
			   			
			   			$.ajax({
							type : "POST",
							url : "<%=request.getContextPath()%>/qr/addCookie",
							async : false,
							data : data,
							cache: false,
							success: function(data) {
								console.log("success data : " + JSON.stringify(data));
								if(data == null || data == "") {
									alert("주문 처리중 오류 발생. 잠시 후 다시 시도해주세요.");
									result = false;
								}
						    },
							error : function (data) {
								alert("주문 처리중 오류 발생. 잠시 후 다시 시도해주세요.");
								console.log("error data : " + data);
								result = false;
							}
						});
			   			
			   			
			   			//결제창 호출
			   			if(result) {
			   				if(frm.Amt.value != "0") {
			   					
			   					payAmt = '0';
			   					
			   					if($("#PayMethod").val() == 'OPCARD' && frm.Currency.value !='KRW') {
			   						payAmt = frm.Amt.value + '00';
			   					}else{
			   						payAmt = frm.Amt.value;
			   					}
			   					
				   				if($("#PayMethod").val() != "CKEYIN") {
					   				innopay.goPay({
						   				PayMethod : frm.PayMethod.value,
						   				Currency : frm.Currency.value,
						   				MID : frm.MID.value,
						   				MerchantKey : frm.MerchantKey.value,
						   				GoodsName : frm.GoodsName.value,
						   				Amt : payAmt,
						   				GoodsCnt : frm.GoodsCnt.value,
						   				BuyerName : frm.BuyerName.value,
						   				BuyerTel : frm.BuyerTel.value,
						   				BuyerEmail : frm.BuyerEmail.value,
						   				ResultYN : frm.ResultYN.value,
						   				Moid : frm.Moid.value,
						   				MallReserved : frm.MallReserved.value,
						   				ReturnURL : frm.ReturnURL.value
						   			});
				   				} else {
				   					goPay(frm);
				   				}
			   				} else {
			   					frm.action = "<%= request.getContextPath() %>/qr/freePayResult/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}";
			   					frm.submit();
			   				}
			   			}
		   			}
	   			}
	   		});
	   		
	   		//결제데이터 셋팅
	   		function setPayData() {
	   			$('input[name=ediDate]').val(getMoid());
	   			
	   			const regex = /[^0-9]/g;
	   			
	   			var guestName = $('input[name=BuyerName]').val();
	   			var Moid = "${storeRoom.store.storeId}-${storeRoom.storeRoomCd}-${storeRoom.storeRoomNm}-" + getMoid();
	   			//var Amt = $('.sum-price').text().replace(',', '').replace('원', '').trim();
	   			
	   			var Amt = $('.sum-price').text().replace(',', '').replace(regex,'').trim();
	   			
	   			var GoodsName = "";
	   			var GoodsCnt =  $('.sum-count').text().replace(',', '').trim();
	   			
	   			var GoodsName = $('.menu-title').first().text();
	   			
	   			//GoodsName은 20자를 넘기면 안된다.
	   			if(GoodsCnt > 1) {
	   				GoodsName = GoodsName.substr(0,15) + " 외 " + Number(GoodsCnt - 1) + "개"; 
	   			}else{
	   				GoodsName = GoodsName.substr(0,20);
	   			}  
	   			
	   			var smenus = new Array(); //메뉴 리스트
				
				$('input[name=smenuCd]').each(function() {
					var smenuOpts = new Array(); //메뉴옵션
					var smenuCd = $(this).val(); //메뉴코드
					var categoryCd = $(this).next().val(); //메뉴 카테고리코드
					var smenuNm = $(this).prev().text(); //메뉴명
					var cnt = $(this).parents('.cart-goods').find('.quantity').val(); //메뉴수량
					
					var menuAmt = $(this).parents('.cart-goods').find('.menu-price').text().replace(',', '').replace(regex, ''); //메뉴가격
					
					//var menuAmt = $(this).parents('.cart-goods').find('.menu-price').text().replace(',', '').replace('원', ''); //메뉴가격
					
					var popupClass = $(this).parents('.cart-goods').find('.change-option').attr('popup-class');
					console.log("popupClass : " + popupClass);
					
					$(popupClass).find('.option').each(function() {
						var chk = $(this).is(':checked');
						
						if(chk) {
							console.log("smenuOpts : " + $(this).siblings('input[name=smenuOpts]').val());
							smenuOpts.push({
								smenuOptCd : $(this).siblings('input[name=smenuOpts]').val(),
								cnt : 1
							});
						}
					});
					
					smenus.push({
						smenuCd : smenuCd,
						categoryCd : categoryCd,
						smenuNm : smenuNm,
						cnt : cnt,
						menuAmt : menuAmt,
						smenuOpts : smenuOpts,
						discount : [0]
					})
				});
	   			
				var order = {
						salesTpCd : "38", //판매방식
						storeId : '${storeRoom.store.storeId}', //상점코드
						storeRoomCd : '${storeRoom.storeRoomCd}', //객실코드
						smenus : smenus, //메뉴리스트
						unit : "원", //결제 통화
						discount : [0], //할인정보
						guestName : guestName, //구매자명
						tel : frm.BuyerTel.value, //구매자 전화번호
						addr : '${storeRoom.store.storeAddrLan}', //매장주소
						addrDtl : '${storeRoom.store.storeAddrDtl}', //매장 상세주소
						orderId : Moid, //주문번호
						amt : Amt, //결제금액
				}
				
				
	   			//frm.Currency.value = frm.unit.value;
	   			frm.Moid.value = Moid;
	   			frm.Amt.value = Amt;
	   			frm.GoodsName.value = GoodsName;
	   			frm.GoodsCnt.value = GoodsCnt;
	   			//frm.ReturnURL.value = "http://localhost:8186/qr/payResult/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}"; //로컬
	   			frm.ReturnURL.value = "https://menuplus.kr/qr/payResult/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}"; //운영
	   			//frm.ReturnURL.value = "http://54.180.64.84:8186/qr/payResult/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}"; //운영
	   			frm.MallReserved.value = "orderId=" + Moid + "&storeId=${storeRoom.store.storeId}" +
	   									 "&shopName=${storeRoom.store.storeNmLan}" + "&roomName=${storeRoom.storeRoomNm}";
	   			
	   			return order;
	   		}
	   		
	   		function goOrder4Room(order) {
	   			var result = true;
	   			console.log("orderInfo : " + JSON.stringify(order));
	   			
	   			$.ajax({
					type : "POST",
					//url : "http://10.10.10.16:8185/api/order4Room", //로컬
					url : "https://admin.menuplus.kr/api/order4Room", //운영
					//url : "http://54.180.64.84:8185/api/order4Room", //운영
					async : false,
					data : JSON.stringify(order),
					contentType : "application/json; charset=utf-8;",
					dataType : "json",
					cache: false,
					success: function(data) {
						console.log("success data : " + JSON.stringify(data));
						result = true;
				    },
					error : function (data) {
						alert("시스템 오류 재시도 필요");
						console.log("error data : " + JSON.stringify(data));
						console.log("error data : " + JSON.stringify(data.responseText));
						result = false;
					}
				});
	   			
	   			return result
	   		}
	   		
	   		//데이터 체크
	   		function validateData() {
	   			var BuyerName = $('input[name=BuyerName]').val().trim();
	   			var BuyerTel = $('input[name=BuyerTel]').val().trim();
	   			var PayMethod = $('#PayMethod :selected').val();
	   			
	   			if(BuyerName == '' || BuyerName == undefined || BuyerName == null) {
	   				alert("구매자명은 필수입니다.");
	   				$('input[name=BuyerName]').focus();
	   				
	   				return false;
	   			}

	   			if(BuyerTel == '' || BuyerTel == undefined || BuyerTel == null || BuyerTel.length != 11) {
	   				alert("전화번호가 유효하지 않습니다.");
	   				$('input[name=BuyerTel]').focus();
	   				
	   				return false;
	   			}
	   			
	   			if(!$('input[name=infoCheck]').is(':checked')) {
	   				alert("이용약관에 동의해 주세요.");
	   				return false;
	   			}
	   			
	   			if(PayMethod == '' || PayMethod == undefined) {
	   				alert("결제수단 미등록 가맹점\n관리자에게 문의하세요.");
	   				return false;
	   			}
	   			
	   			$('.buyer-info').removeClass('on');
	   			$('body').removeClass('scrollDisable').off('scroll touchmove mousewheel');
	   			return true;
	   		}
	   		
	   		var oldOption = new Array(); //기존옵션
	   		var oldPrice = ""; //기존금액
	   		var oldCount = ""; //기존수량
	   		$('.change-option').click(function() {
	   			//기존옵션 확인
	   			var popupClass = $(this).attr('popup-class');
	   			
	   			$(popupClass).find('.option').each(function() {
	   				var chk = $(this).is(':checked');
	   				
	   				if(chk) {
	   					oldOption.push($(this).attr("id"));
	   				}
	   			});
	   			
	   			oldCount = $(popupClass).find('.quantity').val(); //기존 수량
	   			oldPrice = $(popupClass).find('.change-cart-sum').text(); //기존 금액
	   		});
	   		
	   		$('.change-cancel').click(function() {
	   			//기존옵션 유지
				$(this).parents('.popup').find('.option').each(function() {
	   				if(oldOption.includes($(this).attr("id"))) {
	   					$(this).prop('checked', true);
	   				} else {
	   					$(this).prop('checked', false);
	   				}
	   			});
				oldOption = []; //배열 초기화
				$(this).parents('.popup').find('.change-cart-sum').text(oldPrice); //기존 금액
				$(this).parents('.popup').find('.quantity').val(oldCount); //기존수량
	   		});
	   		
	   		//장바구니 변경
	   		$('.change-cart').click(function() {
	   			
	   			const regex1 = /[^0-9]/g;
	   			
	   			var sum = Number($(this).parents('.popup').find('input[name=addCartSum]').val().replace(',', '').replace(regex1, '')); //상품 기본금액
	   			
	   			//var sum = Number($(this).parents('.popup').find('input[name=addCartSum]').val().replace(',', '').replace('원', '')); //상품 기본금액
	   			
	   			var count = Number($(this).parents('.popup').find('.quantity').val()); //상품 수량
	   			var priceClass = $(this).attr('price-class');
	   			var countClass = $(this).parents('.popup').find('.quantity').attr('count-class');
	   			var optionClass = $(this).attr('option-class');
	   			
	   			
	   			$(this).parents('.popup').find('.option').each(function() {
	   				var chk = $(this).is(':checked');
	   				
	   				if(chk) {
	   					$(this).prop('checked', true);
	   					sum += Number($(this).siblings('.option-price').val());
	   				} else {
	   					$(this).prop('checked', false);
	   				}
	   			});
	   			
	   			$(priceClass).html(setComma(sum * count) + "<span>원</span>"); //변경 금액
	   			$(countClass).val(count); //변경 수량
	   			
	   			var html = changeOption($(this)); //옵션 변경 내용
	   			$(optionClass).html(html); //변경 옵션
	   			
	   			var cartPrice = totalPrice(); //총 금액 계산
	   			$('.sum-price').html(setComma(cartPrice) + "<span>원</span>");
	   			
	   			var cartCount = totalCount(); //총 수량 계산
	   			$('.sum-count').text(cartCount);
	   			
	   			oldOption = []; //배열 초기화
	   		});
	   		
	   		//장바구니 삭제
	   		$('.del-cart-goods').click(function() {
	   			var moid = $(this).find('.del-cart').val();
	   			var smenuCd = $(this).parents('.cart-goods').find('input[name=smenuCd]').val();
	   			
	   			sessionStorage.removeItem(moid);
	   			sessionStorage.removeItem("totalCnt" + smenuCd);
	   			
	   			$('.cart-goods-' + moid).remove();
	   			$('.change-order-' + moid).remove();
	   			
	   			var cartPrice = totalPrice(); //총 금액 계산
	   			$('.sum-price').html(setComma(cartPrice) + "<span>원</span>");
	   			
	   			var cartCount = totalCount(); //총 수량 계산
	   			$('.sum-count').text(cartCount);
	   			
	   			if($('.cart-goods').length == 0) {
	   				sessionStorage.clear();
	   				$('.no-menu').addClass('on');
	   			} else {
	   				sessionStorage.setItem("totalPrice", cartPrice); //총금액 
	   				sessionStorage.setItem("cartCount", cartCount); //총수량 세션담기	
	   			}
	   		});
	   		
	   		//옵션변경
	   		function changeOption(e) {
	   			var optionTitle = new Array(); //옵션명
	   			var optionList = new Array(); //옵션내용
	   			var html = ""; //변경옵션 출력
	   			
	   			e.parents('.popup').find('.option').each(function() {
	   				var chk = $(this).is(':checked');
	   				
	   				if(chk) {
	   					if(optionTitle.includes($(this).parents('.option-wrap').find('.title').text())) {
	   						var newOptionList = optionList.pop();
	   						optionList.push(newOptionList + ", " + $(this).parents('.mp-option').find('label').text() + " (" + $(this).parents('.mp-option').find('.p-add').text() + ")");
	   					} else {
	   						optionTitle.push($(this).parents('.option-wrap').find('.title').text());
	   						optionList.push($(this).parents('.option-wrap').find('.title').text() + ": " + $(this).parents('.mp-option').find('label').text() + " (" + $(this).parents('.mp-option').find('.p-add').text() + ")")					
	   					}
	   				}
	   			});
	   			
	   			for(var option in optionList) {
	   				html += "<li>" + optionList[option] + "</li>"
	   			}
	   			
	   			return html;
	   		}
	   		
	   		//총금액 계산
	   		function totalPrice() {
	   			
	   			const regex1 = /[^0-9]/g;
	   			
	   			var sum = 0;
	   			$('.menu-price').each(function() {
	   				sum += Number($(this).text().replace(',', '').replace(regex1, ''));
	   				//sum += Number($(this).text().replace(',', '').replace('원', ''));
	   			});
	   			
	   			return sum;
	   		}
	   		
	   		//총수량 계산
	   		function totalCount() {
	   			var sum = 0;
	   			$('.cart-goods').each(function() {
	   				sum += Number($(this).find('.quantity').val());
	   			});
	   			
	   			return sum;
	   		}
	   		
	   		//콤마 추가
	   		function setComma(value){
	   			value = String(value);
	   	    	value = value.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	   	    	return value;
	   		}
	   		
	   		//주문번호 셋팅
	   		function getMoid(){
	   		    var date = new Date();
	   		    var year = date.getFullYear(); //년
	   		    var month = ("0" + (1 + date.getMonth())).slice(-2); //월
	   		    var day = ("0" + date.getDate()).slice(-2); //일
	   		    var hour = ("0" + date.getHours()).slice(-2); //시간
	   			var minute = ("0" + date.getMinutes()).slice(-2); //분
	   			var second = ("0" + date.getSeconds()).slice(-2); //초

	   		    return year + month + day + hour + minute + second;
	   		}
	   		
	   		//연동스크립트 교체
	   		function loadScript(url) {
	   		    $('script').each(function() {
	   		    	console.log($(this).attr('src'));
	   		    	
	   		    	if($(this).attr('src') == 'https://pg.innopay.co.kr/ipay/js/innopay-2.0.js' ||
	   		    			$(this).attr('src') == 'https://pg.innopay.co.kr/ipay/js/innopay-epay.js' ||
	   		    			$(this).attr('src') == 'https://pg.innopay.co.kr/pay/js/Innopay.js' ||
	   		    			$(this).attr('src') == 'https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js') {
	   		    		$(this).remove();
	   		    	}
	   		    });
	   		    
	   		    var script = document.createElement('script');
	   		    script.src = url;
	   		    
	   		    document.head.append(script);
	   		}
	   		
	   		$("#PayMethod").change(function() {	   			
	   			if($(this).val() == 'EPAY'){ // 간편결제 연동
	   		        loadScript('https://pg.innopay.co.kr/ipay/js/innopay-epay.js');   //간편결제
	   		     	$('input[name=FORWARD]').val('');
	   		     	$('input[name=MID]').val('${midInfo.mid}');
					$('input[name=MerchantKey]').val('${midInfo.mkey}');
	   		    } else if($(this).val() == 'CARD'){
	   		        loadScript('https://pg.innopay.co.kr/ipay/js/innopay-2.0.js');   //통합결제
	   		     	$('input[name=FORWARD]').val('');
	   		     	$('input[name=MID]').val('${midInfo.mid}');
					$('input[name=MerchantKey]').val('${midInfo.mkey}');
	   		    } else if($(this).val() == 'OPCARD'){
					loadScript('https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js'); //해외결제 연동 전용 스크립트
	   		     	$('input[name=FORWARD]').val('');
	   		     	$('input[name=MID]').val('${midInfo.overseasMid}');
					$('input[name=MerchantKey]').val('${midInfo.overseasMkey}');
					$('input[name=Currency]').val('${midInfo.currency}');
	   		    } else {
	   		    	loadScript('https://pg.innopay.co.kr/pay/js/Innopay.js');   //수기결제
	   		    	$('input[name=FORWARD]').val('Y');
	   		    	$('input[name=MID]').val('${midInfo.mid}');
					$('input[name=MerchantKey]').val('${midInfo.mkey}');
	   		    }
	   		});
		});
	 </script>
</head>
<body>
<form action="/qr/addCookie" name="addCookie" id="addCookie" method="POST" style="display:none;">
	<input type="hidden" name="cookieKey" value=""/>
	<input type="hidden" name="cookieValue" value=""/>
</form>
   <div class="wrap">
      <header>
         <div class="gnb">
            <a href="<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}">
               <div class="gnb-logo"><img src="<%= request.getContextPath() %>/qr/img/logo.png"></div>
               <div class="shop-name">${storeRoom.store.storeNmLan}</div>
               <div class="user-n">${storeRoom.storeRoomNm}</div>
            </a>
         </div>
         <!--          구글 다국어 지원 부분 -->
 		<div id="google_translate_element" style="display:none"></div>
 		<jsp:include page="./translate_body.jsp" flush="true"/>
         <div class="page-title">
            장바구니
         </div>
      </header>
      <section class="content">
         <div class="cart-con">
         	<c:forEach items="${cartList}" var="cartList">
            	<div class="cart-goods cart-goods-${cartList.moid}">
            		<div class="title menu-title">${cartList.menuTitle}</div>
            		<input type="hidden" name="smenuCd" value="${cartList.smenuCd}"/>
					<input type="hidden" name="categoryCd" value="${cartList.categoryCd}"/>
            		<div class="goods-info">
	                  <div class="img"><img src="${cartList.menuImg}"></div>
	                  <div class="text-info">
	                     <ul class="option-list">
	                        <li>가격: ${cartList.defaultPrice}</li>
	                        <div class="change-option-${cartList.moid}">
	                        	<c:forEach items="${cartList.optionList}" var="optionList">
			                        <li>${optionList}</li>
		                        </c:forEach>
	                        </div>
	                     </ul>
	                     <div class="price menu-price change-price-${cartList.moid}">${cartList.addCartSum}<span>원</span></div>
	                  </div>
	               </div>
	               <div class="btn-wrap">
                   <a href="#" class="btn btn-s btn-w popup-trigger change-option" popup-class=".change-order-${cartList.moid}">옵션변경</a>
                   <div class="quantity-wrap">
                   	<div class="quantity-input-wrap">
                   		<span class="btn-decrease btn-change"><img src="<%= request.getContextPath() %>/qr/img/minus.png"></span>
                        <input class="quantity change-count-${cartList.moid}" type="text" name="" value="${cartList.menuCnt}" disabled="">
                        <span class="btn-increase btn-change"><img src="<%= request.getContextPath() %>/qr/img/plus.png"></span>
                        <input type="hidden" name="cartNum" value ="change-order-${cartList.moid}"/>
                    </div>
                   </div>
                </div>
                <a href="#" class="del-cart-goods">
                	<img src="<%= request.getContextPath() %>/qr/img/i-x-b.png">
                	<input type="hidden" class="del-cart" value="${cartList.moid}"/>
                </a>
            	</div>
            </c:forEach>
            <a href="/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}" class="add-more"><img src="<%= request.getContextPath() %>/qr/img/plus.png">더 담기</a>
         </div>

         <div class="sum">
            <div class="price-sum">
               <span class="title">총 금액</span>
               <div class="price sum-price">
                  ${totalPrice}<span>원</span>
               </div>
            </div>
            <div class="btn-sum">
               <a href="#" class="btn btn-l btn-d-gray popup-trigger" popup-class=".buyer-info" onclick="menuplus.openTime();">결제하기</a>
               <span class="notranslate"><div class="order-count sum-count">${cartCount}</div></span>
            </div>
               <!-- <a href="#" class="btn btn-l btn-d-gray popup-trigger btn-menu" popup-class=".no-menu"></a> -->
         </div>
      </section>
      <c:forEach items="${cartList}" var="cartList">
      	<div class="popup-wrap change-order change-order-${cartList.moid}">
      		<div class="popup">
      			<div class="popup-con">
	      			<div class="title">${cartList.menuTitle}</div>
	      			<div class="price">${cartList.defaultPrice}</div>
		      		${cartList.popup}
		      		<div class="quantity-wrap">
		      			<div class="title">수량</div>
		      				<div class="quantity-input-wrap">
	                     	<span class="btn-decrease btn-quantity"><img src="<%= request.getContextPath() %>/qr/img/minus.png"></span>
	                     	<input class="quantity" count-class=".change-count-${cartList.moid}" type="text" name="" value="${cartList.menuCnt}" disabled="">
	                     	<span class="btn-increase btn-quantity"><img src="<%= request.getContextPath() %>/qr/img/plus.png"></span>
	                  	</div>
	               </div>
      			</div>
      			<div class="btn-wrap two-btn">
      				<a href="#" class="btn btn-l btn-gray popup-close change-cancel">취소</a>
      				<a href="#" class="btn btn-l btn-d-gray popup-close change-cart" price-class=".change-price-${cartList.moid}" option-class=".change-option-${cartList.moid}"><span class="change-cart-sum">${cartList.addCartSum}</span><span> 원</span> 변경</a>
      				<input type="hidden" name="addCartSum" value="${cartList.defaultPrice}"/>
      			</div>
      		</div>
      	</div>
      </c:forEach>
      <div class="popup-wrap no-menu noti">
         <div class="popup">
            <div class="popup-con">
                <p class="title">메뉴를 선택해주세요</p>
            </div>
            <div class="btn-wrap">
               <a href="/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}" class="btn btn-l btn-d-gray popup-close">확인</a>
            </div>
         </div>
      </div>
      
      <div class="popup-wrap no-back noti">
         <div class="popup">
            <div class="popup-con">
                <p class="title">메뉴선택 화면으로 돌아가시려면 '+ 더 담기'를 누르시거나, 선택한 메뉴를 삭제하고 '확인'버튼을 누르시기 바랍니다.</p>
            </div>
            <div class="btn-wrap">
               <a href="#" class="btn btn-l btn-d-gray popup-close">확인</a>
            </div>
         </div>
      </div>      
      
      <div class="popup-wrap operating-hours">
         <div class="popup">
            <div class="popup-con">
               <div class="img"><img src="<%= request.getContextPath() %>/qr/img/i-clock2.png"></div>
               <div class="title">현재는 운영시간이 아닙니다.</div>
               <div class="description">장바구니는 이용가능하며<br>운영시간에 결제 및 주문이 가능합니다.</div>
               <div class="time-info">
                  <div class="title">운영시간</div>
                  <c:set var="openTm" value="${fn:split(storeRoom.store.openTm, ',')}" />
                  <c:forEach var="openTmValue" items="${openTm}">
                  <div class="info-wrap">
                     <div class="day">${openTmValue}</div>
                     <input type="hidden" name="openTm" value="${openTmValue}"/>
                  </div>
                  </c:forEach>
                  <c:if test="${storeRoom.store.breakTmList ne null and storeRoom.store.breakTmList != ''}">
                  	<div class="info-wrap">
                  		<c:forEach var="breakTmList" items="${storeRoom.store.breakTmList}">
	                  		<div class="day">브레이크 타임 ${breakTmList}</div>
	                  		<input type="hidden" name="breakTm" value="${breakTmList}"/>
	                  	</c:forEach>
                  	</div>
                  </c:if>
                  <c:if test="${storeRoom.store.holiday ne null and storeRoom.store.holiday != ''}">
                  	<div class="info-wrap">
                  		<div class="day">휴무일 ${storeRoom.store.holiday}</div>
                  		<input type="hidden" name="holiTm" value="${storeRoom.store.holiday}"/>
                  	</div>
                  </c:if>
                  <c:if test="${storeRoom.store.vactionDay ne null and storeRoom.store.vactionDay != ''}">
                  	<div class="info-wrap">
	                  	<div class="day vactionDay"></div>
	                  	<input type="hidden" name="vactionDay" value="${storeRoom.store.vactionDay}"/>
                  	</div>
				  </c:if>
               </div>
            </div>
            <div class="btn-wrap">
               <a href="#" class="btn btn-l btn-gray popup-close">확인</a>
            </div>
         </div>
      </div>
      <form action="" name="frm" id="frm" method="POST">
	      <div class="popup-wrap buyer-info">
	         <div class="popup">
	            <div class="popup-con">
	               <div class="input-wrap">
	                  <label for="BuyerName">구매자 이름</label>
	                  <input type="text" name="BuyerName" id="BuyerName" placeholder="이름을 입력해 주세요.">
	               </div>
	               <div class="input-wrap">
	                  <label for="BuyerTel">휴대폰 번호</label>
	                  <input type="number" name="BuyerTel" id="BuyerTel" placeholder="숫자만 입력해 주세요." inputmode="numeric" pattern="[0-9]*">
	               </div>
	               <div class="input-wrap">
	                  <label for="PayMethod">결제방식</label>
	                  <div class="select-wrap">
		                  	<c:if test="${totalPrice eq '0'}">
			                  <select name="PayMethod" id="PayMethod" disabled>
			                  	<option value="FREE">무료상품</option>
			                  </select>
		                  	</c:if>
		                  	<c:if test="${totalPrice ne '0'}">
		                  		<select name="PayMethod" id="PayMethod">
			                  	<c:choose>
			                  		<c:when test="${fn:length(midInfo.payMethodList) > 0 and midInfo.payMethodList[0] ne ''}">
			                  			<c:forEach var="payInfo" items="${midInfo.payMethodList}">
			                  				<c:if test="${payInfo eq '01'}">
												<option value="CARD">카드결제(ISP/안심클릭)</option>
			                  				</c:if>
			                  				<c:if test="${payInfo eq '02'}">
												<option value="CKEYIN">카드결제(카드번호결제)</option>
			                  				</c:if>
			                  				<c:if test="${payInfo eq '03'}">
												<option value="EPAY">간편결제</option>                  					
			                  				</c:if>
			                  				<c:if test="${payInfo eq '04'}">
												<option value="OPCARD">Overseas Card</option>                  					
			                  				</c:if>
			                  			</c:forEach>
			                  		</c:when>
				                  	<c:otherwise>
				                  		<option value="">결제수단 미등록</option>
				                  	</c:otherwise>
			                  	</c:choose>
			                  </select>
		                  	</c:if>
	                  </div>
	               </div>
	               
	               <div class="p-info">
	               	<h4>개인정보 수집 및 이용안내</h4>
	               	<div class="checkbox-info">
                        <input type="checkbox" name="infoCheck" id="infoCheck"><label for="infoCheck">동의</label>
                  	</div>
               	   </div>
               	   <div class="terms">
               	   	<div class="item">
               	   		<div class="con">
               	   			회사는 전자결제 대행 및 결제대금예치 서비스, 현금영수증 서비스 그리고 휴대폰 본인확인 서비스(이하 “서비스”라 칭함) 신청, 상담, 문의사항 등, 서비스의 제공을 위하여 아래와 같은 개인정보를 수집하고 있습니다.
                     	</div>
                    	<ol class="circle">
                    		<li>
                           		<span>개인정보 수집항목</span>
                           		<ol class="hangul">
                              		<li>
                                 		<span>필수 항목</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                       			<span>계약 정보</span>
                                       			<ul>
                                          			<li>
                                          				대표자명, 대표자 휴대폰번호, 대표자 전화번호(회사 번호는 해당 없음), 이메일주소, 담당자명, 담당자 휴대폰번호, 담당자 이메일주소, 담당자 전화번호(회사 번호는 해당 없음)
                                          			</li>
                                       			</ul>
                                    		</li>
                                    		<li>
                                       			<span>
                                       				상기 명시된 개인정보 항목 이외의 “서비스” 이용과정이나 “서비스” 처리 과정에서 다음과 같은 추가 정보들이 자동 혹은 수동으로 생성되어 수집 될 수 있습니다.
                                       			</span>
                                       			<ul>
                                          			<li>
                                          				접속 IP/MAC Address, 쿠키, e-mail, 서비스 접속 일시, 서비스 이용 기록, 불량 혹은 비정상 이용 기록, 결제 기록
                                          			</li>
                                       			</ul>
                                    		</li>
                                    		<li>
                                    			<span>기타</span>
                                       			<ul>
                                          			<li>
                                          				회사는 서비스 이용과 관련한 대금결제, 환불 등에 필요한 다음과 같은 정보 등을 추가로 수집할 수 있습니다.
                                          			</li>
                                          			<li>
                                          				계좌번호, 예금주명, 서비스계약일 등
                                          			</li>
                                       			</ul>
                                    		</li>
                                 		</ol>
                              		</li>
                              		<li>
                                 		<span>선택 항목</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                       			<span>필수 항목 이외에 계약 서류에 기재된 정보 또는 고객이 제공한 정보</span>
                                    		</li>
                                    		<li>
                                       			<span>
                                       				주소, 팩스번호 등
                                       			</span>
                                    		</li>
                                 		</ol>
                              		</li>
                           		</ol>
                        	</li>
                        	<li>
                           		<span>수집 방법</span>
                           		<div class="con">
                           			홈페이지(판매자 회원가입, 문의 상담), 서면 양식, 팩스, 이메일, 업무제휴 계약을 체결한 제휴사로부터 고객이 제시 하는 개인정보 수집
                           		</div>
                        	</li>
                     	</ol>
                  	</div>
                  	<div class="item">
                  		<h2>2. 개인정보의 수집•이용 목적</h2>
                     	<div class="con">
                     		회사는 수집한 개인정보를 다음의 목적을 위해 활용합니다.
                     	</div>
                     	<ol class="circle">
                     		<li>
                     			서비스 제공 계약의 성립, 유지, 종료를 위한 본인 식별 및 실명확인, 각종 회원관리, 계약서 발송 등
                        	</li>
                        	<li>
                        		서비스 제공 과정 중 본인 식별, 인증, 실명확인 및 각종 안내/고지
                        	</li>
                        	<li>
                        		부정 이용 방지 및 비인가 사용방지
                        	</li>
                        	<li>
                        		서비스 제공 및 관련 업무처리에 필요한 동의 또는 철회 등 의사 확인
                        	</li>
                        	<li>
                        		이용 빈도 파악 및 인구통계학적 특성에 따른 서비스 제공 및 CRM
                        	</li>
                        	<li>
                        		서비스 제공을 위한 각 결제수단 별 상점 사업자 정보 등록
                        	</li>
                     	</ol>
                  	</div>
                  	<div class="item">
                  		<h2>3. 개인정보의 보유 및 이용기간</h2>
                     	<div class="con">
                     		이용자의 개인정보는 원칙적으로 개인정보의 수집 및 이용목적이 달성되면 지체 없이 파기 합니다. 단, 다음의 각 목에 해당하는 정보에 대해서는 아래의 이유로 명시한 기간 동안 보존 합니다.
                     	</div>
                     	<ol class="circle">
                        	<li>
                        		<span>회사 내부 방침의 의한 정보보유</span>
                           		<ol class="hangul">
                           			<li>
                           				보존항목: 서비스 상담 수집 항목(회사명, 고객명, 전화번호, E-mail, 상담내용 등)
                              		</li>
                              		<li>
                              			보존이유: 분쟁이 발생 할 경우 소명자료 활용
                              		</li>
                             		<li>
                             			보존기간: <span class="important_text">상담 완료 후 6개월</span>
                              		</li>
                              	</ol>
                        	</li>
                        	<li>
                        		<span>관련법령에 의한 정보보유</span>
                           		<div class="con">
                           			상법, 전자상거래 등에서의 소비자보호에 관한 법률, 전자금융거래법 등 관련법령의 규정에 의하여 보존할 필요가 있는 경우 회사는 관련법령에서 정한 일정한 기간 동안 정보를 보관합니다. 이 경우 회사는 보관하는 정보를 그 보관의 목적으로만 이용하며 보존기간은 다음 각 호와 같습니다.
                           		</div>
                           		<ol class="hangul">
                           			<li>
                                 		<span>계약 또는 청약철회 등에 관한 기록</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                    			보존기간: <span class="important_text">5년</span>
                                    		</li>
                                    		<li>
                                    			보존근거: 전자상거래 등에서의 소비자보호에 관한 법률
                                    		</li>
                                 		</ol>
                              		</li>
                              		<li>
                                 		<span>대금결제 및 재화 등의 공급에 관한 기록</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                    			보존기간: <span class="important_text">5년</span>
                                    		</li>
                                    		<li>
                                       			보존근거: 전자상거래 등에서의 소비자보호에 관한 법률
                                    		</li>
                                 		</ol>
                              		</li>
                              		<li>
                                 		<span>소비자의 불만 또는 분쟁처리에 관한 기록</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                       			보존기간: <span class="important_text">3년</span>
                                    		</li>
                                    		<li>
                                       			보존근거: 전자상거래 등에서의 소비자보호에 관한 법률
                                    		</li>
                                 		</ol>
                              		</li>
                              		<li>
                                 		<span>본인확인에 관한 기록</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                       			보존기간: <span class="important_text">6개월</span>
                                    		</li>
                                    		<li>
                                       			보존근거: 정보통신 이용촉진 및 정보보호 등에 관한 법률
                                    		</li>
                                 		</ol>
                              		</li>
                              		<li>
                                 		<span>방문에 관한 기록</span>
                                 		<ol class="upper-alpha">
                                    		<li>
                                       			보존기간: <span class="important_text">3개월</span>
                                    		</li>
                                    		<li>
                                       			보존근거: 통신비밀보호법
                                    		</li>
                                 		</ol>
                              		</li>
                           		</ol>
                        	</li>
                     	</ol>
                  	</div>
	            </div>
	            <div class="btn-wrap two-btn">
	               <a href="#" class="btn btn-l btn-gray popup-close">취소</a>
	               <a href="#" class="btn btn-l btn-d-gray go-pay goPay">결제하기</a>
	            </div>
	         </div>
	      </div>
	      <!-- <input type="hidden" name="PayMethod" value="CARD"/> -->
	      <input type="hidden" name="MID" value="${midInfo.mid}"/>
	      <input type="hidden" name="MerchantKey" value="${midInfo.mkey}"/>
	      <input type="hidden" name="GoodsName" value=""/>
	      <input type="hidden" name="Amt" value=""/>
	      <input type="hidden" name="GoodsCnt" value=""/>
	      <input type="hidden" name="BuyerEmail" value="noemail@noemail.com"/>
	      <input type="hidden" name="ResultYN" value="N"/>
	      <input type="hidden" name="Moid" value=""/>
	      <input type="hidden" name="ReturnURL" value=""/>
	      <input type="hidden" name="MallReserved" value=""/>
	      <input type="hidden" name="FORWARD" value=""/>
	      <input type="hidden" name="EncryptData" value=""/>
	      <input type="hidden" name="device" value=""/>
	   	  <input type="hidden" name="ediDate" value=""/>;
	   	  <input type="hidden" name="Currency" value="KRW"/>;
      </form>
   </div>
</body>
</html>