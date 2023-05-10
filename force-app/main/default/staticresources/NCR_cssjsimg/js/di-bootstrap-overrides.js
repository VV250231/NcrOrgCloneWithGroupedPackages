/*!
 * Leapfrog-Bootstrap-Overrides for v3.3.4
 */


if (typeof jQuery === 'undefined') {
    throw new Error('LeapFrog-Bootstrap-override\'s JavaScript requires jQuery')
}
+function ($) {
    'use strict';
    var version = $.fn.jquery.split(' ')[0].split('.')
    if ((version[0] < 2 && version[1] < 9) || (version[0] == 1 && version[1] == 9 && version[2] < 1)) {
        throw new Error('LeapFrog-Bootstrap-override\'s JavaScript requires jQuery version 1.9.1 or higher')
    }
    if(console){
        console.log('::.. LeapFrog-Bootstrap-override\'s init ...');
    }
}(jQuery);

var initPopoverOverrides = function(){

    $.fn.popover.Constructor.DEFAULTS.template = '<div class="popover" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><span aria-hidden="true" class="close popover-close" data-dismiss="popover" aria-label="Close" >&times;</span><div class="popover-content"></div></div>';

    $('[data-toggle="popover"]').popover({html:true});

    $('body').on('click', function (e) {
        $('[data-toggle="popover"]').each(function () {
            //the 'is' for buttons that trigger popups
            //the 'has' for icons within a button that triggers a popup
            //console.log(">>"+e.target.className);
            if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
                $(this).popover('hide');
            }
            else if(e.target.className === 'close popover-close') {
                $(this).popover('hide');
            }

        });
    });
}

$(document).ready(function () {

    initPopoverOverrides();
});