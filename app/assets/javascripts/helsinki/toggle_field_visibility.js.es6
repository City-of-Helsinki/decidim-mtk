(($) => {
  const toggleFieldVisibility = ($self) => {
    function setVisibility() {
      const $target = $('#' + $self.data('toggle'));
      $target.toggleClass('hide', !$self.is(':checked'));
    }
    
    $self.on('change', (_) => { setVisibility(); });

    setVisibility();
  };

  $(() => {
    $('[data-toggle-field]').each((i, el) => {
      toggleFieldVisibility($(el));
    });
  });
})(jQuery);
