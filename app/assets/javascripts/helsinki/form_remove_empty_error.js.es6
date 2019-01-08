// This removes the errors from the fields which are empty (a client request).
//
// Some testing users have complained that the error on an empty field is
// confusing them filling out the forms and putting focus to a field and then
// escaping the field. They would only expect to see the error if there is some
// error with the input they give. They know the required fields are marked
// with the asterisk.
//
// Errors on the empty fields are Foundation Abide plugin's intended
// functionality as seen here:
// https://github.com/zurb/foundation-rails/blob/32b34443b88b2e7efd5b31df507f0722317704e1/vendor/assets/js/plugins/foundation.abide.js#L249
//
// Possibly it could be suggested for Foundation to make the required
// validation optional for empty fields.
(($) => {
  const formSubmitErrors = ($self) => {
    $self.on('forminvalid.zf.abide', () => {
      $self.data('submit-occurred', true);

      $('input[required], textarea[required]', $self).each(function() {
        $self.foundation('validateInput', $(this));
      });
    });
  };
  const formElementRemoveEmptyErrors = ($self) => {
    $self.on('invalid.zf.abide.remove-empty-errors', () => {
      const $form = $self.parents('form');
      if ($form.data('submit-occurred')) {
        return;
      }

      if ($self.val().length === 0) {
        var $label = $self.parents('label');
        var $formError = $('.form-error', $label);

        $self.removeClass('is-invalid-input').removeAttr('data-invalid');
        $label.removeClass('is-invalid-label');
        $formError.removeClass('is-visible');
      }
    });
  };

  $(() => {
    $('form').each((i, el) => {
      formSubmitErrors($(el));
    });
    $('input[required], textarea[required]').each((i, el) => {
      const $el = $(el);

      // Only apply in case server validation has not already happened
      if (!$el.is('.is-invalid-input')) {
        formElementRemoveEmptyErrors($el);
      }
    });
  });
})(jQuery);
