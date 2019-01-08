(($, window, decodeURIComponent) => {
  $(() => {
    // Thanks to:
    // https://stackoverflow.com/questions/21825157/internet-explorer-11-detection
    const isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
    if (!isIE11) {
      return;
    }

    // When the page has the bottom comments element, IE11 leaves an extra white
    // line to the body before the footer element for some unexplainable reason.
    // It is somehow related to multiple components on the page and the inline
    // <script> and <link> tags. As it turned out to be a combination of things,
    // it seems near to impossible to find exactly the reason. Sometimes it
    // renders perfectly fine and sometimes not.
    //
    // To "hide" this bug, we add an extra hack that changes the main wrapper's
    // (.off-canvas-wrapper) background color so that the extra margin at the
    // bottom of the screen will be rendered in that color.
    //
    // This issue applies to the single proposal page.
    const $bottom = $('.expanded .wrapper--inner');
    if ($bottom.length > 0) {
      const bodyBgColor = $('.off-canvas-wrapper').css('background-color');
      const bottomBgColor = $bottom.css('background-color');
      const $sep = $('.footer-separator');
      const $main = $('main', $sep);
      const $wrapper = $('> .wrapper', $main);

      $sep.css('background-color', bottomBgColor);
      $wrapper.css('background-color', bodyBgColor);
      $('.koro.koro-basic-copper-light', $main).css('background-color', bodyBgColor);
    }
  });
})(jQuery, window, window.decodeURIComponent);
