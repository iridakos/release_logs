jQuery(document).ready(function () {
    var $container = $('#release_log_entries_container'),
        currentIndex = $container.find('.release-log-entry-row').length,
        autocompleteUrl = $container.data('autocomplete-url');

    var removeLogEntry = function (event) {
        event.preventDefault();

        var $element = $(this);
        var index = $element.data('index'),
            error_row_id = $element.data('error-row-id'),
            $destroyElement = $('#new_release_log_entry_destroy_' + index),
            $idElement = $('#new_release_log_entry_id_' + index);

        if ($idElement.val()) {
            $destroyElement.removeAttr('disabled');
            $destroyElement.closest('.release-log-entry-row').hide();
        } else {
            var $row = $('#release_log_row_' + index);
            $row.remove();
        }

        if (error_row_id) {
            $(error_row_id).remove();
        }
    };

    var fixInclusion = function () {
        var $checkBox = $(this),
            $proxy = $checkBox.closest('.release-log-entry-field-container').find('.inclusion-proxy');

        if ($checkBox.is(':checked')) {
            $proxy.attr('disabled', 'disabled');
        } else {
            $proxy.removeAttr('disabled');
        }
    };

    $('#add-new-release-log').on('click', function (event) {
        event.preventDefault();

        var $template = $('#release_log_row_template'),
            counter = currentIndex++;

        var content = $template.clone();

        content.attr('id', 'release_log_row_' + counter);
        content.find('.remove-release-log-entry').attr('data-index', counter);
        content.find('label.issue-label').attr('for', 'new_release_log_entry_issue_id_' + counter);
        content.find('.release-log-autocomplete').attr('id', 'new_release_log_entry_issue_id_' + counter).data('index', counter);
        content.find('label.note-label').attr('for', 'new_release_log_entry_note_' + counter);
        content.find('.wiki-edit').attr('id', 'new_release_log_entry_note_' + counter);
        content.find('label.include-label').attr('for', 'new_release_log_entry_include_' + counter);
        content.find('.include-in-notification').attr('id', 'new_release_log_entry_include_' + counter);
        content.find('label.category-label').attr('for', 'new_release_log_entry_category_' + counter);
        content.find('.entry-category').attr('id', 'new_release_log_entry_category_' + counter);

        $('#release_log_entries_container').append(content);

        content.find('input,textarea').not('.inclusion-proxy').removeAttr('disabled');
        content.find('a.remove-release-log-entry').on('click', removeLogEntry);

        content.find('.include-in-notification').on('change', fixInclusion);

        observeAutocompleteField('new_release_log_entry_issue_id_' + counter,
            autocompleteUrl,
            {
                select: function (event, object) {
                    var $noteElement = $('#new_release_log_entry_note_' + counter);
                    $noteElement.val(object.item.label + '\n\n' + $noteElement.val());
                }
            }
        );

        var wikiToolbar = new jsToolBar(document.getElementById('new_release_log_entry_note_' + counter));
        wikiToolbar.draw();

        $('#no-release-log-entries').hide();
    });

    $('.remove-release-log-entry').on('click', removeLogEntry);

    $.each($('.release-log-autocomplete'), function (i, element) {
        var $element = $(element);
        observeAutocompleteField($element.attr('id'),
            autocompleteUrl,
            {
                select: function (event, object) {
                    var $noteElement = $('#new_release_log_entry_note_' + $element.data('index'));
                    $noteElement.val(object.item.label + '\n\n' + $noteElement.val());
                }
            }
        );
    });

    $('.release-action-link').on('click', function (event) {
        event.preventDefault();
        var $element = $(this),
            target = $element.data('target');

        if (target == 'rollback') {
            $('.cancellation_fields').find('input, textarea').attr('disabled', 'disabled').end().hide();
            $('.rollback_fields').find('input, textarea').removeAttr('disabled').end().show();
        } else {
            $('.rollback_fields').find('input, textarea').attr('disabled', 'disabled').end().hide();
            $('.cancellation_fields').find('input, textarea').removeAttr('disabled').end().show();
        }

        $('.release-log-action-container').show();
    });

    $('a.cancel-release-log-action').on('click', function (event) {
        event.preventDefault();
        $('.release-log-action-container').hide();
        return false;
    });

    $('.preview-release-log').on('click', function (event) {
        event.preventDefault();

        var $element = $(this);
        var $form = $('#' + $element.data('form-id'));

        $.ajax({
            method: $element.data('action-method') || 'POST',
            type: $element.data('action-method') || 'POST',
            url: $element.data('preview-url'),
            data: $form.serialize(),
            success: function (data) {
                var $container = $('#release_preview_log_container');

                $container.find('#preview_content').html(data);
                $container.show();
            }
        });
    });

    $('.include-in-notification').on('change', fixInclusion);

    $('a.release-log-close-preview').on('click', function (event) {
        event.preventDefault();

        var $container = $('#release_preview_log_container');
        $container.find('.preview-content').html('');
        $container.hide();
    });
});
