(($, Math) => {
  const scrollTo = ($target) => {
    $("html, body").animate({
        scrollTop: Math.round($target.offset().top)
    }, 200);
  };

  $.fn.scrollTo = function() {
    return $(this).each(function() {
      scrollTo($(this));
    });
  };
})(jQuery, window.Math);
