/* 
 * jQuery hint extension.
 *    Displays "hint" watermark on input boxes if no other value is present.
 *
 * Author: Tyler Larson <devel@tltech.com>
 * Copyright: Tyler Larson 2012
 * License: GPLv2 <http://www.gnu.org/licenses/gpl-2.0.html>
 */
(function($) {

	/* Override .val() in order to filter out hints */
	var val_original = $.fn.val_hint_orig = $.fn.val;	
	$.fn.val = function(value) {
		if (typeof value == 'undefined') {
			var rtn = val_original.call(this);
			// getter; filter for hint
			var hint = $(this).data('hint');
			if (hint && (hint == rtn)) rtn = "";
			return rtn;
		} else {
			return val_original.call(this,value);
		}
	}

	/* Main plugin function */
	$.fn.hint = function(options) {
		var settings = { 
			classon: 'hint',
			classoff: '',
			attr: 'hint',
			text: ''
		}
		if (options) $.extend(settings,options);
		
		function hintText($field) {
			return $field.data("hint");
		}
		
		function clearHint($field) {
			if (settings.classon && $field.hasClass(settings.classon)) $field.removeClass(settings.classon);
			if (settings.classoff) $field.addClass(settings.classoff);			
			if (hintText($field) == $field.val_hint_orig()) $field.val_hint_orig('');
		}
		
		function addHint($field) {
			if (!$field.val_hint_orig()) {
				$field.val_hint_orig(hintText($field));
				if (settings.classoff && $field.hasClass(settings.classoff)) $field.removeClass(settings.classoff);
				if (settings.classon) $field.addClass(settings.classon);			

			}
		}
		
		return this.each(function() {
			var $field = $(this);
			var hint = (settings.text) ? settings.text : $field.attr(settings.attr);
			if (hint && !hintText($field)) {
				$field.data("hint",hint);
				addHint($field);
				$field
					.focus(function() { clearHint($(this)); })
					.blur(function() { addHint($(this)); })
					.closest('form').submit(function() { clearHint($field); });
			}
		});
	};
	
	
})(jQuery);
