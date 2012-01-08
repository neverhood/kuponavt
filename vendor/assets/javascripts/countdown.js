Date.prototype.toUTC = function() {
    return new Date(this.getUTCFullYear(), this.getUTCMonth(), this.getUTCDate(), this.getUTCHours(), this.getUTCMinutes(), this.getUTCSeconds());
}

(function($) {
	$.fn.countdown = function (date, options) {
		options = $.extend({
			lang: {
				days:    [' день ', ' дня ', ' дней '],
				hours:   [':', ':', ':'],
				minutes: [':', ':', ':'],
				seconds: ['', '', ''],
				plurar:  function(n) {
					return (n % 10 == 1 && n % 100 != 11 ? 0 : n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) ? 1 : 2);
				}
			}, 
			prefix: "Осталось: ", 
			finish: "Всё"			
		}, options);
		
		var timeDifference = function(begin, end) {
		    if (end < begin) {
			    return false;
		    }
		    var diff = {
		    	seconds: [end.getSeconds() - begin.getSeconds(), 60],
		    	minutes: [end.getMinutes() - begin.getMinutes(), 60],
		    	hours: [end.getUTCHours() - begin.getHours(), 24],
                days: [end.getUTCDate()  - begin.getDate(), new Date(begin.getYear(), begin.getMonth() + 1, 0).getDate()]
               // months: [end.getMonth() - begin.getMonth(), 12],
               // years: [end.getYear()  - begin.getYear(), 0]
		    };
		    var result = new Array();
		    var flag = false;
		    for (i in diff) {
		    	if (flag) {
		    		diff[i][0]--;
		    		flag = false;
		    	}    	
		    	if (diff[i][0] < 0) {
		    		flag = true;
		    		diff[i][0] += diff[i][1];
		    	}
		    	if (!diff[i][0] && options.lang[i] == options.lang.days ) continue;

                if ( options.lang[i] == options.lang.days ) {
                    var monthDiff = ( end.getUTCMonth() - begin.getMonth() >= 0 ) ? ( end.getUTCMonth() - begin.getMonth() ) : 12,
                        yearDiff = ( end.getUTCYear() - begin.getYear() >= 0 ) ? ( end.getUTCYear() - begin.getYear() ) : 0;

                    diff[i][0] = (monthDiff * 30) + (yearDiff * 365) + diff[i][0];
                }

                var num = (diff[i][0] < 10 && options.lang[i] != options.lang.days) ? '0' + diff[i][0] : diff[i][0];

			    result.push(num + '' + options.lang[i][options.lang.plurar(diff[i][0])]);
		    }
		    return result.reverse().join('');
		};
		var elem = $(this);
		var timeUpdate = function () {
            var utcTime = new Date().toUTC(),
                serverTime = new Date( utcTime.setHours( utcTime.getHours() + 2 ) );
		    var s = timeDifference(serverTime, date);

		    if (s.length) {
		    	elem.html(options.prefix + s).
                    data('countdown', true);
		    } else {
		        clearInterval(timer);
		        elem.html(options.finish);
		    }		
		};
		timeUpdate();
		var timer = setInterval(timeUpdate, 1000);		
	};
})(jQuery);
