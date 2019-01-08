(($) => {
  const formFieldLink = ($self) => {
    $self.attr('target', '_blank');
  };

  $(() => {
    $('.checkbox label a, radio label a').each((i, el) => {
      formFieldLink($(el));
    });
  });
})(jQuery);
