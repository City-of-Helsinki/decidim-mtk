(($) => {
  const closeMap = ($self) => {
    $self.on('click', (_) => {
      $('[data-toggle-scrollto]').removeClass('showing-map');
    });
  };

  $(() => {
    $('[data-close-map]').each((i, el) => {
      closeMap($(el));
    });
  });
})(jQuery);
