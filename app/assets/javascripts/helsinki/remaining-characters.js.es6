(($) => {
  var COUNT_KEY = '%count%';

  const remainingCharacters = ($input) => {
    const $target = $($input.data('remaining-characters'));
    const maxCharacters = parseInt($input.attr('maxlength'));

    if ($target.length > 0 && maxCharacters > 0) {
      const messagesJson = $input.data('remaining-characters-messages');
      const messages = $.extend({
        one: COUNT_KEY + ' character left',
        many: COUNT_KEY + ' characters left',
      }, messagesJson);

      const updateStatus = () => {
        var numCharacters = $input.val().length;
        var remaining = maxCharacters - numCharacters;
        var message = remaining === 1 ? messages['one'] : messages['many'];

        $target.text(message.replace(COUNT_KEY, remaining));
      };

      $input.on('keyup', () => {
        updateStatus();
      });
      updateStatus();
    }
  };

  $(() => {
    $('[data-remaining-characters]').each((i, el) => {
      remainingCharacters($(el));
    });
  });
})(jQuery);
