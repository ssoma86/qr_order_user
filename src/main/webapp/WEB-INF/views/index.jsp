<%@page import="java.util.*"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URLDecoder"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%request.setCharacterEncoding("UTF-8");%>
<%pageContext.setAttribute("newLine", "\n"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>메뉴플러스</title>
   <meta http-equiv="Content-Type" content="text/html;" charset="utf-8">
   <meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
   <meta http-equiv="X-UA-Compatible" content="IE-Edge">
   <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css"/>
   <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/qr/css/common.css">
   <script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha256-2Pmvv0kuTBOenSvLm6bvfBSSHrUJ+3A7x6P5Ebd07/g=" crossorigin="anonymous"></script>
   <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>
   <script src="<%= request.getContextPath() %>/qr/js/common.js"></script>
   <jsp:include page="./translate_header.jsp" flush="true"/>
   <script>
   	window.onpageshow = function(event) {
		if(event.persisted || (window.performance && window.performance.navigation.type == 2)) {
			if(sessionStorage.length == 0) {
				window.location.replace('<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}');
			} else {
				history.go(1);
			}
		}
	}
   	$(document).ready(function(){
   		if('${storeRoom.store.design}' == 'H') {
	   		$('.mp-page').removeClass('v-style');
   		}
   		
   		var vaction = '${storeRoom.store.vactionDay}'.replace(/[ㄱ-ㅎㅏ-ㅣ가-힣]/g, "").replace(/\s/gi, "").split(",").sort();
   		$('.vactionDay').text("휴가 (" + vaction + ")");
   		console.log("휴가 (" + vaction + ")");
   		
   		menuplus.openTime();
   		
   		$('.order-search').click(function() {
   			$('.order-h-count').remove(); //수량초기화
   			$('.order-h-list').remove(); //리스트초기화
   			$('.order-h-detail').remove(); //팝업초기화
   			var storeCd = '${storeRoom.store.storeCd}';
   			var buyerTel = $('input[name=BuyerTel]').val();
   			
   			if(buyerTel == '' || buyerTel.length != 11) {
   				$('.no-tel').addClass('on');
   				$('input[name=BuyerTel]').focus();
   				
   				return false;
   			}
   			
   			//쿠기값 조회(전화번호 없을 시 showOrderList 미호출)
   			var cookieValue = menuplus.getCookie(buyerTel);
   			
   			var html = "";
   			var popupHtml = "";
   			if(cookieValue == ';') {
   				$('.no-order').addClass('on');
   				
   				return false;
   			} else {
   				var data = {
   					buyerTel : buyerTel,
   					storeCd : storeCd
   				};
   				
   				$.ajax({
					type : "POST",
					url : "<%=request.getContextPath()%>/qr/showOrderList",
					async : false,
					data : JSON.stringify(data),
					contentType : 'application/json; charset=utf-8',
					dataType : 'json',
					cache: false,
					success: function(data) {
						if(data.result == "0000") {
								var liCnt = 1;
								html += "<div class='order-h-count'><span>총</span> " + data.orderList.length + "<span>건</span></div>";
								html += "<ul class='order-h-list'>";
							for(var order of data.orderList) {
								var menuCnt = 0;
								var menuNm = "";
								
								if(order.smenus.length != 0) {
									menuNm = order.smenus[0].smenuNmLan
								} else {
									menuNm = "메뉴"
								}
								
								for(var i = 0; i < order.smenus.length; i++) {
									menuCnt += order.smenus[i].cnt;
								}
								
								//html : 주문리스트
								//popupHtml : 주문상세 리스트
								if(order.cancelYn == "N" && menuCnt >= 1) {
	   								html += "<li class='oreder-complete popup-trigger order-popup' popup-class='.ohd" + liCnt + "'>";
	   								html += "<div class='dp-flex'>";
	   								/* html += "<div class='order-state'>주문완료</div>"; */
	   								html += "<div class='order-state'>" + order.orderStatus.nm + "</div>";
	   								html += "<div class='date'>" + order.orderDate + "</div>"
	   								html += "</div>";
	   								html += "<div class='order-room'>객실: <b>" + order.storeRoomNm + "</b></div>";
	   								if(order.waitTime != null && order.orderStatus.cd == "30") {
		   								html += "<div class='time'>예상소요시간: <b>" + order.waitTime + "분" + "</b></div>";
	   								}
	   								if(menuCnt == 1) {
	   									html += "<div class='goods-nm'>" + menuNm + "</div>";
	   								} else {
	   									html += "<div class='goods-nm'>" + menuNm + " 외" + (menuCnt - 1) + "개</div>";
	   								}
	   								html += "<div class='price-sum'>" + menuplus.setComma(order.Amount) + "<span>원</span></div>";
	   								html += "</li>";
	   					            
	   								popupHtml += "<div class='popup-wrap order-h-detail ohd" + liCnt +"'>";
	   								popupHtml += "<div class='popup oreder-complete'>";
	   								popupHtml += "<div class='popup-con'>";
	   								popupHtml += "<div class='dp-flex'>";
	   								popupHtml += "<div class='order-state'>" + order.orderStatus.nm + "</div>";
	   								popupHtml += "<div class='date'>" + order.orderDate + "</div>";
	   								popupHtml += "</div>";
	   								popupHtml += "<div class='order-room'>객실: <b>" + order.storeRoomNm + "</b></div>";
	   								if(order.waitTime != null && order.orderStatus.cd == "30") {
	   									popupHtml += "<div class='time'>예상소요시간: <b>" + order.waitTime + "분" + "</b></div>";
	   								}
	   								for(var i = 0; i < order.smenus.length; i++) {
										popupHtml += "<div class='goods-info'>";
										popupHtml += "<div class='name'>" + order.smenus[i].smenuNmLan + "</div>";
										popupHtml += "<div class='option'>";
										
										var menuPrice = order.smenus[i].price;
										var cnt = order.smenus[i].cnt;
										var optionPrice = 0;
										
										for(var j = 0; j < order.smenus[i].smenuOpts.length; j++) {
											optionPrice += order.smenus[i].smenuOpts[j].price;
											popupHtml += "<span>" + order.smenus[i].smenuOpts[j].smenuOptInfos[0].smenuOptInfoNm + "</span>";
										}
										popupHtml += "</div>";
										popupHtml += "<div class='price'>" + menuplus.setComma((menuPrice + optionPrice) * cnt) + "<span>원</span></div>";
										popupHtml += "</div>";
									}
	   								popupHtml += "<div class='price-sum'>";
	   								popupHtml += "<div class='label'>합계</div>";
	   								popupHtml += "<div class='price'>" + menuplus.setComma(order.Amount) + "<span>원</span></div>"
	   								popupHtml += "</div>";
	   								popupHtml += "</div>";
	   								popupHtml += "<div class='btn-wrap'><a href='#' class='btn btn-l btn-gray popup-close'>확인</a></div>";
	   								popupHtml += "</div>";
	   								popupHtml += "</div>";
	   								liCnt++;
								} else if(order.cancelYn == "Y" && menuCnt >= 1){
									html += "<li class='oreder-cancel popup-trigger order-popup' popup-class='.ohd" + liCnt + "'>";
									html += "<div class='dp-flex'>";
									html += "<div class='order-state'>결제취소</div>";
									html += "<div class='date'>" + order.orderDate + "</div>";
   									html += "</div>";
   									html += "<div class='order-room'>객실: <b>" + order.storeRoomNm + "</b></div>";
   									html += "<div class='order-room'>취소사유: <b>" + order.cancelReason + "</b></div>";
   									if(menuCnt == 1) {
	   									html += "<div class='goods-nm'>" + menuNm + "</div>";
	   								} else {
	   									html += "<div class='goods-nm'>" + menuNm + " 외" + (menuCnt - 1) + "개</div>";
	   								}
   									html += "<div class='price-sum'>" + menuplus.setComma(order.Amount) + "<span>원</span></div>";
									html += "</li>";
									
									popupHtml += "<div class='popup-wrap order-h-detail ohd" + liCnt +"'>";
	   								popupHtml += "<div class='popup oreder-cancel'>";
	   								popupHtml += "<div class='popup-con'>";
	   								popupHtml += "<div class='dp-flex'>";
	   								popupHtml += "<div class='order-state'>결제취소</div>";
	   								popupHtml += "<div class='date'>" + order.orderDate + "</div>";
	   								popupHtml += "</div>";
	   								popupHtml += "<div class='order-room'>객실: <b>" + order.storeRoomNm + "</b></div>";
	   								popupHtml += "<div class='order-room'>취소사유: <b>" + order.cancelReason + "</b></div>";
	   								for(var i = 0; i < order.smenus.length; i++) {
										popupHtml += "<div class='goods-info'>";
										popupHtml += "<div class='name'>" + order.smenus[i].smenuNmLan + "</div>";
										popupHtml += "<div class='option'>";
										
										var menuPrice = order.smenus[i].price;
										var cnt = order.smenus[i].cnt;
										var optionPrice = 0;
										
										for(var j = 0; j < order.smenus[i].smenuOpts.length; j++) {
											optionPrice += order.smenus[i].smenuOpts[j].price;
											popupHtml += "<span>" + order.smenus[i].smenuOpts[j].smenuOptInfos[0].smenuOptInfoNm + "</span>";
										}
										popupHtml += "</div>";
										popupHtml += "<div class='price'>" + menuplus.setComma((menuPrice + optionPrice) * cnt) + "<span>원</span></div>";
										popupHtml += "</div>";
									}
	   								popupHtml += "<div class='price-sum'>";
	   								popupHtml += "<div class='label'>합계</div>";
	   								popupHtml += "<div class='price'>" + menuplus.setComma(order.Amount) + "<span>원</span></div>"
	   								popupHtml += "</div>";
	   								popupHtml += "</div>";
	   								popupHtml += "<div class='btn-wrap'><a href='#' class='btn btn-l btn-gray popup-close'>확인</a></div>";
	   								popupHtml += "</div>";
	   								popupHtml += "</div>";
									liCnt++;
								}
								console.log(order);
							}
							html += "</ul>";
							$('.order-history').append(html);
							$('.wrap').append(popupHtml);
							//$('.wrap').append(popupHtml);
						} else {
							$('.no-order').addClass('on');
						}
				    },
					error : function (data) {
						alert("조회중 오류 발생. 잠시 후 다시 시도해주세요.");
						console.log("error data : " + JSON.stringify(data));
					}
				});
   			}
   		});
   		
   		
   			
   	});
   	
   	function goCart() {
   		var menuList = [];
   		var cartCount = sessionStorage.getItem("cartCount");
   		var totalPrice = sessionStorage.getItem("totalPrice");
   		var html = "";
   		
   		if(sessionStorage.length > 0) {
	   		for(var i = 0 ; i < sessionStorage.length; i++) {
	   			if(sessionStorage.key(i).includes("cartData")) {
	   				var moid = JSON.parse(sessionStorage.getItem(sessionStorage.key(i))).moid;
	   				var menuData = sessionStorage.getItem(sessionStorage.key(i));
	   				console.log(moid);
	   				console.log(menuData);
	   				
	   				html += "<input type='hidden' name='moid' value='" + moid + "'/>";
	   				html += "<input type='hidden' name='" + moid + "' value='" + menuData + "'/>"
				}
	   		}
	   		console.log("cartCount : " + cartCount);
	   		console.log("totalPrice : " + totalPrice);
	   		
	   		html += "<input type='hidden' name='cartCount' value='" + cartCount + "'/>";
	   		html += "<input type='hidden' name='totalPrice' value='" + totalPrice + "'/>";
	   		html += "<input type='hidden' name='storeRoom' value='" + JSON.stringify(${storeRoom}) + "'/>";
	   		
	   		$('#cartData').append(html);
	   		$('#cartData').submit();
	   		$('#cartData').html('');		
   		} else {
   			$('.no-menu').addClass('on');
   		}
   		
   	}
   </script>
</head>
<body>
	<form action="/qr/showCart/${storeRoom.storeRoomCd}" name="cartData" id="cartData" method="POST" style="display:none;"></form>
	<input type="hidden" name="storeRoomCd" value="${storeRoom.storeRoomCd}"/>
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
 	
         <ul class="menu">
            <li id="menu1" class="menu-item active"><a href="#">메뉴</a></li>
            <li id="menu2" class="menu-item"><a href="#">소개</a></li>
            <li id="menu3" class="menu-item"><a href="#">주문내역</a></li>
         </ul>
      </header>
      <section class="content">
         <div class="menu-con-wrap ">
            <div class="menu-con mp-page v-style active">
               <div class="tab-g">
                  <div class="tab-wrap">
                  <c:forEach items="${storeRoom.store.categorys}" var="menuList">
                  	<a href="#tab-con${menuList.categoryCd}" class="tab">${menuList.categoryNmLan}</a>
                  </c:forEach>
                  </div>
               </div>
               <div class="tab-con-wrap">
               	<c:forEach items="${storeRoom.store.categorys}" var="menuList">
               		<div id="tab-con${menuList.categoryCd}" class="tab-con">
                     <div class="g-title">${menuList.categoryNmLan}</div>
                     <c:if test="${menuList.categoryDesc ne ''}">
	                     <div class="g-ex">${fn:replace(menuList.categoryDesc, newLine, '<br/>')}</div>
                     </c:if>
                     <div class="mp-menu-wrap">
                     	<c:forEach items="${menuList.ordSmenuInCategory}" var="smenuList">
                     		<c:if test="${smenuList.smenu ne null }">
		                        <div class="mp-menu popup-trigger" popup-class=".goods-order-con${smenuList.smenu.smenuCd}">
		                           <div class="text-wrap">
		                              <div class="title">${smenuList.smenu.smenuNm}</div>
		                              <div class="price"><fmt:formatNumber value="${smenuList.smenu.priceLan}" type="number"/><span>${smenuList.smenu.unit}</span></div>
		                           </div>
		                           <div class="img"><img class="main-img" src="${imgPath}${smenuList.smenu.smenuImg}"></div>
		                           <span class="notranslate">
		                           <div class="order-count order-count-con order-count-con${smenuList.smenu.smenuCd}">0</div>
		                           </span>
		                           <span class="notranslate"><input type="hidden" name="orderCount" value="0"/></span>
		                        </div>
		                        <div class="popup-wrap goods-order goods-order-con${smenuList.smenu.smenuCd}">
						         <div class="popup">
						         	<input type="hidden" name="smenuCd" value="${smenuList.smenu.smenuCd}"/>
						         	<input type="hidden" name="categoryCd" value="${menuList.categoryCd}"/>
						            <div class="popup-con">
						               <div class="mySwiper">
					                  	<div class="swiper-wrapper">
					                  		<c:forEach items="${smenuList.smenu.smenuImgList}" var="smenuImgList">
					                  			<div class="swiper-slide">
					                        		<img class="main-img" src="${imgPath}${smenuImgList}">
					                     		</div>
					                  		</c:forEach>
					                  	</div>
					                   <div class="swiper-pagination"></div>
					               	   </div>
						               <div class="title title-menu">${smenuList.smenu.smenuNm}</div>
						               <div class="description">${smenuList.smenu.smenuDesc}</div>
						               <div class="price"><fmt:formatNumber value="${smenuList.smenu.priceLan}" type="number"/><span>${smenuList.smenu.unit}</span></div>
						               <div class="option-list">
						               <c:forEach items="${smenuList.smenu.smenuOptTps}" var="smenuOptList">
						               <!-- 필수옵션 -->
						               	<c:if test="${smenuOptList.optTpCd eq '21'}">
						               		<c:choose>
						               			<c:when test="${smenuOptList.smenuOptTpMaxCnt eq '1'}">
									               <div class="option-wrap option-wrap-req">
									                  <div class="title-wrap">
									                     <div class="title title-radioReq">${smenuOptList.smenuOptTpNmLan}</div>
									                     <div class="required">필수</div>
									                  </div>
									                  <c:forEach items="${smenuOptList.smenuOpts}" var="smenuOpts">
										                  <div class="mp-option">
										                     <div class="radio-wrap">
										                        <input type="hidden" class="required" value="Y"/>
										                        <input type="radio" class="option" name="radio${smenuList.smenu.ord}-${smenuOptList.ord}" id="radio${smenuList.smenu.ord}-${smenuOpts.ord}"><label for="radio${smenuList.smenu.ord}-${smenuOpts.ord}">${smenuOpts.smenuOptNmLan}</label>
										                        <input type="hidden" class="option-price" name="radioReq" value="${smenuOpts.priceLan}"/>
										                        <input type="hidden" class="smenuOpts" name="smenuOpts" value="${smenuOpts.smenuOptCd}"/>
										                     </div>
										                     <span class="notranslate">
										                     	<div class="p-add">+<fmt:formatNumber value="${smenuOpts.priceLan}" type="number"/>${smenuList.smenu.unit}</div>
										                     </span>
										                  </div>
									                  </c:forEach>
									               </div>
						               			</c:when>
						               			<c:otherwise>
						               				<div class="option-wrap option-wrap-req option-wrap-max">
									                  <div class="title-wrap">
									                     <div class="title title-checkReq">${smenuOptList.smenuOptTpNmLan}</div>
									                     <div class="op-limit">최대 ${smenuOptList.smenuOptTpMaxCnt}개 선택</div>
									                     <input type="hidden" class="maxCnt" value="${smenuOptList.smenuOptTpMaxCnt}" />
									                     <div class="required">필수</div>
									                  </div>
									                  <c:forEach items="${smenuOptList.smenuOpts}" var="smenuOpts">
										                  <div class="mp-option">
										                     <div class="checkbox-wrap">
										                        <input type="hidden" class="required" value="Y"/>
										                        <input type="checkbox" class="option"name="check${smenuList.smenu.ord}-${smenuOpts.ord}" id="check${smenuList.smenu.ord}-${smenuOpts.ord}"><label for="check${smenuList.smenu.ord}-${smenuOpts.ord}">${smenuOpts.smenuOptNmLan}</label>
										                        <input type="hidden" class="option-price" name="checkReq" value="${smenuOpts.priceLan}"/>
										                        <input type="hidden" class="smenuOpts" name="smenuOpts" value="${smenuOpts.smenuOptCd}"/>
										                     </div>
										                     <span class="notranslate">
										                     	<div class="p-add">+<fmt:formatNumber value="${smenuOpts.priceLan}" type="number"/>${smenuList.smenu.unit}</div>
										                     	</span>
										                  </div>
									                  </c:forEach>
									                </div>
						               			</c:otherwise>
						               		</c:choose>
								        </c:if>
						               </c:forEach>
						               <c:forEach items="${smenuList.smenu.smenuOptTps}" var="smenuOptList">
						               	<c:if test="${smenuOptList.optTpCd eq '22'}">
						               		<div class="option-wrap option-wrap-max">
						               			<div class="title-wrap">
						               				<div class="title title-checkOpt">${smenuOptList.smenuOptTpNmLan}</div>
									                <div class="op-limit">최대 ${smenuOptList.smenuOptTpMaxCnt}개 선택</div>
									                <input type="hidden" class="maxCnt" value="${smenuOptList.smenuOptTpMaxCnt}" />
									                <div class="optional">선택</div>
									            </div>
									            <c:forEach items="${smenuOptList.smenuOpts}" var="smenuOpts">
										        	<div class="mp-option">
										            	<div class="checkbox-wrap">
										                	<input type="hidden" class="required" value="N"/>
										                    <input type="checkbox" class="option" name="check${smenuList.smenu.ord}-${smenuOpts.ord}" id="check${smenuList.smenu.ord}-${smenuOpts.ord}"><label for="check${smenuList.smenu.ord}-${smenuOpts.ord}">${smenuOpts.smenuOptNmLan}</label>
										                    <input type="hidden" class="option-price" name="chekcOpt" value="${smenuOpts.priceLan}"/>
										                    <input type="hidden" class="smenuOpts" name="smenuOpts" value="${smenuOpts.smenuOptCd}"/>
										                </div>
										                <span class="notranslate">
										            		<div class="p-add">+<fmt:formatNumber value="${smenuOpts.priceLan}" type="number"/>${smenuList.smenu.unit}</div>
										            	</span>
										            </div>
												</c:forEach>
									        </div>
						               	</c:if>
						               </c:forEach>
						               </div>
						               <div class="quantity-wrap">
						                  <div class="title">수량</div>
						                  <div class="quantity-input-wrap">
						                     <span class="btn-decrease btn-quantity"><img src="<%= request.getContextPath() %>/qr/img/minus.png"></span>
						                     <input class="quantity" type="text" name="" value="1" disabled="">
						                     <span class="btn-increase btn-quantity"><img src="<%= request.getContextPath() %>/qr/img/plus.png"></span>
						                  </div>
						               </div>
						            </div>
						            <div class="btn-wrap two-btn">
						               <a href="#" class="btn btn-l btn-gray popup-close cancel">취소</a>
						               <a href="#" class="btn btn-l btn-d-gray add-cart"><span class="add-cart-sum"><fmt:formatNumber value="${smenuList.smenu.priceLan}" type="number"/></span><span> ${smenuList.smenu.unit}</span> 담기</a>
						               <input type="hidden" name="addCartSum" value="${smenuList.smenu.priceLan}"/>
						            </div>
						         </div>
						      </div>
					      </c:if>
                        </c:forEach>
                     </div>
                  </div>
               	</c:forEach>
                  <p class="info-text">모든 메뉴를 확인 하셨습니다.</p>
               </div>
               <div class="sum">
                  <div class="price-sum">
                     <span class="title">총 금액</span>
                     <div class="price total-price">
                        0<span>원</span>
                     </div>
                     <input type="hidden" name="totalPrice" value="0"/>
                  </div>
                  <div class="btn-sum">
                     <%-- <a href="<%= request.getContextPath() %>/qr/showCart/${storeRoom.storeRoomCd}" onclick="goCart();"class="btn btn-l btn-d-gray">장바구니</a> --%>
                     <a href="#" onclick="goCart();" class="btn btn-l btn-d-gray">장바구니</a>
                     <span class="notranslate">
                     <div class="order-count cart-count">0</div>
                     <input type="hidden" name="cartCount" value="0"/>
                     </span>
                  </div>
               </div>
            </div>
            <div class="menu-con store-info">
               <div class="store-img">
                 <%-- <img src="<%= request.getContextPath() %>/qr/img/store.jpg"> --%>
                 <c:choose>
                 	<c:when test="${fn:length(storeRoom.store.storeImgList) > 0}">
                 		<img src="${imgPath}${storeRoom.store.storeImgList[0]}">
                 	</c:when>
                 	<c:otherwise>
		                 <img src="<%= request.getContextPath() %>/qr/img/store.jpg">
                 	</c:otherwise>
                 </c:choose>
               </div>
               <div class="store-info-list">
                  <div class="icon-wrap">
                     <img src="<%= request.getContextPath() %>/qr/img/i-clock.png">
                  </div>
                  <div class="info-text-wrap">
                     <div class="info-text">
                        <div class="title-s">운영시간</div>
                        <c:set var="openTm" value="${fn:split(storeRoom.store.openTm, ',')}" />
                        <c:forEach var="openTmValue" items="${openTm}">
                        	<div class="data">${openTmValue}</div>
                        	<input type="hidden" name="openTm" value="${openTmValue}"/>
					    </c:forEach>
					    <c:if test="${storeRoom.store.breakTmList ne null and storeRoom.store.breakTmList != ''}">
					    	<c:forEach var="breakTmList" items="${storeRoom.store.breakTmList}">
					    		<div class="data">브레이크 타임 ${breakTmList}</div>
					    		<input type="hidden" name="breakTm" value="${breakTmList}"/>
					    	</c:forEach>
					    </c:if>
					    <c:if test="${storeRoom.store.holiday ne null and storeRoom.store.holiday != ''}">
					    	<div class="data">휴무일 ${storeRoom.store.holiday}</div>
					    	<input type="hidden" name="holiTm" value="${storeRoom.store.holiday}"/>
					    </c:if>
					    <c:if test="${storeRoom.store.vactionDay ne null and storeRoom.store.vactionDay != ''}">
					    	<div class="data vactionDay"></div>
					    	<input type="hidden" name="vactionDay" value="${storeRoom.store.vactionDay}"/>
					    </c:if>
                     </div>
                  </div>
               </div>
               <div class="store-info-list">
                  <div class="icon-wrap">
                     <img src="<%= request.getContextPath() %>/qr/img/i-phone.png">
                  </div>
                  <div class="info-text-wrap">
                     <div class="info-text">
                        <div class="title-s">전화번호</div>
                        <div class="data"><a href="tel:${storeRoom.store.tel}" class="s-phone-call">${storeRoom.store.tel}</a></div>
                     </div>
                  </div>
               </div>
               <div class="store-info-list">
                  <div class="icon-wrap">
                     <img src="<%= request.getContextPath() %>/qr/img/i-shop.png">
                  </div>
                  <div class="info-text-wrap">
                     <div class="info-text">
                        <div class="title-s">운영안내</div>
                        	<div class="data">${fn:replace(storeRoom.store.storeDescLan, newLine, '<br/>')}</div>
                     </div>
                     <div class="info-text">
                        <div class="title-s">주소</div>
                        <div class="data">${storeRoom.store.storeAddrLan}</div>
                     </div>
                     <div class="info-text">
                        <div class="title-s">대표자명</div>
                        <div class="data">${storeRoom.store.ceoNm}</div>
                     </div>
                     <%-- <div class="info-text">
                        <div class="title-s">사업자 번호</div>
                        <div class="data">${storeRoom.store.busiNum}</div>
                     </div> --%>
                  </div>
               </div>
            </div>
            <div class="menu-con order-history">
               <div class="search">
                  <input type="number" name="BuyerTel" placeholder="휴대폰 번호를 입력하세요.">
                  <a href="#" class="btn btn-m btn-d-gray order-search">조회</a>
               </div>
            </div>
         </div>
      </section>
      <div class="popup-wrap no-menu noti">
         <div class="popup">
            <div class="popup-con">
                <p class="title">메뉴를 선택해주세요</p>
            </div>
            <div class="btn-wrap">
               <a href="#" class="btn btn-l btn-d-gray popup-close">확인</a>
            </div>
         </div>
      </div>
      <div class="popup-wrap no-order noti">
         <div class="popup">
            <div class="popup-con">
                <p class="title">주문내역이 없습니다.</p>
            </div>
            <div class="btn-wrap">
               <a href="#" class="btn btn-l btn-d-gray popup-close">확인</a>
            </div>
         </div>
      </div>
      <div class="popup-wrap no-tel noti">
         <div class="popup">
            <div class="popup-con">
                <p class="title">전화번호가 유효하지 않습니다.</p>
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
                  </div>
                  </c:forEach>
                  <c:if test="${storeRoom.store.breakTmList ne null and storeRoom.store.breakTmList != ''}">
                  	<div class="info-wrap">
                  		<c:forEach var="breakTmList" items="${storeRoom.store.breakTmList}">
	                  		<div class="day">브레이크 타임 ${breakTmList}</div>
	                  	</c:forEach>
                  	</div>
                  </c:if>
                  <c:if test="${storeRoom.store.holiday ne null and storeRoom.store.holiday != ''}">
                  	<div class="info-wrap">
                  		<div class="day">휴무일 ${storeRoom.store.holiday}</div>
                  	</div>
                  </c:if>
                  <c:if test="${storeRoom.store.vactionDay ne null and storeRoom.store.vactionDay != ''}">
                  	<div class="info-wrap">
                  		<div class="day vactionDay"></div>
                  	</div>
                  </c:if>
               </div>
            </div>
            <div class="btn-wrap">
               <a href="#" class="btn btn-l btn-gray popup-close">확인</a>
            </div>
         </div>
      </div>
   </div>
</body>
</html>