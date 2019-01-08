((document, $) => {
  const copyToClipboard = ($self) => {
    $self.on('click', () => {
      const toCopy = $self.data('copy-to-clipboard');
      const successMessage = $self.data('copy-to-clipboard-success');
      const $copyEl = $('<textarea></textarea>');
      const copyElement = $copyEl[0];

      $self.after($copyEl);

      $copyEl.val(toCopy).focus().select();
      document.execCommand('copy');
      $copyEl.remove();

      $self.addClass('success').text(successMessage);
    });
  };

  $(() => {
    $('[data-copy-to-clipboard]').each((i, el) => {
      copyToClipboard($(el));
    });
  });
})(document, jQuery);
