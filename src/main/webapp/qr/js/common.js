jQuery(document).ready(function(){
	//세션체크(총 금액, 메뉴수량, 장바구니 수량)
	if(sessionStorage.length != 0) {
		//총 수량
		var cartCount = $('input[name=cartCount]').val(sessionStorage.getItem("cartCount"));
		$('.cart-count').html(setComma(cartCount.val()));
		
		//총 금액
		var totalPrice = $('input[name=totalPrice]').val(sessionStorage.getItem("totalPrice"));
		$('.total-price').html(setComma(totalPrice.val()) + "<span>원</span>");
		
		
		for(var i = 0 ; i < sessionStorage.length; i++) {
			if(sessionStorage.key(i).includes("totalCnt")) {
				var totalCnt = JSON.parse(sessionStorage.getItem(sessionStorage.key(i)));
				$(".order-count-con" + sessionStorage.key(i).substr(8)).html(totalCnt); //상품별 수량
			}
		}
	}
	
	//메뉴 수량표시
	$('.order-count-con').each(function() {
		if($(this).text() == '0') {
			$(this).attr('style', 'display:none;');
		} else {
			$(this).attr('style', 'display:block;');
		}
	});
	
	if($('.cart-count').text() == '0') {
		$('.cart-count').attr('style', 'display:none;');
	} else {
		$('.cart-count').attr('style', 'display:block;');
	}
	

	//a링크 스크롤이동 막기
	$('a[href="#"]').click(function(event) {
		event.preventDefault();      
	});

	//gnb 메뉴 동작
	$(".menu-item").click(function(){
		var menuIndex = $(this).index();
		$(".menu-item").removeClass('active');
    	$(this).addClass('active');
    	$(".menu-con").removeClass('active');
    	$(".menu-con").eq(menuIndex).addClass('active');
  	});

	//메뉴 그룹 닫기 열기
  	$(".tab-con .g-title").click(function(){
  		$(this).parent('.tab-con').toggleClass('off');
  		$(this).parent('.tab-con').find('.mp-menu-wrap').stop().slideToggle('400');
  		$(this).parent('.tab-con').find('.g-ex').stop().slideToggle('400');
  		Page__updateOffsetTop();
  	});

  	//약관 열기 닫기
  	$(".p-info h4").click(function(){
  		$(this).toggleClass('on');
  		$(this).parents('.p-info').next('.terms').stop().slideToggle('400');
  	});
  	
  	//헤더높이
	var top_space = 0;
		if ($('header').length) {
		top_space = $('header').outerHeight() + 51;
	}

  	//메뉴 그룹 이동
  	$('.tab').click(function(e) {
  		var this_btn = $(this);
    	var href = $(this).attr('href');
	    var targetTop = $(href).offset().top - top_space;
	    $(href).removeClass('off');
	    $(href).find('.mp-menu-wrap').show();
	    $(href).find('.g-ex').stop().show();
	    Page__updateOffsetTop();
	    $('html').stop().animate({scrollTop:targetTop}, 300, function(){
			$(".tab.on").removeClass('on');
   			this_btn.addClass('on');});

	    e.preventDefault();
	});

  	//현재 메뉴 그룹 표시
  	function Page__updateIndicatorActive() {
    	var scrollTop = $(window).scrollTop() + top_space + 100;
    	
	    $($('.tab-con').get().reverse()).each(function(index, node) {
	        var $node = $(this);
	        var offsetTop = parseInt($node.attr('data-offset-top'));
	        
	        if ( scrollTop >= offsetTop ) {
	            $('.tab-wrap .tab.on').removeClass('on');
	            var currentPageIndex = $node.index();
	            var currentTab = $('.tab-wrap .tab').eq(currentPageIndex);
	            currentTab.addClass('on');
	            setTimeout(function(){muCenter(currentTab);}, 100);
	            return false;
	        }
	    });
	}

	//메뉴 그룹 위치 최신화
	function Page__updateOffsetTop() {
	    
	    $('.tab-con').each(function(index, node) {
	        var $page = $(node);
	        var offsetTop = $page.offset().top;
	        
	        $page.attr('data-offset-top', offsetTop);
	    });
	    
	    Page__updateIndicatorActive();
	}

	function Page__init() {
	    Page__updateOffsetTop();
	}

	Page__init();

	$(window).resize(Page__updateOffsetTop);
	$(window).scroll(Page__updateIndicatorActive);


	//현재 메뉴 버튼 가운데 정렬
	function muCenter(currentTab){
    	var targetPos = currentTab.position().left;
    	var boxWidth = $('.tab-g').width();
    	var wrapWidth = $('.tab-wrap').width();
    	var selectTargetPos = targetPos + currentTab.outerWidth()/2;
    	var pos;

    	if (selectTargetPos <= boxWidth/2)  {
        	pos = 0
        	$('.tab-g').removeClass('center');
        	$('.tab-g').addClass('front');
    	}
    	else if (wrapWidth - selectTargetPos <= boxWidth/2) {
        	pos = wrapWidth-boxWidth +15;
        	$('.tab-g').removeClass('center');
        	$('.tab-g').addClass('back');
    	}
    	else {
        	pos = targetPos + (currentTab.outerWidth()/2) - boxWidth/2;
        	$('.tab-g').removeClass('front');
        	$('.tab-g').removeClass('back');
        	$('.tab-g').addClass('center');
    	}
    
    	if(wrapWidth > boxWidth) {
    	setTimeout(function() {
				$('.tab-g').stop().animate({
			   		scrollLeft : pos
			   	}, 100 );
			},100);
		}
		 
	};
	/*상품상세 이미지 스와이프*/
  	var swiper = new Swiper(".mySwiper", {
  		autoHeight: true,
  		loop: true,
      pagination: {
        el: ".swiper-pagination",
      },
    });
	/*popup*/
	function popupOn(targetPopup){
		$('.popup-wrap').removeClass('on');
		$(targetPopup).addClass('on');
	}
	function popupOff(targetPopup){
		$(targetPopup).removeClass('on');
	}

	$('.popup-trigger').click(function(){
		scrollDisable();
		var targetPopup = $(this).attr('popup-class');
		popupOn(targetPopup);
	});
	
	//주문상세리스트 동적바인딩
	$(document).on('click', '.order-popup', function(){
		scrollDisable();
		var targetPopup = $(this).attr('popup-class');
		popupOn(targetPopup);
	});

	$('.popup-close').click(function(){
		scrollAble();
		var targetPopup = $(this).parents('.popup-wrap.on');
		popupOff(targetPopup);
	});
	
	//주문상세팝업 닫기 동적바인딩
	$(document).on('click', '.popup-close', function(){
		scrollAble();
		var targetPopup = $(this).parents('.popup-wrap.on');
		popupOff(targetPopup);
	});
	
	$('.cancel').click(function(){
		scrollAble();
		var targetPopup = $(this).parents('.popup-wrap.on');
		popupOff(targetPopup);
		
		var price = setComma($(this).parents('.popup').find($('input[name=addCartSum]')).val()); //상품 기본금액
		$(this).parents('.popup').find('.option').prop('checked', false); //옵션체크 해제
		$(this).parents('.popup').find('.quantity').val('1');
		$(this).parents('.popup').find('.add-cart-sum').text(price);
	});

	/*popup body 스크롤 막기*/
	function scrollDisable(){
    $('body').addClass('scrollDisable').on('scroll touchmove mousewheel', function(e){
        e.preventDefault();
	    });
	}
	function scrollAble(){
	    $('body').removeClass('scrollDisable').off('scroll touchmove mousewheel');
	}

	//수량 옵션(팝업)
	$('.btn-quantity').click(function(e){
	        e.preventDefault();
	        var $count = $(this).parent('.quantity-input-wrap').find('.quantity');
	        var now = parseInt($count.val());
	        var min = 1;
	        var max = 999;
	        var num = now;
	        if($(this).hasClass('btn-decrease')){
	            var type = 'm';
	        }else{
	            var type = 'p';
	        }
	        if(type=='m'){
	            if(now>min){
	                num = now - 1;
	            }
	        }else{
	            if(now<max){
	                num = now + 1;
	            }
	        }
	        if(num != now){
	            $count.val(num);
	        }
	    addCartSum = changeAddCartSum($(this)); //총금액
	    $(this).parents('.popup').find('.add-cart-sum').text(addCartSum);
	    $(this).parents('.popup').find('.change-cart-sum').text(addCartSum);
	});
	
	//수량 옵션(장바구니)
	$('.btn-change').click(function(e) {
		e.preventDefault();
		
		const regex3 = /[^0-9]/g;
		
		var $count = $(this).parent('.quantity-input-wrap').find('.quantity');
	    var now = parseInt($count.val());
	    var min = 1;
	    var max = 999;
	    var num = now;
	    var price = parseInt($(this).parents('.cart-goods').find('.price').text().replace(',', '').replace(regex3, '')) / num; //기본가격
	    //var price = parseInt($(this).parents('.cart-goods').find('.price').text().replace(',', '').replace('원', '')) / num; //기본가격
	    var sumCount = parseInt($('.sum-count').text()); //장바구니 수량
	    var sumPrice = parseInt($('.sum-price').text().replace(',', '').replace(regex3, '')); //총 가격
	    //var sumPrice = parseInt($('.sum-price').text().replace(',', '').replace('원', '')); //총 가격
	    if($(this).hasClass('btn-decrease')){
	        var type = 'm';
	    }else{
	        var type = 'p';
	    }
	    if(type=='m'){
	        if(now>min){
	            num = now - 1;
	            sumCount = sumCount - 1;
	            sumPrice = sumPrice - price;
	        }
	    }else{
	        if(now<max){
	            num = now + 1;
	            sumCount = sumCount + 1;
	            sumPrice = sumPrice + price;
	        }
	    }
	    if(num != now){
	        $count.val(num);
	    }

	    $(this).parents('.cart-goods').find('.price').html(setComma(price * num) + '<span>원</span>'); //메뉴 가격
	    $('.sum-count').text(sumCount); //장바구니 수량
	    $('.sum-price').html(setComma(sumPrice) + '<span>원</span>'); //총 수량
	    
	    
	    //팝업내용(수량, 가격 변경)
	    var popupClass = "." + $(this).siblings('input[name=cartNum]').val();
	    $(popupClass).find('.change-cart-sum').text(setComma(price * num)); //메뉴 가격
	    $(popupClass).find('.quantity').val(num); //수량
	});
	
	//옵션 변경
	$('.checkbox-wrap input, .radio-wrap input').change(function(e) {
		if(menuplus.maxCheck($(this))) {
			var addCartSum = changeAddCartSum($(this));
			$(this).parents('.popup').find('.add-cart-sum').text(addCartSum);
			$(this).parents('.popup').find('.change-cart-sum').text(addCartSum);			
		}
	});
	
	//장바구니 담기
	$('.add-cart').click(function() {
		if(menuplus.checkOption($(this))) {
			var addCartSum = Number($(this).find('.add-cart-sum').text().replace(',', '')); //상품금액
			var count = Number($(this).parents('.popup').find('.quantity').val()); //선택 수량
			var cartCount = Number($(this).parents('html').find('.cart-count').text()); //장바구니 수
			var orderCount = Number($(this).parents('.popup-wrap').prev('.mp-menu').find('.order-count').html()); //기존 상품 수량
			var totalPrice = Number($('input[name=totalPrice]').val()); //총금액
			
			//총금액(선택금액 + 기존금액) 
			$(this).parents('html').find('.total-price').html(setComma(addCartSum + totalPrice) + '<span>원</span>');
			$('input[name=totalPrice]').val(addCartSum + totalPrice);
			
			//총수량(기존수량 + 선택수량)
			$(this).parents('html').find('.cart-count').html(cartCount + count);
			$(this).parents('html').find('input[name=cartCount]').val(cartCount + count);
			$(this).parents('html').find('.cart-count').attr('style', 'display:block;');
			
			//메뉴수량(기존메뉴수량 + 선택수량)
			$(this).parents('.popup-wrap').prev('.mp-menu').find('.order-count').html(orderCount + count);
			$(this).parents('.popup-wrap').prev('.mp-menu').find('input[name=orderCount]').val(orderCount + count);
			$(this).parents('.popup-wrap').prev('.mp-menu').find('.order-count').attr('style', 'display:block;')
			
			
			setCartData($(this)); //장바구니 데이터 생성
			
			//옵션선택, 수량 초기화
			var price = setComma($(this).parents('.popup').find($('input[name=addCartSum]')).val()); //상품 기본금액
			$(this).parents('.popup').find('.option').prop('checked', false); //옵션체크 해제
			$(this).parents('.popup').find('.quantity').val('1');
			$(this).parents('.popup').find('.add-cart-sum').text(price);
			
			//팝업닫기
			$('.goods-order').removeClass('on');
		}
		scrollAble();
	});
	
	//옵션 변경 금액
	function changeAddCartSum(e) {
		
		const regex2 = /[^0-9]/g;
		
		var sum = Number(e.parents('.popup').find('input[name=addCartSum]').val().replace(',', '').replace(regex2, '')); //상품 기본금액
		//var sum = Number(e.parents('.popup').find('input[name=addCartSum]').val().replace(',', '').replace('원', '')); //상품 기본금액
		var count = Number(e.parents('.popup').find('.quantity').val()); //상품 수량
		
		e.parents('.popup').find('.option').each(function() {
			var chk = $(this).is(':checked');
			if(chk) {
				$(this).attr('checked', 'checked');
				sum += Number($(this).siblings('.option-price').val());
			} else {
				$(this).removeAttr('checked');
			}
		});
		return setComma(sum * count);
	}
	
	//장바구니 생성
	function setCartData(e) {
		var storeRoomCd = $('input[name=storeRoomCd]').val();
		var smenuCd = e.parents('.popup').find('input[name=smenuCd]').val(); //메뉴코드
		var categoryCd = e.parents('.popup').find('input[name=categoryCd]').val(); //메뉴코드
		var menuImg = e.parents('.popup').find('.main-img').attr("src"); //이미지경로
		var menuTitle = e.parents('.popup').find('.title-menu').text(); //메뉴명
		var optionTitle = new Array(); //옵션명
		var optionList = new Array(); //옵션내용
		var defaultPrice = e.parents('.popup').find('.price').text(); //상품가격
		var menuCnt = e.parents('.popup').find('.quantity').val(); //상품개수
		var addCartSum = e.parents('.popup').find('.add-cart-sum').text(); //상품 총금액
		var totalPrice = e.parents('html').find('.total-price').html(); //전체 금액
		var moid = "cartData_" + storeRoomCd + "_" + smenuCd + "_" + getMoid(); //주문번호
		var html = "";
		
		//장바구니용 옵션팝업 생성(radio, checkbok id값 변경)
		e.parents('.popup').find('.option').each(function() {
			var optionId = $(this).attr("id");
			$("#" + optionId).attr("id", optionId + "_" + moid);
			$(this).next().attr("for", optionId + "_" + moid);
			
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
		var popup = e.parents('.popup-wrap').find('.option-list').html(); //팝업정보
		
		//옵션팝업 초기화(radio, checkbok id값 초기화)
		e.parents('.popup').find('.option').each(function() {
			var optionId = $(this).attr("id");
			$("#" + optionId).attr("id", optionId.substring(0, optionId.length - moid.length - 1));
			$(this).next().attr("for", optionId.substring(0, optionId.length - moid.length - 1));
		});
		
		var cart = {
				moid : moid,
				storeRoomCd : storeRoomCd,
				smenuCd : smenuCd,
				categoryCd : categoryCd,
				menuImg : menuImg,
				menuTitle : menuTitle,
				optionTitle : optionTitle,
				defaultPrice : defaultPrice,
				optionList : optionList,
				menuCnt : menuCnt,
				addCartSum : addCartSum,
				popup : popup
		}
		console.log(cart);

		var totalPrice = $('input[name=totalPrice]').val();
		var cartCount = $('input[name=cartCount]').val();
		var totalCnt = e.parents('.popup-wrap').prev('.mp-menu').find('.order-count').html(); //메뉴별 총 수량
		
		sessionStorage.setItem(moid, JSON.stringify(cart)); // 장바구니 세션담기
		sessionStorage.setItem("totalCnt" + smenuCd, totalCnt); //메뉴별 총수량 세션담기
		sessionStorage.setItem("totalPrice", totalPrice); //총금액 세션담기
		sessionStorage.setItem("cartCount", cartCount); //총수량 세션담기	
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
	
	function setCookie(name, value) {
		var date = new Date();
		date.setTime(date.getTime() + 60*60);
		document.cookie = name + '=' + escape(value) + ';expires=' + date.toUTCString() + ';path=/';
		alert("쿠키셋팅 성공");
	}
	
	function getCookie(name) {
		var value = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');
		return value? value[2] : null;
	}
});

var menuplus={
		openTime:function() {
			//운영시간 체크
			var days = ["일", "월", "화", "수", "목", "금", "토"]
			var date = new Date();
			var year = date.getFullYear(); //년도
			var month = date.getMonth() + 1; //월
			var day = days[date.getDay()]; //요일 - 일 : 0, 월: 1, 화 : 2, 수 : 3, 목 : 4, 금 : 5, 토 : 6
			var numDay = date.getDate(); //일수
			var hour = date.getHours(); //시간
			var minute = date.getMinutes() //분
			
			month = month >= 10 ? month : '0' + month;
			numDay = numDay >= 10 ? numDay : '0' + numDay;
			hour = hour >= 10 ? hour : '0' + hour;
		    minute = minute >= 10 ? minute : '0' + minute;
		    
			var time = hour + "" + minute;
			
			console.log("현재시간 : " + day + "(" + time + ")");
			var regWeekday = /[월화수목금]/;
			var regHoliday = /[토일]/;
			
			var openCheck = true;
			//영업시간 체크
			if(openCheck) {
				$('input[name=openTm]').each(function(index) {
					if(regWeekday.test(day)) {
						console.log("주중 :" + day);
					}
					
					if(regHoliday.test(day)) {
						console.log("주말 :" + day);
					}
					console.log("운영시간 : " + $(this).val());	
					console.log($(this).val().includes(day));
					if($(this).val().includes(day) || ($(this).val().includes("주중") && regWeekday.test(day))
							|| ($(this).val().includes("주말") && regHoliday.test(day))) { //운영시간
						var openTime = $(this).val().replace(/[ㄱ-ㅎㅏ-ㅣ가-힣]/g, "").replace(/\s/gi, "").replace(/:/gi, ""); //한글제거, 공백제거, ':' 제거
						console.log("openTime: " + openTime);
						if(openTime != '24') { //24시간 미운영
							openTime = openTime.split("~"); // 09:00 ~ 18:00 => [0900, 1800](String to Array)
							console.log("오픈시간 : " + openTime[0]);
							console.log("마감시간 : " + openTime[1]);
							console.log("현재시간 : " + time);
							if(openTime[0] < time && time < openTime[1]) { //영업시간
								console.log("영업시간 포함 : " + $(this).val());
								$('.operating-hours').removeClass('on');
								openCheck = true;
							} else { //운영시간 체크(영업시간 전 or 영업마감)
								console.log("영업시간 미포함 : " + $(this).val());
								openCheck = false;
								$('.operating-hours').addClass('on');
								return false; //break
							}
						} else { //24시간 운영 ex)월화수목 24시간 / 금토일09:00 ~ 18:00
							console.log("영업시간 포함 : " + $(this).val());
							$('.operating-hours').removeClass('on');
							openCheck = true;
						}
					}else if($(this).val().includes("24시간")){ //24시간 운영(연중무휴) ex) 월화수목금토일 24시간
						console.log("영업시간 포함 : " + $(this).val());
						$('.operating-hours').removeClass('on');
						openCheck = true;
					}/* else { //미운영시간
						console.log("영업시간 미포함 : " + $(this).val());
						openCheck = false;
						$('.operating-hours').addClass('on');
						return false; //break
					}*/
				});
			}
			
			if(openCheck) {
				$('input[name=breakTm]').each(function() {
					console.log("브레이크 타임 : " + $(this).val());
					if($(this).val().includes(day)) {
						var breakTime = $(this).val().replace(/[ㄱ-ㅎㅏ-ㅣ가-힣]/g, "").replace(/\s/gi, "").replace(/:/gi, ""); //한글제거, 공백제거, ':' 제거
						console.log(breakTime);
						if(breakTime.includes(",")) { //브레이크타임 2개
							var timeList = breakTime.split(",");
							console.log(timeList);
							for(var i = 0; i < timeList.length; i++) {
								breakTime = timeList[i].split("~");
								console.log(breakTime);
								if(breakTime[0] < time && time < breakTime[1]) { //브레이크 타임
									openCheck = false;
									$('.operating-hours').addClass('on');
									console.log("breakTime : " + $(this).val());
									return false;
								} else { //영업시간
									console.log("not breakTime : " + breakTime);
									$('.operating-hours').removeClass('on');
									openCheck = true;
								}
							}
						} else { //브레이크타임 1개
							breakTime = breakTime.split("~");
							console.log("breakStart : " + breakTime[0]);
							console.log("breakEnd : " + breakTime[1]);
							console.log("현재시간 : " + time);
							
							if(breakTime[0] < time && time < breakTime[1]) { //브레이크 타임
								openCheck = false;
								$('.operating-hours').addClass('on');
								console.log("breakTime : " + $(this).val());
								return false;
							} else { //영업시간
								console.log("not breakTime : " +  $(this).val());
								$('.operating-hours').removeClass('on');
								openCheck = true;
							}
						}
					}
				});
			}
			
			if(openCheck) {
				$('input[name=holiTm]').each(function() {
					if($(this).val().includes(day) || $(this).val().includes(numDay)) {
						openCheck = false;
						$('.operating-hours').addClass('on');
						console.log("휴무일 : " + $(this).val());
						return false;
					}
				});
			}
			
			if(openCheck) {
				$('input[name=vactionDay]').each(function() {
					var vactionDay = $(this).val().replace(/[ㄱ-ㅎㅏ-ㅣ가-힣]/g, "").replace(/\s/gi, "").replace(/-/gi, "").split(","); //한글제거, 공백제거, '-' 제거
					var today = String(year) + String(month) + String(numDay);
					console.log(vactionDay);
					console.log(today);
					if(vactionDay.includes(today)) {
						openCheck = false;
						$('.operating-hours').addClass('on');
						console.log("휴가 : " + $(this).val());
						return false;
					}
				});
			}
			
			if(!openCheck) {
				$('.btn-sum').find('a').attr('popup-class', '.operating-hours');
			} else {
				$('.btn-sum').find('a').attr('popup-class', '.buyer-info');
			}
		},
		
		checkOption:function(e) {
			var check = true;
			e.parents('.popup').find('.option-wrap-req').each(function() {
				console.log("option-wrap-req : " + $(this).find('.title').text());
				$(this).find('.option').each(function() {
					console.log("option : " + $(this).is(':checked') + ", "+ $(this).next('label').text());
					check = $(this).is(':checked');
					
					if(check) return false; //break
				});
				
				console.log("check : " + check);
				if(!check) {
					alert($(this).find('.title').text() + " 선택은 필수입니다.");
					return false; //break
					
				}
				
			});
			
			return check;
		},
		
		maxCheck:function(e) {
			var maxCnt = e.parents('.option-wrap-max').find('.maxCnt').val();
			var checkCnt = 0;
			var check = true;
			
			e.parents('.option-wrap-max').find('.option').each(function() {
				if($(this).is(':checked')) {
					checkCnt++;
				}
			});
			
			if(maxCnt < checkCnt) {
				e.parents('.mp-option').find('input[type=checkbox]').prop('checked', false);
				e.parents('.mp-option').find('input[type=checkbox]').attr("checked");
				check = false;
			}
			
			if(!check) {
				alert(e.parents('.option-wrap-max').find('.title').text() + "은 최대 " + maxCnt + "개 선택 가능합니다.");
			}
			
			return check;
		},
		
		//콤마추가
		setComma:function(value){
			value = String(value);
	        value = value.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	        return value; 
	    },
		
		//쿠키셋팅
		setCookie:function(key, value) {
   			var date = new Date();
   			date.setTime(date.getTime() + (1*60*1000*60) * 3); //3시간
   			var cookieValue = escape(value) + "; path=/qr/" + "; expires=" + date.toGMTString();
   			document.cookie = key + "=" + cookieValue;
   		},
   		
   		//쿠키조회
   		getCookie:function(key) {
   			key = key + "=";
   			var cookieData = document.cookie;
   			var start = cookieData.indexOf(key);
   			var cookieValue = ";"
   			
   			if(start != -1) {
   				start += key.length;
   				var end = cookieData.indexOf(";", start);
   				
   				if(end == -1) {
   					end = cookieData.length;
   				}
   				
   				cookieValue = cookieData.substring(start, end);
   			}
   			
   			return unescape(cookieValue);
   		}
}