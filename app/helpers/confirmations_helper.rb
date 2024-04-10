module ConfirmationsHelper
  # for enum
  def confirmation_question_radio_buttons(form, name, count: nil, excludes: [],
    action: nil, **opts)
    pluralized_name = name.to_s.pluralize.intern
    list = t_enums(pluralized_name, Confirmation).except(*excludes).to_a
    form.collection_radio_buttons(name, list, :first, :second,
      label: {text: confirmation_question_label(name, count: count)},
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      data: {
        node_confirmation_target: name.to_s.camelize(:lower),
        action: action && "node-confirmation##{action}",
      },
      **opts)
  end

  # for bitwise
  def confirmation_question_check_boxes(form, name, count: nil, excludes: [],
    action: nil, **opts)
    pluralized_name = name.to_s.pluralize.intern
    list = t_bitwises(pluralized_name, Confirmation).except(*excludes).to_a
    form.collection_check_boxes(pluralized_name, list, :first, :second,
      label: {text: confirmation_question_label(name, count: count)},
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      data: {
        node_confirmation_target: name.to_s.camelize(:lower),
        action: action && "node-confirmation##{action}",
      },
      **opts)
  end

  def confirmation_question_group(form, name, count: nil, required: false,
    **opts, &block)
    label_class =
      if required
        "form-label required"
      else
        "form-label"
      end
    form.form_group(name,
      label: {
        text: confirmation_question_label(name, count: count),
        class: label_class,
      },
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      **opts, &block)
  end

  def confirmation_question_label(name, count: nil)
    if count
      safe_join([
        tag.strong(t("messages.question_with_number", count: count)),
        " ",
        t(name, scope: "messages.node_confirm_questions"),
      ])
    else
      safe_join([
        tag.strong(t("messages.question")),
        " ",
        t(name, scope: "messages.node_confirm_questions"),
      ])
    end
  end
end
